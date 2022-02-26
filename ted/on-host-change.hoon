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
  ++  add-push-hook
    |=  rid=resource:res
    (add-rem-pull-push-hook rid %push %add)
  ::
  ++  rem-push-hook
    |=  rid=resource:res
    (add-rem-pull-push-hook rid %push %rem)
  ::
  ++  rem-pull-hook
    |=  rid=resource:res
    (add-rem-pull-push-hook rid %pull %rem)
  ::
  ++  add-rem-pull-push-hook
    |=  [rid=resource:res direction=?(%pull %push) action=?(%add %rem)]
    ^-  cage
    :-
      ?:  ?=(%pull direction)
        %pull-hook-action
      %push-hook-action
    !>([action rid])
  ::
  ++  add-graphs
    |=  [our=ship as=(list (pair md-resource:met association:met))]
    =/  m  (strand ,~)
    ^-  form:m
    =*  loop  $
    ?~  as  (pure:m ~)
    =*  mdr  p.i.as
    ?.  ?=(%graph app-name.mdr)
      loop(as t.as)
    ;<  =update:gra  bind:m  (scry-graph resource.mdr)
    ?.  ?=(%add-graph -.q.update)
      ~&  >>>  "add-graphs: scry returns non %add-graph for {<resource.mdr>}: {<update>}"
      loop(as t.as)  ::  TODO: can we do better here?
    =.  entity.resource.q.update  our
    ::
    ;<  ~  bind:m
      (raw-poke-our %graph-store %graph-update-3 !>(update))
    ::
    ;<  ~  bind:m
      (raw-poke-our %graph-push-hook (add-push-hook resource.q.update))
    loop(as t.as)
  ::
  ++  remove-graphs
    |=  [now=@da as=(list (pair md-resource:met association:met))]
    =/  m  (strand ,~)
    ^-  form:m
    =*  loop  $
    ?~  as  (pure:m ~)
    =*  mdr  p.i.as
    ?.  ?=(%graph app-name.mdr)
      loop(as t.as)
    ::
    ;<  ~  bind:m
      (raw-poke-our %graph-pull-hook (rem-pull-hook resource.mdr))
    ::
    =/  =update:gra
      :+  now
        %remove-graph
      resource.mdr
    ;<  ~  bind:m
      (raw-poke-our %graph-store %graph-update-3 !>(update))
    loop(as t.as)
  ::
  ++  add-group
    |=  new=resource:res
    =/  m  (strand ,~)
    ^-  form:m
    ;<  ~  bind:m
      %+  raw-poke-our
        %group-store
      :-  %group-action
      !>([%add-group new *policy:group %.n])  ::  TODO: copy policy
    ::
    ;<  ~  bind:m
      (raw-poke-our %metadata-push-hook (add-push-hook new))
    ;<  ~  bind:m
      (raw-poke-our %contact-push-hook (add-push-hook new))
    (raw-poke-our %group-push-hook (add-push-hook new))
  ::
  ++  remove-group
    |=  [our=ship old=resource:res]
    =/  m  (strand ,~)
    ^-  form:m
    ;<  ~  bind:m
      %+  raw-poke
        [entity.old %group-push-hook]
      [%group-action !>([%remove-members old (silt ~[our])])]
    ;<  ~  bind:m
      %+  raw-poke-our
        %group-store
      [%group-action !>([%remove-group old ~])]
    ::
    ;<  ~  bind:m
      (raw-poke-our %metadata-pull-hook (rem-pull-hook old))
    ;<  ~  bind:m
      (raw-poke-our %contact-pull-hook (rem-pull-hook old))
    (raw-poke-our %group-pull-hook (rem-pull-hook old))
  ::
  ++  update-metadata-store
    |=  [new=resource:res as=(list (pair md-resource:met association:met))]
    =/  m  (strand ,~)
    ^-  form:m
    =*  loop  $
    ?~  as  (pure:m ~)
    =*  mdr  p.i.as
    =*  a    q.i.as
    ::
    =/  remove=cage
      [%metadata-update-2 !>([%remove group.a mdr])]
    ;<  ~  bind:m  (raw-poke-our %metadata-store remove)
    ::
    =/  add-update=update:met
      :^    %add
          new
        mdr(entity.resource entity.new)
      metadatum.a  ::  TODO: do we need to update config? E.g. for group feed
    =/  add=cage  [%metadata-update-2 !>(add-update)]
    ;<  ~  bind:m  (raw-poke-our %metadata-store add)
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
;<  =bowl:spider  bind:m  get-bowl:strandio
~&  >  "getting group metadata..."
;<  =associations:met  bind:m  (scry-group-metadata old)
=/  as=(list (pair md-resource:met association:met))
  ~(tap by associations)
~&  >  "adding new graphs..."
;<  ~  bind:m  (add-graphs our.bowl as)
~&  >  "adding equivalent group..."
;<  ~  bind:m  (add-group new)
~&  >  "removing existing graphs..."
;<  ~  bind:m  (remove-graphs now.bowl as)
~&  >  "removing existing group..."
;<  ~  bind:m  (remove-group our.bowl old)
~&  >  "updating metadata-store..."
;<  ~  bind:m  (update-metadata-store new as)
~&  >  "done"
(pure:m !>(~))
