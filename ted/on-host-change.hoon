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
    (add-rem-pull-push-hook rid %push %remove)
  ::
  ++  add-pull-hook
    |=  rid=resource:res
    (add-rem-pull-push-hook rid %pull %add)
  ::
  ++  rem-pull-hook
    |=  rid=resource:res
    (add-rem-pull-push-hook rid %pull %remove)
  ::
  ++  add-rem-pull-push-hook
    |=  [rid=resource:res direction=?(%pull %push) action=?(%add %remove)]
    ^-  cage
    :-
      ?:  ?=(%pull direction)
        %pull-hook-action
      %push-hook-action
    !>([action rid])
  ::
  ++  update-metadata-store
    |=  [new-group=resource:res as=(list (pair md-resource:met association:met))]
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
          new-group
        mdr(entity.resource entity.new-group)
      metadatum.a  ::  TODO: do we need to update config? E.g. for group feed
    =/  add=cage  [%metadata-update-2 !>(add-update)]
    ;<  ~  bind:m  (raw-poke-our %metadata-store add)
    loop(as t.as)
  ::
  ++  update-host
    |_  [old-group=resource:res new-group=resource:res =bowl:spider]
    ++  update-hook
      |=  [app-hook-pfix=@tas action=?(%add %remove) rid=resource:res]
      =/  action=@tas  %add
      =/  hook-direction=@tas
        ?:(=(our.bowl entity.new-group) %push-hook %pull-hook)
      =/  app-hook=@tas
        (slav %tas (rap 3 app-hook-pfix '-' hook-direction ~))
      =/  hook-action=@tas
        (slav %tas (rap 3 hook-direction '-action' ~))
      (raw-poke-our app-hook hook-action !>([action rid]))
    ::
    ++  add-graphs
      |=  [as=(list (pair md-resource:met association:met))]
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
      =.  entity.resource.q.update  entity.new-group
      ::
      ;<  ~  bind:m
        (raw-poke-our %graph-store %graph-update-3 !>(update))
      ::
      ;<  ~  bind:m
        (update-hook %graph %add resource.q.update)
      loop(as t.as)
    ::
    ++  remove-graphs
      |=  [as=(list (pair md-resource:met association:met))]
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
        :+  now.bowl
          %remove-graph
        resource.mdr
      ;<  ~  bind:m
        (raw-poke-our %graph-store %graph-update-3 !>(update))
      loop(as t.as)
    ::
    ++  add-group
      =/  m  (strand ,~)
      ^-  form:m
      ;<  ~  bind:m
        %+  raw-poke-our
          %group-store
        :-  %group-action
        !>([%add-group new-group *policy:group %.n])  ::  TODO: copy policy
      ::
      ;<  ~  bind:m
        (update-hook %metadata %add new-group)
      ;<  ~  bind:m
        (update-hook %contact %add new-group)  ::  TODO: needed?
      (update-hook %group %add new-group)
    ::
    ++  remove-group
      =/  m  (strand ,~)
      ^-  form:m
      ;<  ~  bind:m
        %+  raw-poke
          [entity.old-group %group-push-hook]
        [%group-action !>([%remove-members old-group (silt ~[our.bowl])])]
      ;<  ~  bind:m
        %+  raw-poke-our
          %group-store
        [%group-action !>([%remove-group old-group ~])]
      ::
      ;<  ~  bind:m
        (raw-poke-our %metadata-pull-hook (rem-pull-hook old-group))
      ;<  ~  bind:m
        (raw-poke-our %contact-pull-hook (rem-pull-hook old-group))  ::  TODO: needed?
      (raw-poke-our %group-pull-hook (rem-pull-hook old-group))
    --
  --
::
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  args  !<((unit (pair resource:res resource:res)) arg)
?~  args  (pure:m !>(~))
=*  old-group  p.u.args
=*  new-group  q.u.args
;<  groups=(set resource:res)  bind:m  scry-groups
?.  (~(has in groups) old-group)  (pure:m !>(~))
;<  =bowl:spider  bind:m  get-bowl:strandio
~&  >  "getting group metadata..."
;<  =associations:met  bind:m  (scry-group-metadata old-group)
=/  as=(list (pair md-resource:met association:met))
  ~(tap by associations)
~&  >  "adding new graphs..."
;<  ~  bind:m
  (~(add-graphs update-host old-group new-group bowl) as)
~&  >  "adding equivalent group..."
;<  ~  bind:m
  ~(add-group update-host old-group new-group bowl)
~&  >  "removing existing graphs..."
;<  ~  bind:m
  (~(remove-graphs update-host old-group new-group bowl) as)
~&  >  "removing existing group..."
;<  ~  bind:m
  ~(remove-group update-host old-group new-group bowl)
~&  >  "updating metadata-store..."
;<  ~  bind:m  (update-metadata-store new-group as)
~&  >  "done"
(pure:m !>(~))
