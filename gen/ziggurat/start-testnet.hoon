/-  *ziggurat
/+  smart=zig-sys-smart, deploy=zig-deploy, sig=zig-sig
/*  capitol-contract  %noun  /lib/zig/compiled/capitol/noun
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [=start=time ~] ~]
:-  %zig-chain-poke
^-  chain-poke
=/  pubkey-1  0x2.e3c1.d19b.fd3e.43aa.319c.b816.1c89.37fb.b246.3a65.f84d.8562.155d.6181.8113.c85b
=/  pubkey-2  0x3.4cdd.5f53.b551.e62f.2238.6eb3.8abd.3e91.a546.fad3.2940.ff2d.c316.50dd.8d38.e609
=/  pubkey-3  0x3.9452.264c.57a5.1b54.d380.70b0.7e0c.934d.15c0.6692.fa9c.7f35.eaf9.eb52.b925.1b7d
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
      [%& `@`'zigs' [300.000.000 ~ `@ux`'zigs-metadata']]
  ==
=/  dead-zigs-grain  ::  ~bus
  ^-  grain:smart
  :*  zigs-2
      zigs-wheat-id:smart
      ::  associated seed: 0xdead
      pubkey-2
      0
      [%& `@`'zigs' [200.000.000 ~ `@ux`'zigs-metadata']]
  ==
=/  cafe-zigs-grain  ::  ~nec
  ^-  grain:smart
  :*  zigs-3
      zigs-wheat-id:smart
      ::  associated seed: 0xcafe
      pubkey-3
      0
      [%& `@`'zigs' [100.000.000 ~ `@ux`'zigs-metadata']]
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