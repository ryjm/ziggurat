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
++  is-allowed
  |=  [him=ship =address:d permission-name=@tas =members:d =permissions:d]
  ^-  ?
  ?~  permissioned=(~(get by permissions) permission-name)  %.n
  ?~  roles-with-access=(~(get ju u.permissioned) address)  %.n
  ?~  ship-roles=(~(get ju members) him)  %.n
  ?!  .=  0
  %~  wyt  in
  %-  ~(int in `(set role:d)`ship-roles)
  `(set role:d)`roles-with-access
::
++  is-allowed-helper
  |=  [him=ship identifier=?(id:smart resource:r) =address:d permission-name=@tas]
  ^-  ?
  ?~  mp=(get-members-and-permissions identifier)  %.n
  =+  [~ members permissions]=mp
  (is-allowed him address permission-name members permissions)
::
++  is-allowed-admin-write-read
  |=  [him=ship identifier=?(id:smart resource:r) =address:d]
  ^-  [? ? ?]
  ?~  mp=(get-members-and-permissions identifier)  [%.n %.n %.n]
  =+  [~ members permissions]=mp
  :+  (is-allowed him address %admin members permissions)
    (is-allowed him address %write members permissions)
  (is-allowed him address %read members permissions)
::
++  is-allowed-write
  |=  [him=ship identifier=?(id:smart resource:r) =address:d]
  ^-  ?
  (is-allowed-helper him identifier address %write)
::
++  is-allowed-read
  |=  [him=ship identifier=?(id:smart resource:r) =address:d]
  ^-  ?
  (is-allowed-helper him identifier address %read)
::
++  is-allowed-admin
  |=  [him=ship identifier=?(id:smart resource:r) =address:d]
  ^-  ?
  (is-allowed-helper him identifier address %admin)
::
++  get-dao
  |=  identifier=?(id:smart resource:r)
  ^-  (unit dao:d)
  =/  scry-path=path
    ?:  ?=(id:smart identifier)
      /daos/(scot %ux identifier)/noun
    :(weld /daos (en-path:rl identifier) /noun)
  .^  (unit dao:d)
      %gx
      %+  scry:io  %daos
      scry-path
  ==
::
++  get-members-and-permissions
  |=  identifier=?(id:smart resource:r)
  ^-  (unit [members:d permissions:d])
  ?~  dao=(get-dao identifier)  ~
  `[members.u.dao permissions.u.dao]
::
--
