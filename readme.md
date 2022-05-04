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
:ziggurat &zig-chain-poke [%set-addr 0x3.e87b.0cbb.431d.0e8a.2ee2.ac42.d9da.cab8.063d.6bb6.2ff9.b2aa.e1b9.0f56.9c3f.3423]

0xbeef  0x3.e87b.0cbb.431d.0e8a.2ee2.ac42.d9da.cab8.063d.6bb6.2ff9.b2aa.e1b9.0f56.9c3f.3423
0xdead  0x2.eaea.cffd.2bbe.e0c0.02dd.b5f8.dd04.e63f.297f.14cf.d809.b616.2137.126c.da9e.8d3d
0xcafe  0x2.4a1c.4643.b429.dc12.6f3b.03f3.f519.aebb.5439.08d3.e0bf.8fc3.cb52.b92c.9802.636e
```
*This is one of 3 addresses with zigs already added, and corresponds to the seed `0xbeef`. to test with more, find matching pubkey in wallet*

3. To start the indexer/block explorer backend, use:
```
:uqbar-indexer &set-chain-source [our %ziggurat]
```
where the argument `[our %ziggurat]` is a dock pointing to the ship running the `%ziggurat` agent to receive block updates from.

4. Start up a new main chain:
```
:ziggurat|start-testnet now
```
(to add other ships, follow above instructions with 2nd and 3rd seed/pubkey combos, but use poke `:ziggurat &zig-chain-poke [%start %validator ~ validators=(silt ~[~zod]) [~ ~]]`) here, where `~[~zod]` is some set of ships validating (you only need one that's not you)

6. Start up a town that has the token contract deployed. Wait until the wallet sees an update from the indexer to do this. There will be a printout that says `"wallet: fetching metadata..."`
```
:sequencer|init 1
```
(1 here is the town-id)

# To use the wallet

1. Scry for a JSON dict of accounts, keyed by address, containing private key, nickname, and nonces:
`.^(@ux %gx /=wallet=/accounts/noun)`

2. Scry for a JSON dict of known assets (rice), keyed by address, then by rice address:
`.^(json %gx /=wallet=/book/json)`

3. Scry for JSON dict of token metadata we're aware of:
`.^(json %gx /=wallet=/token-metadata/json)`

4. Scry for seed phrase and password (todo separate these):
`.^(json %gx /=wallet=/seed/json)`


### Wallet pokes available:
(only those with JSON support shown)

```
{import-seed: {mnemonic: "12-24 word phrase", password: "password", nick: "nickname for the first address in this wallet"}}

{generate-hot-wallet: {password: "password", nick: "nickname"}}

# leave hdpath empty ("") to let wallet auto-increment from 0 on main path
{derive-new-address: {hdpath: "m/44'/60'/0'/0/0", nick: "nickname"}}

# use this to save a hardware wallet account
{add-tracked-address: {address: "0x1234.5678" nick: "nickname"}}

{delete-address: {address: "0x1234.5678"}}

{edit-nickname: {address: "0x1234.5678", nick: "nickname"}}

{set-node: {town: 1, ship: "~zod"}}  # set the sequencer to send txs to, per town

{set-indexer: {ship: "~zod"}}

#  TODO here:
#  add poke to submit signed transaction from HW wallet
#  will need a new flow where frontend builds tx, pokes to receive signable package,
#  then signs with HW and pokes again with signature.

{submit-custom: {from: "0x1234", to: "0x5678", town: 1, gas: {rate: 1, bud: 10000}, args: "[%give ... .. (this is HOON)]", my-grains: {"0x1111", "0x2222"}, cont-grains: {"0x3333", "0x4444"}}}

# for TOKEN and NFT transactions
# 'from' is our address
# 'to' is the address of the smart contract
# 'town' is the number ID of the town on which the contract&rice are deployed
# 'gas' rate and bud are amounts of zigs to spend on tx
# 'args' will eventually cover many types of transactions,
# currently only concerned with token sends following this format,
# where 'token' is address of token metadata rice, 'to' is address receiving tokens.
{submit:
  {from: "0x3.e87b.0cbb.431d.0e8a.2ee2.ac42.d9da.cab8.063d.6bb6.2ff9.b2aa.e1b9.0f56.9c3f.3423",
   to: "0x74.6361.7274.6e6f.632d.7367.697a",
   town: 1,
   gas: {rate: 1, bud: 10000},
   args: {give: {salt: "1.936.157.050", to: "0x2.eaea.cffd.2bbe.e0c0.02dd.b5f8.dd04.e63f.297f.14cf.d809.b616.2137.126c.da9e.8d3d", amount: 777}}
   }
}
```

(example pokes that will work upon chain initialization in dojo):
```
#  ZIGS
:wallet &zig-wallet-poke [%submit 0x3.e87b.0cbb.431d.0e8a.2ee2.ac42.d9da.cab8.063d.6bb6.2ff9.b2aa.e1b9.0f56.9c3f.3423 0x74.6361.7274.6e6f.632d.7367.697a 1 [1 10.000] [%give 1.936.157.050 0x2.eaea.cffd.2bbe.e0c0.02dd.b5f8.dd04.e63f.297f.14cf.d809.b616.2137.126c.da9e.8d3d 777]]

#  NFT
:wallet &zig-wallet-poke [%submit 0x3.e87b.0cbb.431d.0e8a.2ee2.ac42.d9da.cab8.063d.6bb6.2ff9.b2aa.e1b9.0f56.9c3f.3423 0xcafe.babe 1 [1 10.000] [%give 32.770.263.103.071.854 0x2.eaea.cffd.2bbe.e0c0.02dd.b5f8.dd04.e63f.297f.14cf.d809.b616.2137.126c.da9e.8d3d 1]]
```