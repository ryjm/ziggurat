::
::  capitol.hoon
::
::  Contract for managing towns on the Uqbar blockchain.
::  capitol.hoon is deployed on the main chain, where
::  validators execute transactions related to town entry
::  and exit. For transactions submitted here, the sender
::  must include in each transaction a signature from the
::  Urbit star whose town status they wish to modify.
::
|_  =cart
++  write
  |=  inp=zygote
  ^-  chick
  |^
  =/  caller-id  (pin caller.inp)
  ?~  args.inp  !!
  =*  args  +.u.args.inp
  ?-    -.u.args.inp  !!
      %init
    ::  start a new town if one with
    ::  that id doesn't exist
    [%& ~ ~]
  ::
      %join
    ::  become a sequencer on an
    ::  existing town
    [%& ~ ~]
  ::
      %exit
    ::  leave a town that you're
    ::  sequencing on
    [%& ~ ~]
  ==
  ::
  ::  existing towns
  ::
  +$  world
      (map town-id=@ud active=?)
  ::
  ::  town hall rice mold
  ::
  +$  hall
      $:  town-id=@ud
          council=(map id ship)
          order=(list id)
          chair=id
      ==
  --
::
++  read
  |=  inp=path
  ^-  *
  "TBD"
::
++  event
  |=  inp=rooster
  ^-  chick
  ::
  ::  TBD
  ::
  *chick
--
