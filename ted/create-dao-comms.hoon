/-  pull-hook,
    push-hook,
    spider,
    d=dao,
    ms=metadata-store
/+  strandio,
    res=resource,
    smart=zig-sys-smart
::
=*  strand    strand:spider
=*  leave      leave:strandio
=*  poke-our  poke-our:strandio
=*  scry      scry:strandio
=*  take-fact  take-fact:strandio
=*  watch      watch:strandio
=>
  |%
  ::
  ++  dao-contract-id  ::  TODO: remove hardcode
    `@ux`'dao'
  ::
  ++  dao-town-id  ::  TODO: remove hardcode
    1
  ::
  --
=>
  |_  =bowl:spider
  ::
  ++  get-dao
    |=  [dao-id=id:smart dao-rid=resource:res]
    =/  m  (strand ,(unit dao:d))
    ^-  form:m
    ;<  dao-from-id=(unit dao:d)  bind:m
      %+  scry  (unit dao:d)
      /gx/dao/daos/(scot %ux dao-id)/noun
    ;<  dao-from-rid=(unit dao:d)  bind:m
      %+  scry  (unit dao:d)
      /gx/dao/daos/ship/(scot %p entity.dao-rid)/[name.dao-rid]/noun
    (pure:m (mate dao-from-id dao-from-rid))
  ::
  ++  make-metadatum
    |=  name=@tas
    ^-  metadatum:ms
    =|  =metadatum:ms
    =:  title.metadatum         name
        description.metadatum   name
    ::     color.metadatum
        date-created.metadatum  now.bowl
        creator.metadatum       our.bowl
        config.metadatum        [%group feed=~]  :: ?
    ::     picture.metadatum
        preview.metadatum       %.n
        hidden.metadatum        %.n
    ::     vip.metadatum
    ==
    metadatum
  ::
  ++  watch-dao-if-not-exist
    |=  [dao-salt=@ dao-id=id:smart rid=resource:res]
    |^
    =/  m  (strand ,~)
    ^-  form:m
    ::
    ~&  >  "checking for existence of dao..."
    ;<  existing-dao=(unit dao:d)  bind:m
      (get-dao dao-id rid)
    ?:  ?=(^ existing-dao)
      ~&  >  "found pre-existing dao..."
      (pure:m ~)
    ::
    ~&  >  "adding dao to be watched to %dao..."
    ;<  ~  bind:m
      %^  poke-our  %dao  %dao-update
      !>(`on-chain-update:d`[%add-dao dao-salt ~])
    ::
    ;<  ~  bind:m
      %^  watch  indexer-watch-wire
      [entity.rid %uqbar-indexer]  indexer-watch-path
    ~&  >  "waiting for update from indexer..."
    ;<  =cage  bind:m  (take-fact indexer-watch-wire)
    ;<  ~  bind:m
      (leave indexer-watch-wire [entity.rid %uqbar-indexer])
    (pure:m ~)
    ::
    ++  indexer-watch-wire
      /create-dao-comms/(scot %ux dao-id)
    ::
    ++  indexer-watch-path
      /grain/(scot %ux dao-id)
    ::
    --
  ::
  --
::
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  args  !<((unit [rid=resource:res dao-salt=@ dao-name=@t]) arg)
?~  args  (pure:m !>(~))
;<  =bowl:spider  bind:m  get-bowl:strandio
=*  rid       rid.u.args
=*  dao-salt  dao-salt.u.args
=*  dao-name  dao-name.u.args
=/  dao-id=id:smart
  %:  fry-rice:smart
      dao-contract-id
      dao-contract-id
      dao-town-id
      dao-salt
  ==
::
;<  ~  bind:m
  (watch-dao-if-not-exist dao-salt dao-id rid)
::
;<  ~  bind:m
  %^  poke-our  %dao  %dao-update
  !>(`off-chain-update:d`[%add-comms dao-id rid])
::
~&  >  "poking dao-metadata-pu??-hook..."
;<  ~  bind:m
  ?:  =(our.bowl entity.rid)
    %^  poke-our  %dao-metadata-push-hook  %push-hook-action
    !>(`action:push-hook`[%add rid])
  %^  poke-our  %dao-metadata-pull-hook  %pull-hook-action
  !>(`action:pull-hook`[%add entity.rid rid])
::
::  TODO: add dao-contact-pu??-hook?
::
?.  =(our.bowl entity.rid)
  ~&  >  "done"
  (pure:m !>(~))
~&  >  "constructing metadatum..."
=/  =metadatum:ms
  (make-metadatum(bowl bowl) dao-name)
::
~&  >  "poking metadata-store..."
;<  ~  bind:m
  %^  poke-our  %metadata-store  %metadata-action
  !>(`action:ms`[%add rid [%dao rid] metadatum])
~&  >  "done"
(pure:m !>(~))
