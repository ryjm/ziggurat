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
::  /+  *zig-sys-smart
|_  =cart
++  write
  |=  inp=zygote
  ^-  chick
  |^
  ?~  args.inp  !!
  (process (hole arguments u.args.inp) (pin caller.inp))
  ::
  ::  molds used by this contract
  ::
  +$  sig       [p=@ux q=ship r=@ud]
  +$  ziggurat  (map ship sig)
  +$  world     (map town-id=@ud council=(map ship [id sig]))
  ::
  +$  arguments
    $%  [%init =sig town=@ud]
        [%join =sig town=@ud]
        [%exit =sig town=@ud]
        [%become-validator sig]
        [%stop-validating sig]
    ==
  ::
  ::  process a call
  ::
  ++  process
    |=  [args=arguments caller-id=id]
    ?-    -.args
    ::
    ::  calls to join/exit as a sequencer on a town, or make a new one
    ::
        %init
      ::  start a new town if one with if that id doesn't exist
      =/  worl=grain  (~(got by owns.cart) `@ux`'world')
      ?>  ?=(%& -.germ.worl)
      =/  =world  (hole world data.p.germ.worl)
      ?:  (~(has by world) town.args)  !!
      =.  data.p.germ.worl
        (~(put by world) town.args (malt ~[[q.sig.args [caller-id sig.args]]]))
      [%& (malt ~[[id.worl worl]]) ~]
    ::
        %join
      ::  become a sequencer on an existing town
      =/  worl=grain  (~(got by owns.cart) `@ux`'world')
      ?>  ?=(%& -.germ.worl)
      =/  =world  (hole world data.p.germ.worl)
      ?~  current=`(unit (map ship [id sig]))`(~(get by world) town.args)  !!
      =/  new  (~(put by u.current) q.sig.args [caller-id sig.args])
      =.  data.p.germ.worl
        (~(put by world) town.args new)
      [%& (malt ~[[id.worl worl]]) ~]
    ::
        %exit
      ::  leave a town that you're sequencing on
      =/  worl=grain  (~(got by owns.cart) `@ux`'world')
      ?>  ?=(%& -.germ.worl)
      =/  =world  (hole world data.p.germ.worl)
      ?~  current=`(unit (map ship [id sig]))`(~(get by world) town.args)  !!
      =/  new  (~(del by u.current) q.sig.args)
      =.  data.p.germ.worl
        (~(put by world) town.args new)
      [%& (malt ~[[id.worl worl]]) ~]
    ::
    ::  calls to join/exit as a validator on the main chain
    ::
        %become-validator
      =/  zigg=grain  (~(got by owns.cart) `@ux`'ziggurat')
      ?>  ?=(%& -.germ.zigg)
      =/  =ziggurat  (hole ziggurat data.p.germ.zigg)
      ?<  (~(has by ziggurat) q.args)
      =.  data.p.germ.zigg  (~(put by ziggurat) q.args +.args)
      [%& (malt ~[[id.zigg zigg]]) ~]
    ::
        %stop-validating
      =/  zigg=grain  (~(got by owns.cart) `@ux`'ziggurat')
      ?>  ?=(%& -.germ.zigg)
      =/  =ziggurat  (hole ziggurat data.p.germ.zigg)
      ?>  (~(has by ziggurat) q.args)
      =.  data.p.germ.zigg  (~(del by ziggurat) q.args)
      [%& (malt ~[[id.zigg zigg]]) ~]
    ==
  --
::
++  read
  |=  inp=path
  ^-  *
  ::  TODO support reads such as 'get-validators' and 'get-sequencers' on given town
  ~
--
