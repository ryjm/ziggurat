/-  spider,
    d=dao,
    ms=metadata-store
/+  strandio,
    res=resource,
    smart=zig-sys-smart
::
=*  strand    strand:spider
=*  poke-our  poke-our:strandio
=>
  |_  =bowl:spider
  ::
  +$  member-data
    %-  list
    [him=ship =id:smart roles=(set role:d)]
  ::
  ++  make-dao-self
    |=  [name=@tas dao-id=id:smart our-id=id:smart]
    ^-  dao:d
    |^
    =|  =dao:d
    =:  name.dao         name
        permissions.dao  (make-permissions dao-id)
        members.dao      make-members
        id-to-ship.dao   (make-id-to-ship our-id)
        ship-to-id.dao   (make-ship-to-id our-id)
    ==
    dao
    ::
    ++  make-permissions
      |=  dao-id=id:smart
      ^-  permissions:d
      %+  %~  put  by  *permissions:d
        name=%write
      %+  %~  put  ju  *(jug address:d role:d)
      dao-id  %owner
    ::
    ++  make-members
      ^-  members:d
      %+  %~  put  ju  *members:d
      our.bowl  %owner
    ::
    ++  make-id-to-ship
      |=  our-id=id:smart
      ^-  id-to-ship:d
      (~(put by *id-to-ship:d) our-id our.bowl)
    ::
    ++  make-ship-to-id
      |=  our-id=id:smart
      ^-  ship-to-id:d
      (~(put by *ship-to-id:d) our.bowl our-id)
    ::
    --
  ::
  ++  make-dao-given
    |=  [name=@tas dao-id=id:smart =permissions:d md=member-data]
    ^-  dao:d
    |^
    =|  =dao:d
    =.  name.dao         name
    =.  permissions.dao  permissions
    =.  members.dao      make-members
    =.  id-to-ship.dao   make-id-to-ship
    =.  ship-to-id.dao   make-ship-to-id
    dao
    ::
    ++  make-members
      ^-  members:d
      %-  %~  gas  ju  *members:d
      %+  roll  md
      |=  [[him=ship =id:smart roles=(set role:d)] out=(list [ship role:d])]
      %+  weld  out
      %+  turn  ~(tap in roles)
      |=(=role:d [him role])
    ::
    ++  make-id-to-ship
      ^-  id-to-ship:d
      %-  %~  gas  by  *id-to-ship:d
      %+  turn  md
      |=([him=ship =id:smart *] [id him])
    ::
    ++  make-ship-to-id
      ^-  ship-to-id:d
      %-  %~  gas  by  *ship-to-id:d
      %+  turn  md
      |=([him=ship =id:smart *] [him id])
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
      dao-id=id:smart
      our-id=id:smart
      permissions=(unit permissions:d)
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
~&  >  "constructing dao..."
=/  =dao:d
  ?:  ?|  ?=(~ permissions)
          ?=(~ member-data)
      ==
    (make-dao-self dao-name dao-id our-id)
  %:  make-dao-given
      dao-name
      dao-id
      u.permissions
      u.member-data
  ==
~&  >  "poking %dao..."
;<  ~  bind:m
  %^  poke-our  %dao  %dao-update
  !>(`off-chain-update:d`[%on-chain dao-id [%add-dao dao]])
;<  ~  bind:m
  %^  poke-our  %dao  %dao-update
  !>(`off-chain-update:d`[%add-comms dao-id rid])
::  TODO: need to add group to metadata-push-hook?
~&  >  "constructing metadatum..."
=/  =metadatum:ms  (make-metadatum(bowl bowl) dao-name)
~&  >  "poking metadata-store..."
;<  ~  bind:m
  %^  poke-our  %metadata-store  %metadata-action
  !>(`action:ms`[%add rid [%dao rid] metadatum])
~&  >  "done"
(pure:m !>(~))
