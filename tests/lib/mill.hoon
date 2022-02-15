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
/=  trivial        /lib/zig/contracts/trivial
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
        zigs-wheat-id:std   ::  lord
        0xaa    ::  holder
        0                   ::  town-id
        [%& rice]           ::  germ
    ==
  ++  wheat
    ^-  wheat:std
    :-  `zigs-contract
    (silt ~[zigs-rice-id:std])
  ++  wheat-grain
    ^-  grain:std
    :*  zigs-wheat-id:std   ::  id
        zigs-wheat-id:std   ::  lord
        zigs-wheat-id:std   ::  holder
        0                   ::  town-id
        [%| wheat]          ::  germ
    ==
  ++  trivial-grain
    ^-  grain:std
    :*  0x3
        0x3
        0x3
        0
        [%| [`trivial ~]]
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
          [0x3 trivial-grain]
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
    [[0xaa 1] `[%give 0xbb 69 500] (silt [~[zigs-rice-id:std]])]
  =/  shel
    [[0xaa 1] zigs-wheat-id:std rate=1 budget=500 town-id=0]
  =/  egg  [shel yok]
  =/  res  (~(mill mill 0xabcd 0) fake-town:zigs egg 100)
  ::  can't just check the whole town,
  ::  best thing to do is check the zigs data
  =/  loach
    ;;(zigs-mold:zigs +.+.germ:(~(got by p.res) zigs-rice-id:std))
  =/  squid  rice-data:zigs
  ::  this manually performs the changes that the
  ::  zig contract should be doing. not great
  =.  balances.squid
    %+  %~  jab  by
      %+  %~  jab  by
        (~(put by balances.squid) [0xabcd 0])
          0xbb
        |=(bal=@ud (add bal 69))
      0xaa
    |=(bal=@ud (sub bal 69))
  (expect-eq !>(squid) !>(loach))
++  test-zigs-failed-give
  =/  yok
    [[0xaa 1] `[%give 0xbb 1.200 500] (silt [~[zigs-rice-id:std]])]
  =/  shel
    [[0xaa 1] zigs-wheat-id:std rate=1 budget=500 town-id=0]
  =/  egg  [shel yok]
  =/  res  (~(mill mill 0xabcd 0) fake-town:zigs egg 100)
  =/  loach
    ;;(zigs-mold:zigs +.+.germ:(~(got by p.res) zigs-rice-id:std))
  =/  squid  rice-data:zigs
  =.  balances.squid
    (~(put by balances.squid) [0xabcd 0])
  (expect-eq !>(squid) !>(loach))
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