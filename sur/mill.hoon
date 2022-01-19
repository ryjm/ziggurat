|%
+$  id  @ux                   ::  pubkey
++  zigs-wheat    0x0
++  zigs-rice-id  0x1
::
+$  user  [=id nonce=@ud]
::
+$  rice
  $:  =id
      holder=id
      lord=id
      town-id=@ud
      data=*
      holds=(set id)
  ==
::
+$  wheat
  $~  [0x0 ~]
  $:  =id
      contract=(unit hoon)
  ==
::
+$  caller  $@(id user)
::
+$  contract-args
  $%([%read contract-input] [%write contract-input])
+$  contract-input
  $:  =caller
      rice=(map id rice)
      args=(unit noun)
  ==
+$  event-args
  $%  [%read town-id=@ud contract-input]
      [%write town-id=@ud from=id output]
  ==
::
+$  result
  [changed=(map id rice) issued=(map id grain)]
+$  continuation
  [mem=(unit vase) next=(list [to=id town-id=@ud args=call-args])]
+$  output  (each result continuation)
::
+$  contract
  $_  ^&
  |_  mem=(unit vase)
  ++  write
    |~  contract-input
    *output
  ::
  ++  read
    |~  contract-input
    *noun  ::  *(unit grain)
  ++  event
    |~  event-args
    *output
  --
::
+$  grain     (each rice wheat)
+$  granary   (pair (map id grain) (map id @ud))    ::  replace with +merk
+$  town      (map id granary)  ::  "helix"
::
+$  signature  [r=@ux s=@ux type=?(%schnorr %ecdsa)]
::
+$  call-args
  $%([%read call-input] [%write call-input])
+$  call-input
  $:  =caller
      rice=(set id)
      args=(unit noun)
  ==
::
+$  call
  $:  from=caller
      to=id
      rate=@ud
      budget=@ud
      town-id=@ud
      args=call-args
  ==
--
