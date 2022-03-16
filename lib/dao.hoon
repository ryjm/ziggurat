/-  dgs=dao-group-store,
    r=resource
/+  agentio,
    rl=resource
::
|_  =bowl:gall
+*  io  ~(. agentio bowl)
::
++  is-allowed
  |=  [him=ship rid=resource:r permission-name=@tas =members:dgs =permissions:dgs]
  ^-  ?
  ?~  permissioned=(~(get by permissions) permission-name)  %.n
  ?~  roles-with-access=(~(get ju u.permissioned) rid)  %.n
  ?~  ship-roles=(~(get ju members) him)  %.n
  ?!  .=  0
  %~  wyt  in
  %-  ~(int in `(set role:dgs)`ship-roles)
  `(set role:dgs)`roles-with-access
::
++  is-allowed-helper
  |=  [him=ship rid=resource:r permission-name=@tas]
  ^-  ?
  ?~  mp=(get-members-and-permissions rid)  %.n
  =+  [~ members permissions]=mp
  (is-allowed him rid permission-name members permissions)
::
++  is-allowed-admin-write-read
  |=  [him=ship rid=resource:r]
  ^-  [? ? ?]
  ?~  mp=(get-members-and-permissions rid)  [%.n %.n %.n]
  =+  [~ members permissions]=mp
  :+  (is-allowed him rid %admin members permissions)
    (is-allowed him rid %write members permissions)
  (is-allowed him rid %read members permissions)
::
++  is-allowed-write
  |=  [him=ship rid=resource:r]
  ^-  ?
  (is-allowed-helper him rid %write)
::
++  is-allowed-read
  |=  [him=ship rid=resource:r]
  ^-  ?
  (is-allowed-helper him rid %read)
::
++  is-allowed-admin
  |=  [him=ship rid=resource:r]
  ^-  ?
  (is-allowed-helper him rid %admin)
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
