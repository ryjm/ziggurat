/-  spider,
    pull-hook,
    push-hook,
    d=dao,
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
  ++  scry-dao
    |=  rid=resource:res
    =/  m  (strand ,(unit dao:d))
    ^-  form:m
    ;<  dao=(unit dao:d)  bind:m
      %+  scry  (unit dao:d)
      ;:  weld
          /gx/dao/daos
          (en-path:res rid)
          /noun
      ==
    (pure:m dao)
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
    =:  title.metadatum         title
        description.metadatum   description
    ::     color.metadatum
        date-created.metadatum  now.bowl
        creator.metadatum       our.bowl
        config.metadatum        [%graph module=module]
    ::     picture.metadatum
        preview.metadatum       %.n
        hidden.metadatum        %.n
    ::     vip.metadatum
    ==
    metadatum
  ::
  --
::
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  arg-mold
  $:  dao-rid=resource:res
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
=*  dao-rid      dao-rid.u.args
=*  graph-rid    graph-rid.u.args
=*  title        graph-title.u.args
=*  description  graph-description.u.args
=*  module       graph-module.u.args
;<  =bowl:spider  bind:m  get-bowl:strandio
;<  dao=(unit dao:d)  bind:m  (scry-dao dao-rid)
?~  dao
  ~&  >>>  "couldn't find DAO with rid {<dao-rid>}"
  ~&  >>>  "aborting without taking action"
  (pure:m !>(~))
~&  >  "poking graph-pu??-hook..."
;<  ~  bind:m
  ?:  =(our.bowl entity.graph-rid)
    %^  poke-our  %dao-graph-push-hook  %push-hook-action
    !>(`action:push-hook`[%add graph-rid])
  %^  poke-our  %dao-graph-pull-hook  %pull-hook-action
  !>(`action:pull-hook`[%add entity.graph-rid graph-rid])
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
  [%add dao-rid [%graph graph-rid] metadatum]
~&  >  "done"
(pure:m !>(~))
