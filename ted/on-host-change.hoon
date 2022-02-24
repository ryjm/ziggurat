/-  group, spider, grp=group-store, gra=graph-store, met=metadata-store
/+  push-hook, strandio, res=resource::, dao=zig-contracts-dao
::
=*  strand    strand:spider
=*  raw-poke  raw-poke:strandio
=*  raw-poke-our  raw-poke-our:strandio
=*  scry  scry:strandio
=>
  |%
  ++  scry-groups
    =/  m  (strand ,(set resource:res))
    ^-  form:m
    ;<  resources=(set resource:res)  bind:m
      %+  scry  (set resource:res)
      /gy/group-store/groups
    (pure:m resources)
  ::
  ++  scry-group-metadata
    |=  rid=resource:res
    =/  m  (strand ,associations:met)
    ^-  form:m
    ;<  =associations:met  bind:m
      %+  scry  associations:met
      /gx/metadata-store/group/ship/(scot %p entity.rid)/[name.rid]/noun
    (pure:m associations)
  ::
  ++  scry-graph
    |=  rid=resource:res
    =/  m  (strand ,update:gra)
    ^-  form:m
    ;<  =update:gra  bind:m
      %+  scry  update:gra
      /gx/graph-store/graph/(scot %p entity.rid)/[name.rid]/noun
    (pure:m update)
  ::
  ++  make-add-push-hook
    |=  rid=resource:res
    ^-  cage
    [%push-hook-action !>([%add rid])]
  ::
  ++  make-rem-push-hook
    |=  rid=resource:res
    ^-  cage
    [%push-hook-action !>([%rem rid])]
  ::
  ++  add-graphs
    |=  [old=resource:res new=resource:res as=(list (pair md-resource:met association:met))]
    =/  m  (strand ,~)
    ^-  form:m
    =*  loop  $
    ?~  as  (pure:m ~)
    =*  mdr  p.i.as
    ?.  ?=(%graph app-name.mdr)
      loop(as t.as)
    ;<  =update:gra  bind:m  (scry-graph resource.mdr)
    ?.  ?=(%add-graph -.q.update)
      ~&  >  "add-graphs: scry returns non %add-graph: {<update>}"
      (pure:m ~)  ::  TODO: make work
    ?.  =(old resource.q.update)
      ~&  >  "add-graphs: scry returns non old graph: {<update>}"
      (pure:m ~)  ::  TODO: make work
    =.  entity.resource.q.update  entity.new
    ;<  ~  bind:m
      (raw-poke-our %graph-store %graph-update-3 !>(update))
    ;<  ~  bind:m
      (raw-poke-our %graph-push-hook (make-add-push-hook resource.q.update))
    loop(as t.as)
  ::
  ++  remove-graphs
    |=  [old=resource:res as=(list (pair md-resource:met association:met))]
    =/  m  (strand ,~)
    ^-  form:m
    =*  loop  $
    ?~  as  (pure:m ~)
    =*  mdr  p.i.as
    ?.  ?=(old entity.resource.mdr)
      loop(as t.as)
    ?.  ?=(%graph app-name.mdr)
      loop(as t.as)
    ;<  =bowl:spider  bind:m  get-bowl:strandio
    =/  =update:gra
      :+  now.bowl
        %remove-graph
      resource.mdr
    ;<  ~  bind:m
      (raw-poke-our %graph-pull-hook (make-rem-push-hook resource.mdr))
    ;<  ~  bind:m
      (raw-poke-our %graph-store %graph-update-3 !>(update))
    loop(as t.as)
  ::
  ++  update-metadata
    |=  [new=resource:res as=(list (pair md-resource:met association:met))]
    =/  m  (strand ,~)
    ^-  form:m
    =*  loop  $
    ?~  as  (pure:m ~)
    =*  mdr  p.i.as
    =*  a    q.i.as
    =/  remove=cage
      [%metadata-update-2 !>([%remove group.a mdr])]
    ;<  ~  bind:m  (raw-poke-our %metadata-store remove)
    ;<  ~  bind:m
      (raw-poke-our %metadata-push-hook (make-rem-push-hook group.a))
    =/  add-update=update:met
      :^    %add
          new
        =.  entity.resource.mdr  entity.new
        mdr
      metadatum.a  ::  TODO: do we need to update config?
    =/  add=cage  [%metadata-update-2 !>(add-update)]
    ;<  ~  bind:m  (raw-poke-our %metadata-store add)
    ;<  ~  bind:m
      (raw-poke-our %metadata-push-hook (make-add-push-hook new))
    loop(as t.as)
  --
::
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  args  !<((unit (pair resource:res resource:res)) arg)
?~  args  (pure:m !>(~))
=*  old  p.u.args
=*  new  q.u.args
;<  groups=(set resource:res)  bind:m  scry-groups
?.  (~(has in groups) old)  (pure:m !>(~))
~&  >  "getting group metadata..."
;<  =associations:met  bind:m  (scry-group-metadata old)
=/  as  ~(tap by associations)
~&  >  "adding new graphs..."
;<  ~  bind:m  (add-graphs old new as)
~&  >  "adding equivalent group..."
;<  ~  bind:m
  %+  raw-poke-our
    %group-store
  :-  %group-action
  !>([%add-group new *policy:group %.y])  ::  TODO: copy policy
~&  >  "hitting group push hook..."
;<  ~  bind:m
  (raw-poke-our %group-push-hook (make-add-push-hook new))
~&  >  "removing existing graphs..."
;<  ~  bind:m  (remove-graphs old as)
~&  >  "removing existing group..."
;<  ~  bind:m
  %+  raw-poke-our
    %group-store
  [%group-action !>([%remove-group old ~])]
~&  >  "updating metadata..."
;<  ~  bind:m  (update-metadata new as)
~&  >  "done"
(pure:m !>(~))
