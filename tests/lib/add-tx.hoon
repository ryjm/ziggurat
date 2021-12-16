/-  *tx
/+  *test, *add-tx
|%
::
::  helpers for %send txs
::
++  build-send-test-state
  ^-  state
  =/  zigs-id  0x0
  =/  figs-id  0xf
  =/  bigs-id  0xb
  =/  nft-id  0xa
  =/  z
    `asset`[%tok minter=zigs-id amount=1.000]  ::  these are 'zigs'
  =/  f
    `asset`[%tok minter=figs-id amount=1.000]
  =/  b
    `asset`[%tok minter=bigs-id amount=500.000]
  =/  nft
    ^-  asset
    :*  %nft
        minter=nft-id
        id=0
        uri='some data'
        hash=`@ux`(shax 'some data')
        can-xfer=%.y
    ==
  =/  nft-cant-xfer
    ^-  asset
    :*  %nft
        minter=nft-id
        id=1
        uri='no transfers!'
        hash=`@ux`(shax 'no transfers!')
        can-xfer=%.n
    ==
  =/  a1  ::  test account 1
    ^-  account
    :*  %asset-account
        owner=0x1234
        nonce=0
        assets=(malt ~[[zigs-id z] [figs-id f] [bigs-id b] [`@ux`(shax 'some data') nft] [`@ux`(shax 'no transfers!') nft-cant-xfer]])
    ==
  =/  a2  ::  test account 2
    ^-  account
    :*  %asset-account
        owner=0x5678
        nonce=0
        assets=(malt ~[[zigs-id z] [figs-id f] [bigs-id b]])
    ==
  =/  a3  ::  (minter, can't send)
    ^-  account
    :*  %minter-account
        owner=0x1234
        nonce=0
        whitelist=(silt ~[[0x1234]])
        max=1.000
        total=0
    ==
  =/  a4  ::  multisig of accts 1 and 2
    ^-  account
    :*  %asset-account
        owner=[members=(silt `(list pubkey)`[0x1234 0x5678 ~]) threshold=2]
        nonce=0
        assets=(malt ~[[zigs-id z]])
    ==
  :-  0xb.00ba  ::  test state hash
  (malt ~[[0x1 a1] [0x2 a2] [0x3 a3] [0x4 a4]])
::
++  insert-asset
  |=  [who=account-id =asset =state]
  ^+  state
  =/  their-acct  (~(got by accts.state) who)
  ?>  ?=([%asset-account *] their-acct)
  =.  assets.their-acct
    ?-  -.asset
        %nft
      (~(put by assets.their-acct) hash.asset asset)
        %tok
      (~(put by assets.their-acct) minter.asset asset)
    ==
  =.  accts.state
    (~(put by accts.state) who their-acct)
  state
::
++  remove-asset
  |=  [who=account-id asset-id=@ux =state]
  ^+  state
  =/  their-acct  (~(got by accts.state) who)
  ?>  ?=([%asset-account *] their-acct)
  =.  assets.their-acct
    (~(del by assets.their-acct) asset-id)
  =.  accts.state
    (~(put by accts.state) who their-acct)
  state
::
++  increment-nonce
  |=  [who=account-id =state]
  ^+  state
  =/  their-acct  (~(got by accts.state) who)
  ?<  ?=([%blank-account *] their-acct)
  =.  nonce.their-acct
    (succ nonce.their-acct)
  =.  accts.state
    (~(put by accts.state) who their-acct)
  state
::
::  tests for %send txs
::
++  test-send
  =/  t
    :*  %send
        ::  a1 paying feerate of 10
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  sending 500 zigs to a2
        0x2
        (malt ~[[0x0 [%tok 0x0 500]]])
    ==
  =/  output  (process-tx t build-send-test-state)
  =/  correct-fee  10
  ::  a1 less 510 zigs, a2 plus 500
  ::  a1 nonce ++
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 490] build-send-test-state)
  =.  correct-state  (insert-asset 0x2 [%tok 0x0 1.500] correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>((some [correct-fee correct-state])) !>(output))
++  test-send-2-assets
  =/  t
    :*  %send
        ::  a1 paying feerate of 10, fee=10*2
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  a1 sending 500 zigs and 50 figs to a2
        0x2
        (malt ~[[0x0 [%tok 0x0 500]] [0xf [%tok 0xf 50]]])
    ==
  =/  output  (process-tx t build-send-test-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 480] build-send-test-state)
  =.  correct-state  (insert-asset 0x2 [%tok 0x0 1.500] correct-state)
  =.  correct-state  (insert-asset 0x1 [%tok 0xf 950] correct-state)
  =.  correct-state  (insert-asset 0x2 [%tok 0xf 1.050] correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>((some [correct-fee correct-state])) !>(output))
++  test-send-nft
  =/  test-nft
    [%nft 0xa id=0 uri='some data' hash=`@ux`(shax 'some data') can-xfer=%.y]
  =/  t
    :*  %send
        ::  a1 paying feerate of 10, fee=10*1
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  a1 sending 10 zigs to a4 and nft
        0x4
        (malt ~[[hash.test-nft test-nft]])
    ==
  =/  output  (process-tx t build-send-test-state)
  =/  correct-fee  10
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 990] build-send-test-state)
  =.  correct-state  (remove-asset 0x1 (shax 'some data') correct-state)
  =.  correct-state  (insert-asset 0x4 test-nft correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>((some [correct-fee correct-state])) !>(output))
++  test-send-tok-and-nft
  =/  test-nft
    [%nft 0xa id=0 uri='some data' hash=`@ux`(shax 'some data') can-xfer=%.y]
  =/  t
    :*  %send
        ::  a1 paying feerate of 10, fee=10*2
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  a1 sending 10 zigs to a4 and nft
        0x4
        (malt `(list [@ux asset])`~[[0x0 [%tok 0x0 10]] [hash.test-nft test-nft]])
    ==
  =/  output  (process-tx t build-send-test-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 970] build-send-test-state)
  =.  correct-state  (insert-asset 0x4 [%tok 0x0 1.010] correct-state)
  =.  correct-state  (remove-asset 0x1 (shax 'some data') correct-state)
  =.  correct-state  (insert-asset 0x4 test-nft correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>((some [correct-fee correct-state])) !>(output))
++  test-send-untransferrable-nft
  =+  ^=  test-nft
    :*  %nft
        minter=0xa
        id=1
        uri='no transfers!'
        hash=`@ux`(shax 'no transfers!')
        can-xfer=%.n
    ==
  =/  t
    :*  %send
        ::  a1 paying feerate of 10, fee=10*1
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  a1 sending 10 zigs to a4 and nft
        0x4
        (malt ~[[hash.test-nft test-nft]])
    ==
  =/  output  (process-tx t build-send-test-state)
  =/  correct-fee  10
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 990] build-send-test-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>((some [correct-fee correct-state])) !>(output))
++  test-send-no-zigs
  =+  ^=  test-nft
    :*  %nft
        minter=0xa
        id=1
        uri='no transfers!'
        hash=`@ux`(shax 'no transfers!')
        can-xfer=%.n
    ==
  =/  t
    :*  %send
        ::  a1 paying feerate of 10, fee=10*1
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  a1 sending 10 zigs to a4 and nft
        0x4
        (malt ~[[hash.test-nft test-nft]])
    ==
  =/  starting-state
    (insert-asset 0x1 [%tok 0x0 9] build-send-test-state)
  =/  output  (process-tx t starting-state)
  =/  correct-fee  10
  ::  tx will be rejected outright due to lack of zigs
  (expect-eq !>(~) !>(output))
++  test-send-not-enough-asset
  =/  t
    :*  %send
        ::  a1 paying feerate of 10, fee=10*2
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  a1 sending 500 zigs and 50 figs to a2
        0x2
        (malt ~[[0x0 [%tok 0x0 500]] [0xf [%tok 0xf 50]]])
    ==
  =/  starting-state
    (insert-asset 0x1 [%tok 0xf 49] build-send-test-state)
  =/  output  (process-tx t starting-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 980] starting-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>((some [correct-fee correct-state])) !>(output))
++  test-send-no-asset
  =/  t
    :*  %send
        ::  a1 paying feerate of 10, fee=10*2
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  a1 sending 500 zigs and 50 figs to a2
        0x2
        (malt ~[[0x0 [%tok 0x0 500]] [0xf [%tok 0xf 50]]])
    ==
  =/  starting-state
    (remove-asset 0x1 0xf build-send-test-state)
  =/  output  (process-tx t starting-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 980] starting-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>((some [correct-fee correct-state])) !>(output))
++  test-send-same-asset-twice
  =/  t
    :*  %send
        ::  a1 paying feerate of 10, fee=10*3
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  a1 sending 500 zigs and 50 figs to a2
        0x2
        ::  first of duplicates will be replaced in map
        (malt ~[[0x0 [%tok 0x0 500]] [0xf [%tok 0xf 50]] [0xf [%tok 0xf 20]]])
    ==
  =/  output  (process-tx t build-send-test-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 480] build-send-test-state)
  =.  correct-state  (insert-asset 0x1 [%tok 0xf 980] correct-state)
  =.  correct-state  (insert-asset 0x2 [%tok 0x0 1.500] correct-state)
  =.  correct-state  (insert-asset 0x2 [%tok 0xf 1.020] correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>((some [correct-fee correct-state])) !>(output))
++  test-send-part-fail
  =/  t
    :*  %send
        ::  a1 paying feerate of 10, fee=10*3
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  a1 sending 500 zigs and 50 figs to a2
        0x2
        (malt ~[[0x0 [%tok 0x0 500]] [0xf [%tok 0xf 1.000]] [0xb [%tok 0xb 1.000.000]]])
    ==
  =/  output  (process-tx t build-send-test-state)
  =/  correct-fee  30
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 970] build-send-test-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>((some [correct-fee correct-state])) !>(output))
++  test-send-all-fail
  =/  t
    :*  %send
        ::  a1 paying feerate of 10, fee=10*3
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  a1 sending 500 zigs and 50 figs to a2
        0x2
        (malt ~[[0x0 [%tok 0x0 1.000]] [0xf [%tok 0xf 2.000]] [0xb [%tok 0xb 1.000.000]]])
    ==
  =/  output  (process-tx t build-send-test-state)
  =/  correct-fee  30
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 970] build-send-test-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>((some [correct-fee correct-state])) !>(output))
++  test-send-nonexistent-sender
  =/  t
    :*  %send
        ::  nonexistent account
        [0xeee 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  sending 500 zigs to a2
        0x2
        (malt ~[[0x0 [%tok 0x0 500]]])
    ==
  =/  output  (process-tx t build-send-test-state)
  (expect-eq !>(~) !>(output))
::
::  TODO: not sure of the correct behavior here.
::  make a blank account to receive, or reject tx?
::
::  ++  test-send-nonexistent-receiver
::    (expect-eq !>(%.y) !>(%.n))
::  ++  test-send-to-minter
::    ::  should fail?
::    (expect-eq !>(%.y) !>(%.n))
::
::  tests for %mint txs
::
++  build-mint-test-state
  ^-  state
  =/  z
    [%tok zigs-id 1.000]  ::  these are 'zigs'
  =/  a1  ::  test account 1
    `account`[%asset-account 0x1234 0 (malt ~[[zigs-id z]])]
  =/  a2  ::  test account 2
    `account`[%asset-account 0x5678 0 (malt ~[[zigs-id z]])]
  =/  a3  ::  test mint account 
    `account`[%minter-account 0x1234 0 (silt ~[[0x1234]]) max=1.000 total=0]
  :-  0x0  ::  test state hash
  (malt ~[[0x1 a1] [0x2 a2] [0x3 a3]])
++  test-mint
  =/  t
    :*  %mint
        ::  a1(owner of minter-account) paying feerate of 10
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        0x3
        ::  sending 100 'bigs' each to a1 and a2
        ::  sending 2 assets so 10*2 = fee
        :~  [0x1 [%tok 100]]
            [0x2 [%tok 100]]
        ==
    ==
  =/  output  (process-tx t build-mint-test-state)
  =/  correct-fee  20
  =/  correct-state
    :*  0x0
        %-  malt
        :~  [0x1 `account`[%asset-account 0x1234 1 (malt ~[[zigs-id [%tok zigs-id 980]] [0x3 [%tok 0x3 100]]])]]
            [0x2 `account`[%asset-account 0x5678 0 (malt ~[[zigs-id [%tok zigs-id 1.000]] [0x3 [%tok 0x3 100]]])]]
            [0x3 `account`[%minter-account 0x1234 0 (silt ~[[0x1234]]) 1.000 200]]
        ==
    ==
  (expect-eq !>((some [correct-fee correct-state])) !>(output))
  ::++  test-mint-nft
  :: =/  test-nft
  ::   [%nft uri='some data' hash=`@ux`(shax 'some data') can-xfer=%.y]
  :: =/  t
  ::   :*  %mint
  ::       :: owner of mint account
  ::       [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
  ::       :: minting-account
  ::       0x3
  ::       :: assets to mint and to whom
  ::       ~[[0x2 test-nft]]
  ::   ==
  :: =/  output  (process-tx t build-send-test-state)
  :: =/  correct-fee  10
  :: ::  charge the sender acct
  :: =/  correct-state  (insert-asset 0x1 [%tok 0x0 990] build-send-test-state)
  :: =.  correct-state  (remove-asset 0x1 (shax 'some data') correct-state)
  :: =.  correct-state  (insert-asset 0x4 test-nft correct-state)
  :: =.  correct-state  (increment-nonce 0x1 correct-state)
  :: (expect-eq !>((some [correct-fee (some correct-state)])) !>(output))
--
