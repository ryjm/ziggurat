|%
::
::  smart contract functions
::
::  +hole: vase-checks your types for you
++  hole
  |*  [typ=mold val=*]
  ^-  typ
  !<(typ [-:!>(*typ) val])
::
::  +fry: hash lord+town+germ to make grain pubkey
::  TODO make sha256 or w/e for testnet
++  fry
  |=  [lord=id town=@ud =germ]
  ^-  @ux
  =-  (mug (cat 3 lord (cat 3 town -)))
  ?.  ?=(%| -.germ)
    (mug germ)
  ::  fry ignores owns.wheat in hash
  (mug cont.p.germ)
::
::  +pin: get ID from caller
++  pin
  |=  =caller
  ^-  id
  ?:  ?=(@ux caller)
    caller
  id.caller
::
::  smart contract types
::
+$  id  @ux             ::  pubkey
++  zigs-wheat-id  0x0  ::  hardcoded "native" token contract
::
+$  chunk   [(list [@ux egg]) town]
::
+$  account  [=id nonce=@ud zigs=id]
+$  caller  $@(id account)
+$  signature  [r=@ux s=@ux type=?(%schnorr %ecdsa)]
::
+$  germ   (each rice wheat)
+$  rice   data=*
+$  wheat  [cont=(unit *) owns=(set id)]
+$  crop   [=contract owns=(map id grain)]
::
+$  grain
  $:  =id
      lord=id
      holder=id
      town-id=@ud
      =germ
  ==
::
+$  granary   (map id grain)  ::  TODO: replace with +merk
+$  populace  (map id @ud)
+$  town      (pair granary populace)
+$  land      (map @ud town)
::  state accessible by contract
::
+$  cart
  $:  mem=(unit vase)
      me=id
      block=@ud
      town-id=@ud
      owns=(map id grain)
  ==
::  contract definition
::
+$  contract
  $_  ^|
  |_  cart
  ++  write
    |~  zygote
    *chick
  ::
  ++  read
    |~  path
    *noun
  ::
  ++  event
    |~  rooster
    *chick
  --
::  transaction types, fed into contract
::
+$  egg  (pair shell yolk)
+$  shell
  $:  from=caller
      to=id
      rate=@ud
      budget=@ud
      town-id=@ud
  ==
+$  yolk
  $:  =caller
      args=(unit *)
      my-grains=(set id)
      cont-grains=(set id)
  ==
+$  zygote
  $:  =caller
      args=(unit *)
      grains=(map id grain)
  ==
::
+$  embryo   (each zygote rooster)
::
+$  chick    (each rooster hen)
+$  rooster  [changed=(map id grain) issued=(map id grain)]
+$  hen      [mem=(unit vase) next=[to=id town-id=@ud args=yolk]]
--
