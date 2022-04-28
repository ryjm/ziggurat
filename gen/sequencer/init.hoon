/-  *ziggurat
/+  smart=zig-sys-smart, deploy=zig-deploy
/*  zigs-contract  %noun  /lib/zig/compiled/zigs/noun
/*  nft-contract  %noun  /lib/zig/compiled/nft/noun
/*  publish-contract  %noun  /lib/zig/compiled/publish/noun
/*  fungible-contract  %txt  /lib/zig/contracts/fungible/hoon
=/  pubkey-1  0x3.e87b.0cbb.431d.0e8a.2ee2.ac42.d9da.cab8.063d.6bb6.2ff9.b2aa.e1b9.0f56.9c3f.3423
=/  pubkey-2  0x2.eaea.cffd.2bbe.e0c0.02dd.b5f8.dd04.e63f.297f.14cf.d809.b616.2137.126c.da9e.8d3d
=/  pubkey-3  0x2.4a1c.4643.b429.dc12.6f3b.03f3.f519.aebb.5439.08d3.e0bf.8fc3.cb52.b92c.9802.636e
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
      [%& `@`'zigs' [10.321.055.000.000.000.000 ~ `@ux`'zigs-metadata']]
  ==
=/  dead-zigs-grain  ::  ~bus
  ^-  grain:smart
  :*  zigs-2
      zigs-wheat-id:smart
      ::  associated seed: 0xdead
      pubkey-2
      town-id
      [%& `@`'zigs' [50.000.000.000.000.000.000 ~ `@ux`'zigs-metadata']]
  ==
=/  cafe-zigs-grain  ::  ~nec
  ^-  grain:smart
  :*  zigs-3
      zigs-wheat-id:smart
      ::  associated seed: 0xcafe
      pubkey-3
      town-id
      [%& `@`'zigs' [50.000.000.000.000.000.000 ~ `@ux`'zigs-metadata']]
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
      pubkey-1
      town-id
      [%& `@`'nftsalt' [`@ux`'nft-metadata' (malt ~[[1 item-1]]) ~ ~]]
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
        [id.nft-wheat-grain nft-wheat-grain]
        [id.nft-metadata-grain nft-metadata-grain]
        [id.publish-grain publish-grain]
        [zigs-1 beef-zigs-grain]
        [zigs-2 dead-zigs-grain]
        [zigs-3 cafe-zigs-grain]
        [nft-acc-id nft-acc-grain]
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
