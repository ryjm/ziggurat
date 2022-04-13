|%
::
::  smart contract functions
::
::  unclear whether these are useful
::
::  ++  output
::    |=  rice=(list [=grain data=(unit *) new=?])
::    ^-  chick
::    ::  produce a rooster
::    =+  issued=*(map id grain)
::    =+  changed=*(map id grain)
::    |-  ^-  chick
::    ?~  rice  [%& [changed issued]]
::    ::  ignoring contracts for now
::    ?.  ?=(%& -.germ.grain.i.rice)  $(rice t.rice)
::    =+  ?~  data.i.rice  grain.i.rice
::        grain.i.rice(data.p.germ u.data.i.rice)
::    ?:  new.i.rice
::      %=  $
::        rice  t.rice
::        issued  (~(put by issued) id.grain.i.rice -)
::      ==
::    %=  $
::      rice  t.rice
::      changed  (~(put by changed) id.grain.i.rice -)
::    ==
::  ::
::  ++  continuation
::    |=  $:  =cart
::            =caller
::            args=(unit *)
::            inputs=[(set id) (set id)]
::            rice=(list [=grain data=(unit *) new=?])
::        ==
::    ^-  chick
::    ::  produce a hen
::    =/  r=chick  (output rice)
::    :^  %|  ~
::      :+  me.cart  town-id.cart
::      [caller args inputs]
::    ?:  ?=(%& -.r)  p.r  [~ ~]
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
++  pin
  |=  =caller
  ^-  id
  ?:  ?=(@ux caller)
    caller
  id.caller
::
::  smart contract types
::
::  semantic aliases
+$  info          cart
+$  input         zygote
+$  result        chick
+$  final-result  [%& rooster]
+$  continuation  [%| hen]
+$  parcel  ::  ?? wtf to call this: grain that's proven rice
  $:  =id
      lord=id
      holder=id
      town-id=@ud
      germ=[%& rice]
  ==
::
+$  id             @ux  ::  pubkey
++  zigs-wheat-id  `@ux`'zigs-contract'  ::  hardcoded "native" token contract
::
+$  account    [=id nonce=@ud zigs=id]
+$  caller     $@(id account)
+$  signature  [r=@ux s=@ux type=?(%schnorr %ecdsa)]
::
+$  germ   (each rice wheat)
+$  rice   [salt=@ data=*]
::  TODO introduce kelvin versioning to contracts
+$  wheat  [cont=(unit *) owns=(set id)]
+$  crop   [nok=* owns=(map id grain)]
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
  ::  getting rid of this
  ++  event
    |~  rooster
    *chick
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
::  between first-call errors and continuation-call errors later
::
+$  egg  (pair shell yolk)
+$  shell
  $:  from=caller
      sig=[v=@ r=@ s=@] ::  signed hash of yolk
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
+$  zygote
  $:  =caller
      args=(unit *)
      grains=(map id grain)
  ==
::
+$  embryo   (each zygote rooster)
::
+$  chick    (each rooster hen)
::  add "crowing": list of [@tas json]
+$  rooster  [changed=(map id grain) issued=(map id grain)]
+$  hen      [mem=(unit vase) next=[to=id town-id=@ud args=yolk] roost=rooster]
--
