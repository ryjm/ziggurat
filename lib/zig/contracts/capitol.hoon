|_  =cart
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
::  TODO: verify ship signatures
::
++  write
  |=  inp=zygote
  ^-  chick
  |^
  ::  requires world rice in cart
  ::  join/exit requires hall rice in inp
  =/  world-grain=grain  (~(got by owns.cart) `@ux`'world')
  ?>  ?=(%& -.germ.world-grain)
  =*  world  (hole world-mold data.p.germ.world-grain)
  =/  caller-id  (pin caller.inp)
  ?~  args.inp  !!
  =*  args  +.u.args.inp
  ?+    -.u.args.inp  !!
      %init
    ::  start a new town if one with if that id doesn't exist
    ?.  ?=([sig=[p=@ux q=ship r=life] town-id=@ud] args)  !!
    ?:  (~(has by world) town-id.args)  !!
    =.  data.p.germ.world-grain
      (~(put by world) town-id.args (malt ~[[q.sig.args caller-id]]))
    [%& (malt ~[[id.world-grain world-grain]]) ~]
  ::
      %join
    ::  become a sequencer on an existing town
    ?.  ?=([sig=[p=@ux q=ship r=life] town-id=@ud] args)  !!
    ?~  current=`(unit (map ship id))`(~(get by world) town-id.args)  !!
    =/  new  (~(put by u.current) q.sig.args caller-id)
    =.  data.p.germ.world-grain
      (~(put by world) town-id.args new)
    [%& (malt ~[[id.world-grain world-grain]]) ~]
  ::
      %exit
    ::  leave a town that you're sequencing on
    ?.  ?=([sig=[p=@ux q=ship r=life] town-id=@ud] args)  !!
    ?~  current=`(unit (map ship id))`(~(get by world) town-id.args)  !!
    =/  new  (~(del by u.current) q.sig.args)
    =.  data.p.germ.world-grain
      (~(put by world) town-id.args new)
    [%& (malt ~[[id.world-grain world-grain]]) ~]
  ==
  ::
  ::  existing towns and their halls
  ::
  +$  world-mold
      (map town-id=@ud council=(map ship id))
  --
::
++  read
  |=  inp=path
  ^-  *
  "are these even needed anymore?"
::
++  event
  |=  inp=rooster
  ^-  chick
  ::
  ::  TBD
  ::
  *chick
--
