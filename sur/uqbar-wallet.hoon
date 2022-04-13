/+  smart=zig-sys-smart
|%
+$  signature   [p=@ux q=ship r=life]
::
+$  book  (map [town=@ud lord=id:smart salt=@] grain:smart)
::
+$  wallet-update
  $%  [%new-book tokens=(map pub=id:smart =book)]
      [%tx-status status=tape hash=@ux]  ::  "submitted", "received", "rejected", "processed"
  ==
::
+$  wallet-poke
  $%  [%populate seed=@ux]  :: populate wallet with fake data, for testing
      [%fetch-our-rice pubkey=@ux]
      [%import mnemonic=tape password=tape]
      [%create ~]
      ::  TODO add poke to spawn new keypair from seed
      [%delete pubkey=@ux]  ::  only removes tracking, doesn't lose anything
      [%set-node town=@ud =ship]
      [%set-indexer =ship]
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