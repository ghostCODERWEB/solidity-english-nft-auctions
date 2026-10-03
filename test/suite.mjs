export async function suite(h) {
  const token = await h.token();
  const nft = await h.nft();
  const c = await h.deploy("NFTAuctions", [token.target, h.addresses[0]]);
  await h.tx(nft.approve(c.target, 1));
  await h.tx(c.create(nft.target, 1, 100, 20, 5));
  for (const i of [1, 2]) {
    await h.tx(token.mint(h.addresses[i], 1000));
    await h.tx(token.connect(h.signers[i]).approve(c.target, 1000));
  }
  await h.test("below reserve rejected", () =>
    h.revert(() => c.connect(h.signers[1]).bid(1, 99)),
  );
  await h.test("bid is escrowed", async () => {
    await h.tx(c.connect(h.signers[1]).bid(1, 200));
    h.eq(await c.liability(), 200n);
  });
  await h.test("outbid user receives pull credit", async () => {
    await h.tx(c.connect(h.signers[2]).bid(1, 300));
    h.eq(await c.credits(h.addresses[1]), 200n);
    await h.tx(c.connect(h.signers[1]).withdraw());
    h.eq(await c.liability(), 300n);
  });
  await h.test("early settlement rejected", () => h.revert(() => c.settle(1)));
  await h.test("winner receives NFT at settlement", async () => {
    await h.mine(25);
    await h.tx(c.settle(1));
    h.eq(await nft.ownerOf(1), h.addresses[2]);
    h.eq(await c.credits(h.addresses[0]), 300n);
  });
  await h.test("seller withdraw clears liabilities", async () => {
    await h.tx(c.withdraw());
    h.eq(await c.liability(), 0n);
    await h.revert(() => c.settle(1));
  });
}
