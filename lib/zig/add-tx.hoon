/-  *tx
=,  tx
|%
::  something hardcoded
++  zigs-id  `@ux`0x0
::  $process-tx: return modified state that includes 
::  results of this transaction, if valid.
++  process-tx
  |=  [=tx =state]
  ^+  state
  ::  tx from unrecognized account is rejected by got
  =/  account  (~(got by accts.state) account-id.from.tx)
  ?:  ?=([%blank-account *] account)
    !!
  ?>  =((succ nonce.account) nonce.from.tx)
  =/  fee
    %+  mul
      (compute-gas tx)
    ::  fixed feerate or none for creates/updates?
    ?+  -.tx  0  
        ?(%send %mint)
      feerate.from.tx
    ==
  =/  zigs-in-account
    ?-  -.account
        %minter-account
      ::  no zigs held in here, can't pay any fees?
      !!
        %asset-account
      =/  zigs  (~(got by assets.account) zigs-id)
      ?+  -.zigs  !!
          %fung
        amount.zigs
      ==
    ==
  ?>  (gth zigs-in-account fee)
  ::  TODO check validity of signatures
  ::  branch on type of transaction and modify
  ::  output state
  ?-  -.tx
      %send
    =/  to
      ::  TODO should change to allow to send to 
      ::  not-yet-existent account
      (~(got by accts.state) to.tx)
    (process-send state tx account to fee)
  ::
      %mint
    state
  ::
      %lone-mint
    state
  ::
      %create-multisig
    state
  ::
      %update-multisig
    state
  ::
      %create-minter
    state
      %update-minter
    state
  ::  TODO for all: increment nonce of tx sender acct
  ==
::
++  process-send
  |=  [=state =tx =account to=account fee=zigs]
  ^+  state
  ?.  ?=([%send *] tx)
    !!
  ?.  ?=([%asset-account *] account)
    ::  no support for minter account sending assets
    !!
  ?.  ?=([%asset-account *] to)
    ::  no support for minter account receiving assets
    !!
  ::  keeping a map to check for dupes
  =/  seen  `(map account-id ?)`~
  |-  ^+  state
  ?~  assets.tx
    state
  =/  to-send  i.assets.tx
  ~&  >  "working on asset: {<to-send>}"
  ::  check if asset has been seen
  ?^  (~(get by seen) minter.to-send)
    !!  ::  can't send 1 asset twice in tx
  ::  check if enough of asset to send is in wallet
  ::  if so, modify state with that part of the tx
  =/  mine
    (~(got by assets.account) minter.to-send)
  ::  assert that send is valid for this asset
  ?>  ?-  -.to-send
          %nft
        ?:  ?=([%nft *] mine)
          ?&  =(minter.to-send minter.mine)
              =(hash.to-send hash.mine)
              can-xfer.mine
          ==
        !!
          %fung
        ::  if sending zigs, check that fee is covered
        ?:  ?=([%fung *] mine)
          ?:  =(minter.to-send zigs-id)
            ?&  =(minter.to-send minter.mine)
                (gth amount.mine (add fee amount.to-send))
            ==
          ?&  =(minter.to-send minter.mine)
              (gth amount.mine amount.to-send)
          ==
        !!
      ==
  ~&  >  "tx of {<to-send>} approved"
  ::  asset is good to send, modify state
  ::  update sender to have x less of asset
  =.  assets.account
    ?-  -.to-send
        %nft
      (~(del by assets.account) minter.to-send)
        %fung
      %+  ~(jab by assets.account)
        minter.to-send
      |=  =asset
      ?:  ?=([%fung *] asset)
        =.  amount.asset
          (sub amount.asset amount.to-send)
        asset
      !!
    ==
  ~&  >>  "new sender account: {<account>}"
  ::  update receiver to have x more
  =.  assets.to
    ?-  -.to-send
        %nft
      (~(put by assets.to) minter.to-send to-send)
        %fung
      %+  ~(jab by assets.to)
        minter.to-send
      |=  =asset
      ?:  ?=([%fung *] asset)
        =.  amount.asset
          (add amount.asset amount.to-send)
        asset
      !!
    ==
  ~&  >>  "new receiver account: {<to>}"
  ::  update state with 2 modified accounts
  =.  accts.state
    (~(put by accts.state) account-id.from.tx account)
  =.  accts.state
    (~(put by accts.state) to.tx to)  
  =.  seen
    (~(put by seen) minter.to-send %.y)
  $(assets.tx t.assets.tx)
::
++  compute-gas
  |=  [=tx]
  ::  determine how much work this tx requires
  ::  these are all single-action transactions,
  ::  can determine set costs for each type of tx
  7  ::  temporary
--
