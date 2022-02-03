/+  *tiny
=>  |%
    +$  badge=@tas
    +$  role
      [badge desc=@t param=@tas]
    +$  daoist
      [=ship roles=(map badge role)]
    +$  dao-data
      $:  =id
          owners=(set id)          ::  merklized
          threshold=@ud
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
    =/  data  ;;(helix-data data.our-rice)
    =*  args  +.u.args.inp
    =.  data.our-rice
      ?+    -.u.args.inp  data
          %add-owner
        ::  expected args: id
        ?.  ?=(=id args)  data
        data(owners (~(put in owners.data) id.args))
      ::
          %remove-owner
        ::  expected args: id
        ?.  ?=(=id args)  data
        data(owners (~(del in owners.data) id.args))
      ::
          %edit-threshold
        ::  expected args: id
        ?.  ?=(new=@ud args)  data
        ?:  (gth new ~(wyt in owners.data))  data
        data(threshold new)
      ::
          %spawn  ::  add a 'subDAO' cell
        ::  expected args: id
        ?.  ?=(=id args)  data
        data(subdaos (~(put in subdaos.data) id.args))
      ::
          %jettison  ::  remove a 'subDAO' cell
        ::  expected args: id
        ?.  ?=(=id args)  data
        data(subdaos (~(del in subdaos.data) id.args))
      ::
          %join
        ::  expected args: id, daoist
        ?.  ?=([=id =daoist] args)  data
        data(daoists (~(put by daoists.data) id.args daoist.args))
      ::
          %exit
        ::  expected args: id
        ?.  ?=(=id args)  data
        data(daoists (~(del by daoists.data) id.args))
      ::
          %edit
        ::  expected args: id, daoist
        ?.  ?=([=id =daoist] args)  data
        data(daoists (~(del by daoists.data) id.args))
      ::
      ==
    :*  %result
        %write
        changed=(malt ~[[0x0 [%& our-rice]]])
        issued=~
    ==
  ::
  ++  read
    |=  inp=contract-input
    ^-  contract-output
    :+  %result
      %read
    ?~  args.inp  ~
    =/  our-rice=rice  -:~(val by rice.inp)
    =/  data  ;;(helix-data data.our-rice)
    =*  args  +.u.args.inp
    :+  %result  %read
    ^-  *
    ?+    -.u.args.inp  ~
        %get-daoist
      ::  expected args: id
      ?.  ?=(=id args)  ~
      (~(get by daoists.data) id.args)
    ::
        %get-roles
      ::  expected args: id
      ?.  ?=(=id args)  ~
      ?~  ist=(~(get by daoists.data) id.args)  ~
      roles.u.ist
    ::
        %get-role
      ::  expected args: id, badge (@tas)
      ?.  ?=([=id =badge] args)  ~
      ?~  ist=(~(get by daoists.data) id.args)  ~
      (~(get by roles.u.ist) badge.args)
    ::
        %get-ship
      ::  expected args: id
      ?.  ?=(=id args)  ~
      ?~  ist=(~(get by daoists.data) id.args)  ~
      ship.u.ist
    ::
    ==
  ::
  ++  event
    |=  inp=contract-input
    ^-  contract-output
    ?~  args.inp  *contract-output
    =/  caller-id
      ^-  id
      ?:  ?=(@ux caller.inp)
        caller.inp
      id.caller.inp
    =*  args  +.u.args.inp
    ::  ?+    -.u.args.inp  *contract-output
    ::  
    ::  ==
    *contract-output
  --
--
