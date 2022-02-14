::
::  Tests for lib/zig/mill.hoon
::  Basic goal: construct a simple granary / helix state
::  and manipulate it with some calls to our zigs contract.
::  Mill should handle clearing a mempool populated by
::  calls and return an updated granary. The zigs contract
::  should manage transactions properly so this is testing
::  the arms of that contract as well.
::
/+  *test, *zig-mill, std=zig-sys-smart, *zig-contracts-zigs
/=  zigs-contract  /lib/zig/contracts/zigs
/=  tgas-contract  /lib/zig/contracts/test-good-altcoin
|%
++  zigs
  |%
  +$  zigs-mold
    $:  total=@ud
        balances=(map:std id:std @ud)
        allowances=(map:std [owner=id:std sender=id:std] @ud)
        coinbase-rate=@ud
    ==
  ++  user-balances
    ^-  (map:std id:std @ud)
    %-  ~(gas by:std *(map:std id:std @ud))
    :~  [0xaa 1.000]
        [0xbb 1.000]
        [0xcc 500]
        [0xdd 500]
        [0xee 490]
        [0xff 10]
    ==
  ++  user-allowances
    ^-  (map:std [owner=id:std sender=id:std] @ud)
    %-
      %~  gas  by:std
      *(map:std [owner=id:std sender=id:std] @ud)
    :~  [[0xaa 0xbb] 100]
        [[0xee 0xff] 100]
    ==
  ++  rice-data
    ^-  zigs-mold
    :*  total=3.500
        balances=user-balances
        allowances=user-allowances
        coinbase-rate=50  ::  # of tokens granted in +coinbase
    ==
  ++  rice
    ^-  rice:std
    :-  ~                   ::  format
    rice-data               ::  data
  ++  rice-grain
    ^-  grain:std
    :*  zigs-rice-id:std    ::  id
        zigs-rice-id:std    ::  lord
        zigs-rice-id:std    ::  holder
        0                   ::  town-id
        [%& rice]           ::  germ
    ==
  ++  wheat
    ^-  wheat:std
    `zigs-contract
  ++  wheat-grain
    ^-  grain:std
    :*  zigs-wheat-id:std   ::  id
        zigs-wheat-id:std   ::  lord
        zigs-wheat-id:std   ::  holder
        0                   ::  town-id
        [%| wheat]          ::  germ
    ==
  ++  fake-land
    ^-  land:std
    (~(gas by:std *(map @ud town:std)) ~[[0 fake-town]])
  ++  fake-town
    ^-  town:std
    [fake-granary fake-populace]
  ++  fake-granary
    ^-  granary:std
    =/  grains=(list:std (pair:std id:std grain:std))
      :~  [zigs-wheat-id:std wheat-grain]
          [zigs-rice-id:std rice-grain]
      ==
    (~(gas by:std *(map:std id:std grain:std)) grains)
  ++  fake-populace
    ^-  populace:std
    %-  %~  gas  by:std  *(map:std id:std @ud)
    ~[[0xaa 0] [0xbb 0] [0xcc 0]]
  --
::  ++  tgas
  ::    |%
  ::    ++  user-balances
  ::      ^-  (map:std id:std @ud)
  ::      %-  ~(gas by:std *(map:std id:std @ud))
  ::      :~  [0xaa 1.000]
  ::          [0xbb 1.000]
  ::          [0xcc 500]
  ::          [0xdd 500]
  ::          [0xee 490]
  ::          [0xff 10]
  ::      ==
  ::    ++  user-allowances
  ::      ^-  (map:std [owner=id:std sender=id:std] @ud)
  ::      %-
  ::        %~  gas  by:std
  ::        *(map:std [owner=id:std sender=id:std] @ud)
  ::      :~  [[0xaa 0xbb] 100]
  ::          [[0xee 0xff] 100]
  ::      ==
  ::    ++  rice-data
  ::      :*  total=3.500
  ::          balances=user-balances
  ::          allowances=user-allowances
  ::          coinbase-rate=50  ::  # of tokens granted in +coinbase
  ::      ==
  ::    ++  rice
  ::      ^-  rice:std
  ::      :+  zigs-rice-id:std   ::  holder
  ::        ~                     ::  holds
  ::      rice-data               ::  data
  ::    ++  rice-grain
  ::      ^-  grain:std
  ::      :*  tgas-rice-id        ::  id
  ::          tgas-rice-id        ::  lord
  ::          0                   ::  town-id
  ::          [%& rice]           ::  germ
  ::      ==
  ::    ++  wheat
  ::      ^-  wheat:std
  ::      `tgas-contract
  ::    ++  wheat-grain
  ::      ^-  grain:std
  ::      :*  tgas-wheat-id       ::  id
  ::          tgas-wheat-id       ::  lord
  ::          0                   ::  town-id
  ::          [%| wheat]          ::  germ
  ::      ==
  ::    ++  fake-land
  ::      ^-  land:std
  ::      (~(gas by:std *(map:std @ud town:std)) ~[[0 fake-town]])
  ::    ++  fake-town
  ::      ^-  town:std
  ::      [fake-granary fake-populace]
  ::    ++  fake-granary
  ::      ^-  granary:std
  ::      =/  grains=(list:std (pair:std id:std grain:std))
  ::        :~  [zigs-wheat-id:std wheat-grain:zigs]
  ::            [zigs-rice-id:std rice-grain:zigs]
  ::            [tgas-wheat-id wheat-grain]
  ::            [tgas-rice-id rice-grain]
  ::        ==
  ::      (~(gas by:std *(map:std id:std grain:std)) grains)
  ::    ++  fake-populace
  ::      ^-  populace:std
  ::      %-  %~  gas  by:std  *(map:std id:std @ud)
  ::      ~[[0xaa 0] [0xbb 0] [0xcc 0]]
  ::    ++  tgas-wheat-id
  ::      ^-  id:std
  ::      0x2
  ::    ++  tgas-rice-id
  ::      ^-  id:std
  ::      0x3
  ::    --
++  test-zigs-basic-give
  =/  yok
     :*  [0xaa 1]
         [%write ~ [%give 0xbb 200 500]]
         (silt [~[zigs-rice-id:std]]) 
     ==
  =/  shel
    [[0xaa 1] zigs-wheat-id:std rate=1 budget=500 town-id=0]
  =/  egg
    [shel yok]
  ~&  >  "seeking to mill"
  ~&  egg
  =/  res
    (~(mill mill 0xabcd 0) fake-town:zigs egg 100)
  ::~&  >>  res
  ~&  >  "done milling!"
  ::  what's the best way to create a correct updated granary to check against?
  ::  also need to calculate exact fee to get proper outcome
  (expect-eq !>(~) !>(~))
::  ++  test-zigs-failed-give
::    =/  write
::       :*  %write
::           [0xaa 1]
::           %-  %~  gas  in:std  *(set:std id:std)
::           ~[zigs-rice-id:std]
::           [~ [%give 0xbb 2.000 500]]
::       ==
::    =/  call
::      [[0xaa 1] zigs-wheat-id rate=1 budget=500 town-id=0 write]
::    =/  res=town:std
::      (mill 0 fake-town:zigs call)
::    ::  updated granary should be same but minus 0xaa's fee
::    (expect-eq !>(~) !>(res))
::  ++  test-mill-tgas-basic-give
::    =/  write
::       :*  %write
::           [0xaa 1]
::           %-  %~  gas  in:std  *(set:std id:std)
::           ~[tgas-rice-id:tgas]
::           [~ [%give 0xbb 200 500]]
::       ==
::    =/  call
::      [[0xaa 1] tgas-wheat-id:tgas rate=1 budget=500 town-id=0 write]
::    =/  res=town:std
::      (mill 0 fake-town:tgas call)
::    ::  what's the best way to create a correct updated granary to check against?
::    ::  also need to calculate exact fee to get proper outcome
::    (expect-eq !>(~) !>(res))
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