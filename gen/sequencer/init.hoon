/-  *sequencer
/+  smart=zig-sys-smart, deploy=zig-deploy
/*  zigs-contract  %txt  /lib/zig/contracts/zigs/hoon
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [town-id=@ud ~] ~]
=/  beef-zigs-grain  ::  our sequencer account's zigs
  ^-  grain:smart
  :*  0x1.beef
      zigs-wheat-id:smart
      0xbeef
      town-id
      %&^[1.000.000 ~]
  ==
=/  dead-zigs-grain
  ^-  grain:smart
  :*  0x1.dead
      zigs-wheat-id:smart
      0xdead
      town-id
      %&^[500.000 ~]
  ==
=/  cafe-zigs-grain
  ^-  grain:smart
  :*  0x1.cafe
      zigs-wheat-id:smart
      0xcafe
      town-id
      %&^[100.000 ~]
  ==
::  store only contract code, insert into shared subject
=/  wheat
  ^-  wheat:smart
  =/  cont  (of-wain:format zigs-contract)
  :-  `(text-deploy:deploy cont)
  (silt ~[0x1.beef 0x1.dead 0x1.cafe])
=/  wheat-grain
  ^-  grain:smart
  :*  zigs-wheat-id:smart  ::  id
      zigs-wheat-id:smart  ::  lord
      zigs-wheat-id:smart  ::  holder
      town-id              ::  town-id
      [%| wheat]           ::  germ
  ==
=/  fake-granary
  ^-  granary:smart
  =/  grains=(list:smart (pair:smart id:smart grain:smart))
    :~  [zigs-wheat-id:smart wheat-grain]
        [0x1.beef beef-zigs-grain]
        [0x1.dead dead-zigs-grain]
        [0x1.cafe cafe-zigs-grain]
    ==
  (~(gas by:smart *(map:smart id:smart grain:smart)) grains)
=/  fake-populace
  ^-  populace:smart
  %-  %~  gas  by:smart  *(map:smart id:smart @ud)
  ~[[0xbeef 0] [0xdead 0] [0xcafe 0]]
:-  %zig-chain-action
^-  chain-action
:*  %init
    town-id
    `[fake-granary fake-populace]
    [rate=1 bud=100.000]
==
