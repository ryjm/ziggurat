/-  spider,
    dgs=dao-group-store,
    ms=metadata-store
/+  strandio,
    res=resource
::
=*  strand     strand:spider
=*  poke-our   poke-our:strandio
=>
  |_  =bowl:spider
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
  ++  make-dao-group
    |=  [name=@tas dao-id=id:dgs our-id=id:dgs]
    ^-  dao-group:dgs
    =|  =dao-group:dgs
    =.  name.dao-group         name
    =.  dao-id.dao-group       dao-id
    =.  permissions.dao-group  (make-permissions dao-id)
    =.  members.dao-group      make-members
    =.  id-to-ship.dao-group   (make-id-to-ship our-id)
    =.  ship-to-id.dao-group   (make-ship-to-id our-id)
    dao-group
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
      :: permissions=(unit permissions:dgs)
      :: member-data=(list [address:dgs id:dgs roles=(set role:dgs)])
  ==
=/  args  !<((unit arg-mold) arg)
?~  args  (pure:m !>(~))
=*  rid     rid.u.args
=*  name    dao-name.u.args
=*  dao-id  dao-id.u.args
=*  our-id  our-id.u.args
;<  =bowl:spider  bind:m  get-bowl:strandio
~&  >  "constructing dao-group..."
=/  =dao-group:dgs
  (make-dao-group(bowl bowl) name dao-id our-id)
~&  >  "poking dao-group-store..."
;<  ~  bind:m
  %^  poke-our  %dao-group-store  %dao-group-create
  !>(`create:dgs`[%add-group rid dao-group])
::  TODO: need to add group to metadata-push-hook?
~&  >  "constructing metadatum..."
=/  =metadatum:ms  (make-metadatum(bowl bowl) name)
~&  >  "poking metadata-store..."
;<  ~  bind:m
  %^  poke-our  %metadata-store  %metadata-action
  !>(`action:ms`[%add rid [%dao-groups rid] metadatum])
~&  >  "done"
(pure:m !>(~))
