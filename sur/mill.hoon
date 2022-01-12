|%
+$  id  @ux                   ::  pubkey
++  zigs-id  0x0
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
      contract=(unit contract)
  ==
::
+$  caller  $@(id user)
::
+$  input
  $:  =caller
      rice=(set id)
      args=(unit noun)
  ==
::
+$  output
  $:  changed=(map id rice)
      issued=(map id grain)
      next=(list [to=id town-id=@ud args=call-args rice-id=id])
  ==
::
+$  contract
  $_  ^|
  |%
  ++  write
    |~  input
    *output
  ::
  ++  read
    |~  id
    *(unit grain)
  --
::
+$  grain     (each rice wheat)
+$  granary   (pair (map id grain) (map id @ud))    ::  replace with +merk
+$  town      (map id granary)  ::  "helix"
::
+$  signature  [r=@ux s=@ux type=?(%schnorr %ecdsa)]
::
+$  call-args
  $%([%read =id] [%write input])
::
+$  call
  $:  from=caller
      to=id
      rate=@ud
      budget=@ud
      =town=id
      args=call-args
      rice-id=id
  ==
--
