/-  *ziggurat
/+  smart=zig-sys-smart, deploy=zig-deploy
/*  zigs-contract  %noun  /lib/zig/compiled/zigs/noun
/*  nft-contract  %noun  /lib/zig/compiled/nft/noun
/*  publish-contract  %noun  /lib/zig/compiled/publish/noun
/*  fungible-contract  %txt  /lib/zig/contracts/fungible/hoon
=/  pubkey-1  0x2.e3c1.d19b.fd3e.43aa.319c.b816.1c89.37fb.b246.3a65.f84d.8562.155d.6181.8113.c85b
=/  pubkey-2  0x3.4cdd.5f53.b551.e62f.2238.6eb3.8abd.3e91.a546.fad3.2940.ff2d.c316.50dd.8d38.e609
=/  pubkey-3  0x3.9452.264c.57a5.1b54.d380.70b0.7e0c.934d.15c0.6692.fa9c.7f35.eaf9.eb52.b925.1b7d
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [town-id=@ud ~] ~]
=/  zigs-1  (fry-rice:smart pubkey-1 zigs-wheat-id:smart town-id `@`'zigs')
=/  zigs-2  (fry-rice:smart pubkey-2 zigs-wheat-id:smart town-id `@`'zigs')
=/  zigs-3  (fry-rice:smart pubkey-3 zigs-wheat-id:smart town-id `@`'zigs')
=/  beef-zigs-grain  ::  ~zod
  ^-  grain:smart
  :*  zigs-1
      zigs-wheat-id:smart
      ::  associated seed: 0xbeef
      pubkey-1
      town-id
      [%& `@`'zigs' [300.000 ~ `@ux`'zigs-metadata']]
  ==
=/  dead-zigs-grain  ::  ~bus
  ^-  grain:smart
  :*  zigs-2
      zigs-wheat-id:smart
      ::  associated seed: 0xdead
      pubkey-2
      town-id
      [%& `@`'zigs' [200.000 ~ `@ux`'zigs-metadata']]
  ==
=/  cafe-zigs-grain  ::  ~nec
  ^-  grain:smart
  :*  zigs-3
      zigs-wheat-id:smart
      ::  associated seed: 0xcafe
      pubkey-3
      town-id
      [%& `@`'zigs' [100.000 ~ `@ux`'zigs-metadata']]
  ==
=/  zigs-metadata-grain
  ^-  grain:smart
  :*  `@ux`'zigs-metadata'
      zigs-wheat-id:smart
      zigs-wheat-id:smart
      town-id
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
::  store only contract code, insert into shared subject
=/  zigs-wheat
  ^-  wheat:smart
  :-  `(cue q.q.zigs-contract)
  (silt ~[zigs-1 zigs-2 zigs-3 `@ux`'zigs-metadata'])
=/  zigs-wheat-grain
  ^-  grain:smart
  :*  zigs-wheat-id:smart  ::  id
      zigs-wheat-id:smart  ::  lord
      zigs-wheat-id:smart  ::  holder
      town-id              ::  town-id
      [%| zigs-wheat]      ::  germ
  ==
::  publish.hoon contract
=/  publish-grain
  ^-  grain:smart
  :*  0x1111.1111     ::  id
      0x1111.1111     ::  lord
      0x1111.1111     ::  holder
      town-id         ::  town-id
      [%| [`(cue q.q.publish-contract) ~]]  ::  germ
  ==
::
::  NFT stuff
=/  nft-metadata-grain
  ^-  grain:smart
  :*  `@ux`'nft-metadata'
      0xcafe.babe
      0xcafe.babe
      town-id
      :+  %&  `@`'nftsalt'
      :*  name='Monkey JPEGs'
          symbol='BADART'
          item-mold=[hair=@t eyes=@t mouth=@t]
          supply=1
          cap=~
          mintable=%.n
          minters=~
          deployer=0x0
          salt=`@`'nftsalt'
  ==  ==
=/  item-1
  [1 [hair='red' eyes='blue' mouth='smile'] "a smiling monkey" "ipfs://QmUbFVTm113tJEuJ4hZY2Hush4Urzx7PBVmQGjv1dXdSV9" %.y]
=/  nft-acc-id  (fry-rice:smart pubkey-1 0xcafe.babe town-id `@`'nftsalt')
=/  nft-acc-grain
  :*  nft-acc-id
      0xcafe.babe
      0xbeef
      1
      [%& `@`'nftsalt' [`@ux`'nft' (malt ~[[1 item-1]]) ~ ~]]
  ==
=/  nft-wheat
  ^-  wheat:smart
  :-  `(cue q.q.nft-contract)
  (silt ~[`@ux`'nft-metadata' nft-acc-id])
=/  nft-wheat-grain
  ^-  grain:smart
  :*  0xcafe.babe     ::  id
      0xcafe.babe     ::  lord
      0xcafe.babe     ::  holder
      town-id         ::  town-id
      [%| nft-wheat]  ::  germ
  ==
::
=/  fake-granary
  ^-  granary:smart
  =/  grains=(list:smart (pair:smart id:smart grain:smart))
    :~  [id.zigs-wheat-grain zigs-wheat-grain]
        [id.zigs-metadata-grain zigs-metadata-grain]
        ::  [id.nft-wheat-grain nft-wheat-grain]
        ::  [id.nft-metadata-grain nft-metadata-grain]
        ::  [id.publish-grain publish-grain]
        [zigs-1 beef-zigs-grain]
        [zigs-2 dead-zigs-grain]
        [zigs-3 cafe-zigs-grain]
        ::  [nft-acc-id nft-acc-grain]
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
