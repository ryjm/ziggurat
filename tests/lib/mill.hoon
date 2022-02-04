::
::  Tests for lib/zig/mill.hoon
::  Basic goal: construct a simple granary / helix state
::  and manipulate it with some calls to our zigs contract.
::  Mill should handle clearing a mempool populated by
::  calls and return an updated granary. The zigs contract
::  should manage transactions properly so this is testing
::  the arms of that contract as well.
::
/-  *mill
/+  *test, *zig-mill, *tiny, *zig-contracts-zigs
/=  zigs-contract  /lib/zig/contracts/zigs
/=  tgas-contract  /lib/zig/contracts/test-good-altcoin
|%
++  zigs
  |%
  ++  user-balances
    ^-  (map id @ud)
    %-  ~(gas ^by *(map id @ud))
    :: %-  ~(gas by *(map id @ud))
    :~  [0xaa 1.000]
        [0xbb 1.000]
        [0xcc 500]
        [0xdd 500]
        [0xee 490]
        [0xff 10]
    ==
  ++  user-allowances
    ^-  (map [owner=id sender=id] @ud)
    %-  ~(gas ^by *(map [owner=id sender=id] @ud))
    :: %-  ~(gas by *(map [owner=id sender=id] @ud))
    :~  [[0xaa 0xbb] 100]
        [[0xee 0xff] 100]
    ==
  ++  rice-data
    ^-  token-data
    :*  total=3.500
        balances=user-balances
        allowances=user-allowances
        coinbase-rate=50  ::  # of tokens granted in +coinbase
    ==
  ++  rice
    ^-  rice  :: need to be `^rice`?
    :*  zigs-rice-id  ::  id/holder/lord
        zigs-rice-id
        zigs-wheat-id
        0             ::  helix 0
        rice-data
        ~  ::  doesn't hold any other rice
    ==
  ++  wheat
    ^-  wheat  :: need to be `^wheat`?
    :+  zigs-wheat-id
      zigs-wheat-id
    `zigs-contract
  ++  fake-town
    ^-  town
    (~(gas by *(map @ud granary)) ~[[0 fake-granary]])
  ++  fake-granary
    ^-  granary
    =/  grains=(list (pair id grain))
      :~  [zigs-wheat-id %| wheat]
          [zigs-rice-id %& rice]
      ==
    :-  (~(gas ^by *(map id grain)) grains)
    :: :-  (~(gas by *(map id grain)) grains)
    (malt ~[[0xaa 0] [0xbb 0] [0xcc 0]])
++  tgas
  ++  user-balances
    ^-  (map id @ud)
    %-  ~(gas ^by *(map id @ud))
    :: %-  ~(gas by *(map id @ud))
    :~  [0xaa 1.000]
        [0xbb 1.000]
        [0xcc 500]
        [0xdd 500]
        [0xee 490]
        [0xff 10]
    ==
  ++  user-allowances
    ^-  (map [owner=id sender=id] @ud)
    %-  ~(gas ^by *(map [owner=id sender=id] @ud))
    :: %-  ~(gas by *(map [owner=id sender=id] @ud))
    :~  [[0xaa 0xbb] 100]
        [[0xee 0xff] 100]
    ==
  ++  rice-data
    ^-  token-data
    :*  total=3.500
        balances=user-balances
        allowances=user-allowances
        coinbase-rate=50  ::  # of tokens granted in +coinbase
    ==
  ++  rice
    ^-  rice
    :*  tgas-rice-id  ::  id/holder/lord
        tgas-rice-id
        tgas-wheat-id
        0             ::  helix 0
        rice-data
        ~  ::  doesn't hold any other rice
    ==
  ++  wheat
    ^-  wheat
    :+  tgas-wheat-id
      tgas-wheat-id
    `tgas-contract
  ++  fake-town
    ^-  town
    (~(gas by *(map @ud granary)) ~[[0 fake-granary]])
  ++  fake-granary
    ^-  granary
    =/  grains=(list (pair id grain))
      :~  [zigs-wheat-id %| wheat:zigs]
          [zigs-rice-id %& rice:zigs]
          [tgas-wheat-id %| wheat]
          [tgas-rice-id %& rice]
      ==
    :-  (~(gas ^by *(map id grain)) grains)
    :: :-  (~(gas by *(map id grain)) grains)
    (malt ~[[0xaa 0] [0xbb 0] [0xcc 0]])
  ++  tgas-wheat-id
    ^-  id
    0x2
  ++  tgas-rice-id
    ^-  id
    0x3
++  test-zigs-basic-give
  =/  write
     [%write [0xaa 1] (silt ~[zigs-rice-id]) [~ [%give 0xbb 200 500]]]
  =/  call
    [[0xaa 1] zigs-wheat-id rate=1 budget=500 town-id=0 write]
  =/  res=granary
    (mill 0 fake-granary:zigs call)
  ::  what's the best way to create a correct updated granary to check against?
  ::  also need to calculate exact fee to get proper outcome
  (expect-eq !>(~) !>(res))
++  test-zigs-failed-give
  =/  write
     [%write [0xaa 1] (silt ~[zigs-rice-id]) [~ [%give 0xbb 2.000 500]]]
  =/  call
    [[0xaa 1] zigs-wheat-id rate=1 budget=500 town-id=0 write]
  =/  res=granary
    (mill 0 fake-granary:zigs call)
  ::  updated granary should be same but minus 0xaa's fee
  (expect-eq !>(~) !>(res))
++  test-mill-tgas-basic-give
  =/  write
     [%write [0xaa 1] (silt ~[tgas-rice-id:tgas]) [~ [%give 0xbb 200 500]]]
  =/  call
    [[0xaa 1] tgas-wheat-id:tgas rate=1 budget=500 town-id=0 write]
  =/  res=granary
    (mill 0 fake-granary:tgas call)
  ::  what's the best way to create a correct updated granary to check against?
  ::  also need to calculate exact fee to get proper outcome
  (expect-eq !>(~) !>(res))
::
::  Tests here should cover:
::  (all calls to exclusively zigs-contract)
::
::  * executing a single call with +mill
::  * executing same call unsuccessfully -- not enough gas
::  * unsuccessfully -- some constraint in contract unfulfilled
::  * (test all constraints in contract: balance, gas, +give, etc)
::  * executing multiple calls with +mill-all
::
::  Tests for contracts on mill in general
::  (probably good in a separate file / test suite)
::  These will be more involved, requiring custom contracts w
::
::  * test deploying a contract (successful / unsuccessful du
::  * bad: call a contract that issues rice as wheat, vice ve
::  * rule breaking: call contracts that break their lord per
::    (aka: writing to rice that they don't own, cheating)
::  * good: call contract that reads things from other contra
::
--
