/-  *ziggurat
/+  smart=zig-sys-smart, deploy=zig-deploy
/*  capitol-contract  %txt  /lib/zig/contracts/capitol/hoon
/*  zigs-contract  %txt  /lib/zig/contracts/zigs/hoon
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [=start=time ~] ~]
:-  %zig-action
^-  action
=/  beef-zigs-grain  ::  ~zod
  ^-  grain:smart
  :*  0x1.beef
      zigs-wheat-id:smart
      0xbeef
      0
      %&^[1.000.000 ~]
  ==
=/  dead-zigs-grain  ::  ~bus
  ^-  grain:smart
  :*  0x1.dead
      zigs-wheat-id:smart
      0xdead
      0
      %&^[500.000 ~]
  ==
=/  cafe-zigs-grain  ::  ~nec
  ^-  grain:smart
  :*  0x1.cafe
      zigs-wheat-id:smart
      0xcafe
      0
      %&^[100.000 ~]
  ==
=/  world-map
  ^-  grain:smart
  :*  `@ux`'world'            ::  id
      `@ux`'capitol'          ::  lord
      `@ux`'capitol'          ::  holder
      0                       ::  town-id
      [%& data=*(map @ud @ux)]  ::  germ
  ==
=/  wheat
  ^-  wheat:smart
  :-  `(~(deploy deploy ~zod now) /lib/zig/contracts/capitol/hoon)
  (silt ~[`@ux`'world'])
=/  wheat-grain
  ^-  grain:smart
  :*  `@ux`'capitol'  ::  id
      `@ux`'capitol'  ::  lord
      `@ux`'capitol'  ::  holder
      0               ::  town-id
      [%| wheat]      ::  germ
  ==
=/  zigs-wheat
  ^-  wheat:smart
  =/  cont  (of-wain:format zigs-contract)
  :-  `(text-deploy:deploy cont)
  (silt ~[0x1.beef 0x1.dead 0x1.cafe])
=/  zigs-grain
  ^-  grain:smart
  :*  zigs-wheat-id:smart  ::  id
      zigs-wheat-id:smart  ::  lord
      zigs-wheat-id:smart  ::  holder
      0                    ::  town-id
      [%| zigs-wheat]      ::  germ
  ==
=/  fake-granary
  ^-  granary:smart
  =/  grains=(list:smart (pair:smart id:smart grain:smart))
    :~  [`@ux`'capitol' wheat-grain]
        [zigs-wheat-id:smart zigs-grain]
        [`@ux`'world' world-map]
        [0x1.beef beef-zigs-grain]
        [0x1.dead dead-zigs-grain]
        [0x1.cafe cafe-zigs-grain]
    ==
  (~(gas by:smart *(map:smart id:smart grain:smart)) grains)
=/  fake-populace
  ^-  populace:smart
  %-  %~  gas  by:smart  *(map:smart id:smart @ud)
  ~[[0xbeef 0] [0xdead 0] [0xcafe 0]]
:*  %start
    %validator
    (gas:poc ~ [0 [0 start-time p.bek^~ ~]]^~)
    ~
    [fake-granary fake-populace]
==