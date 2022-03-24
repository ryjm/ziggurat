/-  spider,
    dgs=dao-group-store,
    ms=metadata-store
/+  strandio,
    res=resource
::
=*  strand    strand:spider
=*  poke-our  poke-our:strandio
=>
  |_  =bowl:spider
  ::
  +$  member-data
    %-  list
    [him=ship =id:dgs roles=(set role:dgs)]
  ::
  ++  make-dao-group-self
    |=  [name=@tas dao-id=id:dgs our-id=id:dgs]
    ^-  dao-group:dgs
    |^
    =|  =dao-group:dgs
    =.  name.dao-group         name
    =.  dao-id.dao-group       dao-id
    =.  permissions.dao-group  (make-permissions dao-id)
    =.  members.dao-group      make-members
    =.  id-to-ship.dao-group   (make-id-to-ship our-id)
    =.  ship-to-id.dao-group   (make-ship-to-id our-id)
    dao-group
    ::
    ++  make-permissions
      |=  dao-id=id:dgs
      ^-  permissions:dgs
      %+  %~  put  by  *permissions:dgs
        name=%write
      %+  %~  put  ju  *(jug address:dgs role:dgs)
      dao-id  %owner
    ::
    ++  make-members
      ^-  members:dgs
      %+  %~  put  ju  *members:dgs
      our.bowl  %owner
    ::
    ++  make-id-to-ship
      |=  our-id=id:dgs
      ^-  id-to-ship:dgs
      (~(put by *id-to-ship:dgs) our-id our.bowl)
    ::
    ++  make-ship-to-id
      |=  our-id=id:dgs
      ^-  ship-to-id:dgs
      (~(put by *ship-to-id:dgs) our.bowl our-id)
    ::
    --
  ::
  ++  make-dao-group-given
    |=  [name=@tas dao-id=id:dgs =permissions:dgs md=member-data]
    ^-  dao-group:dgs
    |^
    =|  =dao-group:dgs
    =.  name.dao-group         name
    =.  dao-id.dao-group       dao-id
    =.  permissions.dao-group  permissions
    =.  members.dao-group      make-members
    =.  id-to-ship.dao-group   make-id-to-ship
    =.  ship-to-id.dao-group   make-ship-to-id
    dao-group
    ::
    ++  make-members
      ^-  members:dgs
      %-  %~  gas  ju  *members:dgs
      %+  roll  md
      |=  [[him=ship =id:dgs roles=(set role:dgs)] out=(list [ship role:dgs])]
      %+  weld  out
      %+  turn  ~(tap in roles)
      |=(=role:dgs [him role])
    ::
    ++  make-id-to-ship
      ^-  id-to-ship:dgs
      %-  %~  gas  by  *id-to-ship:dgs
      %+  turn  md
      |=([him=ship =id:dgs *] [id him])
    ::
    ++  make-ship-to-id
      ^-  ship-to-id:dgs
      %-  %~  gas  by  *ship-to-id:dgs
      %+  turn  md
      |=([him=ship =id:dgs *] [him id])
    ::
    --
  ::
  ++  make-metadatum
    |=  name=@tas
    ^-  metadatum:ms
    =|  =metadatum:ms
    =.  title.metadatum         name
    =.  description.metadatum   name
    :: =.  color.metadatum
    =.  date-created.metadatum  now.bowl
    =.  creator.metadatum       our.bowl
    =.  config.metadatum        [%group feed=~]  :: ?
    :: =.  picture.metadatum
    =.  preview.metadatum       %.n
    =.  hidden.metadatum        %.n
    :: =.  vip.metadatum
    metadatum
  ::
  --
::
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  arg-mold
  $:  rid=resource:res
      dao-name=@t
      dao-id=id:dgs
      our-id=id:dgs
      permissions=(unit permissions:dgs)
      member-data=(unit member-data)
  ==
=/  args  !<((unit arg-mold) arg)
?~  args  (pure:m !>(~))
=*  rid          rid.u.args
=*  dao-name     dao-name.u.args
=*  dao-id       dao-id.u.args
=*  our-id       our-id.u.args
=*  permissions  permissions.u.args
=*  member-data  member-data.u.args
;<  =bowl:spider  bind:m  get-bowl:strandio
~&  >  "constructing dao-group..."
=/  =dao-group:dgs
  ?:  ?|  ?=(~ permissions)
          ?=(~ member-data)
      ==
    (make-dao-group-self dao-name dao-id our-id)
  %:  make-dao-group-given
      dao-name
      dao-id
      u.permissions
      u.member-data
  ==
~&  >  "poking dao-group-store..."
;<  ~  bind:m
  %^  poke-our  %dao-group-store  %dao-group-update
  !>(`update:dgs`[%add-group rid dao-group])
::  TODO: need to add group to metadata-push-hook?
~&  >  "constructing metadatum..."
=/  =metadatum:ms  (make-metadatum(bowl bowl) dao-name)
~&  >  "poking metadata-store..."
;<  ~  bind:m
  %^  poke-our  %metadata-store  %metadata-action
  !>(`action:ms`[%add rid [%dao-groups rid] metadatum])
~&  >  "done"
(pure:m !>(~))
