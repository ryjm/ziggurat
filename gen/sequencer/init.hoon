/-  *sequencer
/+  smart=zig-sys-smart
/=  zigs-contract  /lib/zig/contracts/zigs
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
=/  wheat
  ^-  wheat:smart
  :-  `zigs-contract
  (silt ~[0x1.beef 0x1.dead 0x1.cafe])
=/  wheat-grain
  ^-  grain:smart
  :*  zigs-wheat-id:smart  ::  id
      zigs-wheat-id:smart  ::  lord
      zigs-wheat-id:smart  ::  holder
      town-id              ::  town-id
      :+    %|             ::  germ
        `zigs-contract
      (silt ~[0x1.beef 0x1.dead 0x1.cafe])        
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
:^    %init
    town-id
  [0xbeef 0 0x1.beef]
[fake-granary fake-populace]
