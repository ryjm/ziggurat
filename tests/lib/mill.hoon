::
::  Tests for lib/zig/mill.hoon
::  Basic goal: construct a simple granary / helix state
::  and manipulate it with some calls to our zigs contract.
::  Mill should handle clearing a mempool populated by
::  calls and return an updated granary. The zigs contract
::  should manage transactions properly so this is testing
::  the arms of that contract as well.
::
/+  *test, *zig-mill, std=zig-sys-smart, *zig-contracts-zigs-utxo
:: /=  zigs-contract  /lib/zig/contracts/zigs
/=  zigs-contract  /lib/zig/contracts/zigs-utxo
/=  tgas-contract  /lib/zig/contracts/test-good-altcoin
/=  multisig-contract  /lib/zig/contracts/multisig
|%
++  zigs-utxo
  |%
  ++  zigs-rice-grains
    ^-  (list (pair id:std grain:std))
    :~  [0xd.ead0 (rice-grain 0xd.ead0 0xdead 1.000)]
        [0xdea.dfee (rice-grain 0xdea.dfee 0xdead 1.000)]
        [0xb.eef0 (rice-grain 0xb.eef0 0xbeef 200)]
        [0xbee.ffee (rice-grain 0xbee.ffee 0xbeef 100)]
    ==
  ++  rice-data
    |=  amount=@ud
    `@ud`amount
  ++  rice
    |=  [holder=id:std amount=@ud]
    ^-  rice:std
    :+  holder          ::  holder
      ~                 ::  holds
    (rice-data amount)  ::  data
  ++  rice-grain
    |=  [=id:std holder=id:std amount=@ud]
    ^-  grain:std
    :*  id=id
        lord=zigs-wheat-id:std
        town-id=0
        germ=[%& (rice holder amount)]
    ==
  ++  zigs-wheat
    ^-  wheat:std
    `zigs-contract
  ++  zigs-wheat-grain
    ^-  grain:std
    :*  id=zigs-wheat-id:std
        lord=zigs-wheat-id:std
        town-id=0
        germ=[%| zigs-wheat]
    ==
  ++  fake-land
    ^-  land:std
    (~(gas by *(map @ud town:std)) ~[[0 fake-town]])
  ++  fake-town
    ^-  town:std
    [fake-granary fake-populace]
  ++  fake-granary
    ^-  granary:std
    =/  grains=(list (pair id:std grain:std))
      (weld ~[[zigs-wheat-id:std zigs-wheat-grain]] zigs-rice-grains)
    (~(gas by *(map id:std grain:std)) grains)
  ++  fake-populace
    ^-  populace:std
    %-  ~(gas by *(map id:std @ud))
    :~  [0xdead 0]
        [0xbeef 0]
    ==
  --
::
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
    :*  zigs-rice-id:std   ::  id
        zigs-wheat-id:std  ::  lord
        zigs-wheat-id:std  ::  holders
        0                  ::  town-id
        [%& rice]          ::  germ
    ==
  ++  wheat
    ^-  wheat:std
    :-  `zigs-contract
    (silt ~[zigs-rice-id:std])
  ++  wheat-grain
    ^-  grain:std
    :*  zigs-wheat-id:std  ::  id
        zigs-wheat-id:std  ::  lord
        zigs-wheat-id:std  ::  holders
        0                  ::  town-id
        [%| wheat]         ::  germ
    ==
  ++  multisig-grain
    ^-  grain:std
    :*  0x3
        0x3
        0x3
        0
        [%| [`multisig-contract ~]]
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
          [0x3 multisig-grain]
      ==
    (~(gas by:std *(map:std id:std grain:std)) grains)
  ++  fake-populace
    ^-  populace:std
    %-  %~  gas  by:std  *(map:std id:std @ud)
    ~[[0xaa 0] [0xbb 0] [0xcc 0]]
  --
::
:: ++  tgas
::   |%
::   ++  user-balances
::     ^-  (map:tiny id:tiny @ud)
::     %-  ~(gas by:tiny *(map:tiny id:tiny @ud))
::     :~  [0xaa 1.000]
::         [0xbb 1.000]
::         [0xcc 500]
::         [0xdd 500]
::         [0xee 490]
::         [0xff 10]
::     ==
::   ++  user-allowances
::     ^-  (map:tiny [owner=id:tiny sender=id:tiny] @ud)
::     %-
::       %~  gas  by:tiny
::       *(map:tiny [owner=id:tiny sender=id:tiny] @ud)
::     :~  [[0xaa 0xbb] 100]
::         [[0xee 0xff] 100]
::     ==
::   ++  rice-data
::     :*  total=3.500
::         balances=user-balances
::         allowances=user-allowances
::         coinbase-rate=50  ::  # of tokens granted in +coinbase
::     ==
::   ++  rice
::     ^-  rice:tiny
::     :+  zigs-rice-id:tiny   ::  holder
::       ~                     ::  holds
::     rice-data               ::  data
::   ++  rice-grain
::     ^-  grain:tiny
::     :*  tgas-rice-id        ::  id
::         tgas-rice-id        ::  lord
::         0                   ::  town-id
::         [%& rice]           ::  germ
::     ==
::   ++  wheat
::     ^-  wheat:tiny
::     `tgas-contract
::   ++  wheat-grain
::     ^-  grain:tiny
::     :*  tgas-wheat-id       ::  id
::         tgas-wheat-id       ::  lord
::         0                   ::  town-id
::         [%| wheat]          ::  germ
::     ==
::   ++  fake-land
::     ^-  land:tiny
::     (~(gas by:tiny *(map:tiny @ud town:tiny)) ~[[0 fake-town]])
::   ++  fake-town
::     ^-  town:tiny
::     [fake-granary fake-populace]
::   ++  fake-granary
::     ^-  granary:tiny
::     =/  grains=(list:tiny (pair:tiny id:tiny grain:tiny))
::       :~  [zigs-wheat-id:tiny wheat-grain:zigs]
::           [zigs-rice-id:tiny rice-grain:zigs]
::           [tgas-wheat-id wheat-grain]
::           [tgas-rice-id rice-grain]
::       ==
::     (~(gas by:tiny *(map:tiny id:tiny grain:tiny)) grains)
::   ++  fake-populace
::     ^-  populace:tiny
::     %-  %~  gas  by:tiny  *(map:tiny id:tiny @ud)
::     ~[[0xaa 0] [0xbb 0] [0xcc 0]]
::   ++  tgas-wheat-id
::     ^-  id:tiny
::     0x2
::   ++  tgas-rice-id
::     ^-  id:tiny
::     0x3
::   --
++  test-zigs-utxo-basic-give
  =/  write
     :*  %write
         [0xdead 1]
         %-  %~  gas  in  *(set id:std)
         ~[[0xd.ead0] [0xdea.dfee]]
         %-  some  :-  %send
         %-  %~  gas  by  *(map id:std (map id:std @ud))
         :~  :-  0xd.ead0
                 (~(gas by *(map id:std @ud)) ~[[0xb.eef1 100] [0xdead.cae0 900]])
         ==
     ==
  =/  call
    [[0xdead 1] zigs-wheat-id:std [fee=0xdea.dfee change=0xdead.cae1 rate=1 budget=500] town-id=0 write]
  =/  [res=town:std fee-bundle=(unit call-input:std)]
    (mill 0 fake-town:zigs-utxo call ~)
  ::  what's the best way to create a correct updated granary to check against?
  ::  also need to calculate exact fee to get proper outcome
  (expect-eq !>(~) !>(res))
::
++  test-zigs-basic-give
  =/  yok
    [[0xaa 1] `[%give 0xbb 69 500] ~]
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
::
++  test-zigs-failed-give
  =/  yok
    [[0xaa 1] `[%give 0xbb 1.200 500] ~]
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
::
++  test-zigs-failed-give-over-budget
  =/  yok
    [[0xaa 1] `[%give 0xbb 500 501] ~]
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
