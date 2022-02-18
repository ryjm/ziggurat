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
:: /=  tgas-contract  /lib/zig/contracts/test-good-altcoin
:: /=  multisig-contract  /lib/zig/contracts/multisig
|%
++  zigs-utxo
  |%
  ++  validator-id
    ^-  id:std
    0xcafe
  ++  town-id
    ^-  @ud
    0
  ++  block
    ^-  @ud
    0
  ++  dead0
    ^-  grain:std
    (rice-grain 0xdead 1.000)
  ++  deadfee
    ^-  grain:std
    (rice-grain 0xdead 999)
  ++  beef0
    ^-  grain:std
    (rice-grain 0xbeef 200)
  ++  beeffee
    ^-  grain:std
    (rice-grain 0xbeef 501)
  ++  zigs-rice-grains
    ^-  (list (pair id:std grain:std))
    =/  dead0=grain:std    dead0
    =/  deadfee=grain:std  deadfee
    =/  beef0=grain:std    beef0
    =/  beeffee=grain:std  beeffee
    :~  [id.dead0 dead0]
        [id.deadfee deadfee]
        [id.beef0 beef0]
        [id.beeffee beeffee]
    ==
  ++  rice-data
    |=  amount=@ud
    `@ud`amount
  ++  rice
    |=  amount=@ud
    ^-  rice:std
    [`@ud (rice-data amount)]
  ++  rice-germ
    |=  amount=@ud
    ^-  germ:std
    [%& (rice amount)]
  ++  rice-grain-id
    |=  amount=@ud
    ^-  id:std
    (fry:std zigs-wheat-id:std town-id (rice-germ amount))
  ++  rice-grain
    |=  [holder=id:std amount=@ud]
    ^-  grain:std
    :*  id=(rice-grain-id amount)
        lord=zigs-wheat-id:std
        holder=holder
        town-id=town-id
        germ=(rice-germ amount)
    ==
  ++  zigs-wheat
    ^-  wheat:std
    [`zigs-contract *(set id:std)]
  ++  zigs-wheat-germ
    ^-  germ:std
    [%| zigs-wheat]
  ++  zigs-wheat-grain
    ^-  grain:std
    :*  id=zigs-wheat-id:std
        lord=zigs-wheat-id:std
        holder=zigs-wheat-id:std
        town-id=town-id
        germ=zigs-wheat-germ
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
        [0xcafe 0]
    ==
  --
::
:: ++  zigs
::   |%
::   +$  zigs-mold
::     $:  total=@ud
::         balances=(map:std id:std @ud)
::         allowances=(map:std [owner=id:std sender=id:std] @ud)
::         coinbase-rate=@ud
::     ==
::   ++  user-balances
::     ^-  (map:std id:std @ud)
::     %-  ~(gas by:std *(map:std id:std @ud))
::     :~  [0xaa 1.000]
::         [0xbb 1.000]
::         [0xcc 500]
::         [0xdd 500]
::         [0xee 490]
::         [0xff 10]
::     ==
::   ++  user-allowances
::     ^-  (map:std [owner=id:std sender=id:std] @ud)
::     %-
::       %~  gas  by:std
::       *(map:std [owner=id:std sender=id:std] @ud)
::     :~  [[0xaa 0xbb] 100]
::         [[0xee 0xff] 100]
::     ==
::   ++  rice-data
::     ^-  zigs-mold
::     :*  total=3.500
::         balances=user-balances
::         allowances=user-allowances
::         coinbase-rate=50  ::  # of tokens granted in +coinbase
::     ==
::   ++  rice
::     ^-  rice:std
::     :-  ~                   ::  format
::     rice-data               ::  data
::   ++  rice-grain
::     ^-  grain:std
::     :*  zigs-rice-id:std   ::  id
::         zigs-wheat-id:std  ::  lord
::         zigs-wheat-id:std  ::  holders
::         0                  ::  town-id
::         [%& rice]          ::  germ
::     ==
::   ++  wheat
::     ^-  wheat:std
::     :-  `zigs-contract
::     (silt ~[zigs-rice-id:std])
::   ++  wheat-grain
::     ^-  grain:std
::     :*  zigs-wheat-id:std  ::  id
::         zigs-wheat-id:std  ::  lord
::         zigs-wheat-id:std  ::  holders
::         0                  ::  town-id
::         [%| wheat]         ::  germ
::     ==
::   ++  multisig-grain
::     ^-  grain:std
::     :*  0x3
::         0x3
::         0x3
::         0
::         [%| [`multisig-contract ~]]
::     ==
::   ++  fake-land
::     ^-  land:std
::     (~(gas by:std *(map @ud town:std)) ~[[0 fake-town]])
::   ++  fake-town
::     ^-  town:std
::     [fake-granary fake-populace]
::   ++  fake-granary
::     ^-  granary:std
::     =/  grains=(list:std (pair:std id:std grain:std))
::       :~  [zigs-wheat-id:std wheat-grain]
::           [zigs-rice-id:std rice-grain]
::           [0x3 multisig-grain]
::       ==
::     (~(gas by:std *(map:std id:std grain:std)) grains)
::   ++  fake-populace
::     ^-  populace:std
::     %-  %~  gas  by:std  *(map:std id:std @ud)
::     ~[[0xaa 0] [0xbb 0] [0xcc 0]]
::   --
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
++  setup-zigs-utxo-basic-give-egg
  |=  [from=user:std fee=id:std sender=id:std txs=(list (pair id:std @ud))]
  ^-  egg:std
  =|  =stamp:std
  =:  fee.stamp      fee
      rate.stamp     1
      budget.stamp   500
  ==
  =|  =shell:std
  =|  =yolk:std
  =:
      from.shell     from
      to.shell       zigs-wheat-id:std
      stamp.shell    stamp
      town-id.shell  town-id:zigs-utxo
      caller.yolk    from
      args.yolk
        %-  some  :-  %send
        %-  %~  gas  by  *(map id:std (map id:std @ud))
        :~  :-  sender
            (~(gas by *(map id:std @ud)) txs)
        ==
      grain-ids.yolk
        %-  %~  gas  in  *(set id:std)
        ~[[sender]]
  ==
  =/  =egg:std  [shell yolk]
  egg
::
++  setup-zigs-utxo-basic-give-egg0
  ^-  egg:std
  %:  setup-zigs-utxo-basic-give-egg
      [0xdead 1]
      id:deadfee:zigs-utxo
      id:dead0:zigs-utxo
      ~[[0xbeef 100] [0xdead 900]]
  ==
::
++  setup-zigs-utxo-basic-give-egg1
  ^-  egg:std
  %:  setup-zigs-utxo-basic-give-egg
      [0xbeef 1]
      id:beeffee:zigs-utxo
      id:beef0:zigs-utxo
      ~[[0xdead 101] [0xbeef 99]]
  ==
::
++  test-zigs-utxo-basic-give
  ::  set up and run mill
  =/  =egg:std  setup-zigs-utxo-basic-give-egg0
  =/  [resulting-town=town:std fee-bundle=(unit yolk:std)]
    (~(mill mill validator-id:zigs-utxo town-id:zigs-utxo) fake-town:zigs-utxo egg block:zigs-utxo ~)
  =*  granary   p.resulting-town
  =*  populace  q.resulting-town
  ::  set up expected outputs
  =/  beef-nonce=@ud              0
  =/  cafe-nonce=@ud              1
  =/  dead-nonce=@ud              1
  =/  beef1-germ=germ:std         [%& `@ud 100]
  =/  dead-change0-germ=germ:std  [%& `@ud 900]
  =/  dead-change1-germ=germ:std  [%& `@ud 998]
  ::  compare
  ;:  weld
  ::  populace
  %+  expect-eq
    !>  beef-nonce
    !>  (~(got by populace) 0xbeef)
  %+  expect-eq
    !>  cafe-nonce
    !>  (~(got by populace) 0xcafe)
  %+  expect-eq
    !>  dead-nonce
    !>  (~(got by populace) 0xdead)
  ::  old `rice`s cleaned up
  %+  expect-eq
    !>  ~
    !>  (~(get by granary) id:deadfee:zigs-utxo)
  %+  expect-eq
    !>  ~
    !>  (~(get by granary) id:dead0:zigs-utxo)
  ::  new `rice`s as expected
  %+  expect-eq
    !>  beef1-germ
    !>
      ?~  beef1-grain=(~(get by granary) (fry:std zigs-wheat-id:std town-id:zigs-utxo beef1-germ))
        ~
      germ.u.beef1-grain
  ::  TODO: add more confirmation of funds in proper accounts
  ==
++  test-zigs-utxo-basic-gives
  ::  set up and run mill
  =/  egg0=egg:std  setup-zigs-utxo-basic-give-egg0
  =/  egg1=egg:std  setup-zigs-utxo-basic-give-egg1
  =/  eggs=(list egg:std)
    ~[egg0 egg1]
  =/  [chunk=(list [id:std egg:std]) resulting-town=town:std]
    (~(mill-all mill validator-id:zigs-utxo town-id:zigs-utxo) fake-town:zigs-utxo eggs block:zigs-utxo)
  =*  granary   p.resulting-town
  =*  populace  q.resulting-town
  ::  set up expected outputs
  =/  beef-nonce=@ud              1
  =/  cafe-nonce=@ud              1
  =/  dead-nonce=@ud              1
  =/  beef1-germ=germ:std         [%& `@ud 100]
  =/  dead-change0-germ=germ:std  [%& `@ud 900]
  =/  dead-change1-germ=germ:std  [%& `@ud 998]
  ::  compare
  ;:  weld
  ::  populace
  %+  expect-eq
    !>  beef-nonce
    !>  (~(got by populace) 0xbeef)
  %+  expect-eq
    !>  cafe-nonce
    !>  (~(got by populace) 0xcafe)
  %+  expect-eq
    !>  dead-nonce
    !>  (~(got by populace) 0xdead)
  ::  chunk
  %+  expect-eq
    !>  (add 1 (lent eggs))  ::  fees tx + submitted txs
    !>  (lent chunk)
  %-  expect
    !>  ?!  ?=(~ (find ~[[`@ux`(shax (jam egg0)) egg0]] `(list [id:std egg:std])`chunk))
  %-  expect
    !>  ?!  ?=(~ (find ~[[`@ux`(shax (jam egg1)) egg1]] `(list [id:std egg:std])`chunk))
  ::  old `rice`s cleaned up
  %+  expect-eq
    !>  ~
    !>  (~(get by granary) id:deadfee:zigs-utxo)
  %+  expect-eq
    !>  ~
    !>  (~(get by granary) id:dead0:zigs-utxo)
  %+  expect-eq
    !>  ~
    !>  (~(get by granary) id:beeffee:zigs-utxo)
  %+  expect-eq
    !>  ~
    !>  (~(get by granary) id:beef0:zigs-utxo)
  ::  new `rice`s as expected
  %+  expect-eq
    !>  beef1-germ
    !>
      ?~  beef1-grain=(~(get by granary) (fry:std zigs-wheat-id:std town-id:zigs-utxo beef1-germ))
        ~
      germ.u.beef1-grain
  ::  TODO: add more confirmation of funds in proper accounts
  ==
::
:: ++  test-zigs-basic-give
::   =/  yok
::     [[0xaa 1] `[%give 0xbb 69 500] ~]
::   =/  shel
::     [[0xaa 1] zigs-wheat-id:std rate=1 budget=500 town-id=0]
::   =/  egg  [shel yok]
::   =/  res  (~(mill mill 0xabcd 0) fake-town:zigs egg 100)
::   ::  can't just check the whole town,
::   ::  best thing to do is check the zigs data
::   =/  loach
::     ;;(zigs-mold:zigs +.+.germ:(~(got by p.res) zigs-rice-id:std))
::   =/  squid  rice-data:zigs
::   ::  this manually performs the changes that the
::   ::  zig contract should be doing. not great
::   =.  balances.squid
::     %+  %~  jab  by
::       %+  %~  jab  by
::         (~(put by balances.squid) [0xabcd 0])
::           0xbb
::         |=(bal=@ud (add bal 69))
::       0xaa
::     |=(bal=@ud (sub bal 69))
::   (expect-eq !>(squid) !>(loach))
:: ::
:: ++  test-zigs-failed-give
::   =/  yok
::     [[0xaa 1] `[%give 0xbb 1.200 500] ~]
::   =/  shel
::     [[0xaa 1] zigs-wheat-id:std rate=1 budget=500 town-id=0]
::   =/  egg  [shel yok]
::   =/  res  (~(mill mill 0xabcd 0) fake-town:zigs egg 100)
::   =/  loach
::     ;;(zigs-mold:zigs +.+.germ:(~(got by p.res) zigs-rice-id:std))
::   =/  squid  rice-data:zigs
::   =.  balances.squid
::     (~(put by balances.squid) [0xabcd 0])
::   (expect-eq !>(squid) !>(loach))
:: ::
:: ++  test-zigs-failed-give-over-budget
::   =/  yok
::     [[0xaa 1] `[%give 0xbb 500 501] ~]
::   =/  shel
::     [[0xaa 1] zigs-wheat-id:std rate=1 budget=500 town-id=0]
::   =/  egg  [shel yok]
::   =/  res  (~(mill mill 0xabcd 0) fake-town:zigs egg 100)
::   =/  loach
::     ;;(zigs-mold:zigs +.+.germ:(~(got by p.res) zigs-rice-id:std))
::   =/  squid  rice-data:zigs
::   =.  balances.squid
::     (~(put by balances.squid) [0xabcd 0])
::   (expect-eq !>(squid) !>(loach))
::  ++  test-mill-tgas-basic-give
::
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
