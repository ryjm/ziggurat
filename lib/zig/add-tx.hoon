/-  tx
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
        ?.  ?=(pubkey owner.account)  %.n
        ::  TODO actual signature validation here
        %.y
      ::  validate all sigs in multisig sender
      ::  and ensure # of signers is above threshold
      ?:  ?=(pubkey owner.account)  %.n
      ?&  %+  gte
            ~(wyt in signers.from.tx)
          threshold.owner.account
          ::
          %+  levy
            ~(tap in signers.from.tx)
          |=  [=pubkey =signature]
          ::  TODO actual signature validation here
          (~(has in members.owner.account) pubkey)
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
  ::  update account with inc'd nonce and fee paid
  =:  nonce.account  +(nonce.account)
      assets.account
    %+  ~(jab by assets.account)
      zigs-id
    |=  z=asset
    ::  zigs will always be tok, just type-asserting
    ?.  ?=([%tok *] z)  !!
    z(amount (sub amount.z fee))
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
    %coinbase         (coinbase state tx account)
  ==
::
::  handlers for each tx type
::
++  send
  |=  [=state =tx =account]
  ^-  (unit _state)
  ::  purely for type assertion
  ?.  ?=([%send *] tx)  ~
  ?.  ?=([%asset-account *] account)  ~
  =/  assets=(list asset)  ~(val by assets.tx)
  =/  to
    %+  fall
      (~(get by accts.state) to.tx)
    [%asset-account owner=to.tx nonce=0 assets=~]
  ?.  ?=([%asset-account *] to)
    ::  no support for minter account receiving assets
    ~&  >>  "error: %send to non-asset account"
    ~
  |-  ^-  (unit _state)
  ::  if finished successfully, return new state
  ?~  assets  `state
  =*  to-send  i.assets
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
  =:  assets.account  (remove-asset to-send assets.account)
      assets.to  (insert-asset to-send assets.to)
  ==
  =.  accts.state
    %+  ~(put by (~(put by accts.state) to.tx to))
      account-id.from.tx
    account
  $(assets t.assets)
::
++  mint
  |=  [=state =tx =account]
  ^-  (unit _state)
  ::  purely for type assertion
  ?.  ?=([%mint *] tx)  ~
  ?.  ?=([%asset-account *] account)  ~
  ?~  find-owner=(~(get by accts.state) minter.tx)
    ~&  >>>  "error: can't find minter-account for this asset"
    ~
  =*  asset-owner  u.find-owner
  ?.  ?=([%minter-account *] asset-owner)
    ~&  >>>  "error: account to perform %mint is not a minter-account"
    ~
  ?.  (~(has in whitelist.asset-owner) account-id.from.tx)
    ~&  >>>  "error: tx sender not in minting whitelist"
    ~
  ::  loop through assets in to.tx and verify all are legit
  ::  while adding to accounts of receivers
  |-  ^-  (unit _state)
  ?~  to.tx
    [~ state(accts (~(put by accts.state) minter.tx asset-owner))]
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
    ~&  >>>  "error: %mint would create too many assets"
    ~
  =/  to-acct
    %+  fall
      (~(get by accts.state) to-whom)
    [%asset-account owner=to-whom nonce=0 assets=~]
  ::  receivers must be asset accounts
  ?.  ?=([%asset-account *] to-acct)
    ~&  >>>  "error: %mint assets to non-asset account"
    ~
  =.  assets.to-acct
    %:  insert-minting-asset
        minter.tx
        total.asset-owner  ::  this becomes ID of nft in collection
        to-send
        assets.to-acct
    ==
  ::  update minter and receiver accounts in state
  %_  $
    to.tx              t.to.tx
    accts.state        (~(put by accts.state) to-whom to-acct)
    total.asset-owner  amount-after-mint
  ==
::
++  lone-mint
  |=  [=state =tx =account]
  ^-  (unit _state)
  ?.  ?=([%lone-mint *] tx)  ~
  =/  blank-account-id  (generate-minter-id from.tx)
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
  ?~  to.tx  `state
  =*  to-send  +.i.to.tx
  =*  to-whom  -.i.to.tx
  =/  to-acct
    %+  fall
      (~(get by accts.state) to-whom)
    [%asset-account owner=to-whom nonce=0 assets=~]
  ::  receivers must be asset accounts
  ?.  ?=([%asset-account *] to-acct)
    ~&  >>  "error: %lone-mint assets to non-asset account"
    ~
  =.  assets.to-acct
    %:  insert-minting-asset
        blank-account-id
        i
        to-send
        assets.to-acct
    ==
  ::  update receiver account in state
  %_  $
    i            +(i)
    to.tx        t.to.tx
    accts.state  (~(put by accts.state) to-whom to-acct)
  ==
::
++  create-minter
  |=  [=state =tx =account]
  ^-  (unit _state)
  ?.  ?=([%create-minter *] tx)  ~
  =/  new-account-id  (generate-minter-id from.tx)
  ::  create new account in state to hold this minter
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
  ?.  ?=([%update-minter *] tx)  ~
  ?~  acct=(~(get by accts.state) minter.tx)
    ~&  >>>  "error: %update-minter on nonexistent account"
    ~
  =*  acct-to-update  u.acct
  ?.  ?=([%minter-account *] acct-to-update)
    ~&  >>>  "error: %update-minter on non-minter account"
    ~
  ::  verify that tx sender owns the minter
  ::  the signature(s) here are validated already,
  ::  but pubkeys/multisigs need to match the current
  ::  owner of the minting account being edited
  ?.  ?.  ?=(pubkey owner.acct-to-update)
        ::  see if multisig owner is enough
        ?:  ?=(pubkey-sender from.tx)  %.n
        %+  levy
          ~(tap in signers.from.tx)
        |=  [=pubkey =signature]
        (~(has in members.owner.acct-to-update) pubkey)
      ::  just check single sender pubkey
      ?.  ?=(pubkey-sender from.tx)  %.n
      =(owner.acct-to-update pubkey.from.tx)
    ~&  >>>  "error: %update-minter sender doesn't match owner"
    ~
  ::  if multisig, make sure new threshold <= member count
  ?.  ?.  ?=(pubkey owner.acct-to-update)
        %+  lte
          ~(wyt in members.owner.acct-to-update)
        threshold.owner.acct-to-update
      %.y  ::  non-multisig so no need to check
    ~&  >>>  "error: %update-minter multisig threshold set too high"
    ~
  :+  ~
    hash.state
  %+  ~(put by accts.state)
    minter.tx
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
  ?.  ?=([%create-multisig *] tx)  ~
  =/  account-id  (generate-asset-account-id owner.tx nonce.from.tx)
  ::  create new account in state to hold this multisig
  ::  if account-id already exists this fails
  ?^  (~(get by accts.state) account-id)
    ~&  >>>  "error: %create-multisig collision with existing account"
    ~
  ?:  (gth threshold.owner.tx ~(wyt in members.owner.tx))
    ~&  >>>  "error: %create-multisig threshold set too high"
    ~
  ?:  =(threshold.owner.tx 0)
    ~&  >>>  "error: %create-multisig threshold set to zero"
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
  ?.  ?=([%update-multisig *] tx)  ~
  ?.  ?=([%asset-account *] account)  ~
  ?:  (gth threshold.owner.tx ~(wyt in members.owner.tx))
    ~&  >>>  "error: %update-multisig threshold set too high"
    ~
  :+  ~
    hash.state
  %+  ~(put by accts.state)
    account-id.from.tx
  :*  %asset-account
      owner.tx
      nonce.account
      assets.account
  ==
++  coinbase
  |=  [=state =tx =account]
  ^-  (unit _state)
  ?.  ?=([%coinbase *] tx)  ~
  ?.  ?=([%asset-account *] account)  ~
  :+  ~
    hash.state
  %+  ~(put by accts.state)
    account-id.from.tx
  account(assets (insert-asset [%tok zigs-id fees.tx] assets.account))
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
::  $generate-asset-account-id: produces a hash
::  to make 1:1 account id from pubkey
::
++  generate-asset-account-id
  |=  [=owner =nonce]
  ^-  account-id
  =/  helix  0x0  ::  TODO helix id goes here
  %-  shax
  ?:  ?=(pubkey owner)
    (ux-concat helix owner)
  ::  sorted and concat'd list of multisig pubkeys
  ::  multisig asset accounts also need nonce, as it
  ::  should(?) be possible for two multisigs with
  ::  the same set of signers to exist
  %+  ux-concat  `@ux`nonce
  %+  ux-concat  helix
  (roll (sort ~(tap in members.owner) lth) ux-concat)
::  $generate-minter-id: produces hash to serve as
::  new account-id for minter accounts from pubkey
::
++  generate-minter-id
  |=  =sender
  ^-  account-id
  %-  shax
  %+  ux-concat  `@ux`nonce.sender
  %+  ux-concat  0x0  ::  TODO helix id goes here
  ?:  ?=(pubkey-sender sender)
    pubkey.sender
  ::  sorted and concat'd list of multisig pubkeys
  %+  roll
    %+  sort
      %+  turn
        ~(tap in signers.sender)
      |=([=pubkey =signature] pubkey)
    lth
  ux-concat
::
++  ux-concat
  |=  [a=@ux b=@ux]
  ^-  @ux
  (cat 3 b a)
::
++  compute-gas
  |=  =tx
  ::  determine how much work this tx requires
  ::  these are all single-action transactions,
  ::  can determine set costs for each type of tx
  ::  based on number of state changes maybe?
  ::  temporary
  ?-  -.tx
    %send             ~(wyt by assets.tx)
    %mint             (lent to.tx)
    %lone-mint        (lent to.tx)
    %create-multisig  1
    %update-multisig  1
    %create-minter    1
    %update-minter    1
    %coinbase         0
  ==
--
