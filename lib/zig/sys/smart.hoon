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
  ?.  ?=(%& -.germ)
    (mug (cat 3 lord (cat 3 town (mug germ))))
  ::  `format.p.germ`s subject can differ by context
  ::  so do not include it in the hash
  (mug (cat 3 lord (cat 3 town (mug data.p.germ))))

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
+$  germ   (each rice wheat)
+$  rice   [format=(unit mold) data=*]
+$  wheat  [cont=(unit *) owns=(set id)]
+$  crop   [=contract owns=(set id)]
::
+$  grain
  $:  =id
      lord=id
      holder=id
      town-id=@ud
      =germ
  ==
::
+$  granary   (map id grain)    ::  replace with +merk
+$  populace  (map id @ud)
+$  town      (pair granary populace)
+$  land      (map @ud town)
::
+$  cart
  $:  mem=(unit vase)
      me=id
      block=@ud
      town-id=@ud
      owned=(map id grain)
  ==
+$  contract
  $_  ^|
  |_  cart
  ++  write
    |~  scramble
    *chick
  ::
  ++  read
    |~  path
    *noun
  ::
  ++  event
    |~  male
    *chick
  --
::
+$  stamp
  $:  fee=id
      rate=@ud
      budget=@ud
  ==
::
+$  egg  (pair shell yolk)
+$  shell
  $:  from=caller
      to=id
      =stamp
      town-id=@ud
  ==
+$  yolk
  $:  =caller
      args=(unit *)
      grain-ids=(set id)
  ==
+$  scramble
  $:  =caller
      args=(unit *)
      grains=(map id grain)
  ==
::
+$  maybe-hatched  (each scramble male)
::
+$  chick   (each male female)
+$  male    [changed=(map id (unit grain)) issued=(map id grain)]
+$  female  [mem=(unit vase) next=[to=id town-id=@ud args=yolk]]
--
