/-  *tx
=,  tx
|%
::  something hardcoded
++  zigs-id  `@ux`0x0
::  $process-tx: return modified state that includes 
::  results of this transaction, if valid.
++  process-tx
  |=  [=tx current=state]
  ::  how to access type 'state' and not face named 'state'?
  ::  named state 'current' to do this
  ^-  (unit state)
  ::  tx from unrecognized account is rejected by got
  =/  account  (~(get by accts.current) account-id.from.tx)
  ?~  account
    ~&  >>>  "error: sender account not found in state"
    ~
  =/  account  u.account
  ?:  ?=([%blank-account *] account)
    ~&  >>>  "error: tx submitted from blank account" 
    ~
  ?.  =((succ nonce.account) nonce.from.tx)
    ~&  >>>  "error: incorrect tx nonce"
    ~
  ::  increment nonce of tx sender acct
  =.  nonce.account  (succ nonce.account)
  =.  accts.current  (~(put by accts.current) account-id.from.tx account)
  =/  fee
    %+  mul
      (compute-gas tx)
    ::  need place to take zigs fee from for tx's from minter accts
    ?+  -.tx  0  
        %send
      feerate.from.tx
    ==
  =/  zigs-in-account
    ?-  -.account
        %minter-account
      ::  no zigs held in here, can't pay any fees?
      0
        %asset-account
      =/  zigs  (~(got by assets.account) zigs-id)
      ?+  -.zigs  0
          %fung
        amount.zigs
      ==
    ==
  ?.  (gte zigs-in-account fee)
    ~&  >>>  "error: {<zigs-in-account>} zigs in account, tx fee is {<fee>}"
    ~
  ::  TODO check validity of signatures
  ::  branch on type of transaction and get output state
  =/  result
    ^-  (unit state)
    ?-  -.tx
        %send
      (process-send current tx account fee)
    ::
        %mint
      (process-mint current tx account fee)
    ::
        %lone-mint
      (some current)
    ::
        %create-multisig
      (some current)
    ::
        %update-multisig
      (some current)
    ::
        %create-minter
      (some current)
    ::
        %update-minter
      (some current)
    ==
  result
::
++  process-mint
  |=  [current=state =tx =account fee=zigs]
  ^-  (unit state)
  ?.  ?=([%mint *] tx)
    ~
  ?.  ?=([%minter-account *] account)
    ~&  >>>  "error: %mint tx from non-minter account"
    ~
  ::  loop through assets in to.tx and verify all are legit
  ::  while adding to accounts of receivers
  |-  ^-  (unit state)
  ::  return modified state if finished successfully
  ?~  to.tx
    (some current)
  =/  to-send  +.i.to.tx
  =/  to-whom  -.i.to.tx
  ::  minter must match tx sender
  ?.  =(minter.to-send account-id.from.tx)
    ~&  >>>  "error: tx sender doesn't match minter"
    ~
  =/  amount-after-mint
    %+  add  total.account
    ?-  -.to-send
        %nft
      1
        %fung
      amount.to-send
    ==
  ::  amount of asset to create must not put total above limit
  ?.  (gte max.account amount-after-mint)
    ~&  >>>  "error: mint would create too many assets"
    ~
  ::  mint is approved, give to receiver and modify total
  =.  total.account  amount-after-mint
  ::  TODO if account doesn't exist make a new one
  =/  receiver-account  (~(got by accts.current) to-whom)
  ::  receivers must be asset accounts
  ?.  ?=([%asset-account *] receiver-account)
    ~&  >>>  "error: sending assets to non-asset account"
    ~
  =.  assets.receiver-account
    (insert-asset to-send assets.receiver-account)
  ::  update minter and receiver accounts in state
  =.  accts.current
    (~(put by accts.current) account-id.from.tx account)
  =.  accts.current
    (~(put by accts.current) to-whom receiver-account)  
  $(to.tx t.to.tx)
::
++  process-send
  |=  [current=state =tx =account fee=zigs]
  ::  how do i access type 'state' and not face named 'state'?
  ^-  (unit state)
  ?.  ?=([%send *] tx)
    ~
  ?.  ?=([%asset-account *] account)
    ::  no support for minter account sending assets
    ~&  >>>  "error: %send tx from minter account"
    ~
  ::  TODO if account doesn't exist make a new one
  =/  to
    (~(got by accts.current) to.tx)
  ?.  ?=([%asset-account *] to)
    ::  no support for minter account receiving assets
    ~&  >>>  "error: sending assets to non-asset account"
    ~
  ::  update sender to pay specified fee
  =.  assets.account
    %+  ~(jab by assets.account)
      zigs-id
    |=  z=asset
    ?.  ?=([%fung *] z)
      ::  expected zigs to be fung, real error
      z
    =.  amount.z
      (sub amount.z fee)
    z
  ::  keeping a map to check for dupes
  =/  seen  `(map account-id ?)`~
  |-  ^-  (unit state)
  ::  if finished successfully, return new state
  ?~  assets.tx
    (some current)
  =/  to-send  i.assets.tx
  ::  check if asset has been seen
  ::  can't send 1 asset twice in tx
  ?^  (~(get by seen) minter.to-send)
    ~&  >>>  "error: sending same asset class twice in one tx"
    ~
  ::  check if enough of asset to send is in wallet
  ::  if so, modify state with that part of the tx
  =/  mine
    (~(got by assets.account) minter.to-send)
  ::  assert that send is valid for this asset
  ?.  ?-  -.to-send
          %nft
        ?:  ?=([%nft *] mine)
          ?&  =(minter.to-send minter.mine)
              =(hash.to-send hash.mine)
              can-xfer.mine
          ==
        %.n
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
        %.n
      ==
    ~&  >>>  "error: don't have enough {<to-send>} to send"
    ~
  ::  asset is good to send, modify state
  ::  update sender to have x less of asset
  =.  assets.account
    (remove-asset to-send assets.account)
  ::  update receiver to have x more
  =.  assets.to
    (insert-asset to-send assets.to)
  ::  update state with 2 modified accounts
  =.  accts.current
    (~(put by accts.current) account-id.from.tx account)
  =.  accts.current
    (~(put by accts.current) to.tx to)  
  =.  seen
    (~(put by seen) minter.to-send %.y)
  $(assets.tx t.assets.tx)
::
++  insert-asset
  |=  [to-send=asset assets=(map account-id asset)]
  ^+  assets 
  ::  add to existing assets in wallet
  ?-  -.to-send
      %nft
    ::  using hash here since NFTs in a collection share account-id
    (~(put by assets) hash.to-send to-send)
      %fung
    ?~  (~(get by assets) minter.to-send)
      ::  asset not yet present in wallet, insert
      (~(put by assets) minter.to-send to-send)
    %+  ~(jab by assets)
      minter.to-send
    |=  =asset
    ?.  ?=([%fung *] asset)
      ::  expected a fung, found an nft?
      asset
    =.  amount.asset
      (add amount.asset amount.to-send)
    asset
  ==
::
++  remove-asset
  |=  [to-remove=asset assets=(map account-id asset)]
  ^+  assets
  ?-  -.to-remove
      %nft
    (~(del by assets) hash.to-remove)
      %fung
    %+  ~(jab by assets)
      minter.to-remove
    |=  =asset
    ?.  ?=([%fung *] asset)
      ::  expected a fung, found an nft?
      asset
    =.  amount.asset
      (sub amount.asset amount.to-remove)
    asset
  ==
::
++  generate-account-id
  |=  [=sender]
  ^-  account-id
  ::
  =/  ux-concat
    |=  [a=@ux b=@ux]
    ^-  @ux
    (cat 0 b a)
  ::  find out how to assert this is not on ed25519...
  =/  id  ^-  @ux
    ::  all 'add's replaced by concat func
    %+  ux-concat  `@ux`nonce.sender
    %+  ux-concat  0x0  ::  helix id = ??
    ?:  ?=(pubkey-sender sender)
      `@ux`pubkey
    ::  sorted and concat'd list of multisig pubkeys
    `@ux`(roll (sort pubkeys.sender lth) ux-concat)
  id
::
++  compute-gas
  |=  [=tx]
  ::  determine how much work this tx requires
  ::  these are all single-action transactions,
  ::  can determine set costs for each type of tx
  1  ::  temporary
--
