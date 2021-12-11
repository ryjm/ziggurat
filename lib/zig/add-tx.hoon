/-  tx
=,  tx
|%
::  something hardcoded
++  zigs-id  `@ux`0x0
::
::  $chunk-transactions: take a set of transactions and apply them
::
++  chunk-transactions
  |=  [=state txs=(list tx)]
  ^+  state
  ::  go through list and process each
  ::  make a note of rejected txs?
  ::  collect total fee count then make a tx
  ::  giving fee to ourself
  ::  build list of [hash tx]
  ::  return final state?
  state
::
::  $process-tx: modify state to results of transaction, if valid.
::
++  process-tx
  |=  [=tx current=state]
  ::  TODO how to access type 'state' and not face named 'state'?
  ::  named state 'current' to do this
  ^-  (unit state)
  ::
  ::  TODO here check validity of signature(s)
  ::
  =/  account  (~(get by accts.current) account-id.from.tx)
  ?~  account
    ~&  >>>  "error: sender account not found in state"
    ~
  =/  account  u.account
  ?.  ?=([%asset-account *] account)
    ~&  >>>  "error: tx submitted from non-asset account" 
    ~
  ?.  =((succ nonce.account) nonce.from.tx)
    ~&  >>>  "error: incorrect tx nonce"
    ~
  ::  increment nonce of tx sender acct
  ::
  =.  nonce.account  (succ nonce.account)
  =/  fee
    %+  mul
      (compute-gas tx)
    feerate.from.tx
  =/  zigs-in-account
    =/  zigs  (~(get by assets.account) zigs-id)
    ?~  zigs  0
    ?+  -.u.zigs  0
        %fung
      amount.u.zigs
    ==
  ?.  (gte zigs-in-account fee)
    ~&  >>>  "error: {<zigs-in-account>} zigs in account, tx fee is {<fee>}"
    ~
  ::  take fee from sender account
  =.  assets.account
    %+  ~(jab by assets.account)
      zigs-id
    |=  z=asset
    ?.  ?=([%fung *] z)
      ::  expect zigs to be fung, real error
      !!
    =.  amount.z
      (sub amount.z fee)
    z
  ::  update account with inc'd nonce and fee paid
  ::
  =.  accts.current
    (~(put by accts.current) account-id.from.tx account)  
  ::  branch on type of transaction and get output state
  ::  TODO cleaner way to write this?
  ::
  ?-  -.tx
      %send
    (send current tx account)
  ::
      %mint
    (mint current tx account)
  ::
      %lone-mint
    (lone-mint current tx account)
  ::
      %create-multisig
    (create-multisig current tx account)
  ::
      %update-multisig
    (update-multisig current tx account)
  ::
      %create-minter
    (create-minter current tx account)
  ::
      %update-minter
    (some current)
  ==
::
::  handlers for each tx type
::
++  send
  |=  [current=state =tx =account]
  ::  how do i access type 'state' and not face named 'state'?
  ^-  (unit state)
  ?.  ?=([%send *] tx)
    ~
  ?.  ?=([%asset-account *] account)
    ::  no support for minter account sending assets
    ~&  >>>  "error: %send tx from minter account"
    ~
  ::  TODO if account doesn't exist make a new one?
  =/  to  (~(get by accts.current) to.tx)
  ?~  to
    ::  trying to send asset to non-existent account,
    ::  TODO make a new account and add to state?
    ~&  >>>  "potential error: %send to non-existent account"
    (some current)
  =/  to  u.to
  ?.  ?=([%asset-account *] to)
    ::  no support for minter account receiving assets
    ~&  >>>  "error: sending assets to non-asset account"
    ~
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
  ::  assert that send is valid for this asset
  ?.  ?-  -.to-send
          %nft
        =/  mine  (~(get by assets.account) hash.to-send)
        ?~  mine  %.n
        ?:  ?=([%nft *] u.mine)
          ?&  =(minter.to-send minter.u.mine)
              can-xfer.u.mine
          ==
        %.n
          %fung
        =/  mine  (~(get by assets.account) minter.to-send)
        ?~  mine  %.n
        ?:  ?=([%fung *] u.mine)
          (gth amount.u.mine amount.to-send)
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
++  mint
  |=  [current=state =tx =account]
  ^-  (unit state)
  ?.  ?=([%mint *] tx)
    ~
  ?.  ?=([%asset-account *] account)
    ~&  >>>  "error: %mint tx from non-asset account"
    ~
  ::  loop through assets in to.tx and verify all are legit
  ::  while adding to accounts of receivers
  |-  ^-  (unit state)
  ?~  to.tx
    (some current)
  =/  to-send  +.i.to.tx
  =/  to-whom  -.i.to.tx
  =/  asset-owner  (~(get by accts.current) minter.to-send)
  ?~  asset-owner
    ~&  >>>  "error: can't find minter-account for this asset"
    ~
  =/  asset-owner  u.asset-owner
  ?.  ?=([%minter-account *] asset-owner)
    ~&  >>>  "error: asset to mint not controlled by minter-account"
    ~
  ::  minter must match tx sender
  ?.  =(owner.asset-owner owner.account)
    ~&  >>>  "error: tx sender doesn't match minter"
    ~
  =/  amount-after-mint
    %+  add  total.asset-owner
    ?-  -.to-send
        %nft
      1
        %fung
      amount.to-send
    ==
  ::  amount of asset to create must not put total above limit
  ?.  (gte max.asset-owner amount-after-mint)
    ~&  >>>  "error: mint would create too many assets"
    ~
  ::  mint is approved, give to receiver and modify total
  =.  total.asset-owner  amount-after-mint
  =/  to  (~(get by accts.current) to-whom)
  ?~  to
    ::  trying to send asset to non-existent account,
    ::  TODO make a new account and add to state?
    $(to.tx t.to.tx)
  ::  receivers must be asset accounts
  ?.  ?=([%asset-account *] u.to)
    ~&  >>>  "error: sending assets to non-asset account"
    ~
  =.  assets.u.to
    (insert-asset to-send assets.u.to)
  ::  update minter and receiver accounts in state
  =.  accts.current
    (~(put by accts.current) minter.to-send asset-owner)
  =.  accts.current
    (~(put by accts.current) to-whom u.to)  
  $(to.tx t.to.tx)
::
++  lone-mint
  |=  [current=state =tx =account]
  ^-  (unit state)
  ?.  ?=([%lone-mint *] tx)
    ~
  =/  blank-account-id  (generate-account-id from.tx)
  ::  create new account in state to hold this mint
  ::  if account-id exists this mint fails
  ?^  (~(get by accts.current) blank-account-id)
    ~&  >>>  "error: %lone-mint collision with existing account"
    ~
  =.  accts.current
    (~(put by accts.current) blank-account-id [%blank-account ~])
  ::  proceed with mint, ensuring all assets
  ::  have same minter of blank-account-id
  |-  ^-  (unit state)
  ?~  to.tx
    (some current)
  =/  to-send  +.i.to.tx
  =/  to-whom  -.i.to.tx
  ::  for a lone mint, no check needed for matching owner, since blank account?
  ::  ?.  =(minter.to-send blank-account-id)
  ::    ~&  >>>  "error: tx sender doesn't match new account id"
  ::    ~
  =/  to  (~(get by accts.current) to-whom)
  ?~  to
    ::  trying to send asset to non-existent account,
    ::  TODO make a new account and add to state?
    $(to.tx t.to.tx)
  ::  receivers must be asset accounts
  ?.  ?=([%asset-account *] u.to)
    ~&  >>>  "warning: sent assets to non-asset account"
    $(to.tx t.to.tx)
  =.  assets.u.to
    (insert-asset to-send assets.u.to)
  ::  update receiver account in state
  =.  accts.current
    (~(put by accts.current) to-whom u.to)  
  $(to.tx t.to.tx)
::
++  create-minter
  |=  [current=state =tx =account]
  ^-  (unit state)
  ?.  ?=([%create-minter *] tx)
    ~
  =/  new-account-id  (generate-account-id from.tx)
  ::  create new account in state to hold this multisig
  ::  if account-id already exists this fails
  ?^  (~(get by accts.current) new-account-id)
    ~&  >>>  "error: %create-minter collision with existing account"
    ~
  =.  accts.current
    %+  ~(put by accts.current)
      new-account-id
    ::  TODO make sure nonce should start at 0
    [%minter-account owner.tx nonce=0 max=max.tx total=0]
  (some current)
::
++  update-minter
  |=  [current=state =tx =account]
  ^-  (unit state)
  ?.  ?=([%update-minter *] tx)
    ~
  =/  acct-to-update
    (~(get by accts.current) account-id.from.tx)
  ?~  acct-to-update
    ~&  >>>  "error: %update-minter on nonexistent account"
    ~
  =/  acct-to-update  u.acct-to-update
  ?.  ?=([%minter-account *] acct-to-update)
    ~&  >>>  "error: %update-minter on non-minter account"
    ~
  ::  if multisig, make sure threshold <= member count
  ?.  ?.  ?=(pubkey owner.tx)
        (lte (lent members.owner.tx) threshold.owner.tx)
      %.y  ::  non-multisig so no need to check
    ~&  >>>  "error: %update-minter multisig threshold set too high"
    ~
  =.  accts.current
    %+  ~(put by accts.current)
      account-id.from.tx
    :*  %minter-account
        owner.tx
        nonce.acct-to-update
        max.acct-to-update
        total.acct-to-update
    ==
  (some current)
::
++  create-multisig
  |=  [current=state =tx =account]
  ^-  (unit state)
  ?.  ?=([%create-multisig *] tx)
    ~
  ::  assert assets is empty, where?
  =/  account-id  (generate-account-id from.tx)
  ::  create new account in state to hold this multisig
  ::  if account-id already exists this fails
  ?^  (~(get by accts.current) account-id)
    ~&  >>>  "error: %create-multisig collision with existing account"
    ~
  ?.  (lte (lent members.owner.tx) threshold.owner.tx)
    ~&  >>>  "error: %create-multisig threshold set too high"
    ~
  =.  accts.current
    %+  ~(put by accts.current)
      account-id
    ::  TODO make sure nonce should start at 0
    [%asset-account owner.tx nonce=0 assets=~]
  (some current)
::
++  update-multisig
  |=  [current=state =tx =account]
  ^-  (unit state)
  ?.  ?=([%update-multisig *] tx)
    ~
  =/  acct-to-update
    (~(get by accts.current) account-id.from.tx)
  ?~  acct-to-update
    ~&  >>>  "error: %update-multisig on nonexistent account"
    ~
  =/  acct-to-update  u.acct-to-update
  ?.  ?=([%asset-account *] acct-to-update)
    ~&  >>>  "error: %update-multisig on non-asset account"
    ~
  ?.  (lte (lent members.owner.tx) threshold.owner.tx)
    ~&  >>>  "error: %update-multisig threshold set too high"
    ~
  =.  accts.current
    %+  ~(put by accts.current)
      account-id.from.tx
    :*  %asset-account
        owner.tx
        nonce.acct-to-update
        assets.acct-to-update
    ==
  (some current)
::
::  helper/utility functions
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
  ::  based on number of state changes maybe?
  ::  temporary
  ?-  -.tx
      %send
    (lent assets.tx)
  ::
      %mint
    (lent to.tx)
  ::
      %lone-mint
    (lent to.tx)
  ::
      %create-multisig
    1
  ::
      %update-multisig
    1
  ::
      %create-minter
    1
  ::
      %update-minter
    1
  ==
--
