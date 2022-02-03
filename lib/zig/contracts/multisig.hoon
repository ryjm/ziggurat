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
    ::  TODO: fix unpleasant pattern:
    ::  should be able to grab a single rice from inp more easily
    ::  contract needs to either have rice ID or be able to name it or something
    ::  RELATED: contracts need access to their own ID somehow! i'm using
    ::  lord.our-rice here which is very ugly.
    ::
    ::  solution: make a stdlib arm for hashing new issued rice.
    ::  contracts store these
    ::  hash default version of rice mold
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
      ::  [%callback ~ ~[[to.call.prop town-id.call.prop args.call.prop]]]
      ::  =/  new-inp  args.call.prop
      ::  $
      *contract-output
    =.  data.germ.u.my-grain
      ?+    -.u.args.inp  data
          %submit-tx
        ::  expected args: tx (call)
        =/  submitted  ;;(call args)
        ::  validate member in multisig
        ?.  (~(has in members.data) caller-id)  *contract-output
        ::  TODO: put hash function in tiny.hoon
        data(pending (~(put by pending.data) 0x0 [submitted (silt ~[caller-id])]))
      ::
          %add-member
        ::  expected args: id
        ?.  ?=(=id args)  ~
        ::  this must be sent by contract
        ?.  =(me caller-id)  *contract-output
        data(members (~(put in members.data) id.args))
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
    *contract-output
    :: =/  our-rice=rice  -:~(val by rice.inp)
    :: =/  data  ;;(multisig-data our-rice)
    :: =*  args  +.u.args.inp
    :: ?+    -.u.args.inp  *contract-output
    ::     %get-members
    ::   ::  expected args: none
    ::   members.data
    :: ::
    ::     %get-member-weight
    ::   ::  expected args: member
    ::   ?.  ?=(member=id args)  *contract-output
    ::   (~(get by weights.data) member.args)
    :: ::
    ::     %get-threshold
    ::   ::  expected args: none
    ::   threshold.data
    :: ::
    ::     %get-pending
    ::   ::  expected args: tx hash
    ::   ?.  ?=(id=@ux args)  *contract-output
    ::   (~(get by pending.data) id.args)
    :: ==
  ++  event
    |=  inp=contract-result
    ^-  contract-output
    *contract-output
  --
--
