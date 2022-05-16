|%
::
::  smart contract functions
::
::  +hole: vase-checks your types for you
::
++  hole
  |*  [typ=mold val=*]
  ^-  typ
  !<(typ [-:!>(*typ) val])
::
::  +fry: hash lord+town+germ to make contract grain pubkey
::
++  fry-contract
  |=  [lord=id town=@ud nok=*]
  ^-  id
  =+  (jam nok)
  `@ux`(sham (cat 3 lord (cat 3 town -))) 
::
++  fry-rice
  |=  [holder=id lord=id town=@ud salt=@]
  ::  TODO remove town from this possibly, for cross-town transfers
  ^-  id
  ^-  @ux
  %^  cat  3
    (end [3 8] (sham holder))
  (end [3 8] (sham (cat 3 town (cat 3 lord salt))))
::
::  +pin: get ID from caller
::
++  pin
  |=  =caller
  ^-  id
  ?:  ?=(@ux caller)
    caller
  id.caller
::
::  smart contract types
::
+$  id             @ux  ::  pubkey
++  zigs-wheat-id  `@ux`'zigs-contract'  ::  hardcoded "native" token contract
::
+$  account    [=id nonce=@ud zigs=id]
+$  caller     $@(id account)
+$  signature  [r=@ux s=@ux type=?(%schnorr %ecdsa)]
::
::  a grain holds either rice (data) or wheat (functions)
::
+$  grain  [=id lord=id holder=id town-id=@ud =germ]
+$  germ   (each rice wheat)
::
+$  rice   [salt=@ data=*]
+$  wheat  [cont=(unit *) owns=(set id)]
+$  crop   [nok=* owns=(map id grain)]  ::  wheat that's been processed by mill.hoon
::
+$  granary   (map id grain)
+$  populace  (map id @ud)
+$  town      (pair granary populace)
+$  land      (map @ud town)
::
::  cart: state accessible by contract
::
+$  cart
  $:  mem=(unit vase)
      me=id
      block=@ud
      town-id=@ud
      owns=(map id grain)
  ==
::
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
    ^|  |_  path
    ++  json
      *^json
    ++  noun
      *^noun
    --
  --
::  transaction types, fed into contract
::
::  egg error codes:
::  code can be anything upon submission,
::  gets set for chunk inclusion in +mill
::  0: successfully performed
::  1: submitted with raw id / no account info
::  2: bad signature
::  3: incorrect nonce
::  4: lack zigs to fulfill budget
::  5: couldn't find contract
::  6: crash in contract execution
::  7: validation of changed/issued rice failed
::
::  NOTE: continuation calls generate their own eggs, which
::  could potentially fail at one of these error points too.
::  currently keeping this simple, but could try to differentiate
::  between first-call and continuation-call errors later
::
+$  egg  (pair shell yolk)
+$  shell
  $:  from=caller
      sig=[v=@ r=@ s=@]  ::  sig on either hash of yolk or eth-hash
      eth-hash=(unit @)  ::  if transaction signed with eth wallet, use this to verify signature
      to=id
      rate=@ud
      budget=@ud
      town-id=@ud
      status=@ud  ::  error code
  ==
+$  yolk
  $:  =caller
      args=(unit *)
      my-grains=(set id)
      cont-grains=(set id)
  ==
::  yolk that's been "fertilized" with data by execution engine
+$  zygote
  $:  =caller
      args=(unit *)
      grains=(map id grain)
  ==
::
+$  chick    (each rooster hen)
::  new: crow, emit information about transaction to be picked up by interested parties
+$  rooster  [changed=(map id grain) issued=(map id grain) crow=(list [@tas json])]
+$  hen      [mem=(unit vase) next=[to=id town-id=@ud args=yolk] roost=rooster]
--
