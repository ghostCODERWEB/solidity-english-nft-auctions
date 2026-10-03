# ABI reference

Generated from the successfully compiled primary contract. Includes inherited methods. Authorization and economic semantics are documented in the source.

| Signature | Type | Mutability | Returns |
|---|---|---|---|
| `constructor(address asset,address admin)` | constructor | nonpayable |  |
| `EnforcedPause()` | error |  |  |
| `ExpectedPause()` | error |  |  |
| `OwnableInvalidOwner(address owner)` | error |  |  |
| `OwnableUnauthorizedAccount(address account)` | error |  |  |
| `ReentrancyGuardReentrantCall()` | error |  |  |
| `SafeERC20FailedOperation(address token)` | error |  |  |
| `Bid(uint256 id,address bidder,uint256 amount,uint64 end)` | event |  |  |
| `Created(uint256 id,address seller,uint64 end)` | event |  |  |
| `OwnershipTransferStarted(address previousOwner,address newOwner)` | event |  |  |
| `OwnershipTransferred(address previousOwner,address newOwner)` | event |  |  |
| `Paused(address account)` | event |  |  |
| `Settled(uint256 id,address winner,uint256 amount)` | event |  |  |
| `Unpaused(address account)` | event |  |  |
| `acceptOwnership()` | function | nonpayable |  |
| `auctions(uint256 )` | function | view | address seller, address collection, uint256 tokenId, uint256 reserve, uint256 bid, address bidder, uint64 end, uint64 extension, bool settled |
| `bid(uint256 id,uint256 amount)` | function | nonpayable |  |
| `create(address collection,uint256 tokenId,uint256 reserve,uint64 duration,uint64 extension)` | function | nonpayable | uint256 id |
| `credits(address )` | function | view | uint256  |
| `liability()` | function | view | uint256  |
| `nextId()` | function | view | uint256  |
| `onERC721Received(address ,address ,uint256 ,bytes )` | function | nonpayable | bytes4  |
| `owner()` | function | view | address  |
| `paused()` | function | view | bool  |
| `pendingOwner()` | function | view | address  |
| `renounceOwnership()` | function | nonpayable |  |
| `setPaused(bool value)` | function | nonpayable |  |
| `settle(uint256 id)` | function | nonpayable |  |
| `token()` | function | view | address  |
| `transferOwnership(address newOwner)` | function | nonpayable |  |
| `withdraw()` | function | nonpayable |  |
