/-  dgs=dao-group-store,
    ms=metadata-store,
    r=resource
/+  agentio,
    rl=resource
::
|_  =bowl:gall
+*  io  ~(. agentio bowl)
::
++  is-allowed
  |=  [him=ship =address:dgs permission-name=@tas =members:dgs =permissions:dgs]
  ^-  ?
  ?~  permissioned=(~(get by permissions) permission-name)  %.n
  ?~  roles-with-access=(~(get ju u.permissioned) address)  %.n
  ?~  ship-roles=(~(get ju members) him)  %.n
  ?!  .=  0
  %~  wyt  in
  %-  ~(int in `(set role:dgs)`ship-roles)
  `(set role:dgs)`roles-with-access
::
++  is-allowed-helper
  |=  [him=ship dao-group-rid=resource:r =address:dgs permission-name=@tas]
  ^-  ?
  ?~  mp=(get-members-and-permissions dao-group-rid)  %.n
  =+  [~ members permissions]=mp
  (is-allowed him address permission-name members permissions)
::
++  is-allowed-admin-write-read
  |=  [him=ship dao-group-rid=resource:r =address:dgs]
  ^-  [? ? ?]
  ?~  mp=(get-members-and-permissions dao-group-rid)  [%.n %.n %.n]
  =+  [~ members permissions]=mp
  :+  (is-allowed him address %admin members permissions)
    (is-allowed him address %write members permissions)
  (is-allowed him address %read members permissions)
::
++  is-allowed-write
  |=  [him=ship dao-group-rid=resource:r =address:dgs]
  ^-  ?
  (is-allowed-helper him dao-group-rid address %write)
::
++  is-allowed-read
  |=  [him=ship dao-group-rid=resource:r =address:dgs]
  ^-  ?
  (is-allowed-helper him dao-group-rid address %read)
::
++  is-allowed-admin
  |=  [him=ship dao-group-rid=resource:r =address:dgs]
  ^-  ?
  (is-allowed-helper him dao-group-rid address %admin)
::
++  get-dao-group
  |=  rid=resource:r
  ^-  (unit dao-group:dgs)
  .^  (unit dao-group:dgs)
      %gx
      %+  scry:io  %dao
      :(weld /dao-groups (en-path:rl rid) /noun)
  ==
::
++  get-members-and-permissions
  |=  rid=resource:r
  ^-  (unit [members:dgs permissions:dgs])
  ?~  dao-group=(get-dao-group rid)  ~
  `[members.u.dao-group permissions.u.dao-group]
::
--
