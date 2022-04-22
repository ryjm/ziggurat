::
::
::  DAO management contract
::
::  Provides the entire on-chain backend for an EScape DAO.
::  Holds a recording of members along with their roles. This
::  contract can serve unlimited DAOs, who simply store their
::  structure as rice held and ruled by this contract on-chain.
::
:: /+  *zig-sys-smart
|_  =cart
++  write
  |=  inp=zygote
  ^-  chick
  |^
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
    ::  expected args: salt, dao
    ::  of which the following may be null:
    ::  (TODO: fill)
    ?>  ?=([@ @t ^ ^ ^ ^ ^ @ud ^] args)  ::  is a dao:d?
    :: ?.  ?=([name=@t thresh=@ud owners=*] args)  !!
    :: =/  owners  ;;((set id) owners.args)
    =/  new-dao-germ=germ  [%& args]
    =/  new-dao-id=id
      (fry-rice me.cart me.cart town-id.cart -.args)
    =-  [%& ~ (malt ~[[new-dao-id -]])]
    :*  id=new-dao-id
        lord=me.cart
        holder=me.cart
        town-id=town-id.cart
        germ=new-dao-germ
    ==
  ::
  =/  dao-id=id  -:~(key by owns.cart)
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
            [%& caller-id]
            dao-id
            %write
            [%& dao]
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
      dao(proposals (~(del by proposals.dao) args))
    $(inp [me.cart `update.prop grains.inp])
  ::
  ::  create a proposal
  ::
  ?:  ?=(%propose -.u.args.inp)
    ::  must be sent by owner
    ?>  %:  is-allowed:dao-lib
            [%& caller-id]
            dao-id
            %write
            [%& dao]
        ==
    ::  expected args: on-chain-update
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
    ?+    -.update  !!
        %add-member
      (~(add-member update:dao-lib dao) +.update)
    ::
        %remove-member
      (~(remove-member update:dao-lib dao) +.update)
    ::
        %add-permissions
      (~(add-permissions update:dao-lib dao) +.update)
    ::
        %remove-permissions
      (~(remove-permissions update:dao-lib dao) +.update)
    ::
        %add-subdao
      (~(add-subdao update:dao-lib dao) +.update)
    ::
        %remove-subdao
      (~(remove-subdao update:dao-lib dao) +.update)
    ::
        %add-roles
      (~(add-roles update:dao-lib dao) +.update)
    ::
        %remove-roles
      (~(remove-roles update:dao-lib dao) +.update)
    ::
    ==
  [%& (malt ~[[id.my-grain my-grain(data.p.germ dao)]]) ~]
  ::
  ++  r  ::  landscape/sur/resource/hoon
    ^?
    |%
    +$  resource   [=entity name=term]
    +$  resources  (set resource)
    ::
    +$  entity
      $@  ship
      $%  !!
      ==
    --
  ::
  ++  ms  ::  landscape/sur/metadata-store/hoon
    ^?
    |%
    ::
    +$  app-name      term
    +$  md-resource   [=app-name =resource:r]
    +$  association   [group=resource:r =metadatum]
    +$  associations  (map md-resource association)
    +$  group-preview
      $:  group=resource:r
          channels=associations
          members=@ud
          channel-count=@ud
          =metadatum
      ==
    ::
    +$  color  @ux
    +$  url    @t
    ::
    ::  $vip-metadata: variation in permissions
    ::
    ::    This will be passed to the graph-permissions mark
    ::    conversion to allow for custom permissions.
    ::
    ::    %reader-comments: Allow readers to comment, regardless
    ::      of whether they can write. (notebook, collections)
    ::    %member-metadata: Allow members to add channels (groups)
    ::    %host-feed: Only host can post to group feed
    ::    %admin-feed: Only admins and host can post to group feed
    ::    %$: No variation
    ::
    +$  vip-metadata  
      $?  %reader-comments
          %member-metadata 
          %host-feed
          %admin-feed
          %$
      ==
    ::
    +$  md-config
      $~  [%empty ~]
      $%  [%group feed=(unit (unit md-resource))]
          [%graph module=term] 
          [%empty ~]
      ==
    ::
    +$  edit-field
      $%  [%title title=cord]
          [%description description=cord]
          [%color color=@ux]
          [%picture =url]
          [%preview preview=?]
          [%hidden hidden=?]
          [%vip vip=vip-metadata]
      ==
    ::
    +$  metadatum
      $:  title=cord
          description=cord
          =color
          date-created=time
          creator=ship
          config=md-config
          picture=url
          preview=?
          hidden=?
          vip=vip-metadata
      ==
    ::
    +$  action
      $%  [%add group=resource:r resource=md-resource =metadatum]
          [%remove group=resource:r resource=md-resource]
          [%edit group=resource:r resource=md-resource =edit-field]
          [%initial-group group=resource:r =associations]
      ==
    ::
    +$  hook-update
       $%  [%req-preview group=resource:r]
           [%preview group-preview]
       ==
    ::
    +$  update
      $%  action
          [%associations =associations]
          $:  %updated-metadata 
              group=resource:r
              resource=md-resource 
              before=metadatum
              =metadatum
          ==
      ==
    ::  historical
    ++  one
      |%
      ::
      +$  action
        $~  [%remove *resource:r *md-resource]
        $<  %edit  ^action
      ::
      +$  update
        $~  [%remove *resource:r *md-resource]
        $<  %edit  ^update
      ::
      --
    ++  zero
      |%
      ::
      +$  association   [group=resource:r =metadatum]
      ::
      +$  associations  (map md-resource association)
      ::
      +$  metadatum
        $:  title=cord
            description=cord
            =color
            date-created=time
            creator=ship
            module=term
            picture=url
            preview=?
            vip=vip-metadata
        ==
      ::
      +$  update
        $%  [%add group=resource:r resource=md-resource =metadatum]
            [%remove group=resource:r resource=md-resource]
            [%initial-group group=resource:r =associations]
            [%associations =associations]
            $:  %updated-metadata 
                group=resource:r
                resource=md-resource 
                before=metadatum
                =metadatum
            ==
        ==
      ::
      --
    ::
    --
  ::
  ++  d  ::  ziggurat/sur/dao/hoon
    |%
    +$  role     @tas  ::  E.g. %marketing, %development
    +$  address  ?(id resource:r)  ::  [chain=@tas id] for other chains?
    +$  member   (each id ship)
    ::  name might be, e.g., %read or %write for a graph;
    ::  %spend for treasury/rice
    +$  permissions  (map name=@tas (jug address role))
    +$  members      (jug id role)
    +$  id-to-ship   (map id ship)
    +$  ship-to-id   (map ship id)
    +$  dao
      $:  name=@t
          =permissions
          =members
          =id-to-ship
          =ship-to-id
          subdaos=(set id)
          :: owners=(set id)  ::  ? or have this in permissions?
          threshold=@ud
          proposals=(map @ux [update=on-chain-update votes=(set id)])
      ==
    ::
    +$  on-chain-update
      $%  [%add-dao =dao]
          [%remove-dao ~]
          [%add-member roles=(set role) =id him=ship]
          [%remove-member =id]
          [%add-permissions name=@tas =address roles=(set role)]
          [%remove-permissions name=@tas =address roles=(set role)]
          [%add-subdao subdao-id=id]
          [%remove-subdao subdao-id=id]
          [%add-roles roles=(set role) =id]
          [%remove-roles roles=(set role) =id]
      ==
    ::  off-chain
    ::
    +$  off-chain-update
      $%  [%on-chain dao-id=id update=on-chain-update]
          [%add-comms dao-id=id rid=resource:r]
          [%remove-comms dao-id=id]
      ==
    ::
    +$  dao-identifier  (each dao address)
    +$  daos            (map id dao)
    +$  dao-id-to-rid   (map id resource:r)
    +$  dao-rid-to-id   (map resource:r id)
    --
  ::
  ++  agentio  ::  base-dev/lib/agentio/hoon
    =>
      |%
      ++  card  card:agent:gall
      --
    ::
    |_  =bowl:gall
    ++  scry
      |=  [desk=@tas =path]
      %+  weld
        /(scot %p our.bowl)/[desk]/(scot %da now.bowl)
      path
    ::
    ++  pass
      |_  =wire
      ++  poke
        |=  [=dock =cage]
        [%pass wire %agent dock %poke cage]
      ::
      ++  poke-our
        |=  [app=term =cage]
        ^-  card
        (poke [our.bowl app] cage)
      ::
      ++  poke-self
        |=  =cage
        ^-  card
        (poke-our dap.bowl cage)
      ::
      ++  arvo
        |=  =note-arvo
        ^-  card
        [%pass wire %arvo note-arvo]
      ::
      ++  watch
        |=  [=dock =path]
        [%pass (watch-wire path) %agent dock %watch path]
      ::
      ++  watch-our
        |=  [app=term =path]
        (watch [our.bowl app] path)
      ::
      ++  watch-wire
        |=  =path
        ^+  wire
        ?.  ?=(~ wire)
          wire
        agentio-watch+path
      ::
      ++  leave
        |=  =dock
        [%pass wire %agent dock %leave ~]
      ::
      ++  leave-our
        |=  app=term
        (leave our.bowl app)
      ::
      ++  leave-path
        |=  [=dock =path]
        =.  wire
          (watch-wire path)
        (leave dock)
      ::
      ++  wait
        |=  p=@da
        (arvo %b %wait p)
      ::
      ++  rest
        |=  p=@da
        (arvo %b %wait p)
      ::
      ++  warp
        |=  [wer=ship =riff:clay]
        (arvo %c %warp wer riff)
      ::
      ++  warp-our
        |=  =riff:clay
        (warp our.bowl riff)
      ::
      ::  right here, right now
      ++  warp-slim
        |=  [genre=?(%sing %next) =care:clay =path]
        =/  =mood:clay
          [care r.byk.bowl path]
        =/  =rave:clay
          ?:(?=(%sing genre) [genre mood] [genre mood])
        (warp-our q.byk.bowl `rave)
      ::
      ++  connect
        |=  [=binding:eyre app=term]
        (arvo %e %connect binding app)
      --
    ::
    ++  fact-curry
      |*  [=mark =mold]
      |=  [paths=(list path) fac=mold]
      (fact mark^!>(fac) paths)
    ::
    ++  fact-kick
      |=  [=path =cage]
      ^-  (list card)
      :~  (fact cage ~[path])
          (kick ~[path])
      ==
    ::
    ++  fact-init
      |=  =cage
      ^-  card
      [%give %fact ~ cage]
    ::
    ++  fact-init-kick
      |=  =cage
      ^-  (list card)
      :~  (fact cage ~)
          (kick ~)
      ==
    ::
    ++  fact
      |=  [=cage paths=(list path)]
      ^-  card
      [%give %fact paths cage]
    ::
    ++  fact-all
      |=  =cage
      ^-  (unit card)
      =/  paths=(set path)
        %-  ~(gas in *(set path))
        %+  turn  ~(tap by sup.bowl)
        |=([duct ship =path] path)
      ?:  =(~ paths)  ~
      `(fact cage ~(tap in paths))
    ::
    ++  kick
      |=  paths=(list path)
      [%give %kick paths ~]
    ::
    ++  kick-only
      |=  [=ship paths=(list path)]
      [%give %kick paths `ship]
    --
  ::
  ++  rl  ::  landscape/lib/resource/hoon
    =<  resource
    |%
    +$  resource  resource:r
    ++  en-path
      |=  =resource
      ^-  path
      ~[%ship (scot %p entity.resource) name.resource]
    ::
    ++  de-path
      |=  =path
      ^-  resource
      (need (de-path-soft path))
    ::
    ++  de-path-soft
      |=  =path
      ^-  (unit resource)
      ?.  ?=([%ship @ @ *] path)
        ~
      =/  ship
        (slaw %p i.t.path)
      ?~  ship
        ~
      `[u.ship i.t.t.path]
    ::
    --
  ::
  ++  dao-lib  ::  ziggurat/lib/dao/hoon
    |_  =bowl:gall
    +*  io  ~(. agentio bowl)
    ::
    ++  get-members-and-permissions
      |=  =dao-identifier:d
      ^-  (unit [=members:d =permissions:d])
      ?~  dao=(get-dao dao-identifier)  ~
      `[members.u.dao permissions.u.dao]
    ::
    ++  get-id-to-ship
      |=  =dao-identifier:d
      ^-  (unit id-to-ship:d)
      ?~  dao=(get-dao dao-identifier)  ~
      `id-to-ship.u.dao
    ::
    ++  get-ship-to-id
      |=  =dao-identifier:d
      ^-  (unit ship-to-id:d)
      ?~  dao=(get-dao dao-identifier)  ~
      `ship-to-id.u.dao
    ::
    ++  member-to-id
      |=  [=member:d =dao-identifier:d]
      ^-  (unit id)
      ?:  ?=(%& -.member)  `p.member
      ?~  dao=(get-dao dao-identifier)  ~
      (~(get by ship-to-id.u.dao) p.member)
    ::
    ++  member-to-ship
      |=  [=member:d =dao-identifier:d]
      ^-  (unit ship)
      ?:  ?=(%| -.member)  `p.member
      ?~  dao=(get-dao dao-identifier)  ~
      (~(get by id-to-ship.u.dao) p.member)
    ::
    ++  get-dao
      |=  =dao-identifier:d
      ^-  (unit dao:d)
      ?:  ?=(%& -.dao-identifier)  `p.dao-identifier
      =/  scry-path=path
        ?:  ?=(id p.dao-identifier)
          /daos/(scot %ux p.dao-identifier)/noun
        :(weld /daos (en-path:rl p.dao-identifier) /noun)
      .^  (unit dao:d)
          %gx
          %+  scry:io  %dao
          scry-path
      ==
    ::
    ++  is-allowed
      |=  $:  =member:d
              =address:d
              permission-name=@tas
              =dao-identifier:d
          ==
      ^-  ?
      ?~  dao=(get-dao dao-identifier)                                %.n
      ?~  permissioned=(~(get by permissions.u.dao) permission-name)  %.n
      ?~  roles-with-access=(~(get ju u.permissioned) address)        %.n
      ?~  user-id=(member-to-id member [%& u.dao])                    %.n
      ?~  ship-roles=(~(get ju members.u.dao) u.user-id)              %.n
      ?!  .=  0
      %~  wyt  in
      %-  ~(int in `(set role:d)`ship-roles)
      `(set role:d)`roles-with-access
    ::
    ++  is-allowed-admin-write-read
      |=  $:  =member:d
              =address:d
              =dao-identifier:d
          ==
      ^-  [? ? ?]
      ?~  dao=(get-dao dao-identifier)  [%.n %.n %.n]
      :+  (is-allowed member address %admin [%& u.dao])
        (is-allowed member address %write [%& u.dao])
      (is-allowed member address %read [%& u.dao])
    ::
    ++  is-allowed-write
      |=  $:  =member:d
              =address:d
              =dao-identifier:d
          ==
      ^-  ?
      (is-allowed member address %write dao-identifier)
    ::
    ++  is-allowed-read
      |=  $:  =member:d
              =address:d
              =dao-identifier:d
          ==
      ^-  ?
      (is-allowed member address %read dao-identifier)
    ::
    ++  is-allowed-admin
      |=  $:  =member:d
              =address:d
              =dao-identifier:d
          ==
      ^-  ?
      (is-allowed member address %admin dao-identifier)
    ::
    ++  is-allowed-host
      |=  $:  =member:d
              =address:d
              =dao-identifier:d
          ==
      ^-  ?
      (is-allowed member address %host dao-identifier)
    ::
    ++  update
      |_  =dao:d
      ::
      ++  add-member
        |=  [roles=(set role:d) =id him=ship]
        ^-  dao:d
        =/  existing-ship=(unit ship)
          (~(get by id-to-ship.dao) id)
        ?:  ?=(^ existing-ship)
          ?:  =(him u.existing-ship)  dao
          ~|  "%dao: cannot add member whose id corresponds to a different ship"
          !!
        =/  existing-id=(unit ^id)
          (~(get by ship-to-id.dao) him)
        ?:  ?=(^ existing-id)
          ?:  =(id u.existing-id)  dao
          ~|  "%dao: cannot add member whose ship corresponds to a different id"
          !!
        ::
        %=  dao
          id-to-ship  (~(put by id-to-ship.dao) id him)
          ship-to-id  (~(put by ship-to-id.dao) him id)
          members
            %-  ~(gas ju members.dao)
            (make-noun-role-pairs id roles)
        ==
      ::
      ++  remove-member
        |=  [=id]
        ^-  dao:d
        ?~  him=(~(get by id-to-ship.dao) id)
          ~|  "%dao: cannot find given member to remove in id-to-ship"
          !!
        ?~  existing-id=(~(get by ship-to-id.dao) u.him)
          ~|  "%dao: cannot find given member to remove in ship-to-id"
          !!
        ~|  "%dao: given id does not match records"
        ?>  =(id u.existing-id)
        ?~  roles=(~(get ju members.dao) id)  !!
        %=  dao
          id-to-ship  (~(del by id-to-ship.dao) id)
          ship-to-id  (~(del by ship-to-id.dao) u.him)
          members
            (remove-roles-helper members.dao roles id)
        ==
      ::
      ++  add-permissions
        |=  [name=@tas =address:d roles=(set role:d)]
        ^-  dao:d
        %=  dao
          permissions
            %:  add-permissions-helper
                name
                permissions.dao
                roles
                address
        ==  ==
      ::
      ++  remove-permissions
        |=  [name=@tas =address:d roles=(set role:d)]
        ^-  dao:d
            %=  dao
              permissions
                %:  remove-permissions-helper
                    name
                    permissions.dao
                    roles
                    address
            ==  ==
      ::
      ++  add-subdao
        |=  subdao-id=id
        ^-  dao:d
        dao(subdaos (~(put in subdaos.dao) subdao-id))
      ::
      ++  remove-subdao
        |=  subdao-id=id
        ^-  dao:d
        dao(subdaos (~(del in subdaos.dao) subdao-id))
      ::
      ++  add-roles
        |=  [roles=(set role:d) =id]
        ^-  dao:d
        ?~  (~(get ju members.dao) id)
          ~|  "%dao: cannot find given member to add roles to"
          !!
        %=  dao
          members
            %-  ~(gas ju members.dao)
            (make-noun-role-pairs id roles)
        ==
      ::
      ++  remove-roles
        |=  [roles=(set role:d) =id]
        ^-  dao:d
        ?~  (~(get ju members.dao) id)
          ~|  "%dao: cannot find given member to remove roles from"
          !!
        dao(members (remove-roles-helper members.dao roles id))
      ::
      ++  add-permissions-helper
        |=  [name=@tas =permissions:d roles=(set role:d) =address:d]
        ^-  permissions:d
        =/  permission=(unit (jug address:d role:d))
          (~(get by permissions) name)
        =/  pairs=(list (pair address:d role:d))
          (make-noun-role-pairs address roles)
        %+  %~  put  by  permissions
          name
        %-  %~  gas  ju
          ?~  permission
            *(jug address:d role:d)
          u.permission
        pairs
      ::
      ++  remove-permissions-helper
        |=  [name=@tas =permissions:d roles=(set role:d) =address:d]
        ^-  permissions:d
        ?~  permission=(~(get by permissions) name)  permissions
        =/  pairs=(list (pair address:d role:d))
          (make-noun-role-pairs address roles)
        |-
        ?~  pairs  (~(put by permissions) name u.permission)
        =.  u.permission  (~(del ju u.permission) i.pairs)
        $(pairs t.pairs)
      ::
      ++  remove-roles-helper
        |=  [=members:d roles=(set role:d) =id]
        ^-  members:d
        =/  pairs=(list (pair ^id role:d))
          (make-noun-role-pairs id roles)
        |-
        ?~  pairs  members
        =.  members  (~(del ju members) i.pairs)
        $(pairs t.pairs)
      ::
      ++  make-noun-role-pairs
        |*  [noun=* roles=(set role:d)]
        ^-  (list (pair _noun role:d))
        %+  turn  ~(tap in roles)
        |=  =role:d
        [p=noun q=role]
      ::
      --
    ::
    --
  ::
  --
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
