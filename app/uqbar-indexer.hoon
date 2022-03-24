::  uqbar-indexer:
::
::  Index blocks
::
::    Receive new blocks, index them,
::    and update subscribers with full blocks
::    or with hashes of interest
::
::
::    ## Scry paths
::
::    /x/block-height:
::      The current block height
::    /x/block:
::      The most recent block
::    /x/block-num/[@ud]:
::      The block with given block number
::    /x/block-hash/[@ux]:
::      The block with given block hash
::    /x/chunk-num/[@ud]/[@ud]:
::      The chunk with given block number/chunk number
::    /x/chunk-hash/[@ux]/[@ud]:
::      The chunk with given block hash/chunk number
::    /x/egg/[@ux]:
::      Info about egg (transaction) with the given hash
::    /x/from/[@ux]:
::      History of sender with the given hash
::    /x/grain/[@ux]:
::      State of grain with given hash
::    /x/id/[@ux]:
::      History of id with the given hash
::    /x/to/[@ux]:
::      History of receiver with the given hash
::    /x/hash/[@ux]:
::      Info about hash
::
::
::    ## Subscription paths (TODO)
::
::    /block:
::
::    /hash/[@ux]:
::
::    ##  Pokes
::
::    %set-chain-source:
::
::
/-  uqbar-indexer,
    zig=ziggurat
/+  agentio,
    dbug,
    default-agent,
    verb,
    smart=zig-sys-smart
::
|%
+$  card  card:agent:gall
::
+$  versioned-state
  $%  state-zero
  ==
::
+$  state-zero
  $:  %0
      chain-source=(unit dock)
      =blocks:uqbar-indexer
      =index:uqbar-indexer
  ==
--
::
=|  state-zero
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
=<
  |_  =bowl:gall
  +*  this            .
      uqbar-indexer-core  +>
      uic                 ~(. uqbar-indexer-core bowl)
      def                 ~(. (default-agent this %|) bowl)
  ::
  ++  on-init  `this(state [%0 ~ ~ *index:uqbar-indexer])
  ++  on-save  !>(state)
  ++  on-load
    |=  =old=vase
    =/  old  !<(versioned-state old-vase)
    ?-  -.old
      %0  `this(state old)
    ==
  ::
  ++  on-poke  ::  on-poke:def
    |=  [=mark =vase]
    ^-  (quip card _this)
    ?>  (team:title our.bowl src.bowl)
    =^  cards  state
      ?+  mark  (on-poke:def mark vase)
      ::
          %set-chain-source
        (set-chain-source:uic !<(dock vase))
      ::
      ==
    [cards this]
  ::
  ++  on-watch  on-watch:def
  ++  on-leave  on-leave:def
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?+  path  (on-peek:def path)
        [%x %block-height ~]
      ``noun+!>(`@ud`(lent blocks))
    ::
        [%x %block ~]
      :^  ~  ~  %noun
      !>  ^-  (unit update:uqbar-indexer)
      ?:  =(0 (lent blocks))  ~
      `(rear blocks)
    ::
        [%x %block-num @ ~]
      =/  block-num=@ud  i.t.t.path
      :^  ~  ~  %noun
      !>  ^-  (unit update:uqbar-indexer)
      (serve-update %block block-num)
    ::
        [%x %chunk-num @ @ ~]
      =/  block-num=@ud  i.t.t.path
      =/  town-id=@ud  i.t.t.t.path
      :^  ~  ~  %noun
      !>  ^-  (unit update:uqbar-indexer)
      (serve-update %chunk [block-num town-id])
    ::
        $?  [%x %block-hash @ ~]
            :: [%x %chunk-hash @ @ ~]
            [%x %egg @ ~]
            [%x %from @ ~]
            [%x %grain @ ~]
            [%x %to @ ~]
        ==
      =/  =query-type:uqbar-indexer  i.t.path
      =/  hash=@ux  i.t.t.path
      :^  ~  ~  %noun
      !>  ^-  (unit update:uqbar-indexer)
      (serve-update query-type hash)
    ::
        [%x %id @ ~]
        ::  search over from and to and return all hits
      =/  hash=@ux  i.t.t.path
      =/  from=update:uqbar-indexer  (serve-update %from hash)
      =/  to=update:uqbar-indexer  (serve-update %to hash)
      :^  ~  ~  %noun
      !>  ^-  (unit update:uqbar-indexer)
      (combine-update-sets:uic ~[from to])
    ::
        [%x %hash @ ~]
        ::  search over all hashes and return all hits
        ::  TODO: make blocks and grains play nice with eggs
        ::        so we can return all hits together
      =/  hash=@ux  i.t.t.path
      :: =/  block-hash=update:uqbar-indexer
      ::   (serve-update %block-hash hash)
      =/  egg=update:uqbar-indexer  (serve-update %egg hash)
      =/  from=update:uqbar-indexer  (serve-update %from hash)
      :: =/  grain=update:uqbar-indexer  (serve-update %grain hash)
      =/  to=update:uqbar-indexer  (serve-update %to hash)
      :^  ~  ~  %noun
      !>  ^-  (unit update:uqbar-indexer)
      (combine-update-sets:uic ~[egg from to])
      :: (combine-update-sets:uic ~[block-hash egg from grain to])
    ::
    ==
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    ^-  (quip card _this)
    ?+  wire  (on-agent:def wire sign)
    ::
        [%chain-update ~]
      ?+  -.sign  (on-agent:def wire sign)
      ::
          %kick
        :_  this
        =/  wcs=(unit card)  (watch-chain-source:uic ~)
        ?~  wcs  ~  ~[u.wcs]
      ::
          %fact
        =+  !<(=update:uqbar-indexer q.cage.sign)
        ?>  ?=(%block -.update)
        ?>  =((lent blocks) num.block-header.update)
        =*  new-block  +.update
        ?~  blocks  `this(blocks ~[new-block])
        =/  previous-block  (rear blocks)
        ?>  .=  data-hash.block-header.previous-block
          data-hash.block-header.new-block
        ::
        =/  [block-hash egg from grain to]
          (parse-block block-num new-block)
        =.  index  (update-index index %block-hash block-hash)
        =.  index  (update-index index %egg egg)
        =.  index  (update-index index %from from)
        =.  index  (update-index index %grain grain)
        =.  index  (update-index index %to to)
        `this(blocks (snoc blocks new-block), index index)
      ::
      ==
    ::
    ==
  ++  on-arvo  on-arvo:def
  ++  on-fail   on-fail:def
  ::
  --
::
|_  =bowl:gall
+*  io   ~(. agentio bowl)
::
++  watch-chain-source
  |=  d=(unit dock)
  ^-  (unit card)
  =/  source=(unit dock)  (mate d chain-source)
  ?~  source  ~
  :-  ~
  %+  %~  watch  pass:io
  /chain-update  u.source  /blocks  :: TODO: fill in actual path
::
++  leave-chain-source
  ^-  (unit card)
  ?~  chain-source  ~
  :-  ~
  %-  %~  leave  pass:io
  /chain-update  u.chain-source
::
++  set-chain-source  :: TODO: is this properly generalized?
  |=  d=dock
  ^-  (quip card _state)
  :_  state(chain-source `d)
  ?~  watch=(watch-chain-source `d)  ~
  ~[u.watch]
:: ::  TODO: make blocks and grains play nice with eggs
:: ::        so we can return all hits together
:: ::
:: ++  combine-update-sets
::   |*  updates=(list (unit update:uqbar-indexer))
::   ^-  (unit update:uqbar-indexer)
::   ?~  updates  ~
::   =/  query-type=(unit @tas)
::     %+  roll  updates
::     |=  [update=(unit update:uqbar-indexer) query-type=(unit @tas)]
::     ?~  update  query-type
::     ?~  query-type  `-.u.update
::     ?>  =(u.query-type -.u.update)
::     u.query-type
::   ?~  query-type  ~
::   =/  combined
::     %-  silt
::     %-  zing
::     %+  murn  updates
::     |=  update=(unit update:uqbar-indexer)
::     ?~  update  ~
::     ?:  ?=(%egg -.u.update)
::       `~(tap in eggs.u.update)
::     ?:  ?=(%grain -.u.update)
::       `~(tap in grains.u.update)
::     ~
::   `[u.query-type combined]
::
++  combine-update-sets
  |=  updates=(list (unit [%egg eggs=(set [=location:uqbar-indexer =egg:smart])]))
  ^-  (unit update:uqbar-indexer)
  ?~  updates  ~
  =/  combined=(set [location:uqbar-indexer egg:smart])
    %-  %~  gas  in  *(set [=location:uqbar-indexer =egg:smart])
    %-  zing
    %+  murn  updates
    |=  update=(unit [%egg eggs=(set [=location:uqbar-indexer =egg:smart])])
    ?~  update  ~
    `~(tap in eggs.u.update)
  `[%egg combined]
::
++  update-index
  |=  $:  =index:uqbar-indexer
          =query-type:uqbar-indexer
          locations=(list [@ux location:uqbar-indexer])
      ==
  ^-  index:uqbar-indexer
  %+  %~  put  by  index
    query-type
  %-  %~  gas  ju
    ?~  old=(~(get by index) query-type)
      *(jug @ux location:uqbar-indexer)
    u.old
  locations
::
++  serve-update
  |=  [=query-type:uqbar-indexer =query-payload:uqbar-indexer]
  |^  ^-  (unit update:uqbar-indexer)
  ?+  query-type  !!
  ::
      %block
    ?>  ?=(@ud query-payload)
    (get-block query-payload)
  ::
      %chunk
    ?>  ?=([@ @] query-payload)  ::  [block-num town-id]
    ?~  block-update=(get-block block-num.query-payload)  ~
    ?>  ?=(%block -.u.block-update)
    ?~  chunk=(~(get by q.block.u.block-update) town-id.query-payload)  ~
    `[%chunk query-payload u.chunk]
  ::
  ::     %chunk-hash
  ::   get-chunk-update
  ::
      ?(%block-hash %egg %from %grain %to)
    get-from-index
  ::
  ==
  ::
  ++  get-block
    |=  block-num=@ud
    ^-  (unit update:uqbar-indexer)
    ?.  (lth block-num (lent blocks))  ~
    `[%block (snag block-num blocks)]
  ::
  ++  get-chunk-update
    ^-  (unit update:uqbar-indexer)
    ?~  locations=~(tap in get-locations)  ~
    ?>  =(1 (lent locations))
    =/  =location:uqbar-indexer  (rear locations)
    ?>  ?=([@ @] location)  ::  [block-num town-id]
    ?~  chunk=(get-chunk block-num.location town-id.location)  ~
    `[%chunk location u.chunk]
  ::
  ++  get-from-index
    ^-  (unit update:uqbar-indexer)
    ?>  ?=(@ux query-payload)
    =/  locations=(list location:uqbar-indexer)
      ~(tap in get-locations)
    ?+  query-type  !!
    ::
        %block-hash
      ?>  =(1 (lent locations))
      =/  =location:uqbar-indexer  (rear locations)
      ?>  ?=(@ location)  ::  block-num
      ?.  (lth location (lent blocks))  ~
      `[%block (snag location blocks)]
    ::
        %grain
      =|  grains=(set [location:uqbar-indexer grain:smart])
      |-
      ?~  locations
        ?~  grains  ~
        `[%grain grains]
      =*  location  i.locations
      ?>  ?=([@ @] location)  ::  [block-num town-id]
      ?~  chunk=(get-chunk block-num.location town-id.location)
        $(locations t.locations)  :: TODO: can we do better here?
      =*  granary  p.+.u.chunk
      ?~  grain=(~(get by granary) query-payload)
        $(locations t.locations)
      %=  $
          locations  t.locations
          grains     (~(put in grains) [location u.grain])
      ==
    ::
        ?(%egg %from %to)
      =|  eggs=(set [location:uqbar-indexer egg:smart])
      |-
      ?~  locations
        ?~  eggs  ~
        `[%egg eggs]
      =*  location  i.locations
      ?>  ?=([@ @ @] location)  ::  [block-num town-id egg-num]
      ?~  chunk=(get-chunk block-num.location town-id.location)
        $(locations t.locations)  :: TODO: can we do better here?
      =*  egg-num  egg-num.location
      =*  txs  -.u.chunk
      ?>  (lth egg-num (lent txs))
      =+  [hash=@ux =egg:smart]=(snag egg-num txs)
      ?>  =(query-payload hash)
      %=  $
          locations  t.locations
          eggs       (~(put in eggs) [location egg])
      ==
    ::
    ==
  ::
  ++  get-locations
    ^-  (set location:uqbar-indexer)
    ?>  ?=(@ux query-payload)
    ?~  query-index=(~(get by index) query-type)  ~  :: TODO: crash instead?
    (~(get ju u.query-index) query-payload)
  ::
  ++  get-chunk
    |=  [block-num=@ud town-id=@ud]
    ^-  (unit chunk:zig)
    ?>  (lth block-num (lent blocks))
    =/  [* =block:zig]  (snag block-num blocks)
    =*  chunks  q.block
    (~(get by chunks) town-id)
  ::
  --
::  parse a given block into hash:location
::  pairs to be added to index
::
++  parse-block
  |=  [block-num=@ud =block-header:zig =block:zig]
  |^
  ^-  $:  (list [@ux block-num=@ud])
          (list [@ux [block-num=@ud town-id=@ud egg-num=@ud]])
          (list [@ux [block-num=@ud town-id=@ud egg-num=@ud]])
          (list [@ux [block-num=@ud town-id=@ud]])
          (list [@ux [block-num=@ud town-id=@ud egg-num=@ud]])
      ==
  =/  block-hash=(list [@ux block-num=@ud])
    ~[[`@ux`data-hash.block-header block-num]]
  =|  egg=(list [@ux [block-num=@ud town-id=@ud egg-num=@ud]])
  =|  from=(list [@ux [block-num=@ud town-id=@ud egg-num=@ud]])
  =|  grain=(list [@ux [block-num=@ud town-id=@ud]])
  =|  to=(list [@ux [block-num=@ud town-id=@ud egg-num=@ud]])
  =/  chunks=(list [town-id=@ud =chunk:zig])  ~(tap by q.block)
  :-  block-hash
  |-
  ?~  chunks
    :*  egg
        from
        grain
        to
    ==
  =*  town-id  town-id.i.chunks
  =*  chunk    chunk.i.chunks
  =*  txs      -.chunk
  =*  granary  p.+.chunk
  ::  grains
  ::
  =+  new-grain=(parse-granary town-id granary)
  ::  transactions
  ::
  =+  [new-egg new-from new-to]=(parse-transactions town-id txs)
  %=  $
      chunks  t.chunks
      egg     (weld egg new-egg)
      from    (weld from new-from)
      grain   (weld grain new-grain)
      to      (weld to new-to)
  ==
  ::
  ++  parse-granary
    |=  [town-id=@ud =granary:smart]
    ^-  (list [@ux [block-num=@ud town-id=@ud]])
    =|  parsed-grain=(list [@ux [block-num=@ud town-id=@ud]])
    =/  grains=(list [@ux grain:smart])
      ~(tap by granary)
    |-
    ?~  grains  [parsed-grain]
    =*  id     id.i.grains
    =*  grain  grain.i.grains
    %=  $
        grains  t.grains
        parsed-grain
          [[id [block-num town-id]] parsed-grain]
    ==
  ::
  ++  parse-transactions
    |=  [town-id=@ud txs=(list [@ux egg:smart])]
    ^-  $:  (list [@ux [block-num=@ud town-id=@ud egg-num=@ud]])
            (list [@ux [block-num=@ud town-id=@ud egg-num=@ud]])
            (list [@ux [block-num=@ud town-id=@ud egg-num=@ud]])
        ==
    =|  parsed-egg=(list [@ux [block-num=@ud town-id=@ud egg-num=@ud]])
    =|  parsed-from=(list [@ux [block-num=@ud town-id=@ud egg-num=@ud]])
    =|  parsed-to=(list [@ux [block-num=@ud town-id=@ud egg-num=@ud]])
    =/  egg-num=@ud  0
    |-
    ?~  txs  [parsed-egg parsed-from parsed-to]
    =*  tx-hash  -.i.txs
    =*  egg      +.i.txs
    =*  to       to.p.egg
    =*  from
      ?:  ?=(@ux from.p.egg)  from.p.egg
      id.from.p.egg
    =/  location=[@ud @ud @ud]  [block-num town-id egg-num]
    %=  $
        txs          t.txs
        parsed-egg   [[tx-hash location] parsed-egg]
        parsed-from  [[from location] parsed-from]
        parsed-to    [[to location] parsed-to]
        egg-num      +(egg-num)
    ==
  ::
  --
::
--
