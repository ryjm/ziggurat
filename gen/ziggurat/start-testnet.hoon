/-  *ziggurat
/+  smart=zig-sys-smart, deploy=zig-deploy, sig=zig-sig
/*  capitol-contract  %txt  /lib/zig/contracts/capitol/hoon
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [=start=time ~] ~]
:-  %zig-chain-poke
^-  chain-poke
=/  beef-zigs-grain  ::  ~zod
  ^-  grain:smart
  :*  0x1.beef
      zigs-wheat-id:smart
      ::  ~zod's address
      ::  associated secret key: 0xbeef
      0x1d.8044.3e18.8c8c.74ef.0551.bac3.ff21.52f3.ced6.9b5d.9b74.70d4.2b8c.20ef.4fb2.d034.f99a.ffc5.f401.5d9c.db9f.bf02.28e2.12de.a1b6.428d.d6f7.6887.e49f.f048.c609.e862
      0
      %&^[100.000.000 ~]
  ==
=/  dead-zigs-grain  ::  ~bus
  ^-  grain:smart
  :*  0x1.dead
      zigs-wheat-id:smart
      0xdead
      0
      %&^[100.000.000 ~]
  ==
=/  cafe-zigs-grain  ::  ~nec
  ^-  grain:smart
  :*  0x1.cafe
      zigs-wheat-id:smart
      0xcafe
      0
      %&^[100.000.000 ~]
  ==
=/  world-map
  ^-  grain:smart
  :*  `@ux`'world'            ::  id
      `@ux`'capitol'          ::  lord
      `@ux`'capitol'          ::  holder
      0                       ::  town-id
      [%& data=*(map @ud @ux)]  ::  germ
  ==
=/  ziggurat-map
  ^-  grain:smart
  :*  `@ux`'ziggurat'
      `@ux`'capitol'
      `@ux`'capitol'
      0
      ::  start chain with this ship as singular validator
      [%& data=(malt ~[[p.bek (sign:sig p.bek now 'attestation')]])]
  ==
=/  wheat
  ^-  wheat:smart
  =/  cont  (of-wain:format capitol-contract)
  :-  `(text-deploy:deploy cont)
  ~
=/  wheat-grain
  ^-  grain:smart
  :*  `@ux`'capitol'  ::  id
      `@ux`'capitol'  ::  lord
      `@ux`'capitol'  ::  holder
      0               ::  town-id
      [%| wheat]      ::  germ
  ==
=/  fake-granary
  ^-  granary:smart
  =/  grains=(list:smart (pair:smart id:smart grain:smart))
    :~  [`@ux`'capitol' wheat-grain]
        [`@ux`'world' world-map]
        [`@ux`'ziggurat' ziggurat-map]
        [0x1.beef beef-zigs-grain]
        [0x1.dead dead-zigs-grain]
        [0x1.cafe cafe-zigs-grain]
    ==
  (~(gas by:smart *(map:smart id:smart grain:smart)) grains)
=/  fake-populace
  ^-  populace:smart
  %-  %~  gas  by:smart  *(map:smart id:smart @ud)
  ~[[0x1d.8044.3e18.8c8c.74ef.0551.bac3.ff21.52f3.ced6.9b5d.9b74.70d4.2b8c.20ef.4fb2.d034.f99a.ffc5.f401.5d9c.db9f.bf02.28e2.12de.a1b6.428d.d6f7.6887.e49f.f048.c609.e862 0] [0xdead 0] [0xcafe 0]]
:*  %start
    %validator
    (gas:poc ~ [0 [0 start-time p.bek^~ ~]]^~)
    ~
    [fake-granary fake-populace]
==