/-  *tx
/+  *test, *add-tx
|%
++  zigs-id  `@ux`0x0
++  build-test-state
  ^-  state
  =/  asset
    [%fung zigs-id 1.000]  ::  these are 'zigs'
  =/  a1  ::  test account 1
    [%asset-account 0x1234 0 (malt ~[[zigs-id asset]])]
  =/  a2  ::  test account 2
    [%asset-account 0x5678 0 (malt ~[[zigs-id asset]])]
  :: =/  a3  ::  test minter account
  ::   [0x5678 0 ~[asset]]
  :-  0x0  ::  test state hash
  (malt ~[[0x1 a1] [0x2 a2]])
++  test-send
  =/  t
    :*  %send
        ::  a1 paying feerate of 10
        [0x1 1 0x1234 [0xaa 0xbb %ecdsa] 10]
        0x2
        ::  a1 sending 5 zigs to a2
        ~[[%fung zigs-id 5]]
    ==
  ~&  >  (process-tx t build-test-state)
  :: ~&  state
  (expect-eq !>(%.y) !>(%.n))
++  test-send-2-assets
  (expect-eq !>(%.y) !>(%.n))
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
++  test-mint
  (expect-eq !>(%.y) !>(%.n))
--
