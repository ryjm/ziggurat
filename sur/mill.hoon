|%
+$  id  @ux                   ::  pubkey
++  zigs-wheat-id  0x0
++  zigs-rice-id  0x1
::
+$  user  [=id nonce=@ud]
+$  caller  $@(id user)
+$  signature  [r=@ux s=@ux type=?(%schnorr %ecdsa)]
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
+$  grain     (each rice wheat)
+$  granary   (pair (map id grain) (map id @ud))    ::  replace with +merk
+$  town      (map @ud granary)  ::  "helix"
--
