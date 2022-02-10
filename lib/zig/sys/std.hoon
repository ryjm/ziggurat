|%
::
::  contract functions
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
  (mug (cat 3 lord (cat 3 town (mug germ))))
::  our types
::
+$  id  @ux                   ::  pubkey
++  zigs-wheat-id  0x0
++  zigs-rice-id  0x1
::
+$  user  [=id nonce=@ud]
+$  caller  $@(id user)
+$  signature  [r=@ux s=@ux type=?(%schnorr %ecdsa)]
::
+$  germ  (each rice wheat)
::
+$  rice
  $:  holder=id
      ::  holds=(set id)
      data=*
  ==
::
+$  wheat  (unit *)
::
+$  grain
  $:  =id
      lord=id
      town-id=@ud
      =germ
  ==
::
+$  granary   (map id grain)    ::  replace with +merk
+$  populace  (map id @ud)
+$  town      (pair granary populace)
+$  land      (map @ud town)
::
+$  contract
  $_  ^|
  |_  [mem=(unit vase) me=id]
  ++  write
    |~  contract-input
    *contract-output
  ::
  ++  read
    |~  contract-input
    *contract-output
  ::
  ++  event
    |~  contract-result
    *contract-output
  --
::
+$  call
  $:  from=caller
      to=id
      rate=@ud
      budget=@ud
      town-id=@ud
      args=call-args
  ==
::
+$  call-args
  [?(%read %write) call-input]
+$  call-input
  $:  =caller
      rice-ids=(set id)
      args=(unit noun)
  ==
::
+$  contract-args
  $%  [?(%read %write) contract-input]
      [%event contract-result]
  ==
::
+$  contract-input
  $:  =caller
      args=(unit noun)
      rice=contract-input-rice
  ==
::
+$  contract-input-rice
  %+  map  id
  $:  =id
      lord=id
      town-id=@ud
      germ=[%& rice]
  ==
::
+$  contract-output
  $%  [%result p=contract-result]
      [%callback p=continuation]
  ==
::
+$  contract-result
  $%  [%read =noun]
      [%write changed=(map id grain) issued=(map id grain)]
  ==
::
+$  continuation  [mem=(unit vase) next=[to=id town-id=@ud args=call-args]]
--
