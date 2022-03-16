/-  *ziggurat
/+  smart=zig-sys-smart, deploy=zig-deploy
/*  capitol-contract  %txt  /lib/zig/contracts/capitol/hoon
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [=start=time ~] ~]
:-  %zig-action
^-  action
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
    ~[[`@ux`'capitol' wheat-grain] [`@ux`'world' world-map]]
  (~(gas by:smart *(map:smart id:smart grain:smart)) grains)
=/  fake-populace
  ^-  populace:smart
  %-  %~  gas  by:smart  *(map:smart id:smart @ud)
  ~[[0xbeef 0] [0xdead 0] [0xcafe 0]]
:*  %start
    %validator
    (gas:poc ~ [0 [0 start-time [~zod ~bus ~] ~]]^~)
    (silt [~zod ~bus ~])
    [fake-granary fake-populace]
==
