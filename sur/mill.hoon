|%
+$  id  @ux                   ::  pubkey
::
+$  user  [=id nonce=@ud]
::
+$  rice
  $:  =id
      owner=id
      helix-id=@ud
      data=*
      owns=(set id)
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
+$  output  [mutated=(map id rice) issued=(map id grain)]
::
+$  wheat
  $~  [0x0 ~]
  $:  =id
      contract=(unit contract)
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
+$  grain  (each rice wheat)
+$  mill   (map id grain)  :: replace with +merk
::
+$  signature  [r=@ux s=@ux type=?(%schnorr %ecdsa)]
::
+$  call-args
  $%([%read =id] [%write input])
::
+$  call
  $:  to=id
      budget=@ud
      =helix=id
      args=call-args
  ==
--
