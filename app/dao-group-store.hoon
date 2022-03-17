::  dao-group-store [landscape]:
::
::  Store DAO groups of ships
::
::    dao-group-store stores DAO groups of ships, so that resources
::    in other apps can be associated with a DAO group.
::
::
::    ## Scry paths
::
::    /y/dao-groups:
::      A listing of the current groups
::    /x/dao-groups/[resource]:
::      The group itself
::
::    ## Subscription paths (TODO)
::
::    /dao-groups:
::      A stream of the current updates to the state, sending the initial state
::      upon subscribe.
::
::    ##  Pokes
::
::    %dao-group-create:
::      Create a DAO group. Further documented in /sur/dao-group-store.hoon
::
::    %dao-group-modify:
::      Modify the DAO group. Further documented in /sur/dao-group-store.hoon
::
::
/-  res=resource,
    store=dao-group-store
/+  dbug,
    default-agent,
    verb,
    daolib=dao,
    reslib=resource
::
|%
+$  card  card:agent:gall
::
+$  versioned-state
  $%  state-zero
  ==
::
+$  state-zero
  [%0 =dao-groups:store]
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
  +*  this            .
      dao-group-core  +>
      dgc             ~(. dao-group-core bowl)
      def             ~(. (default-agent this %|) bowl)
      dao             ~(. daolib bowl)
  ::
  ++  on-init  `this(state [%0 ~])
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
          %dao-group-create
        (dao-group-create:dgc !<(create:store vase))
      ::
          %dao-group-modify
        (dao-group-modify:dgc !<(modify:store vase))
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
        [%y %dao-groups ~]
      ``noun+!>(`(set resource:res)`~(key by dao-groups))
    ::
        [%x %dao-groups %ship @ @ ~]
      =/  rid=(unit resource:res)
        (de-path-soft:reslib t.t.path)
      ?~  rid   ~
      ``noun+!>(`(unit dao-group:store)`(peek-dao-group:dgc u.rid))
    ::
    ==
  ::
  ++  on-agent  on-agent:def
  ++  on-arvo  on-arvo:def
  ++  on-fail   on-fail:def
  ::
  --
::
|_  =bowl:gall
+*  dao  ~(. daolib bowl)
::
++  peek-dao-group
  |=  rid=resource:res
  ^-  (unit dao-group:store)
  (~(get by dao-groups) rid)
::
++  dao-group-create
  |=  =create:store
  ^-  (quip card _state)
  |^
  ?-  -.create
      %add-group  (add-group +.create)
  ==
  ::  +add-group: add group to store
  ::
  ::    no-op if group already exists
  ::
  ++  add-group
    |=  [rid=resource:res =dao-group:store]
    ^-  (quip card _state)
    ?:  ?=(^ (~(get by dao-groups) rid))  `state
    =.  dao-groups  (~(put by dao-groups) rid dao-group)
    :_  state
    (send-diff %add-group rid dao-group)
  ::
  --
::
++  has-write-dao-permissions
  |=  dao-group-rid=resource:res
  ^-  (unit dao-group:store)
  ?~  dao-group=(peek-dao-group dao-group-rid)
    ~
  ?.  %:  is-allowed:dao
          src.bowl
          dao-id.u.dao-group
          %write
          members.u.dao-group
          permissions.u.dao-group
      ==
    ~
  dao-group
::  +dao-group-modify: modify DAO group store
::
::    no-op if group does not exist
::    or if user does not have %owner
::    permissions for DAO
::
++  dao-group-modify
  |=  =modify:store
  ^-  (quip card _state)
  |^
  ?-  -.modify
      %remove-group        (remove-group +.modify)
      %add-member          (add-member +.modify)
      %remove-member       (remove-member +.modify)
      %add-permissions     (add-permissions +.modify)
      %remove-permissions  (remove-permissions +.modify)
      %add-roles           (add-roles +.modify)
      %remove-roles        (remove-roles +.modify)
  ==
  ::  +remove-group: remove group from store
  ::
  ++  remove-group
    |=  rid=resource:res
    ^-  (quip card _state)
    ?~  (has-write-dao-permissions rid)  `state
    =.  dao-groups
      (~(del by dao-groups) rid)
    :_  state
    (send-diff %remove-group rid)
  ::  +add-member: add members to group
  ::
  ++  add-member
    |=  [rid=resource:res roles=(set role:store) =id:store him=ship]
    ^-  (quip card _state)
    ?~  dao-group=(has-write-dao-permissions rid)  `state
    =/  existing-ship=(unit ship)
      (~(get by id-to-ship.u.dao-group) id)
    ?:  ?=(^ existing-ship)
      ?:  =(him u.existing-ship)  `state
      ~|  "dao-group-store: cannot add member whose id corresponds to a different ship"
      !!
    =/  existing-id=(unit id:store)
      (~(get by ship-to-id.u.dao-group) him)
    ?:  ?=(^ existing-id)
      ?:  =(id u.existing-id)  `state
      ~|  "dao-group-store: cannot add member whose ship corresponds to a different id"
      !!
    ::
    =.  dao-groups
      %+  ~(jab by dao-groups)  rid
      |=  dao-group:store
      %=  +<
        id-to-ship  (~(put by id-to-ship) id him)
        ship-to-id  (~(put by ship-to-id) him id)
        members
          %-  ~(gas ju members)
          (make-ship-role-pairs him roles)
      ==
    :_  state
    (send-diff %add-member rid roles id him)
  ::  +remove-member: remove members from group
  ::
  ++  remove-member
    |=  [rid=resource:res him=ship]
    ^-  (quip card _state)
    ?~  dao-group=(has-write-dao-permissions rid)  `state
    ?~  id=(~(get by ship-to-id.u.dao-group) him)  `state
    ?~  existing-ship=(~(get by id-to-ship.u.dao-group) u.id)
      ~|  "dao-group-store: cannot find given member to remove in id-to-ship"
      !!
    ~|  "dao-group-store: given ship does not match records"
    ?>  =(him u.existing-ship)
    ?~  roles=(~(get ju members.u.dao-group) him)  `state
    =.  dao-groups
      %+  ~(jab by dao-groups)  rid
      |=  dao-group:store
      %=  +<
        id-to-ship  (~(del by id-to-ship) u.id)
        ship-to-id  (~(del by ship-to-id) him)
        members
          (remove-roles-helper members roles him)
      ==
    :_  state
    (send-diff %remove-member rid him)
  ::  +add-permissions: add 
  ::
  ++  add-permissions
    |=  [rid=resource:res name=@tas =address:store roles=(set role:store)]
    ^-  (quip card _state)
    ?~  (has-write-dao-permissions rid)  `state
    =/  pairs=(list (pair address:store role:store))
      (make-noun-role-pairs address roles)
    =.  dao-groups
      %+  ~(jab by dao-groups)  rid
      |=  dao-group:store
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
    (send-diff %add-permissions rid name address roles)
  ::  +remove-permissions: remove 
  ::
  ++  remove-permissions
    |=  [rid=resource:res name=@tas =address:store roles=(set role:store)]
    ^-  (quip card _state)
    ?~  dao-group=(has-write-dao-permissions rid)  `state
    =/  pairs=(list (pair address:store role:store))
      (make-noun-role-pairs address roles)
    =.  dao-groups
      %+  ~(jab by dao-groups)  rid
      |=  dao-group:store
      %=  +<
        permissions
          %:  remove-permissions-helper
              name
              permissions.u.dao-group
              roles
              address
      ==  ==
    :_  state
    (send-diff %remove-permissions rid name address roles)
  ::  +add-roles: add roles to ships
  ::
  ::    crash if ships are not in group
  ::
  ++  add-roles
    |=  [rid=resource:res roles=(set role:store) him=ship]
    ^-  (quip card _state)
    ?~  dao-group=(has-write-dao-permissions rid)  `state
    ?~  (~(get ju members.u.dao-group) him)  !!
    =.  dao-groups
      %+  ~(jab by dao-groups)  rid
      |=  dao-group:store
      %=  +<
        members
          %-  ~(gas ju members)
          (make-noun-role-pairs him roles)
      ==
    :_  state
    (send-diff %add-roles rid roles him)
  ::  +remove-roles: remove roles from ships
  ::
  ::    crash if ships are not in group or tag does not exist
  ::
  ++  remove-roles
    |=  [rid=resource:res roles=(set role:store) him=ship]
    ^-  (quip card _state)
    ?~  dao-group=(has-write-dao-permissions rid)  `state
    ?~  (~(get ju members.u.dao-group) him)  !!
    =.  dao-groups
      %+  ~(jab by dao-groups)  rid
      |=  dao-group:store
      +<(members (remove-roles-helper members roles him))
    :_  state
    (send-diff %remove-roles rid roles him)
  ::
  ++  add-permissions-helper
    |=  [name=@tas =permissions:store roles=(set role:store) =address:store]
    ^-  permissions:store
    =/  permission=(unit (jug address:store role:store))
      (~(get by permissions) name)
    =/  pairs=(list (pair address:store role:store))
      (make-noun-role-pairs address roles)
    %+  %~  put  by  permissions
      name
    %-  %~  gas  ju
      ?~  permission
        *(jug address:store role:store)
      u.permission
    pairs
  ::  TODO: use polymorphism?
  ++  remove-permissions-helper
    |=  [name=@tas =permissions:store roles=(set role:store) =address:store]
    ^-  permissions:store
    ?~  permission=(~(get by permissions) name)  permissions
    =/  pairs=(list (pair address:store role:store))
      (make-noun-role-pairs address roles)
    |-
    ?~  pairs  (~(put by permissions) name u.permission)
    =.  u.permission  (~(del ju u.permission) i.pairs)
    $(pairs t.pairs)
  ::
  ++  remove-roles-helper
    |=  [=members:store roles=(set role:store) him=ship]
    ^-  members:store
    =/  pairs=(list (pair ship role:store))
      (make-noun-role-pairs him roles)
    |-
    ?~  pairs  members
    =.  members  (~(del ju members) i.pairs)
    $(pairs t.pairs)
  ::
  ++  make-ship-role-pairs
    |=  [him=ship roles=(set role:store)]
    ^-  (list (pair ship role:store))
    %+  turn  ~(tap in roles)
    |=  =role:store
    [p=him q=role]
  ::
  ++  make-noun-role-pairs
    |*  [noun=* roles=(set role:store)]
    ^-  (list (pair _noun role:store))
    %+  turn  ~(tap in roles)
    |=  =role:store
    [p=noun q=role]
  ::
  --
::  +send-diff: update subscribers of new state
::
::    We only allow subscriptions on /groups
::    so just give the fact there.
::
++  send-diff
  |=  =update:store
  ^-  (list card)
  [%give %fact ~[/dao-groups] %dao-group-update-0 !>(update)]~
::
--
