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

*TODO: make this work again with new wallet*

### To use the wallet

1. Without starting a blockchain, you can populate the wallet with fake data:
`:wallet &zig-wallet-poke [%populate ~]`

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

{import: {mnemonic="12-24 word phrase", password="password"}}

{create: true}

{delete: {pubkey="0x1234.5678"}}  # public key to stop tracking in wallet

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
  {from: "0x1111",
   to: "0x2222",
   town: 1,
   gas: {rate: 1, bud: 10000},
   args: {give: {token: 0x3333, to: 0x4444, amount: 10}}
   }
}
```
