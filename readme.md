# Development Instructions

1. Start by cloning the urbit/urbit repository from github.
`git clone git@github.com:urbit/urbit.git`

2. Then, change directory to urbit/pkg.
`cd urbit/pkg`

3. Then, add this repository as a submodule. This is necessary to resolve symbolic
links to other desks, such as base-dev and garden-dev.
`git submodule add git@github.com:uqbar-dao/ziggurat.git ziggurat`

4. To boot your development Urbit, run the following command:
`urbit -F zod`

5. To create a `%zig` desk, run
`|merge %zig our %base`

6. To mount the `%zig` desk to the filesystem, run
`|mount %zig`.

7. Next, remove all the files from the zig directory.
`rm -rf zod/zig/*`

8. Now, copy all the files from our ziggurat repository into the `%zig` desk.
`cp -RL urbit/pkg/ziggurat/* zod/zig/`

9. Commit those files into your Urbit.
`|commit %zig`

10. Now, install the desk in your Urbit, which will run the agents.
`|install our %zig`

### To initialize a blockchain:

1. Start by populating the wallet with the correct data (need to do this first, but with block explorer we can make wallet find this itself):
```
:wallet &zig-wallet-poke [%populate 0xbeef]
```
*for testing: use `0xbeef` for ~zod, `0xdead` for next ship, `0xcafe` for 3rd*

2. Give your validator agent a pubkey to match the data in the wallet:
```
:ziggurat &zig-chain-poke [%set-addr 0x2.e3c1.d19b.fd3e.43aa.319c.b816.1c89.37fb.b246.3a65.f84d.8562.155d.6181.8113.c85b]
```
*This is one of 3 addresses with zigs already added, and corresponds to the seed `0xbeef`. to test with more, find matching pubkey in wallet*

3. To start the indexer/block explorer backend, use:
```
:uqbar-indexer &set-chain-source [our %ziggurat]
```
where the argument `[our %ziggurat]` is a dock pointing to the ship running the `%ziggurat` agent to receive block updates from.

4. Set the wallet to receive state updates from your ship's indexer:
```
:wallet &zig-wallet-poke [%set-indexer our]
```

5. Start up a new main chain:
```
:ziggurat|start-testnet now
```
(to add other ships, follow above instructions with 2nd and 3rd seed/pubkey combos, but use poke `:ziggurat &zig-chain-poke [%start %validator ~ validators=(silt ~[~zod ~nec]) [~ ~]]`) here, where `~[~zod ~nec]` is the current set of validators including the one being added)

6. To make the wallet aware of the assets spawned for you in the town and main chain you just launched, it's necessary to use a scry. Wait until the indexer has a chance to observe a new block, then use this poke:
```
:wallet &zig-wallet-poke [%fetch-our-rice 0x2.e3c1.d19b.fd3e.43aa.319c.b816.1c89.37fb.b246.3a65.f84d.8562.155d.6181.8113.c85b]
```
(the pubkey here should match the one you used in step 2. The ship running the wallet must also be running a block explorer.)

7. Start up a town that has the token contract deployed. You have to do step 6 first, otherwise the sequencer agent won't have the data from the main chain it needs to set up a transaction.
```
:sequencer|init 1
```
(1 here is the town-id)

Make sure to perform step (6) again if you need updated chain state in your wallet.

### To use the wallet

2. Scry for a JSON dict of accounts, keyed by address, containing seed and nonces:
`.^(@ux %gx /=wallet=/accounts/noun)`

3. Scry for a JSON dict of known assets (rice), keyed by address, then by rice address:
`.^(json %gx /=wallet=/book/json)`

4. Scry for JSON dict of token metadata we're aware of:
`.^(json %gx /=wallet=/token-metadata/json)`

4. Wallet pokes available:
(only those with JSON support shown)
```
{populate: true}

{import: {mnemonic: "12-24 word phrase", password: "password"}}

{create: true}

{delete: {pubkey: "0x1234.5678"}}  # public key to stop tracking in wallet

{set-node: {town: 1, ship: "~zod"}}  # set the sequencer to send txs to, per town

# currently only supporting token sends
# 'from' is our pubkey
# 'to' is the address of the smart contract
# 'town' is the number ID of the town on which the contract&rice are deployed
# 'gas' rate and bud are amounts of zigs to spend on tx
# 'args' will eventually cover many types of transactions,
# currently only concerned with token sends following this format,
# where 'token' is address of token metadata rice, 'to' is pubkey receiving tokens.
{submit:
  {from: "0x2.e3c1.d19b.fd3e.43aa.319c.b816.1c89.37fb.b246.3a65.f84d.8562.155d.6181.8113.c85b",
   to: "0x74.6361.7274.6e6f.632d.7367.697a",
   town: 1,
   gas: {rate: 1, bud: 10000},
   args: {give: {token: "0x61.7461.6461.7465.6d2d.7367.697a", to: "0x3.4cdd.5f53.b551.e62f.2238.6eb3.8abd.3e91.a546.fad3.2940.ff2d.c316.50dd.8d38.e609", amount: 777}}
   }
}
```

(an example poke that will work upon chain initialization in dojo):
```
:wallet &zig-wallet-poke [%submit 0x2.e3c1.d19b.fd3e.43aa.319c.b816.1c89.37fb.b246.3a65.f84d.8562.155d.6181.8113.c85b 0x74.6361.7274.6e6f.632d.7367.697a 1 [1 10.000] [%give 0x61.7461.6461.7465.6d2d.7367.697a 0x3.4cdd.5f53.b551.e62f.2238.6eb3.8abd.3e91.a546.fad3.2940.ff2d.c316.50dd.8d38.e609 777]]
```
If this fails with an error "wallet can't find our zigs account for that town!", use the fetch-rice poke then try again.