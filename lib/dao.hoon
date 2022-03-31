/-  d=dao,
    ms=metadata-store,
    r=resource
/+  agentio,
    rl=resource,
    smart=zig-sys-smart
::
|_  =bowl:gall
+*  io  ~(. agentio bowl)
::
++  member-to-id
  |=  [=member:d =address:d]
  ^-  (unit id:smart)
  ?:  ?=(%& -.member)  `p.member
  ?~  ship-to-id=(get-ship-to-id address)  ~
  (~(get by u.ship-to-id) p.member)
::
++  member-to-ship
  |=  [=member:d =address:d]
  ^-  (unit ship)
  ?:  ?=(%| -.member)  `p.member
  ?~  id-to-ship=(get-id-to-ship address)  ~
  (~(get by u.id-to-ship) p.member)
::
++  is-allowed
  |=  $:  =member:d
          =address:d
          permission-name=@tas
          =members:d
          =permissions:d
      ==
  ^-  ?
  ?~  permissioned=(~(get by permissions) permission-name)  %.n
  ?~  roles-with-access=(~(get ju u.permissioned) address)  %.n
  ?~  user-id=(member-to-id member address)                 %.n
  ?~  ship-roles=(~(get ju members) u.user-id)              %.n
  ?!  .=  0
  %~  wyt  in
  %-  ~(int in `(set role:d)`ship-roles)
  `(set role:d)`roles-with-access
::
++  is-allowed-helper
  |=  $:  =member:d
          identifier=address:d
          =address:d
          permission-name=@tas
      ==
  ^-  ?
  ?~  mp=(get-members-and-permissions identifier)  %.n
  =*  members      members.u.mp
  =*  permissions  permissions.u.mp
  (is-allowed member address permission-name members permissions)
::
++  is-allowed-admin-write-read
  |=  $:  =member:d
          identifier=address:d
          =address:d
      ==
  ^-  [? ? ?]
  ?~  mp=(get-members-and-permissions identifier)  [%.n %.n %.n]
  =*  members      members.u.mp
  =*  permissions  permissions.u.mp
  :+  (is-allowed member address %admin members permissions)
    (is-allowed member address %write members permissions)
  (is-allowed member address %read members permissions)
::
++  is-allowed-write
  |=  $:  =member:d
          identifier=address:d
          =address:d
      ==
  ^-  ?
  (is-allowed-helper member identifier address %write)
::
++  is-allowed-read
  |=  $:  =member:d
          identifier=address:d
          =address:d
      ==
  ^-  ?
  (is-allowed-helper member identifier address %read)
::
++  is-allowed-admin
  |=  $:  =member:d
          identifier=address:d
          =address:d
      ==
  ^-  ?
  (is-allowed-helper member identifier address %admin)
::
++  get-dao
  |=  =address:d
  ^-  (unit dao:d)
  =/  scry-path=path
    ?:  ?=(id:smart address)
      /daos/(scot %ux address)/noun
    :(weld /daos (en-path:rl address) /noun)
  .^  (unit dao:d)
      %gx
      %+  scry:io  %dao
      scry-path
  ==
::
++  get-members-and-permissions
  |=  =address:d
  ^-  (unit [=members:d =permissions:d])
  ?~  dao=(get-dao address)  ~
  `[members.u.dao permissions.u.dao]
::
++  get-id-to-ship
  |=  =address:d
  ^-  (unit id-to-ship:d)
  ?~  dao=(get-dao address)  ~
  `id-to-ship.u.dao
::
++  get-ship-to-id
  |=  =address:d
  ^-  (unit ship-to-id:d)
  ?~  dao=(get-dao address)  ~
  `ship-to-id.u.dao
::
++  update
  |_  =dao:d
  ::
  ++  add-member
    |=  [roles=(set role:d) =id:smart him=ship]
    ^-  dao:d
    =/  existing-ship=(unit ship)
      (~(get by id-to-ship.dao) id)
    ?:  ?=(^ existing-ship)
      ?:  =(him u.existing-ship)  dao
      ~|  "%dao: cannot add member whose id corresponds to a different ship"
      !!
    =/  existing-id=(unit id:smart)
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
    |=  [=id:smart]
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
    |=  subdao-id=id:smart
    ^-  dao:d
    dao(subdaos (~(put in subdaos.dao) subdao-id))
  ::
  ++  remove-subdao
    |=  subdao-id=id:smart
    ^-  dao:d
    dao(subdaos (~(del in subdaos.dao) subdao-id))
  ::
  ++  add-roles
    |=  [roles=(set role:d) =id:smart]
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
    |=  [roles=(set role:d) =id:smart]
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
--
