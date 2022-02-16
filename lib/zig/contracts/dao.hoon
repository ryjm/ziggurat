/+  *zig-sys-smart
=>  |%
    +$  badge  @tas
    +$  role
      [=badge desc=@t param=@tas]
    +$  daoist
      [=ship roles=(map badge role)]
    +$  action
      $%  [%add-owner =id]
          [%remove-owner =id]        
          [%edit-threshold new=@ud]
          [%spawn =id subdao=dao-data]  ::  generate new subDAO
          [%jettison =id]               ::  remove subDAO
          [%join =id =daoist]           ::  add new member
          [%exit =id]                   ::  remove member
          [%edit =id =daoist]           ::  alter member roleset
      ==
    +$  dao-data
      $:  name=@t
          owners=(set id)          ::  merklized
          threshold=@ud
          proposals=(map @ux [act=action votes=(set id)])
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
::  contract can serve unlimited DAOs, who simply store their
::  structure as rice owned by this contract on-chain.
::
|_  =cart
++  write
  |=  inp=scramble
  ^-  chick
  ?~  args.inp  !!
  =*  args  +.u.args.inp
  ::  make this a stdlib function, every contract uses it
  =/  caller-id
    ^-  id
    ?:  ?=(@ux caller.inp)
      caller.inp
    id.caller.inp
  ::
  ::  create a brand-new DAO
  ::
  ?:  ?=(%create-dao -.u.args.inp)
    ::  start a new 'root cell' for a new DAO
    ::  expected args: name, initial owner set,
    ::  initial threshold
    ?.  ?=([name=@t thresh=@ud owners=*] args)  !!
    =/  owners  ;;((set id) owners.args)
    =/  new-dao-germ  [%& ~ [name.args owners thresh.args ~ ~ ~]]
    =/  new-dao-id  (fry caller-id 0 new-dao-germ)
    =-  [%& ~ (malt ~[[new-dao-id -]])]
    [new-dao-id me.cart me.cart town-id.cart new-dao-germ]  
  ::
  =/  my-grain=grain  -:~(val by owned.cart)
  ?>  =(lord.my-grain me.cart)
  ?>  ?=(%& -.germ.my-grain)
  =/  data  (hole dao-data data.p.germ.my-grain)
  ::
  ::  vote on a proposal
  ::
  ?:  ?=(%vote -.u.args.inp)
    ::  must be sent by owner
    ?.  (~(has in owners.data) caller-id)  !!
    ::  expected args: hash of proposal
    ?.  ?=(id=@ux args)  !!
    =/  prop  (~(got by proposals.data) id.args)
    =.  prop  prop(votes (~(put in votes.prop) caller-id))
    ?:  (gth threshold.data ~(wyt in votes.prop))
      ::  if threshold is higher than current # of votes,
      ::  just register vote and update rice
      [%& (malt ~[[id.my-grain my-grain(data.p.germ data)]]) ~]
    ::  otherwise execute proposal and remove from rice
    =.  data.p.germ.my-grain
      data(proposals (~(del by proposals.data) id.args))
    $(inp [me.cart `act.prop grains.inp])
  ::
  ::  create a proposal
  ::
  ?:  ?=(%propose -.u.args.inp)
    ::  must be sent by owner
    ?.  (~(has in owners.data) caller-id)  !!
    ::  expected args: action
    =/  act  ;;(action args)
    =.  proposals.data
      %+  ~(put by proposals.data)
        (mug act)
      [act (silt ~[caller-id])]
    [%& (malt ~[[id.my-grain my-grain(data.p.germ data)]]) ~]
  ::
  ::  execute a proposal (called only by this contract)
  ::
  ?>  =(me.cart caller-id)
  =/  act  ;;(action (need args.inp))
  =.  data
    ?-    -.act
        %add-owner
      data(owners (~(put in owners.data) id.act))
    ::
        %remove-owner
      data(owners (~(del in owners.data) id.act))
    ::
        %edit-threshold
      ?:  (gth new.act ~(wyt in owners.data))  !!
      data(threshold new.act)
    ::
        %spawn
      ::  actually need to issue rices here
      data(subdaos (~(put in subdaos.data) id.act))
    ::
        %jettison
      data(subdaos (~(del in subdaos.data) id.act))
    ::
        %join
      data(daoists (~(put by daoists.data) id.act daoist.act))
    ::
        %exit
      data(daoists (~(del by daoists.data) id.act))
    ::
        %edit
      data(daoists (~(put by daoists.data) id.act daoist.act))
    ::
    ==
  [%& (malt ~[[id.my-grain my-grain(data.p.germ data)]]) ~]
::
++  read
  |=  inp=path
  ^-  *
  "TBD"
::
++  event
  |=  inp=male
  ^-  chick
  ::  
  ::  TBD
  ::  
  *chick
--