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
    `asset`[%fung minter=zigs-id amount=1.000]  ::  these are 'zigs'
  =/  f
    `asset`[%fung minter=figs-id amount=1.000]
  =/  b
    `asset`[%fung minter=bigs-id amount=500.000]
  =/  nft
    ^-  asset
    :*  %nft
        minter=nft-id
        uri='some data'
        hash=`@ux`(shax 'some data')
        can-xfer=%.y
    ==
  =/  a1  ::  test account 1
    ^-  account
    :*  %asset-account
        owner=0x1234
        nonce=0
        assets=(malt ~[[zigs-id z] [figs-id f] [bigs-id b] [`@ux`(shax 'some data') nft]])
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
        %fung
      (~(put by assets.their-acct) minter.asset asset)
    ==
  =.  accts.state
    (~(put by accts.state) who their-acct)
  state
::
++  remove-asset
  |=  [who=account-id =id =state]
  ^+  state
  =/  their-acct  (~(got by accts.state) who)
  ?>  ?=([%asset-account *] their-acct)
  =.  assets.their-acct
    (~(del by assets.their-acct) id)
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
        ~[[%fung 0x0 500]]
    ==
  =/  output  (process-tx t build-send-test-state)
  ::  a1 less 510 zigs, a2 plus 500
  ::  a1 nonce ++
  =/  correct-state  (insert-asset 0x1 [%fung 0x0 490] build-send-test-state)
  =.  correct-state  (insert-asset 0x2 [%fung 0x0 1.500] correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>((some correct-state)) !>(output))
++  test-send-2-assets
  =/  t
    :*  %send
        ::  a1 paying feerate of 10, fee=10*2
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  a1 sending 500 zigs and 50 figs to a2
        0x2
        ~[[%fung 0x0 500] [%fung 0xf 50]]
    ==
  =/  output  (process-tx t build-send-test-state)
  =/  correct-state  (insert-asset 0x1 [%fung 0x0 480] build-send-test-state)
  =.  correct-state  (insert-asset 0x2 [%fung 0x0 1.500] correct-state)
  =.  correct-state  (insert-asset 0x1 [%fung 0xf 950] correct-state)
  =.  correct-state  (insert-asset 0x2 [%fung 0xf 1.050] correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>((some correct-state)) !>(output))
++  test-send-fung-and-nft
  =/  t
    :*  %send
        ::  a1 paying feerate of 10, fee=10*2
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  a1 sending 10 zigs to a4 and nft
        0x4
        ~[[%fung 0x0 10] [%nft 0xa uri='some data' hash=`@ux`(shax 'some data') can-xfer=%.y]]
    ==
  =/  output  (process-tx t build-send-test-state)
  =/  correct-state  (insert-asset 0x1 [%fung 0x0 970] build-send-test-state)
  =.  correct-state  (insert-asset 0x4 [%fung 0x0 1.010] correct-state)
  =.  correct-state  (remove-asset 0x1 `@ux`(shax 'some data') correct-state)
  =.  correct-state  (insert-asset 0x4 [%nft 0xa uri='some data' hash=`@ux`(shax 'some data') can-xfer=%.y] correct-state)
  =.  correct-state  (increment-nonce 0x1 correct-state)
  (expect-eq !>((some correct-state)) !>(output))
++  test-send-nft
  (expect-eq !>(%.y) !>(%.n))
++  test-send-untransferrable-nft
  ::  should fail
  (expect-eq !>(%.y) !>(%.n))
++  test-send-no-zigs
  ::  should fail
  (expect-eq !>(%.y) !>(%.n))
++  test-send-no-asset
  ::  should fail
  (expect-eq !>(%.y) !>(%.n))
++  test-send-same-asset-twice
  ::  should fail
  (expect-eq !>(%.y) !>(%.n))
++  test-send-part-fail
  ::  should fail
  (expect-eq !>(%.y) !>(%.n))
++  test-send-all-fail
  ::  should fail
  (expect-eq !>(%.y) !>(%.n))
++  test-send-nonexistent-sender
  ::  should fail
  (expect-eq !>(%.y) !>(%.n))
++  test-send-nonexistent-receiver
  (expect-eq !>(%.y) !>(%.n))
++  test-send-to-minter
  ::  should fail
  (expect-eq !>(%.y) !>(%.n))
::
::  tests for %mint txs
::
++  build-mint-test-state
  ^-  state
  =/  z
    [%fung zigs-id 1.000]  ::  these are 'zigs'
  =/  b
    [%fung 0x3 100]  ::  these are 'bigs', created by a3
  =/  a1  ::  test account 1
    `account`[%asset-account 0x1234 0 (malt ~[[zigs-id z]])]
  =/  a2  ::  test account 2
    `account`[%asset-account 0x5678 0 (malt ~[[zigs-id z]])]
  =/  a3  ::  test mint account 
    `account`[%minter-account 0x1234 0 max=1.000 total=0]
  :-  0x0  ::  test state hash
  (malt ~[[0x1 a1] [0x2 a2] [0x3 a3]])
++  test-mint
  =/  t
    :*  %mint
        ::  a1(owner of minter-account) paying feerate of 10
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        ::  sending 100 'bigs' each to a1 and a2
        ::  sending 2 assets so 10*2 = fee
        :~  [0x1 [%fung 0x3 100]]
            [0x2 [%fung 0x3 100]]
        ==        
    ==
  =/  output  (process-tx t build-mint-test-state)
  =/  correct-state
    ^-  (unit state)
    %-  some
    :*  0x0
        %-  malt
        :~  [0x1 `account`[%asset-account 0x1234 1 (malt ~[[zigs-id [%fung zigs-id 980]] [0x3 [%fung 0x3 100]]])]]
            [0x2 `account`[%asset-account 0x5678 0 (malt ~[[zigs-id [%fung zigs-id 1.000]] [0x3 [%fung 0x3 100]]])]]
            [0x3 `account`[%minter-account 0x1234 0 1.000 200]]
        ==
    ==
  (expect-eq !>(correct-state) !>(output))
--
