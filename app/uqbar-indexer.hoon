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
    res=resource,
    store=dao-group-store,
    zig=ziggurat
/+  agentio,
    dbug,
    default-agent,
    verb,
    daolib=dao,
    reslib=resource,
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
      block-source=(unit dock)
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
  ++  on-init  `this(state [%0 *dao-groups:store ~])
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
      ::     %serve-update
      ::   :_  this
      ::   ?~  $=  update
      ::       %-  serve-update:uic
      ::       !<  :-  query-type:uqbar-indexer
      ::           query-payload:uqbar-index
      ::       vase
      ::     ~
      ::   update
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
        $?  [%x %block-hash @ ~]
            [%x %egg @ ~]
            [%x %from @ ~]
            [%x %grain @ ~]
            [%x %to @ ~]
        ==
      =/  =query-type:uqbar-indexer  i.t.path
      =/  hash=@ux  i.t.t.path
      :^  ~  ~  %noun
      !>  ^-  (unit update:uqbar-indexer)
      (serve-update query-type block-hash)
    ::
        [%x %id @ ~]
        ::  search over from and to and return all hits
      =/  hash=@ux  i.t.t.path
      :^  ~  ~  %noun
      !>  ^-  (unit update:uqbar-indexer)
      (serve-update query-type block-hash)
    ::
        [%x %hash @ ~]
        ::  search over all hashes and return all hits
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
        ?~  wcs=watch-chain-source:uic  ~
        ~[u.wcs]
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
          (parse-block block-num block)
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
  ^-  (unit card)
  ?~  chain-source  ~
  :-  ~
  %+  %~  watch  pass:io
  /chain-update  u.chain-source  /blocks  :: TODO: fill in actual path
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
  ?~  watch=watch-chain-source  ~
  ~[u.watch]
::
++  update-index
  |=  $:  =index:uqbar-indexer
          =query-type:uqbar-indexer
          locations=(list [id:smart location:uqbar-indexer])
      ==
  ^-  index:uqbar-indexer
  %+  %~  put  by  index
    query-type
  %-  %~  gas  by
    ?~  old=(~(get by index) query-type)
      *(map id:smart location:uqbar-indexer)
    old
  locations
::
++  serve-update
  |=  [=query-type:uqbar-indexer =query-payload:uqbar-index]
  ^-  (unit update:uqbar-indexer)
  |^
  ?+  query-type  !!
      %block
    get-block
  ::
      ?(%block-hash %egg %from %grain %to)
    get-from-index
  ::
  ==
  ::
  ++  get-block
    ^-  (unit update:uqbar-indexer)
    ?>  ?=(@ud query-payload)
    ?.  (lth query-payload (lent blocks))  ~
    `[%block (snag query-payload blocks)]
  ::
  ++  get-chunk-update
    ^-  (unit update:uqbar-indexer)
    ?~  chunk=(get-chunk u.location)  ~
    `[%chunk u.chunk]
  ::
  ++  get-from-index
    ^-  (unit update:uqbar-indexer)
    ?>  ?=(@ux query-payload)
    ?~  location=get-location  ~
    ?~  chunk=(get-chunk u.location)
    ?-  query-type
    ::
        %block-hash
      ?>  ?=(@ u.location)  ::  block-num
      ?.  (lth u.location (lent blocks))  ~
      `[%block (snag u.location blocks)]
    ::
        %grain
      ?>  ?=([@ @] u.location)  ::  [block-num town-id]
      =*  granary  p.+.u.chunk
      ?~  grain=(~(get by granary) query-payload)  ~
      `[%grain u.grain]
    ::
        ?(%egg %from %to)
      ?>  ?=([@ @ @] u.location)  ::  [block-num town-id egg-num]
      =*  egg-num  egg-num.u.location
      =*  txs  -.u.chunk
      ?>  (lth egg-num (lent txs))
      =+  [hash=@ux =egg:smart]=(snag egg-num txs)
      ?>  =(query-payload hash)
      `[%egg egg]
    ::
    ==
  ::
  ++  get-location
    ^-  (unit location:uqbar-indexer)
    ?~  query-index=(~(get by index) query-type)  ~  :: TODO: crash instead?
    (~(get by query-index) query-payload)
  ::
  ++  get-chunk
    |=  location:uqbar-indexer
    ^-  (unit chunk:zig)
    =*  block-num  block-num.location
    =*  town-id  town-id.location
    ?>  (lth block-num (lent blocks))
    =+  [block-header block]=(snag block-num blocks)
    =*  chunks  q.block
    (~(get by chunks) town-id)
  ::
  --
::
++  parse-block
  |=  [block-num=@ud =block:zig]
  |^
  ^-  $:  (list [id:smart block-num=@ud])
          (list [id:smart [block-num=@ud town-id=@ud]])
          (list [id:smart [block-num=@ud town-id=@ud egg-num=@ud]])
          (list [id:smart [block-num=@ud town-id=@ud egg-num=@ud]])
          (list [id:smart [block-num=@ud town-id=@ud egg-num=@ud]])
      ==
  =/  block-hash=(list [id:smart block-num=@ud])
    [`@ux`data-hash.block-header.block block-num]
  =|  egg=(list [id:smart [block-num=@ud town-id=@ud egg-num=@ud]])
  =|  from=(list [id:smart [block-num=@ud town-id=@ud egg-num=@ud]])
  =|  grain=(list [id:smart [block-num=@ud town-id=@ud]])
  =|  to=(list [id:smart [block-num=@ud town-id=@ud egg-num=@ud]])
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
    ^-  (list [id:smart [block-num=@ud town-id=@ud]])
    =|  parsed-grain=(list [id:smart [block-num=@ud town-id=@ud]])
    =/  grains=(list [id:smart grain:smart])
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
    ^-  $:  (list [id:smart [block-num=@ud town-id=@ud egg-num=@ud]])
            (list [id:smart [block-num=@ud town-id=@ud egg-num=@ud]])
            (list [id:smart [block-num=@ud town-id=@ud egg-num=@ud]])
        ==
    =|  parsed-egg=(list [id:smart [block-num=@ud town-id=@ud egg-num=@ud]])
    =|  parsed-from=(list [id:smart [block-num=@ud town-id=@ud egg-num=@ud]])
    =|  parsed-to=(list [id:smart [block-num=@ud town-id=@ud egg-num=@ud]])
    =/  egg-num=@ud  0
    |-
    ?~  txs  [parsed-egg parsed-from parsed-to]
    =*  tx-hash  -.i.txs
    =*  egg      +.i.txs
    =*  from     from.p.egg
    =*  to       to.p.egg
    =/  location=[@ud @ud @ud]  [block-num town-id egg-num]
    %=  $
        txs          t.txs
        parsed-egg   [[tx-hash location] parsed-egg]
        parsed-from  [[from location] parsed-from]
        parsed-to    [[to location] parsed-to]
        egg-num      +(egg-num)
    ==
  ::
::
--
