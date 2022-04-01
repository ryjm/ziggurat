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
$%  [%populate ~]  :: populate wallet with fake data, for testing
    [%import seed=@]
    [%create ~]
    [%delete pubkey=@ux]
    [%set-node town=@ud =ship]
    $:  %submit
        from=id:smart
        to=id:smart
        town=@ud
        gas=[rate=@ud bud=@ud]
        args=supported-args  ::  see below
    ==
  ==
::
+$  supported-args  ::  *currently only handling token sends*
  $%  [%give token=id:smart to=id:smart amount=@ud]
  ==
```
