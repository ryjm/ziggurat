/+  smart=zig-sys-smart
|%
+$  signature   [p=@ux q=ship r=life]
::
+$  book  (map [town=@ud lord=id:smart salt=@] [=token-type =grain:smart])
+$  transaction-store  (map pub=@ux [sent=(map @ux [=egg:smart args=supported-args]) received=(map @ux =egg:smart)])
+$  metadata-store  (map @ asset-metadata)  ::  metadata is keyed by SALT of grains associated.
::
+$  token-type  @tas
::
+$  wallet-update
  $%  [%new-book tokens=(map pub=id:smart =book)]
      [%tx-status hash=@ux =egg:smart args=(unit supported-args)]
      ::  TX status codes:
      ::  100: transaction submitted from wallet to sequencer
      ::  101: transaction received by sequencer
      ::  103: failure: transaction rejected by sequencer
      ::  105: alert: transaction sent *to our address*
      ::  0-7: see smart.hoon -- contract execution error codes
  ==
::
+$  wallet-poke
  $%  [%populate seed=@ux]  :: populate wallet with fake data, for testing
      [%fetch-metadata id=@ux type=token-type]
      [%import mnemonic=tape password=tape]
      [%create password=tape]
      ::  TODO add poke to spawn new keypair from seed
      [%delete pubkey=@ux]  ::  only removes tracking, doesn't lose anything
      [%set-node town=@ud =ship]
      [%set-indexer =ship]
      [%set-nonce address=@ux town=@ud new=@ud]  ::  for testing
      ::
      $:  %submit-custom
          ::  essentially a full egg
          from=id:smart
          to=id:smart
          town=@ud
          gas=[rate=@ud bud=@ud]
          args=@t  ::  literally ream-ed to form args
          my-grains=(set id:smart)
          cont-grains=(set id:smart)
      ==
      ::
      $:  %submit
          from=id:smart
          to=id:smart
          town=@ud
          gas=[rate=@ud bud=@ud]
          args=supported-args
      ==
  ==
::
+$  supported-args
  $%  [%give salt=@ to=id:smart amount=@ud]
      [%give-nft salt=@ to=id:smart item-id=@ud]
      ::  only used on backend for validators/sequencers
      [%become-validator =signature]
      [%stop-validating =signature]
      [%init =signature town=@ud]
      [%join =signature town=@ud]
      [%exit =signature town=@ud]
      [%custom args=@t]
  ==
::
+$  asset-metadata
  $%  [%token token-metadata]
      [%nft nft-metadata]
  ==
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
+$  nft-metadata
  $:  name=@t
      symbol=@t
      item-mold=mold
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
::
+$  nft-account
  $:  metadata=id:smart
      items=(map @ud item)
      allowances=(set [id:smart @ud])
      full-allowances=(set id:smart)
  ==
+$  item
  $:  id=@ud
      data=*
      desc=tape
      uri=tape
      transferrable=?
  ==
--