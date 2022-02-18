::
::  Tests for lib/zig/mill.hoon
::  Basic goal: construct a simple town / helix state
::  and manipulate it with some calls to our zigs contract.
::  Mill should handle clearing a mempool populated by
::  calls and return an updated town. The zigs contract
::  should manage transactions properly so this is testing
::  the arms of that contract as well.
::
::  Tests here should cover:
::  (all calls to exclusively zigs contract)
::
::  * executing a single call with +mill
::  * executing same call unsuccessfully -- not enough gas
::  * unsuccessfully -- some constraint in contract unfulfilled
::  * (test all constraints in contract: balance, gas, +give, etc)
::  * executing multiple calls with +mill-all
::
/+  *test, *zig-mill, smart=zig-sys-smart :: , *zig-contracts-zigs
/=  zigs-contract  /lib/zig/contracts/zigs
|%
++  zigs
  |%
  +$  account-mold
    $:  balance=@ud
        allowances=(map:smart sender=id:smart @ud)
    ==
  ++  town-id  0
  ++  set-fee  7  :: arbitrary replacement for +bull calculations
  ++  beef-zigs-grain
    ^-  grain:smart
    :*  0x1.beef
        zigs-wheat-id:smart
        0xbeef
        town-id
        %&^[1.000.000 ~]
    ==
  ++  dead-zigs-grain
    ^-  grain:smart
    :*  0x1.dead
        zigs-wheat-id:smart
        0xdead
        town-id
        %&^[500.000 ~]
    ==
  ++  cafe-zigs-grain
    ^-  grain:smart
    :*  0x1.cafe
        zigs-wheat-id:smart
        0xcafe
        town-id
        %&^[100.000 ~]
    ==
  ++  wheat
    ^-  wheat:smart
    :-  `zigs-contract
    (silt ~[0x1.beef 0x1.dead 0x1.cafe])
  ++  wheat-grain
    ^-  grain:smart
    :*  zigs-wheat-id:smart  ::  id
        zigs-wheat-id:smart  ::  lord
        zigs-wheat-id:smart  ::  holders
        town-id              ::  town-id
        :+    %|             ::  germ
          `zigs-contract
        (silt ~[0x1.beef 0x1.dead 0x1.cafe])        
    ==
  ++  fake-granary
    ^-  granary:smart
    =/  grains=(list:smart (pair:smart id:smart grain:smart))
      :~  [zigs-wheat-id:smart wheat-grain]
          [0x1.beef beef-zigs-grain]
          [0x1.dead dead-zigs-grain]
          [0x1.cafe cafe-zigs-grain]
      ==
    (~(gas by:smart *(map:smart id:smart grain:smart)) grains)
  ++  fake-populace
    ^-  populace:smart
    %-  %~  gas  by:smart  *(map:smart id:smart @ud)
    ~[[0xbeef 0] [0xdead 0] [0xcafe 0]]
  ++  fake-town
    ^-  town:smart
    [fake-granary fake-populace]
  ++  fake-land
    ^-  land:smart
    (~(gas by:smart *(map @ud town:smart)) ~[[town-id fake-town]])
  --
++  test-zigs-basic-give
  =/  bud  500
  =/  now  *@da
  =/  yok
    [[0xbeef 1 0x1.beef] `[%give 0xcafe 690 bud] (silt ~[0x1.beef]) (silt ~[0x1.cafe])]
  =/  shel
    [[0xbeef 1 0x1.beef] zigs-wheat-id:smart 1 bud town-id]
  =/  egg  [shel yok]
  =/  res  
    %+  ~(mill mill [0xdead 1 0x1.dead] town-id 1 now)
      fake-town:zigs
    egg
  ::  can't just check the whole town,
  ::  best thing to do is check the zigs data
  =/  beef-account
    (hole:smart account-mold:zigs +.germ:(~(got by p.-.res) 0x1.beef))
  =/  cafe-account
    (hole:smart account-mold:zigs +.germ:(~(got by p.-.res) 0x1.cafe))
  =/  correct-beef-account
    `account-mold:zigs`[(sub 1.000.000 (add 690 set-fee:zigs)) ~]
  =/  correct-cafe-account
    `account-mold:zigs`[(add 100.000 690) ~]
  %+  expect-eq
    !>([beef-account cafe-account])
  !>([correct-beef-account correct-cafe-account])
++  test-zigs-failed-give-amount-too-high
  =/  bud  500
  =/  now  *@da
  =/  yok
    [[0xbeef 1 0x1.beef] `[%give 0xcafe 69.000.000 bud] (silt ~[0x1.beef]) (silt ~[0x1.cafe])]
  =/  shel
    [[0xbeef 1 0x1.beef] zigs-wheat-id:smart 1 bud town-id]
  =/  egg  [shel yok]
  =/  res  
    %+  ~(mill mill [0xdead 1 0x1.dead] town-id 1 now)
      fake-town:zigs
    egg
  =/  beef-account
    (hole:smart account-mold:zigs +.germ:(~(got by p.-.res) 0x1.beef))
  =/  cafe-account
    (hole:smart account-mold:zigs +.germ:(~(got by p.-.res) 0x1.cafe))
  =/  correct-beef-account
    `account-mold:zigs`[(sub 1.000.000 set-fee:zigs) ~]
  =/  correct-cafe-account
    `account-mold:zigs`[100.000 ~]
  %+  expect-eq
    !>([beef-account cafe-account])
  !>([correct-beef-account correct-cafe-account])
++  test-zigs-failed-give-budget-too-high
  =/  bud  500
  =/  now  *@da
  =/  yok
    [[0xbeef 1 0x1.beef] `[%give 0xcafe 999.501 bud] (silt ~[0x1.beef]) (silt ~[0x1.cafe])]
  =/  shel
    [[0xbeef 1 0x1.beef] zigs-wheat-id:smart 1 bud town-id]
  =/  egg  [shel yok]
  =/  res  
    %+  ~(mill mill [0xdead 1 0x1.dead] town-id 1 now)
      fake-town:zigs
    egg
  =/  beef-account
    (hole:smart account-mold:zigs +.germ:(~(got by p.-.res) 0x1.beef))
  =/  cafe-account
    (hole:smart account-mold:zigs +.germ:(~(got by p.-.res) 0x1.cafe))
  =/  correct-beef-account
    `account-mold:zigs`[(sub 1.000.000 set-fee:zigs) ~]
  =/  correct-cafe-account
    `account-mold:zigs`[100.000 ~]
  %+  expect-eq
    !>([beef-account cafe-account])
  !>([correct-beef-account correct-cafe-account])
++  test-zigs-failed-give-cant-afford-gas
  ::  stub: can't test this until we integrate +bull
  (expect-eq !>(%.y) !>(%.y))
--