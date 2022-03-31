::  dao:
::
::  Store DAOs of ships
::
::    %dao stores DAOs and keeps them updated to
::    the latest chain state, so that resources
::    and other apps can be associated with a DAO.
::
::
::    ## Scry paths
::
::    /y/daos:
::      A listing of current DAO id:rid pairs
::    /x/daos/[id]:
::      The DAO itself
::    /x/daos/[resource]:
::      The DAO itself
::
::    ## Subscription paths (TODO)
::
::    /daos:
::      A stream of the current updates to the state, sending the initial state
::      upon subscribe.
::
::    ##  Pokes
::
::    %dao-update:
::      Update the DAO. Further documented in /sur/dao.hoon
::
::
/-  uqbar-indexer,
    d=dao,
    res=resource
/+  agentio,
    dbug,
    default-agent,
    verb,
    daol=dao,
    reslib=resource,
    smart=zig-sys-smart
::
|%
+$  card  card:agent:gall
::
+$  versioned-state
  $%  state-zero
  ==
::
+$  state-zero
  $:  %0
      =daos:d
      =dao-id-to-rid:d
      =dao-rid-to-id:d
      indexer=(unit dock) ::  TODO: indexer should be set of indexers?
  ==
--
::
=|  state-zero
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
=<
  |_  =bowl:gall
  +*  this      .
      dao-core  +>
      dc        ~(. dao-core bowl)
      def       ~(. (default-agent this %|) bowl)
      io        ~(. agentio bowl)
  ::
  ++  on-init  `this
  ++  on-save  !>(state)
  ++  on-load
    |=  =old=vase
    =/  old  !<(versioned-state old-vase)
    ?-  -.old
      %0  `this(state old)
    ==
  ::
  ++  on-poke  ::  on-poke:def
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?>  (team:title our.bowl src.bowl)
    =^  cards  state
      ?+  mark  (on-poke:def mark vase)
      ::
          %dao-update
        (dao-update:dc !<(off-chain-update:d vase))
      ::
      ::     %send-to-chain
      ::   =+  !<(rid=resource:res vase)
      ::   ?~  dao=(has-write-dao-permissions:dc rid)  !!
      ::   %+  %~  poke-our  pass:io  /send-to-chain
      ::     %wallet
      ::   :-  %zig-wallet-poke
      ::   !>  ^-  wallet-poke:zig
      ::   :*  %submit
      ::       sequencer=~
      ::       to=dao-contract-id
      ::       town=dao-town-id
      ::       gas=[rate=1 bud=1]
      ::       args=~
      ::       my-grains=(~(put in *(set @ux)) dao-id.dao)
      ::       cont-grains=~
      ::   ==
      ::
          %set-indexer
        (set-indexer:dc !<(dock vase))
      ::
      ==
    [cards this]
  ::
  ++  on-watch  on-watch:def
  ++  on-leave  on-leave:def
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?+  path  (on-peek:def path)
        [%y %daos ~]
      ``noun+!>(`dao-id-to-rid:d`dao-id-to-rid)
    ::
        [%x %daos @ ~]
      =/  dao-id=id:smart  (slav %ux i.t.t.path)
      ``noun+!>(`(unit dao:d)`(peek-dao:dc dao-id))
    ::
        [%x %daos %ship @ @ ~]
      =/  rid=(unit resource:res)
        (de-path-soft:reslib t.t.path)
      ?~  rid   ~
      ``noun+!>(`(unit dao:d)`(peek-dao:dc u.rid))
    ::
    ==
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ?+  wire  (on-agent:def wire sign)
    ::
        [%dao-update @ ~]
      =/  dao-id=id:smart  (slav %ux i.t.wire)
      ?+  -.sign  (on-agent:def wire sign)
      ::
          %kick
        :_  this
        ?~  (peek-dao dao-id)  ~
        ?~  wi=(watch-indexer dao-id)  ~
        ~[u.wi]
      ::
          %fact
        |^
        =+  !<(=update:uqbar-indexer q.cage.sign)
        ?>  ?=(%grain -.update)
        =/  new-dao=dao:d
          (get-dao-from-update update)
        =*  members  members.new-dao
        ?~  (~(get by ship-to-id.new-dao) our.bowl)
          ::  We are no longer in DAO: remove it.
          =^  cards  state
            (remove-dao:dc dao-id)
          [cards this]
        ::  We are still in DAO: update it.
        :-  ~
        %=  this
          daos  (~(put by daos) dao-id new-dao)  :: TODO: instead walk through and make minimal change to existing structure?
        ==
        ::
        ++  get-dao-from-update
          |=  =update:uqbar-indexer
          ^-  dao:d
          ?>  ?=(%grain -.update)
          =/  grains=(list [location:uqbar-indexer grain:smart])
            ~(tap in grains.update)
          ?>  =(1 (lent grains))
          =/  [* dao-grain=grain:smart]  (snag 0 grains)
          ?>  ?=(%& -.germ.dao-grain)
          ;;(dao:d p.germ.dao-grain)
        ::
        --
      ::
      ==
    ::
    ==
  ++  on-arvo  on-arvo:def
  ++  on-fail   on-fail:def
  ::
  --
::
|_  =bowl:gall
+*  dao-lib  ~(. daol bowl)
    io       ~(. agentio bowl)
::
++  address-to-id
    |=  =address:d
    ^-  (unit id:smart)
    ?:  ?=(id:smart address)  `address
    (~(get by dao-rid-to-id) address)
::
++  peek-dao
  |=  identifier=address:d
  ^-  (unit dao:d)
  ?~  id=(address-to-id identifier)  ~
  (~(get by daos) u.id)
::
++  watch-indexer
  |=  dao-id=id:smart
  ^-  (unit card)
  ?~  indexer  ~
  :-  ~
  %+  %~  watch  pass:io
    /dao-update/(scot %ux dao-id)
  u.indexer  /grain/(scot %ux dao-id)
::
++  leave-indexer
  |=  dao-id=id:smart
  ^-  (unit card)
  ?~  indexer  ~
  :-  ~
  %-  %~  leave  pass:io
    /dao-update/(scot %ux dao-id)
  u.indexer
::
++  set-indexer  :: TODO: is this properly generalized?
  |=  indexer-dock=dock
  ^-  (quip card _state)
  :_  state(indexer `indexer-dock)
  ?:  =(0 ~(wyt by daos))  ~
  %+  murn  ~(tap by daos)
  |=  [dao-id=id:smart =dao:d]
  (watch-indexer dao-id)
::
++  has-write-dao-permissions
  |=  identifier=address:d
  ^-  (unit dao:d)
  ?~  id=(address-to-id identifier)  ~
  ?~  dao=(peek-dao u.id)  ~
  ?.  %:  is-allowed:dao-lib
          [%| src.bowl]
          u.id
          %write
          members.u.dao
          permissions.u.dao
      ==
    ~
  dao
::
++  remove-dao
  |=  dao-id=id:smart
  ^-  (quip card _state)
  ?~  (peek-dao dao-id)  `state
  =.  daos
    (~(del by daos) dao-id)
  :_  state
  :-  (send-diff %on-chain dao-id %remove-dao ~)
  ?~  li=(leave-indexer dao-id)  ~  [u.li ~]
::  +dao-update: update DAO
::
::    no-op if DAO does not exist
::    or if user does not have %write
::    permissions for DAO
::
++  dao-update
  |=  =off-chain-update:d
  ^-  (quip card _state)
  |^
  ?-  -.off-chain-update
      %add-comms     (add-comms +.off-chain-update)
      %remove-comms  (remove-comms +.off-chain-update)
      %on-chain
    =*  dao-id  dao-id.off-chain-update
    =*  update  update.off-chain-update
    ?-  -.update
        %add-dao             (add-dao dao-id +.update)
        %remove-dao          (remove-dao dao-id)
        %add-member          (add-member dao-id +.update)
        %remove-member       (remove-member dao-id +.update)
        %add-permissions     (add-permissions dao-id +.update)
        %remove-permissions  (remove-permissions dao-id +.update)
        %add-roles           (add-roles dao-id +.update)
        %remove-roles        (remove-roles dao-id +.update)
        %add-subdao          (add-subdao dao-id +.update)
        %remove-subdao       (remove-subdao dao-id +.update)
    ==
  ==
  ::
  ++  add-comms
    |=  [dao-id=id:smart rid=resource:res]
    ^-  (quip card _state)
    ?~  (has-write-dao-permissions dao-id)  `state
    =.  dao-id-to-rid  (~(put by dao-id-to-rid) dao-id rid)
    =.  dao-rid-to-id  (~(put by dao-rid-to-id) rid dao-id)
    :_  state
    ~[(send-diff %add-comms dao-id rid)]
  ::
  ++  remove-comms
    |=  dao-id=id:smart
    ^-  (quip card _state)
    ?~  rid=(~(get by dao-id-to-rid) dao-id)  `state
    ?~  (~(get by dao-rid-to-id) u.rid)  `state
    =.  dao-id-to-rid  (~(del by dao-id-to-rid) dao-id)
    =.  dao-rid-to-id  (~(del by dao-rid-to-id) u.rid)
    :_  state
    ~[(send-diff %remove-comms dao-id)]
  ::
  ++  add-dao
    |=  [dao-id=id:smart =dao:d]
    ^-  (quip card _state)
    ?:  ?=(^ (peek-dao dao-id))  `state
    =.  daos  (~(put by daos) dao-id dao)
    :_  state
    :-  (send-diff %on-chain dao-id %add-dao dao)
    ?~  wi=(watch-indexer dao-id)  ~  [u.wi ~]
  ::
  ++  add-member
    |=  [dao-id=id:smart roles=(set role:d) =id:smart him=ship]
    ^-  (quip card _state)
    ?~  dao=(has-write-dao-permissions dao-id)  `state
    =/  existing-ship=(unit ship)
      (~(get by id-to-ship.u.dao) id)
    ?:  ?=(^ existing-ship)
      ?:  =(him u.existing-ship)  `state
      ~|  "%dao: cannot add member whose id corresponds to a different ship"
      !!
    =/  existing-id=(unit id:smart)
      (~(get by ship-to-id.u.dao) him)
    ?:  ?=(^ existing-id)
      ?:  =(id u.existing-id)  `state
      ~|  "%dao: cannot add member whose ship corresponds to a different id"
      !!
    ::
    =.  daos
      %+  ~(jab by daos)  dao-id
      |=  dao:d
      %=  +<
        id-to-ship  (~(put by id-to-ship) id him)
        ship-to-id  (~(put by ship-to-id) him id)
        members
          %-  ~(gas ju members)
          (make-noun-role-pairs id roles)
      ==
    :_  state
    ~[(send-diff %on-chain dao-id %add-member roles id him)]
  ::
  ++  remove-member
    |=  [dao-id=id:smart =id:smart]
    ^-  (quip card _state)
    ?~  dao=(has-write-dao-permissions dao-id)  `state
    ?~  him=(~(get by id-to-ship.u.dao) id)
      ~|  "%dao: cannot find given member to remove in id-to-ship"
      !!
    ?~  existing-id=(~(get by ship-to-id.u.dao) u.him)
      ~|  "%dao: cannot find given member to remove in ship-to-id"
      !!
    ~|  "%dao: given id does not match records"
    ?>  =(id u.existing-id)
    ?~  roles=(~(get ju members.u.dao) id)  `state
    =.  daos
      %+  ~(jab by daos)  dao-id
      |=  dao:d
      %=  +<
        id-to-ship  (~(del by id-to-ship) id)
        ship-to-id  (~(del by ship-to-id) u.him)
        members
          (remove-roles-helper members roles id)
      ==
    :_  state
    ~[(send-diff %on-chain dao-id %remove-member id)]
  ::
  ++  add-permissions
    |=  [dao-id=id:smart name=@tas =address:d roles=(set role:d)]
    ^-  (quip card _state)
    ?~  (has-write-dao-permissions dao-id)  `state
    =/  pairs=(list (pair address:d role:d))
      (make-noun-role-pairs address roles)
    =.  daos
      %+  ~(jab by daos)  dao-id
      |=  dao:d
      %=  +<
        permissions
          %:  add-permissions-helper
              name
              permissions
              roles
              address
          ==
      ==
    :_  state
    ~[(send-diff %on-chain dao-id %add-permissions name address roles)]
  ::
  ++  remove-permissions
    |=  [dao-id=id:smart name=@tas =address:d roles=(set role:d)]
    ^-  (quip card _state)
    ?~  dao=(has-write-dao-permissions dao-id)  `state
    =/  pairs=(list (pair address:d role:d))
      (make-noun-role-pairs address roles)
    =.  daos
      %+  ~(jab by daos)  dao-id
      |=  dao:d
      %=  +<
        permissions
          %:  remove-permissions-helper
              name
              permissions.u.dao
              roles
              address
      ==  ==
    :_  state
    ~[(send-diff %on-chain dao-id %remove-permissions name address roles)]
  ::
  ++  add-subdao
    |=  [dao-id=id:smart subdao-id=id:smart]
    ^-  (quip card _state)
    ?~  dao=(has-write-dao-permissions dao-id)  `state
    =.  daos
      %+  ~(jab by daos)  dao-id
      |=  dao:d
      +<(subdaos (~(put in subdaos.u.dao) subdao-id))
    :_  state
    ~[(send-diff %on-chain dao-id %add-subdao subdao-id)]
  ::
  ++  remove-subdao
    |=  [dao-id=id:smart subdao-id=id:smart]
    ^-  (quip card _state)
    ?~  dao=(has-write-dao-permissions dao-id)  `state
    =.  daos
      %+  ~(jab by daos)  dao-id
      |=  dao:d
      +<(subdaos (~(del in subdaos.u.dao) subdao-id))
    :_  state
    ~[(send-diff %on-chain dao-id %remove-subdao subdao-id)]
  ::  +add-roles: add roles to members
  ::
  ::    crash if member id is not in DAO
  ::
  ++  add-roles
    |=  [dao-id=id:smart roles=(set role:d) =id:smart]
    ^-  (quip card _state)
    ?~  dao=(has-write-dao-permissions dao-id)  `state
    ?~  (~(get ju members.u.dao) id)  !!
    =.  daos
      %+  ~(jab by daos)  dao-id
      |=  dao:d
      %=  +<
        members
          %-  ~(gas ju members)
          (make-noun-role-pairs id roles)
      ==
    :_  state
    ~[(send-diff %on-chain dao-id %add-roles roles id)]
  ::  +remove-roles: remove roles from members
  ::
  ::    crash if member id is not in DAO
  ::    TODO: crash if role does not exist?
  ::
  ++  remove-roles
    |=  [dao-id=id:smart roles=(set role:d) =id:smart]
    ^-  (quip card _state)
    ?~  dao=(has-write-dao-permissions dao-id)  `state
    ?~  (~(get ju members.u.dao) id)  !!
    =.  daos
      %+  ~(jab by daos)  dao-id
      |=  dao:d
      +<(members (remove-roles-helper members roles id))
    :_  state
    ~[(send-diff %on-chain dao-id %remove-roles roles id)]
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
    |=  [=members:d roles=(set role:d) =id:smart]
    ^-  members:d
    =/  pairs=(list (pair id:smart role:d))
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
::  +send-diff: update subscribers of new state
::
::    We only allow subscriptions on /daos
::    so just give the fact there.
::
++  send-diff
  |=  update=off-chain-update:d
  ^-  card
  [%give %fact ~[/daos] %dao-update !>(update)]
::
--
