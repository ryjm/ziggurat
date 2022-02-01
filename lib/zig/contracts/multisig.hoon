/+  *tiny
=>  |%
    +$  multisig-data
      $:  =id
          members=(set id)
          threshold=@ud
          pending=(map @ux [=call votes=(set id)])
      ==
    --
|%
++  multisig-contract
  ^-  contract
  |_  mem=(unit vase)
  ++  write
    |=  inp=contract-input
    ^-  contract-output
    ?~  args.inp  *contract-output
    =/  caller-id
      ^-  id
      ?:  ?=(@ux caller.inp)
        caller.inp
      id.caller.inp
    ::  TODO: fix upleasant pattern:
    ::  should be able to grab a single rice from inp more easily
    ::  contract needs to either have rice ID or be able to name it or something
    ::  RELATED: contracts need access to their own ID somehow! i'm using
    ::  lord.our-rice here which is very ugly.
    =/  our-rice=rice  -:~(val by rice.inp)
    =/  data  ;;(multisig-data data.our-rice)
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
        =.  data.our-rice  data
        [%result %write (malt ~[[id.our-rice [%& our-rice]]]) ~]
      [%callback ~ ~[[to.call.prop town-id.call.prop args.call.prop]]]
    =.  data.our-rice
      ?+    -.u.args.inp  data
          %submit-tx
        ::  expected args: tx (call)
        ?.  ?=(=call args)  ~
        ::  validate member in multisig
        ?.  (~(has in members.data) caller-id)  *contract-output
        ::  TODO: put hash function in tiny.hoon
        data(pending (~(put by pending.data) 0x0 [call (silt ~[caller-id])]))
      ::
          %add-member
        ::  expected args: id
        ?.  ?=(=id args)  ~
        ::  this must be sent by contract
        ::  ?.  =(our-id caller-id)  *contract-output
        data(members (~(put in members.data) id))
      ::
          %remove-member
        ::  expected args: id
        ?.  ?=(=id args)  ~
        ::  this must be sent by contract
        ::  ?.  =(our-id caller-id)  *contract-output
        data(members (~(del in members.data) id))
      ::
          %set-threshold
        ::  expected args: new-thresh
        ?.  ?=(new-thresh=@ud args)  ~
        ::  this must be sent by contract
        ::  ?.  =(our-id caller-id)  *contract-output
        data(threshold new-thresh)
      ==
    :*  %result
        %write
        changed=(malt ~[[id.our-rice [%& our-rice]]])
        issued=~
    ==
  ++  read
    |=  inp=contract-input
    ^-  contract-output
    :+  %result
      %read
    ?~  args.inp  *contract-output
    =/  our-rice=rice  -:~(val by rice.inp)
    =/  data  ;;(multisig-data our-rice)
    =*  args  +.u.args.inp
    ?+    -.u.args.inp  *contract-output
        %get-members
      ::  expected args: none
      members.data
    ::
        %get-member-weight
      ::  expected args: member
      ?.  ?=(member=id args)  *contract-output
      (~(get by weights.data) member.args)
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
    |=  inp=contract-input
    ^-  contract-output
    *contract-output
  --
--
