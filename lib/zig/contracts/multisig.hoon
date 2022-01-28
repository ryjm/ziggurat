/+  *tiny
=>  |%
    +$  multisig-data
      $:  =id
          members=(set id)
          weights=(map id @ud)
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
      [%callback ~ ~[[lord.our-rice town-id.our-rice [%write lord.our-rice (silt ~[id.our-rice]) [~ %execute call.prop]]]]]
    =.  data.our-rice
      ?+    -.u.args.inp  data
          %submit-tx
        ::  expected args: tx (call), membersig
        data
      ::
          %approve
        ::  expected args: tx hash, membersig
        ?.  ?=([member=id] args)  ~
        ::  should emit event triggering actual call
        ::  if this sig pushes it over thresh
        data
      ::
          %add-member
        ::  expected args: id, weight (default 1)
        ::  this must be sent by contract
        data
      ::
          %change-weight
        ::  expected args: id, new weight
        ::  this must be sent by contract
        data
      ::
          %remove-member
        ::  expected args: id
        ::  this must be sent by contract
        data
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
      ?.  ?=([member=id] args)  *contract-output
      (~(get by weights.data) member.args)
    ::
        %get-threshold
      ::  expected args: none
      threshold.data
    ::
        %get-pending
      ::  expected args: tx hash
      ?.  ?=([id=@ux] args)  *contract-output
      (~(get by pending.data) id.args)
    ==
  ++  event
    |=  =contract-input
    ^-  contract-output
    [%result %read ~]
  --
--
