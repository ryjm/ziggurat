/+  *tiny
=>  |%
    +$  multisig-data
      $:  members=(set id)
          threshold=@ud
          pending=(map @ux [=call votes=(set id)])
      ==
    --
|%
++  multisig-contract
  ^-  contract
  |_  [mem=(unit vase) me=id]
  ++  write
    |=  inp=contract-input
    ^-  contract-output
    ?~  args.inp  *contract-output
    =/  caller-id
      ^-  id
      ?:  ?=(@ux caller.inp)
        caller.inp
      id.caller.inp
    ?:  ?=(%create-multisig -.u.args.inp)
      =*  args  +.u.args.inp
      ::  issue a new multisig rice
      ::  expected args: initial member set, initial threshold
      ::  TODO make member set arg once that's figured out
      ?.  ?=([members=ship thresh=@ud] args)  !!
      =/  new-sig-germ  [%& [caller-id ~ ['newMULTISIG']]]
      =/  new-sig-id  (fry caller-id 0 new-sig-germ)
      [%result %write ~ issued=(malt ~[[new-sig-id [new-sig-id caller-id 0 new-sig-germ]]])]
    =*  my-grain-id  -.+.u.args.inp
    ?.  ?=(@ux my-grain-id)  !!
    ?~  my-grain=(~(get by rice.inp) my-grain-id)  !!
    =/  data  !<(multisig-data !>(data.germ.u.my-grain))
    =*  args  +.+.u.args.inp
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
        =.  data.germ.u.my-grain  data
        [%result %write changed=(malt ~[[my-grain-id u.my-grain]]) issued=~]
      =.  data.germ.u.my-grain
        data(pending (~(del by pending.data) hash.args))
      =/  next
        `contract-input`[me args.args.call.prop rice.inp]
      $(inp next)
    =.  data.germ.u.my-grain
      ?+    -.u.args.inp  data
          %submit-tx
        ::  validate member in multisig
        ?.  (~(has in members.data) caller-id)  !!
        ::  expected args: tx (call)
        =/  submitted  ;;(call args)
        data(pending (~(put by pending.data) (mug submitted) [submitted (silt ~[caller-id])]))
      ::
          %add-member
        ::  this must be sent by contract
        ?.  =(me caller-id)  !!
        ::  expected args: id
        ?.  ?=(=id args)  !!
        data(members (~(put in members.data) id.args))
      ::
          %remove-member
        ::  this must be sent by contract
        ?.  =(me caller-id)  !!
        ::  expected args: id
        ?.  ?=(=id args)  !!
        data(members (~(del in members.data) id))
      ::
          %set-threshold
        ::  this must be sent by contract
        ?.  =(me caller-id)  !!
        ::  expected args: new-thresh
        ?.  ?=(new-thresh=@ud args)  !!
        data(threshold new-thresh.args)
      ==
    :*  %result
        %write
        changed=(malt ~[[my-grain-id u.my-grain]])
        issued=~
    ==
  ++  read
    |=  inp=contract-input
    ^-  contract-output
    :+  %result
      %read
    ?~  args.inp  !!
    =*  my-grain-id  -.+.u.args.inp
    ?.  ?=(@ux my-grain-id)  !!
    ?~  my-grain=(~(get by rice.inp) my-grain-id)  !!
    =/  data  !<(multisig-data !>(data.germ.u.my-grain))
    =*  args  +.+.u.args.inp
    ?+    -.u.args.inp  !!
        %get-members
      ::  expected args: none
      members.data
    ::
        %get-threshold
      ::  expected args: none
      threshold.data
    ::
        %get-pending
      ::  expected args: tx hash
      ?.  ?=(id=@ux args)  !!
      (~(get by pending.data) id.args)
    ==
  ++  event
    |=  inp=contract-result
    ^-  contract-output
    *contract-output
  --
--
