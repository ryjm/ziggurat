/-  *ziggurat
/+  smart=zig-sys-smart, deploy=zig-deploy
/*  zigs-contract  %txt  /lib/zig/contracts/zigs/hoon
=/  pubkey-1  0x1d.8044.3e18.8c8c.74ef.0551.bac3.ff21.52f3.ced6.9b5d.9b74.70d4.2b8c.20ef.4fb2.d034.f99a.ffc5.f401.5d9c.db9f.bf02.28e2.12de.a1b6.428d.d6f7.6887.e49f.f048.c609.e862
=/  pubkey-2  0x57.8d3b.e138.c6fe.6b91.1400.aafe.f203.194b.a8c9.2080.3aa3.76bb.5afb.cfda.f2e8.90c7.2bcb.12ad.28bb.de3e.546a.c356.25af.0f9a.29a4.c01e.5399.1a13.b3ba.ee36.74ae.7062
=/  pubkey-3  0x68.ba7e.534f.2b79.ee33.f388.5482.27dc.eeb6.ddb6.4c39.81a1.7743.4d66.82b8.7ad4.7b9e.0085.d9bb.cc95.5996.a8a6.c955.8cd9.5a41.7f8d.425c.3064.b1fc.541f.2eec.6ce5.0162
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [town-id=@ud ~] ~]
=/  zigs-1  (fry-rice:smart pubkey-1 0 town-id `@`'zigs')
=/  zigs-2  (fry-rice:smart pubkey-2 0 town-id `@`'zigs')
=/  zigs-3  (fry-rice:smart pubkey-3 0 town-id `@`'zigs')
=/  beef-zigs-grain  ::  ~zod
  ^-  grain:smart
  :*  zigs-1
      zigs-wheat-id:smart
      ::  associated secret key: 0xbeef
      pubkey-1
      town-id
      [%& `@`'zigs' [100.000.000 ~]]
  ==
=/  dead-zigs-grain  ::  ~bus
  ^-  grain:smart
  :*  zigs-2
      zigs-wheat-id:smart
      pubkey-2
      town-id
      [%& `@`'zigs' [100.000.000 ~]]
  ==
=/  cafe-zigs-grain  ::  ~nec
  ^-  grain:smart
  :*  zigs-3
      zigs-wheat-id:smart
      pubkey-3
      town-id
      [%& `@`'zigs' [100.000.000 ~]]
  ==
::  store only contract code, insert into shared subject
=/  wheat
  ^-  wheat:smart
  =/  cont  (of-wain:format zigs-contract)
  :-  `(~(text-deploy deploy p.bek now) cont)
  (silt ~[zigs-1 zigs-2 zigs-3])
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
        [zigs-1 beef-zigs-grain]
        [zigs-2 dead-zigs-grain]
        [zigs-3 cafe-zigs-grain]
    ==
  (~(gas by:smart *(map:smart id:smart grain:smart)) grains)
=/  fake-populace
  ^-  populace:smart
  %-  %~  gas  by:smart  *(map:smart id:smart @ud)
  ~[[pubkey-1 0] [pubkey-2 0] [pubkey-3 0]]
:-  %zig-hall-poke
^-  hall-poke
:*  %init
    town-id
    `[fake-granary fake-populace]
    [rate=1 bud=10.000]
==
