/-  *tx
/+  *test, *add-tx
|%
::
::  helpers
::
++  build-test-state
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
        ::  nonce=0
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
++  edit-acct
  |=  [who=account-id new=account =state]
  ^+  state
  state(accts (~(put by accts.state) who new))
++  increment-nonce
  |=  [who=account-id =state]
  ^+  state
  =/  their-acct  (~(got by accts.state) who)
  ?>  ?=([%asset-account *] their-acct)
  =.  nonce.their-acct
    (succ nonce.their-acct)
  =.  accts.state
    (~(put by accts.state) who their-acct)
  state
::
::  tests for txs in general
::
++  test-tx-bad-sender
  =/  t
    :*  %send
        [0xfff 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  sending 500 zigs from bad account to a2
        0x2
        (malt ~[[0x0 [%tok 0x0 500]]])
    ==
  =/  output  (process-tx t build-test-state)
  (expect-eq !>(~) !>(output))
++  test-tx-bad-nonce
  =/  t
    :*  %send
        ::  bad nonce
        [0x1 127 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  sending 500 zigs from a1 to a2
        0x2
        (malt ~[[0x0 [%tok 0x0 500]]])
    ==
  =/  output  (process-tx t build-test-state)
  (expect-eq !>(~) !>(output))
++  test-tx-from-minter
  =/  t
    :*  %send
        [0x3 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  sending 500 zigs from bad account to a2
        0x2
        (malt ~[[0x0 [%tok 0x0 500]]])
    ==
  =/  output  (process-tx t build-test-state)
  (expect-eq !>(~) !>(output))
++  test-tx-cant-cover-fee
  =/  t
    :*  %send
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  sending 2 assets but can't cover 20 fee
        0x2
        (malt ~[[0xf [%tok 0xf 500]] [0xb [%tok 0xb 1.000]]])
    ==
  =/  starting-state  (insert-asset 0x1 [%tok 0x0 19] build-test-state)
  =/  output  (process-tx t starting-state)
  (expect-eq !>(~) !>(output))
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
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  10
  ::  a1 less 510 zigs, a2 plus 500
  ::  a1 nonce ++
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 490] build-test-state)
  =.  correct-state  (insert-asset 0x2 [%tok 0x0 1.500] correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
++  test-send-2-assets
  =/  t
    :*  %send
        ::  a1 paying feerate of 10, fee=10*2
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  a1 sending 500 zigs and 50 figs to a2
        0x2
        (malt ~[[0x0 [%tok 0x0 500]] [0xf [%tok 0xf 50]]])
    ==
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 480] build-test-state)
  =.  correct-state  (insert-asset 0x2 [%tok 0x0 1.500] correct-state)
  =.  correct-state  (insert-asset 0x1 [%tok 0xf 950] correct-state)
  =.  correct-state  (insert-asset 0x2 [%tok 0xf 1.050] correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
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
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  10
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 990] build-test-state)
  =.  correct-state  (remove-asset 0x1 (shax 'some data') correct-state)
  =.  correct-state  (insert-asset 0x4 test-nft correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
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
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 970] build-test-state)
  =.  correct-state  (insert-asset 0x4 [%tok 0x0 1.010] correct-state)
  =.  correct-state  (remove-asset 0x1 (shax 'some data') correct-state)
  =.  correct-state  (insert-asset 0x4 test-nft correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
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
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  10
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 990] build-test-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
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
    (insert-asset 0x1 [%tok 0x0 9] build-test-state)
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
    (insert-asset 0x1 [%tok 0xf 49] build-test-state)
  =/  output  (process-tx t starting-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 980] starting-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
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
    (remove-asset 0x1 0xf build-test-state)
  =/  output  (process-tx t starting-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 980] starting-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
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
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 480] build-test-state)
  =.  correct-state  (insert-asset 0x1 [%tok 0xf 980] correct-state)
  =.  correct-state  (insert-asset 0x2 [%tok 0x0 1.500] correct-state)
  =.  correct-state  (insert-asset 0x2 [%tok 0xf 1.020] correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
++  test-send-part-fail
  =/  t
    :*  %send
        ::  a1 paying feerate of 10, fee=10*3
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  a1 sending 500 zigs and 50 figs to a2
        0x2
        (malt ~[[0x0 [%tok 0x0 500]] [0xf [%tok 0xf 1.000]] [0xb [%tok 0xb 1.000.000]]])
    ==
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  30
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 970] build-test-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
++  test-send-all-fail
  =/  t
    :*  %send
        ::  a1 paying feerate of 10, fee=10*3
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  a1 sending 500 zigs and 50 figs to a2
        0x2
        (malt ~[[0x0 [%tok 0x0 1.000]] [0xf [%tok 0xf 2.000]] [0xb [%tok 0xb 1.000.000]]])
    ==
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  30
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 970] build-test-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
++  test-send-to-minter
  =/  t
    :*  %send
        ::  a1 paying feerate of 10, fee=10*3
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  a1 sending 500 zigs and 50 figs to a3 (minter)
        0x3
        (malt ~[[0x0 [%tok 0x0 500]] [0xf [%tok 0xf 500]]])
    ==
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 480] build-test-state)
  =.  correct-state  (insert-asset 0x1 [%tok 0xf 500] correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
::
::  TODO: not sure of the correct behavior here.
::  make a blank account to receive, or delete assets into the aether?
::  (currently doing latter)
::
++  test-send-nonexistent-receiver
  =/  t
    :*  %send
        ::  a1 paying feerate of 10, fee=10*2
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  a1 sending 500 zigs and 50 figs to nonexistent acct
        0xeee
        (malt ~[[0x0 [%tok 0x0 500]] [0xf [%tok 0xf 50]]])
    ==
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 480] build-test-state)
  =.  correct-state  (insert-asset 0x1 [%tok 0xf 950] correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
++  test-send-nonexistent-sender
  =/  t
    :*  %send
        ::  nonexistent account
        [0xeee 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  sending 500 zigs to a2
        0x2
        (malt ~[[0x0 [%tok 0x0 500]]])
    ==
  =/  output  (process-tx t build-test-state)
  (expect-eq !>(~) !>(output))
::
::  tests for %mint txs
::
++  test-mint-tok
  =/  t
    :*  %mint
        ::  a1(owner of minter-account) paying feerate of 10
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        0x3
        ::  sending 100 tokens each to a1 and a2
        ::  sending 2 assets so 10*2 = fee
        :~  [0x1 [%tok 100]]
            [0x2 [%tok 100]]
        ==
    ==
  =/  updated-minter
    :*  %minter-account
        owner=0x1234
        whitelist=(silt ~[[0x1234]])
        max=1.000
        total=200
    ==
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x1 [%tok 0x3 100] build-test-state)
  =.  correct-state  (insert-asset 0x2 [%tok 0x3 100] correct-state)
  =.  correct-state  (insert-asset 0x1 [%tok 0x0 980] correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  =.  correct-state  (edit-acct 0x3 updated-minter correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
++  test-mint-to-nonexistent
  =/  t
    :*  %mint
        ::  a1(owner of minter-account) paying feerate of 10
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        0x3
        ::  sending 100 tokens each to a1 and a2
        ::  sending 200 to account not in state
        ::  sending 3 assets so 10*3 = fee
        :~  [0x1 [%tok 100]]
            [0x2 [%tok 100]]
            [0xeee [%tok 200]]
        ==
    ==
  =/  updated-minter
    :*  %minter-account
        owner=0x1234
        whitelist=(silt ~[[0x1234]])
        max=1.000
        total=400
    ==
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  30
  =/  correct-state  (insert-asset 0x1 [%tok 0x3 100] build-test-state)
  =.  correct-state  (insert-asset 0x2 [%tok 0x3 100] correct-state)
  =.  correct-state  (insert-asset 0x1 [%tok 0x0 970] correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  =.  correct-state  (edit-acct 0x3 updated-minter correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
++  test-mint-nfts
  =/  minting-nft
    [%nft uri='0' hash=`@ux`(shax '0') can-xfer=%.y]
  =/  nft-0
    :*  %nft
        minter=0x3
        id=0
        uri='0'
        hash=`@ux`(shax '0')
        can-xfer=%.y
    ==
  =/  nft-1
    nft-0(id 1)
  =/  t
    :*  %mint
        ::  a1(owner of minter-account) paying feerate of 10
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        0x3
        ::  sending 1 nft to a1 and a2
        ::  sending 2 assets so 10*2 = fee
        :~  [0x1 minting-nft]
            [0x2 minting-nft]
        ==
    ==
  =/  updated-minter
    :*  %minter-account
        owner=0x1234
        whitelist=(silt ~[[0x1234]])
        max=1.000
        total=2
    ==
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x1 nft-0 build-test-state)
  =.  correct-state  (insert-asset 0x2 nft-1 correct-state)
  =.  correct-state  (insert-asset 0x1 [%tok 0x0 980] correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  =.  correct-state  (edit-acct 0x3 updated-minter correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
++  test-mint-exact-max
  =/  t
    :*  %mint
        ::  a1(owner of minter-account) paying feerate of 10
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        0x3
        ::  sending 100 tokens each to a1 and a2
        ::  sending 2 assets so 10*2 = fee
        :~  [0x1 [%tok 500]]
            [0x2 [%tok 500]]
        ==
    ==
  =/  updated-minter
    :*  %minter-account
        owner=0x1234
        whitelist=(silt ~[[0x1234]])
        max=1.000
        total=1.000
    ==
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x1 [%tok 0x3 500] build-test-state)
  =.  correct-state  (insert-asset 0x2 [%tok 0x3 500] correct-state)
  =.  correct-state  (insert-asset 0x1 [%tok 0x0 980] correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  =.  correct-state  (edit-acct 0x3 updated-minter correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
++  test-mint-too-many
  =/  t
    :*  %mint
        ::  a1(owner of minter-account) paying feerate of 10
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        0x3
        ::  sending 2 assets so 10*2 = fee
        :~  [0x1 [%tok 501]]
            [0x2 [%tok 500]]
        ==
    ==
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x1 [%tok 0x0 980] build-test-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
++  test-mint-not-on-whitelist
  =/  t
    :*  %mint
        ::  a2(NOT on whitelist of minter-account) paying feerate of 10
        [0x2 1 0x5678 [0xaa 0xbb %ecdsa] 10]
        0x3
        ::  sending 2 assets so 10*2 = fee
        :~  [0x1 [%tok 501]]
            [0x2 [%tok 500]]
        ==
    ==
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x2 [%tok 0x0 980] build-test-state)
  =.  correct-state  (increment-nonce 0x2 correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
++  test-mint-no-minter
  =/  t
    :*  %mint
        [0x2 1 0x5678 [0xaa 0xbb %ecdsa] 10]
        0xeee  ::  (no such minter)
        ::  sending 2 assets so 10*2 = fee
        :~  [0x1 [%tok 501]]
            [0x2 [%tok 500]]
        ==
    ==
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x2 [%tok 0x0 980] build-test-state)
  =.  correct-state  (increment-nonce 0x2 correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
::
::  %lone-mint tests
::
++  test-lone-mint-tok
  =/  from
    [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
  =/  new-id
    (generate-account-id from)
  =/  t
    :*  %lone-mint
        ::  a1(owner of minter-account) paying feerate of 10
        from
        ::  sending 100 tokens each to a1 and a2
        ::  sending 2 assets so 10*2 = fee
        :~  [0x1 [%tok 100]]
            [0x2 [%tok 100]]
        ==
    ==
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x1 [%tok new-id 100] build-test-state)
  =.  correct-state  (insert-asset 0x2 [%tok new-id 100] correct-state)
  =.  correct-state  (insert-asset 0x1 [%tok 0x0 980] correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  =.  correct-state  (edit-acct new-id [%blank-account ~] correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
++  test-lone-mint-to-nonexistent
  =/  from
    [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
  =/  new-id
    (generate-account-id from)
  =/  t
    :*  %lone-mint
        ::  a1(owner of minter-account) paying feerate of 10
        from
        ::  sending 100 tokens each to a1 and a2
        ::  sending 200 to account not in state
        ::  sending 3 assets so 10*3 = fee
        :~  [0x1 [%tok 100]]
            [0x2 [%tok 100]]
            [0xeee [%tok 200]]
        ==
    ==
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  30
  =/  correct-state  (insert-asset 0x1 [%tok new-id 100] build-test-state)
  =.  correct-state  (insert-asset 0x2 [%tok new-id 100] correct-state)
  =.  correct-state  (insert-asset 0x1 [%tok 0x0 970] correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  =.  correct-state  (edit-acct new-id [%blank-account ~] correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
++  test-lone-mint-nft
  =/  from
    [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
  =/  new-id
    (generate-account-id from)
  =/  minting-nft
    [%nft uri='0' hash=`@ux`(shax '0') can-xfer=%.y]
  =/  nft-0
    :*  %nft
        minter=new-id
        id=0
        uri='0'
        hash=`@ux`(shax '0')
        can-xfer=%.y
    ==
  =/  nft-1
    nft-0(id 1)
  =/  t
    :*  %lone-mint
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  sending 1 nft to a1 and a2
        ::  sending 2 assets so 10*2 = fee
        :~  [0x1 minting-nft]
            [0x2 minting-nft]
        ==
    ==
  =/  output  (process-tx t build-test-state)
  =/  correct-fee  20
  =/  correct-state  (insert-asset 0x1 nft-0 build-test-state)
  =.  correct-state  (insert-asset 0x2 nft-1 correct-state)
  =.  correct-state  (insert-asset 0x1 [%tok 0x0 980] correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  =.  correct-state  (edit-acct new-id [%blank-account ~] correct-state)
  (expect-eq !>([~ [correct-fee correct-state]]) !>(output))
--
