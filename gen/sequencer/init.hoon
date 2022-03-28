/-  *ziggurat
/+  smart=zig-sys-smart, deploy=zig-deploy
/*  zigs-contract  %txt  /lib/zig/contracts/zigs/hoon
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [town-id=@ud ~] ~]
=/  beef-zigs-grain  ::  ~zod
  ^-  grain:smart
  :*  0x1.beef
      zigs-wheat-id:smart
      ::  ~zod's address
      ::  associated secret key: 0xbeef
      0x1d.8044.3e18.8c8c.74ef.0551.bac3.ff21.52f3.ced6.9b5d.9b74.70d4.2b8c.20ef.4fb2.d034.f99a.ffc5.f401.5d9c.db9f.bf02.28e2.12de.a1b6.428d.d6f7.6887.e49f.f048.c609.e862
      town-id
      %&^[1.000.000 ~]
  ==
=/  dead-zigs-grain  ::  ~bus
  ^-  grain:smart
  :*  0x1.dead
      zigs-wheat-id:smart
      0xdead
      town-id
      %&^[500.000 ~]
  ==
=/  cafe-zigs-grain  ::  ~nec
  ^-  grain:smart
  :*  0x1.cafe
      zigs-wheat-id:smart
      0xcafe
      town-id
      %&^[100.000 ~]
  ==
=/  address-book-grain
  ^-  grain:smart
  :*  `@ux`'address-book'
      zigs-wheat-id:smart
      zigs-wheat-id:smart
      town-id
      %&^[(malt ~[[0x1d.8044.3e18.8c8c.74ef.0551.bac3.ff21.52f3.ced6.9b5d.9b74.70d4.2b8c.20ef.4fb2.d034.f99a.ffc5.f401.5d9c.db9f.bf02.28e2.12de.a1b6.428d.d6f7.6887.e49f.f048.c609.e862 0x1.beef] [0xdead 0x1.dead] [0xcafe 0x1.cafe]])]
  ==
::  store only contract code, insert into shared subject
=/  wheat
  ^-  wheat:smart
  =/  cont  (of-wain:format zigs-contract)
  :-  `(text-deploy:deploy cont)
  (silt ~[0x1.beef 0x1.dead 0x1.cafe `@ux`'address-book'])
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
        [`@ux`'address-book' address-book-grain]
        [0x1.beef beef-zigs-grain]
        [0x1.dead dead-zigs-grain]
        [0x1.cafe cafe-zigs-grain]
    ==
  (~(gas by:smart *(map:smart id:smart grain:smart)) grains)
=/  fake-populace
  ^-  populace:smart
  %-  %~  gas  by:smart  *(map:smart id:smart @ud)
  ~[[0x1d.8044.3e18.8c8c.74ef.0551.bac3.ff21.52f3.ced6.9b5d.9b74.70d4.2b8c.20ef.4fb2.d034.f99a.ffc5.f401.5d9c.db9f.bf02.28e2.12de.a1b6.428d.d6f7.6887.e49f.f048.c609.e862 0] [0xdead 0] [0xcafe 0]]
:-  %zig-hall-poke
^-  hall-poke
:*  %init
    town-id
    `[fake-granary fake-populace]
    [rate=1 bud=10.000]
==
