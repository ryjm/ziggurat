/+  *tiny
=>  |%
    +$  multisig-data
      $:  members=(set id)
          threshold=@ud
          pending=(map @ux [=call votes=(set id)])
      ==
    ::  result of (mug [0xbeef 0 [%& *(set @) *@ud *(map @ @)]])
    ++  my-rice-id  0x2f49.8146
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
    ?~  my-grain=(~(get by rice.inp) my-rice-id)  *contract-output
    =/  data  ;;(multisig-data data.germ.u.my-grain)
    =*  args  +.u.args.inp
    ?:  ?=(%approve -.u.args.inp)
      ::  expected args: tx hash
      ::  should emit event triggering actual call
      ::  if this sig pushes it over thresh
      ?.  ?=(hash=@ux args)  *contract-output
      ::  validate member in multisig
      ?.  (~(has in members.data) caller-id)  *contract-output
      ?~  prop=(~(get by pending.data) hash.args)  *contract-output
      =/  prop  u.prop(votes (~(put in votes.u.prop) caller-id))
      =.  pending.data  (~(put by pending.data) hash.args prop)
      ::  check if proposal is at threshold, execute if so
      ::  otherwise simply update rice
      ?:  (gth threshold.data ~(wyt in votes.prop))
        =.  data.germ.u.my-grain  data
        [%result %write changed=(malt ~[[my-rice-id u.my-grain]]) issued=~]
      =/  new-inp
        `contract-input`[me args.args.call.prop rice.inp]
      $(inp new-inp)
    =.  data.germ.u.my-grain
      ?+    -.u.args.inp  data
          %submit-tx
        ::  validate member in multisig
        ?.  (~(has in members.data) caller-id)  *contract-output
        ::  expected args: tx (call)
        =/  submitted  ;;(call args)
        data(pending (~(put by pending.data) (mug submitted) [submitted (silt ~[caller-id])]))
      ::
          %add-member
        ::  this must be sent by contract
        ?.  =(me caller-id)  *contract-output
        ::  expected args: id
        ?.  ?=(=id args)  ~
        data(members (~(put in members.data) id.args))
      ::
          %remove-member
        ::  this must be sent by contract
        ?.  =(me caller-id)  *contract-output
        ::  expected args: id
        ?.  ?=(=id args)  ~
        data(members (~(del in members.data) id))
      ::
          %set-threshold
        ::  this must be sent by contract
        ?.  =(me caller-id)  *contract-output
        ::  expected args: new-thresh
        ?.  ?=(new-thresh=@ud args)  ~
        data(threshold new-thresh.args)
      ==
    :*  %result
        %write
        changed=(malt ~[[my-rice-id u.my-grain]])
        issued=~
    ==
  ++  read
    |=  inp=contract-input
    ^-  contract-output
    :+  %result
      %read
    ?~  args.inp  *contract-output
    ?~  my-grain=(~(get by rice.inp) my-rice-id)  *contract-output
    =/  data  ;;(multisig-data data.germ.u.my-grain)
    =*  args  +.u.args.inp
    ?+    -.u.args.inp  *contract-output
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
      ?.  ?=(id=@ux args)  *contract-output
      (~(get by pending.data) id.args)
    ==
  ++  event
    |=  inp=contract-result
    ^-  contract-output
    *contract-output
  --
--
