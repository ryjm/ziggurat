/+  smart=zig-sys-smart
|%
++  epoch-interval  ~s30
++  relay-town-id   0
::
+$  epoch   [num=@ud =start=time order=(list ship) =slots]
::
+$  epochs  ((mop @ud epoch) gth)
++  poc     ((on @ud epoch) gth)
::
+$  block         (pair signature chunks)
+$  block-header  [num=@ud prev-header-hash=@uvH data-hash=@uvH]
+$  slot          (pair block-header (unit block))
::
+$  slots  ((mop @ud slot) gth)
++  sot    ((on @ud slot) gth)
::
+$  signature   [p=@ux q=ship r=life]
::
+$  chunks  (map town-id=@ud =chunk)
+$  chunk   [(list [@ux egg:smart]) town:smart]
::
+$  basket  (set egg:smart)  ::  mempool
::
::  runs a town
::
+$  hall  [council=(map ship [id:smart signature]) order=(list ship)]
::
+$  update
  $%  [%epochs-catchup =epochs]
      [%blocks-catchup epoch-num=@ud =slots]
      [%new-block epoch-num=@ud header=block-header =block]
      ::  todo: add data availability data
      ::
      [%saw-block epoch-num=@ud header=block-header]
  ==
+$  sequencer-update
  $%  [%next-producer =ship]
      [%new-hall council=(map ship [id:smart signature])]
  ==
+$  chunk-update  [%new-chunk =town:smart]
::
+$  chain-poke
  $%  [%set-addr =id:smart]
      [%start mode=?(%fisherman %validator) history=epochs validators=(set ship) starting-state=town:smart]
      [%stop ~]
      [%new-epoch ~]
      [%receive-chunk town-id=@ud =chunk]
  ==
::
+$  weave-poke
  $%  [%forward eggs=(set egg:smart)]
      [%receive eggs=(set egg:smart)]
  ==
::
+$  hall-poke
  $%  ::  will remove starting-state for persistent testnet
      [%init town-id=@ud starting-state=(unit town:smart) gas=[rate=@ud bud=@ud]]
      [%join town-id=@ud gas=[rate=@ud bud=@ud]]
      [%exit gas=[rate=@ud bud=@ud]]
      [%clear-state ~]
  ==
::
::  uqbar wallet types
::  TODO move into its own file as this grows
::
+$  book  (map [town=@ud lord=id:smart salt=@] grain:smart)
::
+$  wallet-poke
  $%  [%populate ~]  :: populate wallet with fake data, for testing
      [%import mnemonic=tape password=tape]
      [%create ~]
      ::  TODO add poke to spawn new keypair from seed
      [%delete pubkey=@ux]  ::  only removes tracking, doesn't lose anything
      [%set-node town=@ud =ship]
      [%set-nonce address=@ux town=@ud new=@ud]  ::  for testing
      $:  %submit
          from=id:smart
          to=id:smart  town=@ud
          gas=[rate=@ud bud=@ud]
          args=supported-args
      ==
  ==
::
+$  supported-args
  $%  [%give token=id:smart to=id:smart amount=@ud]
      ::  only used on backend for validators/sequencers
      [%become-validator =signature]
      [%stop-validating =signature]
      [%init =signature town=@ud]
      [%join =signature town=@ud]
      [%exit =signature town=@ud]
  ==
::
+$  token-metadata
  $:  name=@t
      symbol=@t
      decimals=@ud
      supply=@ud
      cap=(unit @ud)
      mintable=?
      minters=(set id:smart)
      deployer=id:smart
      salt=@
  ==
::
+$  token-account
  $:  balance=@ud
      allowances=(map sender=id:smart @ud)
      metadata=id:smart
  ==
--
