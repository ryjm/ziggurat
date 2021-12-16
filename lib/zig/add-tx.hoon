/-  tx
/+  *zig-sig
=,  tx
|%
::  something hardcoded
++  zigs-id  0x0
::
::  $txs-to-chunk: builds chunk out of selected txs from mempool
::
::  Given the current helix state and mempool, the chunk
::  producer selects a maximally-rewarding subset of transactions
::  and attempts to apply them to the state. Failing transactions
::  still result in fees paid to the chunk producer. The resulting
::  chunk includes a $coinbase transaction, which rewards the
::  producer for its work.
::
::  Need to choose where this hooks into the validator agent
::  and what format the mempool and chunk should take.
::
++  txs-to-chunk
  |=  [=state mempool=(list tx) our=sender]
  ^-  [(list [hash=@ux =tx]) _state]
  ::  go through list and process each tx
  ::  make a note of rejected txs?
  ::  collect total fee count then make a tx
  ::  giving fee to ourself
  ::  build list of [hash tx]
  ::  return final state with list?
  =/  txs  (gather mempool)
  =+  [results=*(list [hash=@ux =tx]) total-fees=*zigs]
  |-  ^-  [(list [hash=@ux =tx]) _state]
  ?~  txs
    ::  time to sum resulting fees and coinbase ourselves
    =/  payment=tx
      [%coinbase our total-fees]
    ?~  res=(process-tx payment state)
      ~&  >>>  "error: failed to award chunk fees to ourselves"
      !!
    :_  +.u.res
    (flop [[`@ux`(shax (jam payment)) payment] results])
  ::  check to see if tx was processed
  ?~  res=(process-tx i.txs state)
    $(txs t.txs)
  %_  $
    txs         t.txs
    results     [[`@ux`(shax (jam i.txs)) i.txs] results]
    state       +.u.res
    total-fees  -.u.res
  ==
::
::  $gather: select transactions from mempool
::
++  gather
  |=  mempool=(list tx)
  ^-  (list tx)
  ::  choosing the txs with highest feerate
  ::  to build the best overall chunk for producer
  ::  TODO determine cutoff point for size of chunk
  ::  could be size of data, # of CSEs..
  %+  sort
    mempool
  |=  [a=tx b=tx]
  (gth feerate.from.a feerate.from.b)
::
::  $process-tx: modify state to results of transaction, if valid.
::
++  process-tx
  |=  [=tx =state]
  ^-  (unit [fee=zigs _state])
  ::  find account which will perform tx
  ::
  ?~  acc=(~(get by accts.state) account-id.from.tx)
    ~&  >>>  "error: sender account not found in state"
    ~
  =*  account  u.acc
  ?.  ?=([%asset-account *] account)
    ~&  >>>  "error: tx submitted from non-asset account" 
    ~
  ::  check validity of signature(s)
  ::  TODO ECDSA and Schnorr implementations 
  ?.  ?:  ?=(pubkey-sender from.tx)
        ::  validate single sig from sender
        ?.  ?=(pubkey owner.account)
          %.n
        ::  %:  validate
        ::      ~zod
        ::      [r.sig.from.tx ~zod 1]
        ::      (shax (con account-id.from.tx nonce.from.tx))
        ::      ~2021.12.13..19.05.17..7258
        ::  ==
        %.y
      ::  validate all sigs in multisig sender
      ?:  ?=(pubkey owner.account)
        %.n
      ?&  (gte (lent sigs.from.tx) threshold.owner.account)
          ::  %+  levy
          ::    sigs.from.tx
          ::  |=  =signature
          ::  %:  validate
          ::      ~zod
          ::      [r.signature ~zod 1]
          ::      (shax (con account-id.from.tx nonce.from.tx))
          ::      ~2021.12.13..19.05.17..7258
          ::  ==
          %.y
      ==
    ~&  >>>  "error: transaction signature(s) not valid"
    ~
  ?.  =(+(nonce.account) nonce.from.tx)
    ~&  >>>  "error: incorrect tx nonce"
    ~
  =/  fee  (mul (compute-gas tx) feerate.from.tx)
  =/  zigs-in-account
    ?~  zigs=(~(get by assets.account) zigs-id)  0
    ?.  ?=([%tok *] u.zigs)  0
    amount.u.zigs
  ?.  (gte zigs-in-account fee)
    ~&  >>>  "error: {<zigs-in-account>} zigs in account, tx fee is {<fee>}"
    ~
  =:
  ::  take fee from sender account
    assets.account
  %+  ~(jab by assets.account)
    zigs-id
  |=  z=asset
  ::  zigs will always be tok, just type-asserting
  ?.  ?=([%tok *] z)  !!
  z(amount (sub amount.z fee))
  ::  update account with inc'd nonce and fee paid
    nonce.account
  +(nonce.account)
  ==
  =.  accts.state
    (~(put by accts.state) account-id.from.tx account)
  =-  `[fee ?~(- state u:-)]
  ?-  -.tx
    %send             (send state tx account)
    %mint             (mint state tx account)
    %lone-mint        (lone-mint state tx account)
    %create-multisig  (create-multisig state tx account)
    %update-multisig  (update-multisig state tx account)
    %create-minter    (create-minter state tx account)
    %update-minter    (update-minter state tx account)
    %coinbase         (reward state tx account)
  ==
::
::  handlers for each tx type
::
++  send
  |=  [=state =tx =account]
  ^-  (unit _state)
  ?.  ?=([%send *] tx)
    ~
  ::  purely for type assertion
  ?.  ?=([%asset-account *] account)
    ::  no support for minter account sending assets
    ~&  >>>  "error: %send tx from minter account"
    ~
  =/  assets=(list asset)  ~(val by assets.tx)
  |-  ^-  (unit _state)
  ::  if finished successfully, return new state
  ?~  assets
    `state
  =*  to-send  i.assets
  ?~  to=(~(get by accts.state) to.tx)
    ::  trying to send asset to non-existent account
    ::  TODO if account doesn't exist make a new one?
    ~&  >>  "warning: %send to non-existent account"
    =.  assets.account  (remove-asset to-send assets.account)
    %_  $
      assets          t.assets
      ::
        accts.state
      %+  ~(put by accts.state)
        account-id.from.tx
      account
    ==
  ?.  ?=([%asset-account *] u.to)
    ::  no support for minter account receiving assets
    ~&  >>  "warning: %send to non-asset account"
    =.  assets.account  (remove-asset to-send assets.account)
    %_  $
      assets          t.assets
      ::
        accts.state
      %+  ~(put by accts.state)
        account-id.from.tx
      account
    ==
  ::  assert that send is valid for this asset
  ?.  ?-  -.to-send
          %nft
        ?~  mine=(~(get by assets.account) hash.to-send)
          %.n
        ?:  ?=([%nft *] u.mine)
          ?&  =(minter.to-send minter.u.mine)
              can-xfer.u.mine
          ==
        %.n
        ::
          %tok  
        ?~  mine=(~(get by assets.account) minter.to-send)
          %.n
        ?:  ?=([%tok *] u.mine)
          (gth amount.u.mine amount.to-send)
        %.n
      ==
    ~&  >>>  "error: don't have enough {<minter.to-send>} to send, or tried to send untransferrable NFT"
    ~
  ::  asset is good to send, modify state
  ::  update sender to have x less of asset
  ::  update receiver to have x more
  =:  
    assets.account  (remove-asset to-send assets.account)
    assets.u.to  (insert-asset to-send assets.u.to)
  ==
  =.  accts.state
    %+  ~(put by (~(put by accts.state) to.tx u.to))
      account-id.from.tx
    account
  $(assets t.assets)
::
++  mint
  |=  [=state =tx =account]
  ^-  (unit _state)
  ?.  ?=([%mint *] tx)
    ~
  ?.  ?=([%asset-account *] account)
    ~&  >>>  "error: %mint tx from non-asset account"
    ~
  ?~  find-owner=(~(get by accts.state) minter.tx)
    ~&  >>>  "error: can't find minter-account for this asset"
    ~
  =*  asset-owner  u.find-owner
  ?.  ?=([%minter-account *] asset-owner)
    ~&  >>>  "error: account to perform %mint is not a minter-account"
    ~
  ?.  (~(has in whitelist.asset-owner) owner.account)
    ~&  >>>  "error: tx sender not in minting whitelist"
    ~
  ::  loop through assets in to.tx and verify all are legit
  ::  while adding to accounts of receivers
  |-  ^-  (unit _state)
  ?~  to.tx  [~ state]
  =*  to-send  +.i.to.tx
  =*  to-whom  -.i.to.tx
  =/  amount-after-mint
    %+  add  total.asset-owner
    ?-  -.to-send
      %nft  1
      %tok  amount.to-send
    ==
  ::  amount of asset to create must not put total above limit
  ?.  (gte max.asset-owner amount-after-mint)
    ~&  >>>  "error: mint would create too many assets"
    ~
  ?~  to-acct=(~(get by accts.state) to-whom)
    ::  trying to send asset to non-existent account,
    ::  TODO make a new account and add to state?
    ~&  >>  "warning: minted assets to nonexistent account"
    =.  total.asset-owner  amount-after-mint
    %_  $
      to.tx        t.to.tx
      accts.state  (~(put by accts.state) minter.tx asset-owner)
    ==
  ::  receivers must be asset accounts
  ?.  ?=([%asset-account *] u.to-acct)
    ~&  >>  "warning: minted assets to non-asset account"
    =.  total.asset-owner  amount-after-mint
    %_  $
      to.tx        t.to.tx
      accts.state  (~(put by accts.state) minter.tx asset-owner)
    ==
  =.  assets.u.to-acct
    %:  insert-minting-asset
        minter.tx
        total.asset-owner  ::  this becomes ID of nft in collection
        to-send
        assets.u.to-acct
    ==
  =.  total.asset-owner  amount-after-mint
  ::  update minter and receiver accounts in state
  %_  $
    to.tx    t.to.tx
    ::
      accts.state
    %+  ~(put by (~(put by accts.state) to-whom u.to-acct))
      minter.tx
    asset-owner
  ==
::
++  lone-mint
  |=  [=state =tx =account]
  ^-  (unit _state)
  ?.  ?=([%lone-mint *] tx)
    ~
  =/  blank-account-id  (generate-account-id from.tx)
  ::  create new account in state to hold this mint
  ::  if account-id exists this mint fails
  ?^  (~(get by accts.state) blank-account-id)
    ~&  >>>  "error: %lone-mint collision with existing account"
    ~
  =.  accts.state
    %+  ~(put by accts.state)
      blank-account-id
    [%blank-account ~]
  ::  proceed with mint, ensuring all assets
  ::  have same minter of blank-account-id
  ::  NFT IDs start at i=0 and count up
  =+  i=0
  |-  ^-  (unit _state)
  ?~  to.tx
    `state
  =*  to-send  +.i.to.tx
  =*  to-whom  -.i.to.tx
  ?~  to-acct=(~(get by accts.state) to-whom)
    ::  trying to send asset to non-existent account,
    ::  TODO make a new account and add to state?
    ~&  >>  "warning: minted assets to nonexistent account"
    $(to.tx t.to.tx)
  ::  receivers must be asset accounts
  ?.  ?=([%asset-account *] u.to-acct)
    ~&  >>  "warning: minted assets to non-asset account"
    $(to.tx t.to.tx)
  =.  assets.u.to-acct
    %:  insert-minting-asset
        blank-account-id
        i
        to-send
        assets.u.to-acct
    ==
  ::  update receiver account in state
  %_  $
    i            +(i)
    to.tx        t.to.tx
    accts.state  (~(put by accts.state) to-whom u.to-acct)
  ==
::
++  create-minter
  |=  [=state =tx =account]
  ^-  (unit _state)
  ?.  ?=([%create-minter *] tx)
    ~
  =/  new-account-id  (generate-account-id from.tx)
  ::  create new account in state to hold this multisig
  ::  if account-id already exists this fails
  ?^  (~(get by accts.state) new-account-id)
    ~&  >>>  "error: %create-minter collision with existing account"
    ~
  :+  ~
    hash.state
  %+  ~(put by accts.state)
    new-account-id
  :*  %minter-account
      owner.tx
      ::  nonce=0
      whitelist.tx
      max.tx
      total=0
  ==
::
++  update-minter
  |=  [=state =tx =account]
  ^-  (unit _state)
  ?.  ?=([%update-minter *] tx)
    ~
  ?~  acct=(~(get by accts.state) account-id.from.tx)
    ~&  >>>  "error: %update-minter on nonexistent account"
    ~
  =*  acct-to-update  u.acct
  ?.  ?=([%minter-account *] acct-to-update)
    ~&  >>>  "error: %update-minter on non-minter account"
    ~
  ::  if multisig, make sure threshold <= member count
  ?.  ?.  ?=(pubkey owner.tx)
        (lte (lent members.owner.tx) threshold.owner.tx)
      %.y  ::  non-multisig so no need to check
    ~&  >>>  "error: %update-minter multisig threshold set too high"
    ~
  :+  ~
    hash.state
  %+  ~(put by accts.state)
    account-id.from.tx
  :*  %minter-account
      owner.tx
      ::  nonce.acct-to-update
      whitelist.tx
      max.acct-to-update
      total.acct-to-update
  ==
::
++  create-multisig
  |=  [=state =tx =account]
  ^-  (unit _state)
  ?.  ?=([%create-multisig *] tx)
    ~
  ::  assert assets is empty, where?
  =/  account-id  (generate-account-id from.tx)
  ::  create new account in state to hold this multisig
  ::  if account-id already exists this fails
  ?^  (~(get by accts.state) account-id)
    ~&  >>>  "error: %create-multisig collision with existing account"
    ~
  ?.  (lte (lent members.owner.tx) threshold.owner.tx)
    ~&  >>>  "error: %create-multisig threshold set too high"
    ~
  :+  ~
    hash.state
  %+  ~(put by accts.state)
    account-id
  ::  TODO make sure nonce should start at 0
  [%asset-account owner.tx nonce=0 assets=~]
::
++  update-multisig
  |=  [=state =tx =account]
  ^-  (unit _state)
  ?.  ?=([%update-multisig *] tx)
    ~
  ?~  acct=(~(get by accts.state) account-id.from.tx)
    ~&  >>>  "error: %update-multisig on nonexistent account"
    ~
  =/  acct-to-update  u.acct
  ?.  ?=([%asset-account *] acct-to-update)
    ~&  >>>  "error: %update-multisig on non-asset account"
    ~
  ?.  (lte (lent members.owner.tx) threshold.owner.tx)
    ~&  >>>  "error: %update-multisig threshold set too high"
    ~
  :+  ~
    hash.state
  %+  ~(put by accts.state)
    account-id.from.tx
  :*  %asset-account
      owner.tx
      nonce.acct-to-update
      assets.acct-to-update
  ==
++  reward
  |=  [=state =tx =account]
  ~
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
      %tok
    ?~  (~(get by assets) minter.to-send)
      ::  asset not yet present in wallet, insert
      (~(put by assets) minter.to-send to-send)
    %+  ~(jab by assets)
      minter.to-send
    |=  =asset
    ?.  ?=([%tok *] asset)
      ::  expected a tok, found an nft?
      asset
    asset(amount (add amount.asset amount.to-send))
  ==
::
++  insert-minting-asset
  |=  [minter=account-id =id to-send=minting-asset assets=(map account-id asset)]
  ^+  assets 
  ::  add to existing assets in wallet
  ?-  -.to-send
      %nft
    =/  new-asset=asset
      :*  %nft
          minter
          id
          uri.to-send
          hash.to-send
          can-xfer.to-send
      ==
    ::  using hash here since NFTs in a collection share account-id
    (~(put by assets) hash.to-send new-asset)
      %tok
    =/  new-asset=asset
      [%tok minter=minter amount=amount.to-send]
    ?~  (~(get by assets) minter)
      ::  asset not yet present in wallet, insert
      (~(put by assets) minter new-asset)
    %+  ~(jab by assets)
      minter
    |=  =asset
    ?.  ?=([%tok *] asset)
      ::  expected a tok, found an nft?
      asset
    asset(amount (add amount.asset amount.to-send))
  ==
::
++  remove-asset
  |=  [to-remove=asset assets=(map account-id asset)]
  ^+  assets
  ?-  -.to-remove
      %nft
    (~(del by assets) hash.to-remove)
      %tok
    %+  ~(jab by assets)
      minter.to-remove
    |=  =asset
    ?.  ?=([%tok *] asset)
      ::  expected a tok, found an nft?
      asset
    asset(amount (sub amount.asset amount.to-remove))
  ==
::  $generate-account-id: produces a hash based on pubkeys and details of account
::
++  generate-account-id
  |=  [=sender]
  ^-  account-id
  ::
  =/  ux-concat
    |=  [a=@ux b=@ux]
    ^-  @ux
    (cat 3 b a)
  %+  ux-concat  `@ux`nonce.sender
  %+  ux-concat  0x0  ::  TODO helix id goes here
  ?:  ?=(pubkey-sender sender)
    pubkey.sender
  ::  sorted and concat'd list of multisig pubkeys
  (roll (sort pubkeys.sender lth) ux-concat)
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
    ::  TODO better way to get length/size of set?
    (lent ~(tap by assets.tx))
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
      %coinbase
    0
  ==
--
