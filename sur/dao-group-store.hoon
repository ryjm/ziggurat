/-  r=resource
::
|%
+$  id           @ux
+$  role         @tas  ::  E.g. %marketing, %development
+$  address      ?(id resource:r)  ::  [chain=@tas id] for other chains?
::  name might be, e.g., %read or %write for a graph;
::  %spend for treasury/rice
+$  permissions  (map name=@tas (jug address role))
+$  members      (jug ship role)
+$  id-to-ship   (map id ship)
+$  ship-to-id   (map ship id)
+$  dao-group
  $:  name=@t
      dao-id=id
      =permissions
      =members
      =id-to-ship
      =ship-to-id
      subdaos=(set id)
      :: owners=(set id)  ::  ? or have this in permissions?
      :: ::  needed here?
      :: threshold=@ud
      :: proposals=(map @ux [act=action votes=(set id)])
  ==
::
+$  dao-groups  (map resource:r dao-group)
::
+$  create
  $%  [%add-group =resource:r =dao-group]
  ==
::
+$  modify
  $%  [%remove-group =resource:r]
      [%add-member =resource:r roles=(set role) =id =ship]
      [%remove-member =resource:r =ship]
      [%add-permissions =resource:r name=@tas =address roles=(set role)]
      [%remove-permissions =resource:r name=@tas =address roles=(set role)]
      [%add-subdao =resource:r subdao-id=id]
      [%remove-subdao =resource:r subdao-id=id]
      [%add-roles =resource:r roles=(set role) =ship]
      [%remove-roles =resource:r roles=(set role) =ship]
  ==
+$  update
  $%  create
      modify
  ==
--
