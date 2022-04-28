/-  *ziggurat
/+  smart=zig-sys-smart, deploy=zig-deploy, sig=zig-sig
/*  capitol-contract  %noun  /lib/zig/compiled/capitol/noun
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [=start=time ~] ~]
:-  %zig-chain-poke
^-  chain-poke
=/  pubkey-1  0x3.e87b.0cbb.431d.0e8a.2ee2.ac42.d9da.cab8.063d.6bb6.2ff9.b2aa.e1b9.0f56.9c3f.3423
=/  pubkey-2  0x2.eaea.cffd.2bbe.e0c0.02dd.b5f8.dd04.e63f.297f.14cf.d809.b616.2137.126c.da9e.8d3d
=/  pubkey-3  0x2.4a1c.4643.b429.dc12.6f3b.03f3.f519.aebb.5439.08d3.e0bf.8fc3.cb52.b92c.9802.636e
=/  zigs-1  (fry-rice:smart pubkey-1 zigs-wheat-id:smart 0 `@`'zigs')
=/  zigs-2  (fry-rice:smart pubkey-2 zigs-wheat-id:smart 0 `@`'zigs')
=/  zigs-3  (fry-rice:smart pubkey-3 zigs-wheat-id:smart 0 `@`'zigs')
=/  beef-zigs-grain  ::  ~zod
  ^-  grain:smart
  :*  zigs-1
      zigs-wheat-id:smart
      ::  associated seed: 0xbeef
      pubkey-1
      0
      [%& `@`'zigs' [300.000.000.000.000.000.000 ~ `@ux`'zigs-metadata']]
  ==
=/  dead-zigs-grain  ::  ~bus
  ^-  grain:smart
  :*  zigs-2
      zigs-wheat-id:smart
      ::  associated seed: 0xdead
      pubkey-2
      0
      [%& `@`'zigs' [200.000.000.000.000.000.000 ~ `@ux`'zigs-metadata']]
  ==
=/  cafe-zigs-grain  ::  ~nec
  ^-  grain:smart
  :*  zigs-3
      zigs-wheat-id:smart
      ::  associated seed: 0xcafe
      pubkey-3
      0
      [%& `@`'zigs' [100.000.000.000.000.000.000 ~ `@ux`'zigs-metadata']]
  ==
=/  zigs-metadata-grain
  ^-  grain:smart
  :*  `@ux`'zigs-metadata'
      zigs-wheat-id:smart
      zigs-wheat-id:smart
      0
      :+  %&  `@`'zigs'
      :*  name='Uqbar Tokens'
          symbol='ZIG'
          decimals=18
          supply=1.000.000.000.000.000.000.000.000
          cap=~
          mintable=%.n
          minters=~
          deployer=0x0
          salt=`@`'zigs'
      == 
  ==
=/  world-map
  ^-  grain:smart
  :*  `@ux`'world'            ::  id
      `@ux`'capitol'          ::  lord
      `@ux`'capitol'          ::  holder
      0                       ::  town-id
      [%& `@`'world' data=*(map @ud @ux)]  ::  germ
  ==
=/  ziggurat-map
  ^-  grain:smart
  :*  `@ux`'ziggurat'
      `@ux`'capitol'
      `@ux`'capitol'
      0
      ::  start chain with this ship as singular validator
      [%& `@`'ziggurat' data=(malt ~[[p.bek (sign:sig p.bek now 'attestation')]])]
  ==
=/  capitol-grain
  ^-  grain:smart
  :*  `@ux`'capitol'  ::  id
      `@ux`'capitol'  ::  lord
      `@ux`'capitol'  ::  holder
      0               ::  town-id
      :-  %|          ::  germ
      ^-  wheat:smart
      ::  =/  cont  (of-wain:format capitol-contract)
      ::  :-  `(~(text-deploy deploy p.bek now) cont)
      :-  `(cue q.q.capitol-contract)
      ~
  ==
=/  fake-granary
  ^-  granary:smart
  =/  grains=(list:smart (pair:smart id:smart grain:smart))
    :~  [`@ux`'capitol' capitol-grain]
        [`@ux`'world' world-map]
        [`@ux`'ziggurat' ziggurat-map]
        [`@ux`'zigs-metadata' zigs-metadata-grain]
        [zigs-1 beef-zigs-grain]
        [zigs-2 dead-zigs-grain]
        [zigs-3 cafe-zigs-grain]
    ==
  (~(gas by:smart *(map:smart id:smart grain:smart)) grains)
=/  fake-populace
  ^-  populace:smart
  %-  %~  gas  by:smart  *(map:smart id:smart @ud)
  ~[[pubkey-1 0] [pubkey-2 0] [pubkey-3 0]]
:*  %start
    %validator
    (gas:poc ~ [0 [0 start-time p.bek^~ ~]]^~)
    ~
    [fake-granary fake-populace]
==