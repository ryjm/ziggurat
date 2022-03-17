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
    =/  new-hall-germ
      :-  %&
      ^-  *
      :-  town-id.args
          (malt ~[[q.sig.args caller-id]])
    =/  new-hall-hash=id
      `@ux`(sham (cat 3 me.cart (cat 3 0 (jam new-hall-germ))))
    =.  data.p.germ.world-grain  (~(put by world) town-id.args new-hall-hash)
    :+  %&
      (malt ~[[id.world-grain world-grain]])
    (malt ~[[new-hall-hash [new-hall-hash me.cart me.cart 0 new-hall-germ]]])
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
      (~(del by world) town-id.args)
    :+  %&
      [[id.world-grain world-grain] ~ ~]
    [[id.hall-grain hall-grain] ~ ~]
  ==
  ::
  ::  existing towns and the rice that store their hall
  ::
  +$  world-mold
      (map town-id=@ud address=id)
  ::
  ::  town hall rice mold
  ::
  +$  hall-mold
      $:  town-id=@ud
          council=(map ship id)
          ::  stakes=(map ship amt=@ud)
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
