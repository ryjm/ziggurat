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
--
