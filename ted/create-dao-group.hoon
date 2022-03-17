/-  spider,
    dgs=dao-group-store
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
=|  =dao-group:dgs
=.  name.dao-group         name
=.  dao-id.dao-group       dao-id
=.  permissions.dao-group  (make-permissions(bowl bowl) dao-id)
=.  members.dao-group      make-members(bowl bowl)
=.  id-to-ship.dao-group   (make-id-to-ship(bowl bowl) our-id)
=.  ship-to-id.dao-group   (make-ship-to-id(bowl bowl) our-id)
~&  >  "poking dao-group-store..."
;<  ~  bind:m
  %^  poke-our  %dao-group-store  %dao-group-action
  !>(`action:dgs`[%add-group rid dao-group])
~&  >  "done"
(pure:m !>(~))
