/-  group, spider, grp=group-store, gra=graph-store, met=metadata-store
/+  push-hook, strandio, res=resource::, dao=zig-contracts-dao
::
=*  strand  strand:spider
=*  poke  poke:strandio
=*  poke-our  poke-our:strandio
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
  ++  scry-group
    |=  rid=resource:res
    =/  m  (strand ,(unit group:group))
    ^-  form:m
    ;<  g=(unit group:group)  bind:m
      %+  scry  (unit group:group)
      /gx/group-store/groups/ship/(scot %p entity.rid)/[name.rid]/noun
    (pure:m g)
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
  ++  rem-pull-hook
    |=  rid=resource:res
    ^-  cage
    [%pull-hook-action !>([%remove rid])]
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
    ;<  ~  bind:m  (poke-our %metadata-store remove)
    ::
    =/  add-update=update:met
      :^    %add
          new-group
        mdr(entity.resource entity.new-group)
      metadatum.a  ::  TODO: do we need to update config? E.g. for group feed
    =/  add=cage  [%metadata-update-2 !>(add-update)]
    ;<  ~  bind:m  (poke-our %metadata-store add)
    loop(as t.as)
  ::
  ++  update-host
    |_  [old-group=resource:res new-group=resource:res =bowl:spider]
    ::
    ++  update-hook
      |=  [app-hook-pfix=@tas action=?(%add %remove) rid=resource:res]
      =/  action  %add
      =/  hook-direction=@tas
        ?:(=(our.bowl entity.new-group) %push-hook %pull-hook)
      =/  app-hook=@tas
        (slav %tas (rap 3 app-hook-pfix '-' hook-direction ~))
      |^
      ?:  =(our.bowl entity.new-group)
        update-hook-push
      update-hook-pull
      ::
      ++  update-hook-pull
        (poke-our app-hook %pull-hook-action !>([action entity.new-group rid]))
      ::
      ++  update-hook-push
        (poke-our app-hook %push-hook-action !>([action rid]))
      --
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
        ~&  >>>  "on-host-change +add-graphs: +scry-graph returns non %add-graph for {<resource.mdr>}: {<update>}"
        loop(as t.as)  ::  TODO: can we do better here?
      =.  p.update  now.bowl
      =.  entity.resource.q.update  entity.new-group
      ::
      ;<  ~  bind:m
        (poke-our %graph-store %graph-update-3 !>(update))
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
        (poke-our %graph-pull-hook (rem-pull-hook resource.mdr))
      ::
      =/  =update:gra
        :+  now.bowl
          %remove-graph
        resource.mdr
      ;<  ~  bind:m
        (poke-our %graph-store %graph-update-3 !>(update))
      loop(as t.as)
    ::
    ++  add-group
      =/  m  (strand ,~)
      ^-  form:m
      ;<  g=(unit group:group)  bind:m  (scry-group old-group)
      ?~  g
        ~&  >>>  "on-host-change +add-group: +scry-group returns ~ for {<old-group>}"
        (pure:m ~)
      ;<  ~  bind:m
        %+  poke-our
          %group-store
        :-  %group-action
        !>([%add-group new-group policy.u.g %.n])  ::  TODO: copy policy
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
        %+  poke-our  %group-push-hook
        :-  %group-update-0
        !>([%remove-members old-group (silt ~[our.bowl])])
      ;<  ~  bind:m
        %+  poke-our
          %group-store
        [%group-action !>([%remove-group old-group ~])]
      ::
      ;<  ~  bind:m
        (poke-our %metadata-pull-hook (rem-pull-hook old-group))
      ;<  ~  bind:m
        (poke-our %contact-pull-hook (rem-pull-hook old-group))  ::  TODO: needed?
      (poke-our %group-pull-hook (rem-pull-hook old-group))
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
