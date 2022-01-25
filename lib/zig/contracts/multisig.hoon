/+  *tiny
=>  |%
    +$  multisig-data
      $:  =id
          members=(set id)
          weights=(map id @ud)
          threshold=@ud
          pending=(map @ux [=call votes=(set signature)])
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
    =/  our-rice=rice  -:~(val by rice.inp)
    =/  data  ;;(multisig-data data.our-rice)
    =*  args  +.u.args.inp
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
        changed=(malt ~[[id.our-rice our-rice]])
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
    |=  =event-args
    ^-  contract-output
    [%result %read ~]
  --
--