/-  spider,
    push-hook,
    dgs=dao-group-store,
    gs=graph-store,
    ms=metadata-store
/+  strandio,
    res=resource
::
=*  strand    strand:spider
=*  poke-our  poke-our:strandio
=*  scry      scry:strandio
=>
  |%
  ::
  ++  scry-dao-group
    |=  rid=resource:res
    =/  m  (strand ,(unit dao-group:dgs))
    ^-  form:m
    ;<  dg=(unit dao-group:dgs)  bind:m
      %+  scry  (unit dao-group:dgs)
      ;:  weld
          /gx/dao-group-store/dao-groups
          (en-path:res rid)
          /noun
      ==
    (pure:m dg)
  ::
  ++  make-graph-mark
    |=  graph-module=@tas
    ^-  (unit mark)
    `(cat 3 'graph-validator-' graph-module)
  ::
  ++  make-metadatum
    |=  [=bowl:spider title=@t description=@t module=@tas]
    ^-  metadatum:ms
    =|  =metadatum:ms
    =.  title.metadatum         title
    =.  description.metadatum   description
    :: =.  color.metadatum
    =.  date-created.metadatum  now.bowl
    =.  creator.metadatum       our.bowl
    =.  config.metadatum        [%graph module=module]
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
  $:  dao-group-rid=resource:res
      graph-rid=resource:res
      graph-title=cord
      graph-description=cord
      graph-module=?(%chat %link %publish)
      :: existing-graph=graph:gs  ::  assume empty
      :: overwrite=?  ::  assume %.y
      :: graph-color=color  ::  use default
      :: graph-vip  ::  use default
  ==
=/  args  !<((unit arg-mold) arg)
?~  args  (pure:m !>(~))
=*  dao-group-rid      dao-group-rid.u.args
=*  graph-rid          graph-rid.u.args
=*  title        graph-title.u.args
=*  description  graph-description.u.args
=*  module       graph-module.u.args
;<  =bowl:spider  bind:m  get-bowl:strandio
;<  dao-group=(unit dao-group:dgs)  bind:m
  (scry-dao-group dao-group-rid)
?~  dao-group 
  ~&  >>>  "couldn't find DAO group with rid {<dao-group-rid>}"
  ~&  >>>  "aborting without taking action"
  (pure:m !>(~))
~&  >  "poking graph-push-hook..."
;<  ~  bind:m
  %^  poke-our  %dao-graph-push-hook  %push-hook-action
  !>(`action:push-hook`[%add graph-rid])
~&  >  "poking graph-store..."
;<  ~  bind:m
  %^  poke-our  %graph-store  %graph-update-3
  !>  ^-  update:gs
  :-  now.bowl
  :-  %add-graph
  :^    graph-rid
      *graph:gs
    (make-graph-mark module)
  %.y
~&  >  "constructing metadata..."
=/  =metadatum:ms
  (make-metadatum bowl title description module)
~&  >  "poking metadata-store..."
;<  ~  bind:m
  %^  poke-our  %metadata-store  %metadata-action
  !>  ^-  action:ms
  [%add dao-group-rid [%graph graph-rid] metadatum]
~&  >  "done"
(pure:m !>(~))
