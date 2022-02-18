/+  *zig-sys-smart
=>  |%
    +$  multisig-data
      $:  members=(set id)
          threshold=@ud
          pending=(map @ux [=egg votes=(set id)])
      ==
    --
|_  =cart
++  write
  |=  inp=scramble
  ^-  chick
  ?~  args.inp  !!
  =/  caller-id
    ^-  id
    ?:  ?=(@ux caller.inp)
      caller.inp
    id.caller.inp
  =*  args  +.u.args.inp
  ?:  ?=(%create-multisig -.u.args.inp)
    ::  issue a new multisig rice
    ::  expected args: initial threshold, initial member set
    ::  (each following arg is a member id, terminated by ~)
    ?.  ?=([thresh=@ud members=*] args)  !!
    =/  members  ;;((set id) members.args)
    =/  new-sig-germ  [%& ~ [members thresh.args ~]]
    =/  new-sig-id  (fry caller-id 0 new-sig-germ) 
    =-  [%& ~ (malt ~[[new-sig-id -]])]
    [new-sig-id me.cart me.cart town-id.cart new-sig-germ]
  =/  my-grain=grain  -:~(val by owned.cart)
  ?>  =(lord.my-grain me.cart)
  ?>  ?=(%& -.germ.my-grain)
  =/  data  (hole multisig-data data.p.germ.my-grain)
  ?:  ?=(%vote -.u.args.inp)
    ::  expected args: tx hash
    ::  should emit event triggering actual call
    ::  if this sig pushes it over thresh
    ?.  ?=(hash=@ux args)  !!
    ::  validate member in multisig
    ?.  (~(has in members.data) caller-id)  !!
    ?~  prop=(~(get by pending.data) hash.args)  !!
    =/  prop  u.prop(votes (~(put in votes.u.prop) caller-id))
    =.  pending.data  (~(put by pending.data) hash.args prop)
    ::  check if proposal is at threshold, execute if so
    ::  otherwise simply update rice
    ?:  (gth threshold.data ~(wyt in votes.prop))
      =.  data.p.germ.my-grain  data
      [%& (malt ~[[id.my-grain my-grain]]) ~]
    =.  data.p.germ.my-grain
      data(pending (~(del by pending.data) hash.args))
    ::  if the pending egg is a multisig action, just
    ::  recurse with $
    ::  otherwise issue a female chick with the call.
    *chick
  =.  data.p.germ.my-grain
    ?+    -.u.args.inp  !!
        %submit-tx
      ::  validate member in multisig
      ?.  (~(has in members.data) caller-id)  !!
      ::  expected args: tx (call)
      =/  submitted  ;;(egg args)
      data(pending (~(put by pending.data) (mug submitted) [submitted (silt ~[caller-id])]))
    ::
        %add-member
      ::  this must be sent by contract
      ?.  =(me.cart caller-id)  !!
      ::  expected args: id
      ?.  ?=(=id args)  !!
      data(members (~(put in members.data) id.args))
    ::
        %remove-member
      ::  this must be sent by contract
      ?.  =(me.cart caller-id)  !!
      ::  expected args: id
      ?.  ?=(=id args)  !!
      data(members (~(del in members.data) id))
    ::
        %set-threshold
      ::  this must be sent by contract
      ?.  =(me.cart caller-id)  !!
      ::  expected args: new-thresh
      ?.  ?=(new-thresh=@ud args)  !!
      data(threshold new-thresh.args)
    ==
  [%& (malt ~[[id.my-grain my-grain]]) ~]
++  read
  |=  inp=path
  ^-  *
  ::  TODO scrys
  69
++  event
  |=  inp=male
  ^-  chick
  *chick
--
