/-  *tx
/+  *test, *add-tx
|%
++  zigs-id  0x0
++  figs-id  0xffff
++  build-send-test-state
  ^-  state
  =/  z
    [%fung zigs-id 1.000]  ::  these are 'zigs'
  =/  f
    [%fung figs-id 1.000]
  =/  a1  ::  test account 1
    [%asset-account 0x1234 0 (malt ~[[zigs-id z] [figs-id f]])]
  =/  a2  ::  test account 2
    [%asset-account 0x5678 0 (malt ~[[zigs-id z] [figs-id f]])]
  :-  0x0  ::  test state hash
  (malt ~[[0x1 a1] [0x2 a2]])
++  test-send
  =/  t
    :*  %send
        ::  a1 paying feerate of 10
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        0x2
        ::  a1 sending 500 zigs to a2
        ~[[%fung zigs-id 500]]
    ==
  =/  output  (process-tx t build-send-test-state)
  =/  correct-state
    ^-  (unit state)
    %-  some
    :*  0x0
        %-  malt 
        :~  [0x1 [%asset-account 0x1234 1 (malt ~[[zigs-id [%fung zigs-id 490]] [figs-id [%fung figs-id 1.000]]])]]
            [0x2 [%asset-account 0x5678 0 (malt ~[[zigs-id [%fung zigs-id 1.500]] [figs-id [%fung figs-id 1.000]]])]]
        ==
    ==
  (expect-eq !>(correct-state) !>(output))
++  test-send-2-assets
  =/  t
    :*  %send
        ::  a1 paying feerate of 10
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        0x2
        ::  a1 sending 500 zigs to a2 and 50 'figs'
        ~[[%fung zigs-id 500] [%fung 0xffff 50]]
    ==
  =/  output  (process-tx t build-send-test-state)
  =/  correct-state
    ^-  (unit state)
    %-  some
    :*  0x0
        %-  malt
        :~  [0x1 [%asset-account 0x1234 1 (malt ~[[zigs-id [%fung zigs-id 490]] [figs-id [%fung figs-id 950]]])]]
            [0x2 [%asset-account 0x5678 0 (malt ~[[zigs-id [%fung zigs-id 1.500]] [figs-id [%fung figs-id 1.050]]])]]
        ==
    ==
  (expect-eq !>(correct-state) !>(output))
++  test-send-3-assets
  (expect-eq !>(%.y) !>(%.n))
++  test-send-fung-and-nft
  (expect-eq !>(%.y) !>(%.n))
++  test-send-nft
  (expect-eq !>(%.y) !>(%.n))
++  test-send-wrong-nft
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
++  build-mint-test-state
  ^-  state
  =/  z
    [%fung zigs-id 1.000]  ::  these are 'zigs'
  =/  a1  ::  test account 1
    `account`[%asset-account 0x1234 0 (malt ~[[zigs-id z]])]
  =/  a2  ::  test account 2
    `account`[%asset-account 0x5678 0 (malt ~[[zigs-id z]])]
  =/  a3  ::  test mint account 
    `account`[%minter-account 0xbbbb 0 max=1.000 total=0]
  :-  0x0  ::  test state hash
  (malt ~[[0x1 a1] [0x2 a2] [0x3 a3]])
++  test-mint
  =/  t
    :*  %mint
        ::  a3(minter-account) paying feerate of 10
        [0x3 1 0xbbbb [0xaa 0xbb %ecdsa] 10]
        ::  sending 100 'bigs' each to a1 and a2
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
        :~  [0x1 `account`[%asset-account 0x1234 0 (malt ~[[zigs-id [%fung zigs-id 1.000]] [0x3 [%fung 0x3 100]]])]]
            [0x2 `account`[%asset-account 0x5678 0 (malt ~[[zigs-id [%fung zigs-id 1.000]] [0x3 [%fung 0x3 100]]])]]
            [0x3 `account`[%minter-account 0xbbbb 1 1.000 200]]
        ==
    ==
  (expect-eq !>(correct-state) !>(output))
--
