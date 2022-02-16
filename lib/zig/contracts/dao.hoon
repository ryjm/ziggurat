/+  *tiny
=>  |%
    +$  badge  @tas
    +$  role
      [=badge desc=@t param=@tas]
    +$  daoist
      [=ship roles=(map badge role)]
    +$  dao-data
      $:  name=@t
          owners=(set id)          ::  merklized
          threshold=@ud
          proposals=(map @ux [=call votes=(set id)])
          daoists=(map id daoist)  ::  merklized
          ::  set of rice that hold subDAO info. these
          ::  rice must also fit the mold of $dao-data
          subdaos=(set id)
      ==
    --
::
::  DAO management contract
::
::  Provides the entire on-chain backend for an EScape DAO.
::  Holds a recording of members along with their roles. This
::  contract should be owned by a multisig contract, which
::  serves as the final source of truth for the DAO.
::
::  owner-multisig is lord of this contract
::  owners set here should match that multisig
::  if this contract is to be mutable. otherwise
::  can set lord to 0x0 or whatever to make immutable
::
|%
++  dao-contract
  ^-  contract
  |_  [mem=(unit vase) me=id]
  ++  write
    |=  inp=contract-input
    ^-  contract-output
    ?~  args.inp  !!
    =/  caller-id
      ^-  id
      ?:  ?=(@ux caller.inp)
        caller.inp
      id.caller.inp
    ?:  ?=(%create-dao -.u.args.inp)
      ::  start a new 'root cell' for a new DAO
      ::  expected args: name, initial owner set,
      ::  initial threshold, initial daoist set
      ::  TODO no good way to have list-args yet
      =/  new-dao-germ  [%& [caller-id ~ ['newDAO']]]
      =/  new-dao-id  (fry caller-id 0 new-dao-germ)
      [%result %write ~ issued=(malt ~[[new-dao-id [new-dao-id caller-id 0 new-dao-germ]]])]
    ::  TODO! Contracts should deal with any rice,
    ::  not just those hardcoded by pubkey. We want
    ::  people to be able to deploy their own rice
    ::  that matches the contract's types and use
    ::  the function bundle in the contract to edit
    ::  their rice. This would let a single dao-contract
    ::  work for a TON of DAOs...
    ::
    ::  Possible solution: include ID of your rice as
    ::  an argument in your call. Doing this below:
    =*  my-grain-id  -.+.u.args.inp
    ?.  ?=(@ux my-grain-id)  !!
    ?~  my-grain=(~(get by rice.inp) my-grain-id)  !!
    ?>  =(lord.u.my-grain me)
    =/  data  !<(dao-data [-:!>(*dao-data) data.germ.u.my-grain])
    =*  args  +.+.u.args.inp
    ?:  ?=(%vote -.u.args.inp)
      ::  must be sent by owner
      ?.  (~(has in owners.data) caller-id)  !!
      ::  expected args: hash of proposal
      ?.  ?=(id=@ux args)  !!
      ?~  prop=(~(get by proposals.data) id.args)  !!
      =.  u.prop  u.prop(votes (~(put in votes.u.prop) caller-id))
      ?:  (gth threshold.data ~(wyt in votes.u.prop))
        =.  data.germ.u.my-grain  data
        [%result %write changed=(malt ~[[my-grain-id u.my-grain]]) ~]
      =.  data.germ.u.my-grain
        data(proposals (~(del by proposals.data) id.args))
      =/  next
        `contract-input`[me args.args.call.u.prop rice.inp]
      $(inp next)
    =.  data
      ?+    -.u.args.inp  !!
          %add-owner
        ::  this must be sent by contract
        ?.  =(me caller-id)  !!
        ::  expected args: id
        ?.  ?=(=id args)  !!
        data(owners (~(put in owners.data) id.args))
      ::
          %remove-owner
        ?.  =(me caller-id)  !!
        ::  expected args: id
        ?.  ?=(=id args)  !!
        data(owners (~(del in owners.data) id.args))
      ::
          %edit-threshold
        ?.  =(me caller-id)  !!
        ::  expected args: id
        ?.  ?=(new=@ud args)  !!
        ?:  (gth new.args ~(wyt in owners.data))  data
        data(threshold new.args)
      ::
          %spawn  ::  add a 'subDAO' cell
        ?.  =(me caller-id)  !!
        ::  expected args: id
        ?.  ?=(=id args)  !!
        data(subdaos (~(put in subdaos.data) id.args))
      ::
          %jettison  ::  remove a 'subDAO' cell
        ?.  =(me caller-id)  !!
        ::  expected args: id
        ?.  ?=(=id args)  !!
        data(subdaos (~(del in subdaos.data) id.args))
      ::
          %join
        ?.  =(me caller-id)  !!
        ::  expected args: id, ship, role
        ?.  ?=([=id =ship =role] args)  !!
        =/  new-daoist
          [ship.args (malt ~[[badge.role.args role.args]])]
        data(daoists (~(put by daoists.data) id.args new-daoist))
      ::
          %exit
        ?.  =(me caller-id)  !!
        ::  expected args: id
        ?.  ?=(=id args)  !!
        data(daoists (~(del by daoists.data) id.args))
      ::
          %edit
        ?.  =(me caller-id)  !!
        ::  expected args: id, ship, role
        ::  TODO: change to set of roles once we can
        ?.  ?=([=id =ship =role] args)  !!
        =/  new-daoist
          [ship.args (malt ~[[badge.role.args role.args]])]
        data(daoists (~(put by daoists.data) id.args new-daoist))
      ::
      ==
    :*  %result
        %write
        changed=(malt ~[[id.u.my-grain u.my-grain]])
        issued=~
    ==
  ::
  ++  read
    |=  inp=contract-input
    ^-  contract-output
    :+  %result
      %read
    ?~  args.inp  ~
    =*  my-grain-id  -.+.u.args.inp
    ?.  ?=(@ux my-grain-id)  !!
    ?~  my-grain=(~(get by rice.inp) my-grain-id)  !!
    =/  data  !<(dao-data [-:!>(*dao-data) data.germ.u.my-grain])
    =*  args  +.+.u.args.inp
    :+  %result  %read
    ^-  *
    ?+    -.u.args.inp  !!
        %get-daoist
      ::  expected args: id
      ?.  ?=(=id args)  !!
      (~(get by daoists.data) id.args)
    ::
        %get-roles
      ::  expected args: id
      ?.  ?=(=id args)  !!
      ?~  ist=(~(get by daoists.data) id.args)  !!
      roles.u.ist
    ::
        %get-role
      ::  expected args: id, badge (@tas)
      ?.  ?=([=id =badge] args)  !!
      ?~  ist=(~(get by daoists.data) id.args)  !!
      (~(get by roles.u.ist) badge.args)
    ::
        %get-ship
      ::  expected args: id
      ?.  ?=(=id args)  !!
      ?~  ist=(~(get by daoists.data) id.args)  !!
      ship.u.ist
    ::
    ==
  ::
  ++  event
    |=  inp=contract-result
    ^-  contract-output
    ::  
    ::  TBD
    ::  
    *contract-output
  --
--
