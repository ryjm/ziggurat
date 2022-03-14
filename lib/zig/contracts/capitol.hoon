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
/+  *zig-sys-smart
|_  =cart
++  write
  |=  inp=zygote
  ^-  chick
  |^
  ::  requires world rice in cart
  ::  join/exit requires hall rice in inp
  =/  world-grain  (~(got by owns.cart) `@ux`'world')
  ?>  ?=(%& -.germ.world-grain)
  =*  world  (hole world-mold data.p.germ.world-grain)
  =/  caller-id  (pin caller.inp)
  ?~  args.inp  !!
  =*  args  +.u.args.inp
  ?+    -.u.args.inp  !!
      %init
    ::  start a new town if one with if that id doesn't exist
    ?.  ?=([sig=[p=@ux q=ship r=life] town-id=@ud] args)  !!
    =/  active  (~(get by world) town-id.args)
    ?.  ?|(?=(~ active) !u.active)  !!
    =/  new-hall-germ
      :-  %&
      :^    town-id.args
          (malt ~[[q.sig.args caller-id]])
        [q.sig.args]~
      q.sig.args
    =/  new-hall-hash
      (fry 0x0 0 new-hall-germ)
    =.  data.p.germ.world-grain  (~(put by world) town-id.args %.y)
    :+  %&
      [[id.world-grain world-grain] ~ ~]
    [[new-hall-hash [new-hall-hash 0x0 0x0 0 new-hall-germ]] ~ ~]
  ::
      %join
    ::  become a sequencer on an existing town
    ?.  ?=([sig=[p=@ux q=ship r=life] town-id=@ud] args)  !!
    ?.  (~(has by world) town-id.args)  !!
    =/  hall-grain=grain  -:~(val by grains.inp)
    ?>  ?=(%& -.germ.hall-grain)
    =/  hall  (hole hall-mold data.p.germ.hall-grain)
    =.  data.p.germ.hall-grain
      hall(council (~(put by council.hall) q.sig.args caller-id))
    :+  %&  ~
    [[id.hall-grain hall-grain] ~ ~]
  ::
      %exit
    ::  leave a town that you're sequencing on
    ?.  ?=([sig=[p=@ux q=ship r=life] town-id=@ud] args)  !!
    ?.  (~(has by world) town-id.args)  !!
    =/  hall-grain=grain  -:~(val by grains.inp)
    ?>  ?=(%& -.germ.hall-grain)
    =/  hall  (hole hall-mold data.p.germ.hall-grain)
    =/  updated  hall(council (~(del by council.hall) q.sig.args))
    =.  data.p.germ.hall-grain  updated
    ?.  =(0 ~(wyt by council.updated))
      ::  town is still active
      :+  %&  ~
      [[id.hall-grain hall-grain] ~ ~]
    ::  town has no sequencers and is thus inactive
    =.  data.p.germ.world-grain
      (~(put by world) town-id.args %.n)
    :+  %&
      [[id.world-grain world-grain] ~ ~]
    [[id.hall-grain hall-grain] ~ ~]
  ==
  ::
  ::  existing towns
  ::
  +$  world-mold
      (map town-id=@ud active=?)
  ::
  ::  town hall rice mold
  ::
  +$  hall-mold
      $:  town-id=@ud
          council=(map ship id)
          ::  stakes=(map ship amt=@ud)
          order=(list ship)
      ==
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
