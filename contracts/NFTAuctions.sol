// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {SuiteBase, AssetFlow} from "./SuiteBase.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title English NFT auction escrow
/// @notice ERC721 English auctions with token bids, anti-sniping extensions, reserve prices and pull refunds.
/// @dev Reference implementation; independent audit required before production.

contract NFTAuctions is SuiteBase, ERC721Holder {
    using SafeERC20 for IERC20;
    IERC20 public immutable token;
    uint256 public nextId;
    uint256 public liability;
    struct Auction {
        address seller;
        address collection;
        uint256 tokenId;
        uint256 reserve;
        uint256 bid;
        address bidder;
        uint64 end;
        uint64 extension;
        bool settled;
    }
    mapping(uint256 => Auction) public auctions;
    mapping(address => uint256) public credits;
    event Created(uint256 indexed id, address indexed seller, uint64 end);
    event Bid(
        uint256 indexed id,
        address indexed bidder,
        uint256 amount,
        uint64 end
    );
    event Settled(uint256 indexed id, address winner, uint256 amount);
    constructor(address asset, address admin) SuiteBase(admin) {
        require(asset.code.length > 0, "asset");
        token = IERC20(asset);
    }
    function create(
        address collection,
        uint256 tokenId,
        uint256 reserve,
        uint64 duration,
        uint64 extension
    ) external nonReentrant whenNotPaused returns (uint256 id) {
        require(
            collection.code.length > 0 &&
                reserve > 0 &&
                duration > 0 &&
                extension <= duration &&
                IERC721(collection).ownerOf(tokenId) == msg.sender,
            "auction"
        );
        id = ++nextId;
        auctions[id] = Auction(
            msg.sender,
            collection,
            tokenId,
            reserve,
            0,
            address(0),
            uint64(block.timestamp) + duration,
            extension,
            false
        );
        IERC721(collection).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );
        emit Created(id, msg.sender, uint64(block.timestamp) + duration);
    }
    function bid(
        uint256 id,
        uint256 amount
    ) external nonReentrant whenNotPaused {
        Auction storage a = auctions[id];
        require(
            a.seller != address(0) &&
                !a.settled &&
                block.timestamp < a.end &&
                msg.sender != a.seller &&
                amount >= a.reserve &&
                amount > a.bid,
            "bid"
        );
        AssetFlow.pullExact(token, msg.sender, amount);
        liability += amount;
        if (a.bid > 0) credits[a.bidder] += a.bid;
        a.bid = amount;
        a.bidder = msg.sender;
        if (a.end - block.timestamp < a.extension)
            a.end = uint64(block.timestamp) + a.extension;
        emit Bid(id, msg.sender, amount, a.end);
    }
    function settle(uint256 id) external nonReentrant {
        Auction storage a = auctions[id];
        require(
            a.seller != address(0) && !a.settled && block.timestamp >= a.end,
            "settle"
        );
        a.settled = true;
        address winner = a.bidder == address(0) ? a.seller : a.bidder;
        if (a.bid > 0) credits[a.seller] += a.bid;
        IERC721(a.collection).safeTransferFrom(
            address(this),
            winner,
            a.tokenId
        );
        emit Settled(id, winner, a.bid);
    }
    function withdraw() external nonReentrant {
        uint256 amount = credits[msg.sender];
        require(amount > 0, "credit");
        credits[msg.sender] = 0;
        liability -= amount;
        token.safeTransfer(msg.sender, amount);
    }
}
