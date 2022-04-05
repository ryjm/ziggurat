/-  d=dao
/+  *zig-sys-smart,
    dao-lib=dao
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
  |=  inp=zygote
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
  ?:  ?=(%add-dao -.u.args.inp)
    ::  start a new 'root cell' for a new DAO
    ::  expected args: dao
    ::  of which the following may be null:
    ::  (TODO: fill)
    ?>  ?=(dao:d args)
    :: ?.  ?=([name=@t thresh=@ud owners=*] args)  !!
    :: =/  owners  ;;((set id) owners.args)
    =/  new-dao-germ=germ  [%& args]
    =/  new-dao-id=id  (fry caller-id 0 new-dao-germ)
    =-  [%& (malt ~[[new-dao-id -]])]
    :*  id=new-dao-id
        lord=me.cart
        holder=me.cart
        town-id=town-id.cart
        germ=new-dao-germ
    ==
  ::
  =/  dao-id=grain  -:~(key by owns.cart)
  =/  my-grain=grain  -:~(val by owns.cart)
  ?>  =(lord.my-grain me.cart)
  ?>  ?=(%& -.germ.my-grain)
  =/  dao  (hole dao:d data.p.germ.my-grain)
  ::
  ::  vote on a proposal
  ::
  ?:  ?=(%vote -.u.args.inp)
    ::  must be sent by owner
    ?>  %:  is-allowed:dao-lib
            caller-id
            grain-id
            %write
            members.dao
            permissions.dao
        ==
    ::  expected args: hash of proposal
    ?>  ?=(@ux args)
    =/  prop  (~(got by proposals.dao) args)
    =.  prop  prop(votes (~(put in votes.prop) caller-id))
    ?:  (gth threshold.dao ~(wyt in votes.prop))
      ::  if threshold is higher than current # of votes,
      ::  just register vote and update rice
      [%& (malt ~[[id.my-grain my-grain(data.p.germ dao)]]) ~]
    ::  otherwise execute proposal and remove from rice
    =.  data.p.germ.my-grain
      dao(proposals (~(del by proposals.dao) id.args))
    $(inp [me.cart `update.prop grains.inp])
  ::
  ::  create a proposal
  ::
  ?:  ?=(%propose -.u.args.inp)
    ::  must be sent by owner
    ?>  %:  is-allowed:dao-lib
            caller-id
            grain-id
            %write
            members.dao
            permissions.dao
        ==
    ::  expected args: on-chain-update
    ?>  ?=(on-chain-update:d args)
    =/  update  ;;(on-chain-update:d args)
    =.  proposals.dao
      %+  ~(put by proposals.dao)
        (mug update)
      [update (silt ~[caller-id])]
    [%& (malt ~[[id.my-grain my-grain(data.p.germ dao)]]) ~]
  ::
  ::  execute a proposal (called only by this contract)
  ::
  ?>  =(me.cart caller-id)
  =/  update  ;;(on-chain-update:d (need args.inp))
  =.  dao
    ?-    -.update
        %add-member
      (~(add-member dao-lib dao) +.update)
    ::
        %remove-member
      (~(remove-member dao-lib dao) +.update)
    ::
        %add-permissions
      (~(add-permissions dao-lib dao) +.update)
    ::
        %remove-permissions
      (~(remove-permissions dao-lib dao) +.update)
    ::
        %add-subdao
      (~(add-subdao dao-lib dao) +.update)
    ::
        %remove-subdao
      (~(remove-subdao dao-lib dao) +.update)
    ::
        %add-roles
      (~(add-roles dao-lib dao) +.update)
    ::
        %remove-roles
      (~(remove-roles dao-lib dao) +.update)
    ::
    ==
  [%& (malt ~[[id.my-grain my-grain(data.p.germ dao)]]) ~]
::
++  read
  |=  inp=path
  ^-  *
  "TBD"
::
++  event
  |=  inp=rooster
  ^-  chick
  ::  
  ::  TBD
  ::  
  *chick
--
