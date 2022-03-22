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
::  TODO: verify ship signatures!
::
++  write
  |=  inp=zygote
  ^-  chick
  |^
  =/  caller-id  (pin caller.inp)
  ?~  args.inp  !!
  =*  args  +.u.args.inp
  ?+    -.u.args.inp  !!
  ::  calls to create, join, or exit a town
  ::
      %init
    =/  world-grain=grain  (~(got by owns.cart) `@ux`'world')
    ?>  ?=(%& -.germ.world-grain)
    =*  world  (hole world-mold data.p.germ.world-grain)
    ::  start a new town if one with if that id doesn't exist
    ?.  ?=([=sig town-id=@ud] args)  !!
    ?:  (~(has by world) town-id.args)  !!
    =.  data.p.germ.world-grain
      (~(put by world) town-id.args (malt ~[[q.sig.args [caller-id sig.args]]]))
    [%& (malt ~[[id.world-grain world-grain]]) ~]
  ::
      %join
    =/  world-grain=grain  (~(got by owns.cart) `@ux`'world')
    ?>  ?=(%& -.germ.world-grain)
    =*  world  (hole world-mold data.p.germ.world-grain)
    ::  become a sequencer on an existing town
    ?.  ?=([=sig town-id=@ud] args)  !!
    ?~  current=`(unit (map ship [id sig]))`(~(get by world) town-id.args)  !!
    =/  new  (~(put by u.current) q.sig.args [caller-id sig.args])
    =.  data.p.germ.world-grain
      (~(put by world) town-id.args new)
    [%& (malt ~[[id.world-grain world-grain]]) ~]
  ::
      %exit
    =/  world-grain=grain  (~(got by owns.cart) `@ux`'world')
    ?>  ?=(%& -.germ.world-grain)
    =*  world  (hole world-mold data.p.germ.world-grain)
    ::  leave a town that you're sequencing on
    ?.  ?=([=sig town-id=@ud] args)  !!
    ?~  current=`(unit (map ship [id sig]))`(~(get by world) town-id.args)  !!
    =/  new  (~(del by u.current) q.sig.args)
    =.  data.p.germ.world-grain
      (~(put by world) town-id.args new)
    [%& (malt ~[[id.world-grain world-grain]]) ~]
  ::
  ::  calls to join/exit as a validator on the main chain
  ::
      %become-validator
    =/  ziggurat-grain=grain  (~(got by owns.cart) `@ux`'ziggurat')
    ?>  ?=(%& -.germ.ziggurat-grain)
    =*  ziggurat  (hole ziggurat-mold data.p.germ.ziggurat-grain)
    ::  join the chain
    ?.  ?=(sig args)  !!
    =.  data.p.germ.ziggurat-grain  (~(put by ziggurat) q.args args)
    [%& (malt ~[[id.ziggurat-grain ziggurat-grain]]) ~]
  ::
      %stop-validating
    =/  ziggurat-grain=grain  (~(got by owns.cart) `@ux`'ziggurat')
    ?>  ?=(%& -.germ.ziggurat-grain)
    =*  ziggurat  (hole ziggurat-mold data.p.germ.ziggurat-grain)
    ::  leave the chain
    ?.  ?=(sig args)  !!
    =.  data.p.germ.ziggurat-grain  (~(del by ziggurat) q.args)
    [%& (malt ~[[id.ziggurat-grain ziggurat-grain]]) ~]
  ==
  +$  sig  [p=@ux q=ship r=life]
  ::
  ::  validators on main chain
  ::
  +$  ziggurat-mold  (map ship sig)
  ::
  ::  existing towns and their halls
  ::
  +$  world-mold
    (map town-id=@ud council=(map ship [id sig]))
  --
::
::  TBD
::
++  read
  |=  inp=path
  ^-  *
  %tbd
::
++  event
  |=  inp=rooster
  ^-  chick
  *chick
--
