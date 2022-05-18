/-  group,
    pull-hook,
    push-hook,
    spider,
    gra=graph-store,
    grp=group-store,
    met=metadata-store
/+  push-hook,
    strandio,
    dao-lib=dao,
    res=resource
::
=*  strand     strand:spider
=*  leave      leave:strandio
=*  poke-our   poke-our:strandio
=*  scry       scry:strandio
=*  take-fact  take-fact:strandio
=*  watch      watch:strandio
=>
  |%
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
    :-  %pull-hook-action
    !>(`action:pull-hook`[%remove rid])
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
      :-  %metadata-update-2
      !>(`update:met`[%remove group.a mdr])
    ;<  ~  bind:m  (poke-our %metadata-store remove)
    ::
    =/  new-metadatum=metadatum:met
      ?.  ?=(%group -.config.metadatum.a)  metadatum.a
      ?~  feed.config.metadatum.a          metadatum.a
      ?~  u.feed.config.metadatum.a        metadatum.a
      metadatum.a(entity.resource.u.u.feed.config entity.new-group)
    =/  add=cage
      :-  %metadata-update-2
      !>  ^-  update:met
      :^    %add
          new-group
        mdr(entity.resource entity.new-group)
      new-metadatum
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
      |^
      =/  m  (strand ,~)
      ?:  =(our.bowl entity.new-group)
        ;<  ~  bind:m  add-push-hook
        (pure:m ~)
      ;<  ~  bind:m  add-pull-hook
      (pure:m ~)
      ::
      ++  add-pull-hook
        %^  poke-our
            app-add-hook
          %pull-hook-action
        !>(`action:pull-hook`[%add entity.new-group rid])
      ::
      ++  add-push-hook
        %^  poke-our
            app-add-hook
          %push-hook-action
        !>(`action:push-hook`[%add rid])
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
        ~&  >>>  %+  weld
            "on-host-change +add-graphs: +scry-graph returns"
          " non %add-graph for {<resource.mdr>}: {<update>}"
        loop(as t.as)  ::  TODO: can we do better here?
      =.  p.update  now.bowl
      =.  entity.resource.q.update  entity.new-group
      ::
      ;<  ~  bind:m
        (update-hook %dao-graph resource.q.update)
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
      ::
      =/  =update:gra
        :+  now.bowl
          %remove-graph
        resource.mdr
      ;<  ~  bind:m
        (poke-our %graph-store %graph-update-3 !>(update))
      ::
      ?:  =(our.bowl entity.old-group)
        loop(as t.as)
      ;<  ~  bind:m
        (poke-our %dao-graph-pull-hook (rem-pull-hook resource.mdr))
      ::
      loop(as t.as)
    ::
    ++  update-hooks
      =/  m  (strand ,~)
      ^-  form:m
      ;<  ~  bind:m
        (update-hook %dao-metadata new-group)
      (pure:m ~)
    ::
    ++  remove-hooks
      =/  m  (strand ,~)
      ^-  form:m
      ;<  ~  bind:m
        (poke-our %dao-metadata-pull-hook (rem-pull-hook old-group))
      (pure:m ~)
    ::
    --
  --
::
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  args  !<((unit (pair (unit resource:res) resource:res)) arg)
?~  args  (pure:m !>(~))
=*  old-dao-rid  p.u.args
=*  new-dao-rid  q.u.args
?~  old-dao-rid  (pure:m !>(~))
;<  =bowl:spider  bind:m  get-bowl:strandio
?:  ?&  ?=(~ (get-dao:dao-lib(our.bowl our.bowl, now.bowl now.bowl) [%| u.old-dao-rid]))
        ?=(~ (get-dao:dao-lib(our.bowl our.bowl, now.bowl now.bowl) [%| new-dao-rid]))
    ==
  (pure:m !>(~))
~&  >  "getting group metadata..."
;<  =associations:met  bind:m  (scry-group-metadata u.old-dao-rid)
=/  as=(list (pair md-resource:met association:met))
  ~(tap by associations)
~&  >  "updating hooks..."
;<  ~  bind:m
  ~(update-hooks update-host u.old-dao-rid new-dao-rid bowl)
~&  >  "adding new graphs..."
;<  ~  bind:m
  (~(add-graphs update-host u.old-dao-rid new-dao-rid bowl) as)
~&  >  "removing existing graphs..."
;<  ~  bind:m
  (~(remove-graphs update-host u.old-dao-rid new-dao-rid bowl) as)
~&  >  "updating metadata-store..."
;<  ~  bind:m  (update-metadata-store new-dao-rid as)
~&  >  "done"
(pure:m !>(~))
