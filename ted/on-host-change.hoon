/-  group, spider, grp=group-store, gra=graph-store, met=metadata-store
/+  push-hook, strandio, res=resource
::
=*  strand     strand:spider
=*  leave      leave:strandio
=*  poke-our   poke-our:strandio
=*  scry       scry:strandio
=*  take-fact  take-fact:strandio
=*  watch      watch:strandio
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
      |=  [app-hook-pfix=@tas rid=resource:res]
      =/  add-hook-direction=@tas
        ?:(=(our.bowl entity.new-group) %push-hook %pull-hook)
      =/  app-add-hook=@tas
        (rap 3 app-hook-pfix '-' add-hook-direction ~)
      =/  hook-action=@tas
        (rap 3 add-hook-direction '-action' ~)
      |^
      =/  m  (strand ,~)
      ?:  =(our.bowl entity.old-group)
        ;<  ~  bind:m
          (remove-hook %push-hook-action [entity.old-group name.rid])
        ;<  ~  bind:m  add-pull-hook
        (pure:m ~)
      ?:  =(our.bowl entity.new-group)
        ;<  ~  bind:m  add-hook
        (pure:m ~)
      ;<  ~  bind:m  add-pull-hook
      (pure:m ~)
      ::
      ++  add-pull-hook
        %^  poke-our
            app-add-hook
          %pull-hook-action
        !>([%add entity.new-group rid])
      ::
      ++  add-hook
        %^  poke-our
            app-add-hook
          hook-action
        !>([%add rid])
      ::
      ++  remove-hook
        |=  [rem-hook-action=@tas rem-rid=resource:res]
        %^  poke-our
            (rap 3 app-hook-pfix '-' %push-hook ~)
          rem-hook-action
        !>([%remove rem-rid])
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
        (update-hook %graph resource.q.update)
      ::
      ;<  ~  bind:m
        (poke-our %graph-store %graph-update-3 !>(update))
      loop(as t.as)
    ::
    ++  remove-graphs
      |=  [as=(list (pair md-resource:met association:met))]
      =/  m  (strand ,~)
      ^-  form:m
      |-
      =*  loop  $
      ?~  as  (pure:m ~)
      =*  mdr  p.i.as
      ?.  ?=(%graph app-name.mdr)
        loop(as t.as)
      =/  =wire
        /on-host-change/remove-graphs/(scot %da now.bowl)
      =/  =path
        ;:  weld
          /resource/ver
          (en-path:res resource.mdr)
          /(scot %ud 3)
        ==
      ;<  ~  bind:m
        (watch wire [entity.resource.mdr %graph-push-hook] path)
      ::
      =/  =update:gra
        :+  now.bowl
          %remove-graph
        resource.mdr
      ;<  ~  bind:m
        (poke-our %graph-store %graph-update-3 !>(update))
      ::
      ?:  =(our.bowl entity.old-group)
        ;<  ~  bind:m  (leave wire [entity.old-group %graph-push-hook])
        loop(as t.as)
      ;<  ~  bind:m
        (poke-our %graph-pull-hook (rem-pull-hook resource.mdr))
      ::
      ;<  =cage  bind:m  (take-fact wire)
      ;<  ~  bind:m  (leave wire [entity.old-group %graph-push-hook])
      ?.  ?=(%graph-update-3 -.cage)
        ~&  >>>  "on-host-change remove-graphs: expected %graph-update-3; instead got:"
        ~&  >>>  cage
        !!  :: TODO: what should happen here?
      =/  rem-update=update:gra  !<(update:gra +.cage)
      ?.  ?&
            ?=(%add-graph -.q.rem-update)
            =(resource.mdr resource.q.rem-update)
          ==
        ~&  >>>  "on-host-change remove-graphs: expected %add-graph and same resource; instead got:"
        ~&  >>>  rem-update
        !!  :: TODO: what should happen here?
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
        !>([%add-group new-group policy.u.g %.n])
      ::
      ;<  ~  bind:m
        %+  poke-our
          %group-store
        :-  %group-action
        !>([%add-members new-group members.u.g])
      ::
      ;<  ~  bind:m
        (update-hook %metadata new-group)
      ;<  ~  bind:m
        (update-hook %contact new-group)
      ;<  ~  bind:m
        (update-hook %group new-group)
      (pure:m ~)
    ::
    ++  remove-group
      =/  m  (strand ,~)
      ^-  form:m
      ;<  ~  bind:m
        %+  poke-our
          %group-store
        [%group-action !>([%remove-group old-group ~])]
      ::
      ;<  ~  bind:m
        (poke-our %metadata-pull-hook (rem-pull-hook old-group))
      ;<  ~  bind:m
        (poke-our %contact-pull-hook (rem-pull-hook old-group))
      ;<  ~  bind:m
        (poke-our %group-pull-hook (rem-pull-hook old-group))
      (pure:m ~)
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
~&  >  "adding equivalent group..."
;<  ~  bind:m
  ~(add-group update-host old-group new-group bowl)
~&  >  "adding new graphs..."
;<  ~  bind:m
  (~(add-graphs update-host old-group new-group bowl) as)
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
