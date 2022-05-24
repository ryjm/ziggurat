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
::    /x/block-hash/[@ux]:
::      The slot with given block hash
::    /x/chunk-num/[@ud]/[@ud]/[@ud]:
::      The chunk with given epoch/block/chunk number
::    /x/chunk-hash/[@ux]/[@ud]:
::      The chunk with given block hash/chunk number
::    /x/egg/[@ux]:
::      Info about egg (transaction) with the given hash
::    /x/from/[@ux]:
::      History of sender with the given hash
::    /x/grain/[@ux]:
::      State of grain with given hash
::    /x/hash/[@ux]:
::      Info about hash
::    /x/headers/[@ud]:
::      Most recent [@ud] block headers (up to some cached max)
::    /x/holder/[@ux]:
::      Grains held by id with given hash
::    /x/id/[@ux]:
::      History of id with the given hash
::    /x/lord/[@ux]:
::      Grains ruled by lord with given hash
::    /x/slot:
::      The most recent slot
::    /x/slot-num/[@ud]:
::      The slot with given block number
::    /x/to/[@ux]:
::      History of receiver with the given hash
::
::
::    ## Subscription paths
::
::    /chunk/[@ud]:
::      A stream of each new chunk for a given town.
::
::    /id/[@ux]:
::      A stream of new activity of given id.
::
::    /grain/[@ux]:
::      A stream of changes to given grain.
::
::    /holder/[@ux]:
::      A stream of new activity of given holder.
::
::    /lord/[@ux]:
::      A stream of new activity of given lord.
::
::    /slot:
::      A stream of each new slot.
::
::
::    ##  Pokes
::
::    %set-chain-source:
::      Subscribe to source for new blocks.
::
::    %consume-indexer-update:
::      Add a block or chunk to the index.
::
::    %serve-update:
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
  $%  state-0
  ==
::
+$  base-state-0
  $:  =epochs:zig
      num-recent-headers=@ud
      recent-headers=(list [epoch-num=@ud =block-header:zig])
      $=  serve-previous-update
    $-([=query-type:uqbar-indexer =query-payload:uqbar-indexer] (unit update:uqbar-indexer))
  ==
+$  indices-0
  $:  block-index=(jug @ux block-location:uqbar-indexer)
      egg-index=(jug @ux egg-location:uqbar-indexer)
      from-index=(jug @ux second-order-location:uqbar-indexer)
      grain-index=(jug @ux town-location:uqbar-indexer)
      holder-index=(jug @ux second-order-location:uqbar-indexer)
      lord-index=(jug @ux second-order-location:uqbar-indexer)
      to-index=(jug @ux second-order-location:uqbar-indexer)
  ==
+$  state-0  [%0 base-state-0 indices-0]
::
--
::
=|  state-0
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
=<
  |_  =bowl:gall
  +*  this                .
      def                 ~(. (default-agent this %|) bowl)
      io                  ~(. agentio bowl)
      uqbar-indexer-core  +>
      uic                 ~(. uqbar-indexer-core bowl)
  ::
  ++  on-init  `this(num-recent-headers 50, serve-previous-update serve-update)
  ++  on-save  !>(state)
  ++  on-load
    |=  =old=vase
    =/  old  !<(versioned-state old-vase)
    ?-  -.old
      %0  `this(state old)
    ==
  ::
  ++  on-poke
    |=  [=mark =vase]
    ^-  (quip card _this)
    =^  cards  state
      ?+    mark  (on-poke:def mark vase)
      ::
          %set-chain-source
        ?>  (team:title our.bowl src.bowl)
        (set-chain-source:uic !<(dock vase))
      ::
          %set-num-recent-headers
        ?>  (team:title our.bowl src.bowl)
        `state(num-recent-headers !<(@ud vase))
      ::
      ::  TODO: add %consume-update and %serve-update pokes
      ::  https://github.com/uqbar-dao/ziggurat/blob/da1d37adf538ee908945557a68387d3c87e1c32e/app/uqbar-indexer.hoon#L138
      ::
      ==
    [cards this]
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    ?+    path  (on-watch:def path)
    ::
        [%chunk @ ~]
      :_  this
      =/  town-id=@ud  (slav %ud i.t.path)
      ?~  newest-epoch=(pry:poc:zig epochs)  ~
      ?~  newest-slot=(pry:sot:zig slots.val.u.newest-epoch)
        ~
      =*  newest-block  q.val.u.newest-slot
      ?~  newest-block  ~
      =*  newest-chunks  q.u.newest-block
      =/  newest-chunk  (~(get by newest-chunks) town-id)
      ?~  newest-chunk  ~
      :_  ~
      %+  fact:io
        :-  %uqbar-indexer-update
        !>  ^-  update:uqbar-indexer
        :+  %chunk
          :+  epoch-num=num.val.u.newest-epoch
            block-num=num.p.val.u.newest-slot
          town-id=town-id
        u.newest-chunk
      ~
    ::
        [%id @ ~]
      :_  this
      =/  payload=@ux  (slav %ux i.t.path)
      =/  from=(unit update:uqbar-indexer)
        (serve-previous-update %from payload)
      =/  to=(unit update:uqbar-indexer)
        (serve-previous-update %to payload)
      =/  update=(unit update:uqbar-indexer)
        %-  combine-egg-updates
        ;;  %-  list
          %-  unit
          [%egg eggs=(map id:smart [egg-location:uqbar-indexer egg:smart])]
        ~[from to]
      ?~  update  ~
      :_  ~
      %+  fact:io
        :-  %uqbar-indexer-update
        !>(`update:uqbar-indexer`u.update)
      ~
    ::
        ?([%grain @ ~] [%holder @ ~] [%lord @ ~])
      :_  this
      =/  query-type=?(%grain %holder %lord)  i.path
      =/  payload=@ux  (slav %ux i.t.path)
      ?~  update=(serve-previous-update query-type payload)
        ~
      :_  ~
      %+  fact:io
        :-  %uqbar-indexer-update
        !>(`update:uqbar-indexer`u.update)
      ~
    ::
        [%slot ~]
      :_  this
      ?~  newest-epoch=(pry:poc:zig epochs)  ~
      ?~  newest-slot=(pry:sot:zig slots.val.u.newest-epoch)
        ~
      :_  ~
      %+  fact:io
        :-  %uqbar-indexer-update
        !>  ^-  update:uqbar-indexer
        [%slot val.u.newest-slot]
      ~
    ::
    ==
  ::
  ++  on-leave
    |=  =path
    ^-  (quip card _this)
    ?+    path  (on-watch:def path)
    ::
        $?  [%chunk @ ~]
            [%id @ ~]
            [%grain @ ~]
            [%holder @ ~]
            [%lord @ ~]
            [%slot ~]
        ==
      `this
    ::
    ==
  ::
  ++  on-peek
    |=  =path
    ^-  (unit (unit cage))
    ?+    path  (on-peek:def path)
    ::
        [%x %block-height ~]
      ?~  recent-headers  [~ ~]
      =*  most-recent  i.recent-headers
      :^  ~  ~  %noun
      !>  ^-  [epoch-num=@ud block-num=@ud]
      :-  epoch-num.most-recent
      num.block-header.most-recent
    ::
        [%x %chunk-num @ @ @ ~]
      =/  epoch-num=@ud  (slav %ud i.t.t.path)
      =/  block-num=@ud  (slav %ud i.t.t.t.path)
      =/  town-id=@ud  (slav %ud i.t.t.t.t.path)
      ?~  up=(serve-update %chunk [epoch-num block-num town-id])
        [~ ~]
      :^  ~  ~  %uqbar-indexer-update
      !>  ^-  update:uqbar-indexer
      u.up
    ::
        $?  [%x %block-hash @ ~]
            :: [%x %chunk-hash @ @ ~]
            [%x %egg @ ~]
            [%x %from @ ~]
            [%x %grain @ ~]
            [%x %holder @ ~]
            [%x %lord @ ~]
            [%x %to @ ~]
        ==
      =/  =query-type:uqbar-indexer
        ;;(query-type:uqbar-indexer i.t.path)
      =/  hash=@ux  (slav %ux i.t.t.path)
      ?~  up=(serve-update query-type hash)  [~ ~]
      :^  ~  ~  %uqbar-indexer-update
      !>  ^-  update:uqbar-indexer
      u.up
    ::
        [%x %headers @ ~]
      ?~  recent-headers  [~ ~]
      =/  num-headers=@ud  (slav %ud i.t.t.path)
      :^  ~  ~  %uqbar-indexer-headers
      !>  ^-  (list [epoch-num=@ud =block-header:zig])
      %+  scag
        num-headers
      ^-  (list [epoch-num=@ud =block-header:zig])
      recent-headers
    ::
        [%x %slot ~]
      ?~  newest-epoch=(pry:poc:zig epochs)  [~ ~]
      ?~  newest-slot=(pry:sot:zig slots.val.u.newest-epoch)
        [~ ~]
      :^  ~  ~  %uqbar-indexer-update
      !>  ^-  update:uqbar-indexer
      [%slot val.u.newest-slot]
    ::
        [%x %slot-num @ @ ~]
      =/  epoch-num=@ud  (slav %ud i.t.t.path)
      =/  block-num=@ud  (slav %ud i.t.t.t.path)
      ?~  up=(serve-update %slot epoch-num block-num)  [~ ~]
      :^  ~  ~  %uqbar-indexer-update
      !>  ^-  update:uqbar-indexer
      u.up
    ::
        [%x %id @ ~]
        ::  search over from and to and return all hits
      =/  hash=@ux  (slav %ux i.t.t.path)
      =/  egg=(unit update:uqbar-indexer)
        (serve-update %egg hash)
      =/  from=(unit update:uqbar-indexer)
        (serve-update %from hash)
      =/  to=(unit update:uqbar-indexer)
        (serve-update %to hash)
      =/  up=(unit update:uqbar-indexer)
        %-  combine-egg-updates
        ;;  %-  list
          %-  unit
          [%egg eggs=(map id:smart [egg-location:uqbar-indexer egg:smart])]
        ~[egg from to]
      ?~  up  [~ ~]
      :^  ~  ~  %uqbar-indexer-update
      !>  ^-  update:uqbar-indexer
      u.up
    ::
        [%x %hash @ ~]
        ::  search over all hashes and return all hits
        ::  TODO: make blocks and grains play nice with eggs
        ::        so we can return all hits together
      =/  hash=@ux  (slav %ux i.t.t.path)
      =/  egg=(unit update:uqbar-indexer)
        (serve-update %egg hash)
      =/  grain=(unit update:uqbar-indexer)
        (serve-update %grain hash)
      =/  from=(unit update:uqbar-indexer)
        (serve-update %from hash)
      =/  to=(unit update:uqbar-indexer)
        (serve-update %to hash)
      =/  up=(unit update:uqbar-indexer)
        %+  combine-updates
          ;;  %-  list
              %-  unit
              [%egg eggs=(map id:smart [egg-location:uqbar-indexer egg:smart])]
          [~[egg from to]]
        ;;  %-  list
            %-  unit
            [%grain grains=(map id:smart [town-location:uqbar-indexer grain:smart])]
        [~[grain]]
      ?~  up  [~ ~]
      :^  ~  ~  %uqbar-indexer-update
      !>  ^-  update:uqbar-indexer
      u.up
    ::
    ==
  ::
  ++  on-agent
    |=  [=wire =sign:agent:gall]
    |^  ^-  (quip card _this)
    ?+    wire  (on-agent:def wire sign)
    ::
        [%chain-update ~]
      ?+    -.sign  (on-agent:def wire sign)
      ::
          %kick
        :_  this
        =/  old-source=(unit dock)
          (get-wex-dock-by-wire:uic wire)
        ?~  old-source  ~
        ~[(watch-chain-source:uic u.old-source)]
      ::
          %fact
        =^  cards  state
          %-  consume-ziggurat-update
          !<(update:zig q.cage.sign)
        [cards this]
      ::
      ==
    ::
        [%epochs-catchup ~]
      ?+    -.sign  (on-agent:def wire sign)
      ::
          %kick
        `this
      ::
          %fact
        =^  cards  state
          %-  consume-ziggurat-update
          !<(update:zig q.cage.sign)
        [cards this]
      ::
      ==
    ::
    ==
    ::
    :: +consume-indexer-update:
    :: https://github.com/uqbar-dao/ziggurat/blob/da1d37adf538ee908945557a68387d3c87e1c32e/app/uqbar-indexer.hoon#L697
    ::
    ++  consume-ziggurat-update
      |=  =update:zig
      |^  ^-  (quip card _state)
      ?+    -.update  !!  :: TODO: can we do better here?
      ::
          %epochs-catchup
        =/  =epochs:zig  epochs.update
        =|  cards=(list card)
        |-
        ?~  epochs  [cards state]
        =/  epoch  (pop:poc:zig epochs)
        =*  epoch-num   num.val.head.epoch
        =/  =slots:zig  slots.val.head.epoch
        =+  ^=  [new-cards new-state]
            |-
            ?~  slots  [cards state]
            =/  slot  (pop:sot:zig slots)
            =+  ^=  [new-cards new-state]
                (consume-slot epoch-num val.head.slot)
            $(slots rest.slot, cards new-cards, state new-state)
        $(epochs rest.epoch, cards new-cards, state new-state)
      ::
          %indexer-block
        %+  consume-slot
        epoch-num.update  [header.update blk.update]
      ::
      ::  add %chunk handling? see e.g.
      ::  https://github.com/uqbar-dao/ziggurat/blob/da1d37adf538ee908945557a68387d3c87e1c32e/app/uqbar-indexer.hoon#L923
      ==
      ::
      ++  consume-slot
        |=  [epoch-num=@ud =slot:zig]
        ^-  (quip card _state)
        =*  header  p.slot
        =*  block   q.slot
        ?~  block  `state  :: TODO: log block header?
        =*  block-num  num.header
        =/  working-epoch=epoch:zig
          ?~  existing-epoch=(get:poc:zig epochs epoch-num)
            :^    num=epoch-num
                start-time=*time  ::  TODO: get this info from sequencer
              order=~
            slots=(put:sot:zig *slots:zig block-num slot)
          %=  u.existing-epoch  ::  TODO: do more checks to avoid overwriting (unnecessary work)
              slots
            %^    put:sot:zig
                slots.u.existing-epoch
              block-num
            slot
          ::
          ==
        ::  store and index the new block
        ::
        =+  ^=  [block-hash egg from grain holder lord to]
            ((parse-block epoch-num block-num) slot)
        =:  block-index     (~(gas ju block-index) block-hash)
            egg-index       (~(gas ju egg-index) egg)
            from-index      (~(gas ju from-index) from)
            grain-index     (~(gas ju grain-index) grain)
            holder-index    (~(gas ju holder-index) holder)
            lord-index      (~(gas ju lord-index) lord)
            to-index        (~(gas ju to-index) to)
            epochs          (put:poc:zig epochs epoch-num working-epoch)
            recent-headers
          :-  [epoch-num header]
          %+  scag
            (dec num-recent-headers)
          ^-  (list [epoch-num=@ud =block-header:zig])
          recent-headers
        ::
        ==
        |^
        =/  serve-most-recent-update=_serve-update
          make-serve-most-recent-update
        :_  state(serve-previous-update serve-most-recent-update)
        %^  make-all-sub-cards
        epoch-num  block-num  serve-most-recent-update
        ::
        ++  make-sub-paths
          ^-  (jug @tas @u)
          %-  %~  gas  ju  *(jug @tas @u)
          %+  turn  ~(val by sup.bowl)
          |=  [ship sub-path=path]
          ^-  [@tas @u]
          :-  `@tas`-.sub-path
          ?:  ?=(%slot -.sub-path)  0  ::  unused placeholder
          ?:  ?=(%chunk -.sub-path)
            (slav %ud -.+.sub-path)
          (slav %ux -.+.sub-path)
        ::
        ++  make-serve-most-recent-update
          ::  pass only most recent update to subs
          ^-  _serve-update
          %=  serve-update
              block-index
            (~(gas ju *(jug @ux block-location:uqbar-indexer)) block-hash)
          ::
              egg-index
            (~(gas ju *(jug @ux egg-location:uqbar-indexer)) egg)
          ::
              from-index
            (~(gas ju *(jug @ux second-order-location:uqbar-indexer)) from)
          ::
              grain-index
            (~(gas ju *(jug @ux town-location:uqbar-indexer)) grain)
          ::
              holder-index
            (~(gas ju *(jug @ux second-order-location:uqbar-indexer)) holder)
          ::
              lord-index
            (~(gas ju *(jug @ux second-order-location:uqbar-indexer)) lord)
          ::
              to-index
            (~(gas ju *(jug @ux second-order-location:uqbar-indexer)) to)
          ::
          ==
        ::
        ++  make-all-sub-cards
          |=  $:  epoch-num=@ud
                  block-num=@ud
                  serve-most-recent-update=_serve-update
              ==
          ^-  (list card)
          =/  sub-paths=(jug @tas @u)  make-sub-paths
          |^
          %-  zing
          :~  (make-sub-cards %ud `[epoch-num block-num] %chunk /chunk)
              (make-sub-cards %ux ~ %from /id)
              (make-sub-cards %ux ~ %to /id)
              (make-sub-cards %ux ~ %grain /grain)
              (make-sub-cards %ux ~ %holder /holder)
              (make-sub-cards %ux ~ %lord /lord)
              ?~  (~(get by sub-paths) %slot)  ~
              :_  ~
              %+  fact:io
                :-  %uqbar-indexer-update
                !>  ^-  update:uqbar-indexer
                [%slot slot]
              ~[/slot]
          ==
          ::
          ++  make-sub-cards
            |=  $:  id-type=?(%ux %ud)
                    payload-prefix=(unit [@ud @ud])
                    =query-type:uqbar-indexer
                    path-prefix=path
                ==
            ^-  (list card)
            %+  murn  ~(tap in (~(get ju sub-paths) query-type))
            |=  id=@u
            =/  payload=?(@u [@ud @ud @u])
              ?~  payload-prefix  id
              [-.u.payload-prefix +.u.payload-prefix id]
            =/  old-update=(unit update:uqbar-indexer)
              (serve-previous-update query-type payload)
            =/  update=(unit update:uqbar-indexer)
              (serve-most-recent-update query-type payload)
            ?:  (are-updates-same old-update update)  ~
            ?~  update  ~
            :-  ~
            %+  fact:io
              :-  %uqbar-indexer-update
              !>(`update:uqbar-indexer`u.update)
            ~[(snoc path-prefix (scot id-type id))]
          ::
          --
        ::
        --
      ::
      --
    --
  ::
  ++  on-arvo  on-arvo:def
  ++  on-fail   on-fail:def
  ::
  --
::
|_  =bowl:gall
+*  io   ~(. agentio bowl)
::
++  epochs-catchup-wire
  ^-  wire
  /epochs-catchup
::
++  chain-update-wire
  ^-  wire
  /chain-update
::
++  get-epoch-catchup
  |=  d=dock
  ^-  card
  %+  %~  watch  pass:io
  epochs-catchup-wire  d  /validator/epoch-catchup/0
::
++  watch-chain-source
  |=  d=dock
  ^-  card
  %+  %~  watch  pass:io
  :: TODO: improve (maybe metadata from zig and chunks from seq?)
  chain-update-wire  d  /indexer/updates
::
++  get-wex-dock-by-wire
  |=  w=wire
  ^-  (unit dock)
  ?:  =(0 ~(wyt by wex.bowl))  ~
  =/  wexs=(list [w=wire s=ship t=term])
    ~(tap in ~(key by wex.bowl))
  |-
  ?~  wexs  ~
  =*  wex  i.wexs
  ?.  =(w w.wex)
    $(wexs t.wexs)
  :-  ~
  [s.wex t.wex]
::
++  leave-chain-source
  ::  will only leave first chain-update wire;
  ::  should only ever be subscribed to one;
  ::  should we generalize anyways just in case?
  ^-  (unit card)
  =/  old-source=(unit dock)
    (get-wex-dock-by-wire chain-update-wire)
  ?~  old-source  ~
  :-  ~
  %-  %~  leave  pass:io
  chain-update-wire  u.old-source
::
++  set-chain-source  :: TODO: is this properly generalized?
  |=  d=dock
  ^-  (quip card _state)
  =/  watch-card=card  (watch-chain-source d)
  :_  state
  =/  leave-card=(unit card)  leave-chain-source
  ?~  leave-card
    ~[(get-epoch-catchup d) watch-card]
  ~[u.leave-card watch-card]
::
++  get-slot
  |=  [epoch-num=@ud block-num=@ud]
  ^-  (unit slot:zig)
  ?~  epoch=(get:poc:zig epochs epoch-num)  ~
  (get:sot:zig slots.u.epoch block-num)
::
++  get-chunk
  |=  [epoch-num=@ud block-num=@ud town-id=@ud]
  ^-  (unit chunk:zig)
  ?~  slot=(get-slot epoch-num block-num)  ~
  ?~  block=q.u.slot                       ~
  =*  chunks  q.u.block
  (~(get by chunks) town-id)
::  TODO: make blocks and grains play nice with eggs
::        so we can return all hits together
::
:: https://github.com/uqbar-dao/ziggurat/blob/da1d37adf538ee908945557a68387d3c87e1c32e/app/uqbar-indexer.hoon#L361:
::
++  combine-egg-updates
  |=  updates=(list (unit [%egg eggs=(map id:smart [egg-location:uqbar-indexer egg:smart])]))
  ^-  (unit update:uqbar-indexer)
  ?~  updates  ~
  =/  combined=(map id:smart [egg-location:uqbar-indexer egg:smart])
    (combine-egg-updates-to-map updates)
  ?~  combined  ~
  `[%egg combined]
::
++  combine-egg-updates-to-map
  |=  updates=(list (unit [%egg eggs=(map id:smart [egg-location:uqbar-indexer egg:smart])]))
  ^-  (map id:smart [egg-location:uqbar-indexer egg:smart])
  ?~  updates  ~
  =/  combined=(map id:smart [egg-location:uqbar-indexer egg:smart])
    %-  %~  gas  by  *(map id:smart [egg-location:uqbar-indexer egg:smart])
    %-  zing
    %+  turn  updates
    |=  update=(unit [%egg eggs=(map id:smart [egg-location:uqbar-indexer egg:smart])])
    ?~  update  ~
    ~(tap by eggs.u.update)
  combined
::
++  combine-grain-updates-to-map
  |=  updates=(list (unit [%grain grains=(map id:smart [town-location:uqbar-indexer grain:smart])]))
  ^-  (map id:smart [town-location:uqbar-indexer grain:smart])
  ?~  updates  ~
  =/  combined=(map id:smart [town-location:uqbar-indexer grain:smart])
    %-  %~  gas  by  *(map id:smart [town-location:uqbar-indexer grain:smart])
    %-  zing
    %+  turn  updates
    |=  update=(unit [%grain grains=(map id:smart [town-location:uqbar-indexer grain:smart])])
    ?~  update  ~
    ~(tap by grains.u.update)
  combined
::
++  combine-updates
  |=  $:  egg-updates=(list (unit [%egg eggs=(map id:smart [egg-location:uqbar-indexer egg:smart])]))
          grain-updates=(list (unit [%grain grains=(map id:smart [town-location:uqbar-indexer grain:smart])]))
      ==
  ^-  (unit update:uqbar-indexer)
  ?:  ?&  ?=(~ egg-updates)
          ?=(~ grain-updates)
      ==
    ~
  =/  combined-egg=(map id:smart [egg-location:uqbar-indexer egg:smart])
    (combine-egg-updates-to-map egg-updates)
  =/  combined-grain=(map id:smart [town-location:uqbar-indexer grain:smart])
    (combine-grain-updates-to-map grain-updates)
  `[%hash combined-egg combined-grain]
::
++  are-updates-same
  ::  %.y if non-location portion of update is same
  ::  %.n if different
  |=  [one=(unit update:uqbar-indexer) two=(unit update:uqbar-indexer)]
  ^-  ?
  ?~  one  ?=(~ two)
  ?~  two  %.n
  :: ?.  ?=(-.u.one -.u.two)  %.n  ::  different update type?
  ?+    -.u.one  !!
  ::
      %chunk
    ?.  ?=(%chunk -.u.two)  %.n
    =(chunk.u.one chunk.u.two)
  ::
      %egg
    ?.  ?=(%egg -.u.two)  %.n
    =/  two-eggs=(set egg:smart)
      %-  %~  gas  in  *(set egg:smart)
      %+  turn  ~(val by eggs.u.two)
      |=  [egg-location:uqbar-indexer =egg:smart]
      egg
    %-  %~  all  by  eggs.u.one
    |=  [egg-location:uqbar-indexer one-egg=egg:smart]
    (~(has in two-eggs) one-egg)
  ::
      %grain
    ?.  ?=(%grain -.u.two)  %.n
    =/  two-grains=(set grain:smart)
      %-  %~  gas  in  *(set grain:smart)
      %+  turn  ~(val by grains.u.two)
      |=  [town-location:uqbar-indexer =grain:smart]
      grain
    %-  %~  all  by  grains.u.one
    |=  [town-location:uqbar-indexer one-grain=grain:smart]
    (~(has in two-grains) one-grain)
  ::
      %slot
    ?.  ?=(%slot -.u.two)  %.n
    =(slot.u.one slot.u.two)
  ::
  ==
::
++  serve-update
  |=  [=query-type:uqbar-indexer =query-payload:uqbar-indexer]
  |^  ^-  (unit update:uqbar-indexer)
  ?+    query-type  !!
  ::
      %chunk
    ?.  ?=(town-location:uqbar-indexer query-payload)  ~
    =/  slot=(unit slot:zig)
      (get-slot epoch-num.query-payload block-num.query-payload)
    ?~  slot  ~
    ?~  q.u.slot  ~
    =*  chunks  q.u.q.u.slot
    =/  chunk=(unit chunk:zig)
      (~(get by chunks) town-id.query-payload)
    ?~  chunk  ~
    `[%chunk query-payload u.chunk]
  ::
  ::     %chunk-hash
  ::   get-chunk-update
  ::
      ?(%block-hash %egg %from %grain %holder %lord %to)
    get-from-index
  ::
      %slot
    ?.  ?=(block-location:uqbar-indexer query-payload)  ~
    (get-slot-update query-payload)
  ::
  ==
  ::
  ++  get-slot-update
    |=  [epoch-num=@ud block-num=@ud]
    ^-  (unit update:uqbar-indexer)
    ?~  slot=(get-slot epoch-num block-num)  ~
    `[%slot u.slot]
  ::
  ++  get-chunk-update
    ^-  (unit update:uqbar-indexer)
    =/  locations=(list location:uqbar-indexer)
      ~(tap in get-locations)
    ~|  "uqbar-indexer: chunk not unique"
    ?>  =(1 (lent locations))
    =/  =location:uqbar-indexer  (snag 0 locations)
    ?.  ?=(town-location:uqbar-indexer location)  ~
    ?~  chunk=(get-chunk location)                ~
    `[%chunk location u.chunk]
  ::
  ++  get-from-index
    ^-  (unit update:uqbar-indexer)
    ?.  ?=(@ux query-payload)  ~
    =/  locations=(list location:uqbar-indexer)
      ~(tap in get-locations)
    |^
    ?+    query-type  !!
    ::
        %block-hash
      get-block-hash
    ::
        %grain
      get-grain
    ::
        %egg
      get-egg
    ::
        ?(%from %holder %lord %to)
      get-second-order
    ::
    ==
    ::
    ++  get-block-hash
      ~|  "uqbar-indexer: block hash not unique"
      ?>  =(1 (lent locations))
      =/  =location:uqbar-indexer  (snag 0 locations)
      ?.  ?=(block-location:uqbar-indexer location)  ~
      (get-slot-update location)
    ::
    ++  get-grain
      =|  grains=(map grain-id=id:smart [town-location:uqbar-indexer grain:smart])
      |-
      ?~  locations
        ?~  grains  ~
        `[%grain grains]
      =*  location  i.locations
      ?.  ?=(town-location:uqbar-indexer location)
        $(locations t.locations)
      ?~  chunk=(get-chunk location)
        $(locations t.locations)
      =*  granary  p.+.u.chunk
      ?~  grain=(~(get by granary) query-payload)
        $(locations t.locations)
      %=  $
          locations  t.locations
          grains
        (~(put by grains) id.u.grain [location u.grain])
      ::
      ==
    ::
    ++  get-egg
      =|  eggs=(map id:smart [egg-location:uqbar-indexer egg:smart])
      |-
      ?~  locations
        ?~  eggs  ~
        `[%egg eggs]
      =*  location  i.locations
      ?.  ?=(egg-location:uqbar-indexer location)
        $(locations t.locations)
      ?~  chunk=(get-chunk epoch-num.location block-num.location town-id.location)
        $(locations t.locations)  :: TODO: can we do better here?
      =*  egg-num  egg-num.location
      =*  txs  -.u.chunk
      ?.  (lth egg-num (lent txs))  $(locations t.locations)
      =+  [hash=@ux =egg:smart]=(snag egg-num txs)
      ~|  "uqbar-indexer: location points to incorrect egg. query type, payload, hash, location, egg: {<query-type>}, {<query-payload>}, {<hash>}, {<location>}, {<egg>}"
      ?>  ?|  =(query-payload hash)
              ?:  ?=(id:smart from.p.egg)
                =(query-payload from.p.egg)
              =(query-payload id.from.p.egg)
              =(query-payload to.p.egg)
          ==
      %=  $
          locations  t.locations
          eggs       (~(put by eggs) hash [location egg])
      ==
    ::
    ++  get-second-order
      =/  update-type=?(%egg %grain)
        ?:  ?|  ?=(%holder query-type)
                ?=(%lord query-type)
            ==
          %grain
        %egg
      %+  roll  locations
      |=  $:  second-order-id=location:uqbar-indexer
              out=(unit update:uqbar-indexer)
          ==
      =/  next-update=(unit update:uqbar-indexer)
        %=  get-from-index
            query-type     update-type
            query-payload  second-order-id
        ==
      ::  TODO: rewrite to avoid multiply type checking
      ::  (currently doing so because the =(update-type ..)
      ::  is not sufficient for the compiler to allow access
      ::  to out and next-update attributes in ?+)
      ?~  next-update                     out
      ?.  =(update-type -.u.next-update)  out
      ?~  out                             next-update
      ?.  =(update-type -.u.out)          next-update
      :-  ~
      ?+  -.u.out  !!
      ::
          %egg
        ?>  ?=(%egg -.u.next-update)
        %=  u.out
            eggs
          (~(uni by eggs.u.out) eggs.u.next-update)
        ::
        ==
      ::
          %grain
        ?>  ?=(%grain -.u.next-update)
        %=  u.out
            grains
          (~(uni by grains.u.out) grains.u.next-update)
        ::
        ==
      ::
      ==
    ::
    --
  ::
  ++  get-locations
    ^-  (set location:uqbar-indexer)
    ?>  ?=(@ux query-payload)
    ?+    query-type  !!
    ::
        %block-hash
      (~(get ju block-index) query-payload)
    ::
        %egg
      (~(get ju egg-index) query-payload)
    ::
        %from
      (~(get ju from-index) query-payload)
    ::
        %grain
      (~(get ju grain-index) query-payload)
    ::
        %holder
      (~(get ju holder-index) query-payload)
    ::
        %lord
      (~(get ju lord-index) query-payload)
    ::
        %to
      (~(get ju to-index) query-payload)
    ::
    ==
  ::
  --
::  parse a given block into hash:location
::  pairs to be added to *-index
::
++  parse-block
  |_  [epoch-num=@ud block-num=@ud]
  ++  $
    |=  [=slot:zig]
    ^-  $:  (list [@ux block-location:uqbar-indexer])
            (list [@ux egg-location:uqbar-indexer])
            (list [@ux second-order-location:uqbar-indexer])
            (list [@ux town-location:uqbar-indexer])
            (list [@ux second-order-location:uqbar-indexer])
            (list [@ux second-order-location:uqbar-indexer])
            (list [@ux second-order-location:uqbar-indexer])
        ==
    ?>  ?=(^ q.slot)
    =*  block-header  p.slot
    =*  block         u.q.slot
    =/  block-hash=(list [@ux block-location:uqbar-indexer])
      ~[[`@ux`data-hash.block-header epoch-num block-num]]  :: TODO: should key be @uvH?
    =|  egg=(list [@ux egg-location:uqbar-indexer])
    =|  from=(list [@ux second-order-location:uqbar-indexer])
    =|  grain=(list [@ux town-location:uqbar-indexer])
    =|  holder=(list [@ux second-order-location:uqbar-indexer])
    =|  lord=(list [@ux second-order-location:uqbar-indexer])
    =|  to=(list [@ux second-order-location:uqbar-indexer])
    =/  chunks=(list [town-id=@ud =chunk:zig])  ~(tap by q.block)
    :-  block-hash
    |-
    ?~  chunks  [egg from grain holder lord to]
    =*  town-id  town-id.i.chunks
    =*  chunk    chunk.i.chunks
    ::
    =+  ^=  [new-egg new-from new-grain new-holder new-lord new-to]
        (parse-chunk town-id chunk)
    %=  $
        chunks  t.chunks
        egg     (weld egg new-egg)
        from    (weld from new-from)
        grain   (weld grain new-grain)
        holder  (weld holder new-holder)
        lord    (weld lord new-lord)
        to      (weld to new-to)
    ==
  ::
  ++  parse-chunk
    |=  [town-id=@ud =chunk:zig]
    ^-  $:  (list [@ux egg-location:uqbar-indexer])
            (list [@ux second-order-location:uqbar-indexer])
            (list [@ux town-location:uqbar-indexer])
            (list [@ux second-order-location:uqbar-indexer])
            (list [@ux second-order-location:uqbar-indexer])
            (list [@ux second-order-location:uqbar-indexer])
        ==
    =*  txs      -.chunk
    =*  granary  p.+.chunk
    ::
    =+  [new-grain new-holder new-lord]=(parse-granary town-id granary)
    =+  [new-egg new-from new-to]=(parse-transactions town-id txs)
    [new-egg new-from new-grain new-holder new-lord new-to]
  ::
  ++  parse-granary
    |=  [town-id=@ud =granary:smart]
    ^-  $:  (list [@ux town-location:uqbar-indexer])
            (list [@ux second-order-location:uqbar-indexer])
            (list [@ux second-order-location:uqbar-indexer])
        ==
    =|  parsed-grain=(list [@ux town-location:uqbar-indexer])
    =|  parsed-holder=(list [@ux second-order-location:uqbar-indexer])
    =|  parsed-lord=(list [@ux second-order-location:uqbar-indexer])
    =/  grains=(list [@ux grain:smart])
      ~(tap by granary)
    |-
    ?~  grains  [parsed-grain parsed-holder parsed-lord]
    =*  grain-id   id.i.grains
    =*  holder-id  holder.i.grains
    =*  lord-id    lord.i.grains
    %=  $
        grains  t.grains
        parsed-grain
      :_  parsed-grain
      :-  grain-id
      [epoch-num block-num town-id]
    ::
        parsed-holder
      [[holder-id grain-id] parsed-holder]
    ::
        parsed-lord
      [[lord-id grain-id] parsed-lord]
    ::
    ==
  ::
  ++  parse-transactions
    |=  [town-id=@ud txs=(list [@ux egg:smart])]
    ^-  $:  (list [@ux egg-location:uqbar-indexer])
            (list [@ux second-order-location:uqbar-indexer])
            (list [@ux second-order-location:uqbar-indexer])
        ==
    =|  parsed-egg=(list [@ux egg-location:uqbar-indexer])
    =|  parsed-from=(list [@ux second-order-location:uqbar-indexer])
    =|  parsed-to=(list [@ux second-order-location:uqbar-indexer])
    =/  egg-num=@ud  0
    |-
    ?~  txs  [parsed-egg parsed-from parsed-to]
    =*  tx-hash  -.i.txs
    =*  egg      +.i.txs
    =*  to       to.p.egg
    =*  from
      ?:  ?=(@ux from.p.egg)  from.p.egg
      id.from.p.egg
    =/  =egg-location:uqbar-indexer
      [epoch-num block-num town-id egg-num]
    %=  $
        txs          t.txs
        parsed-egg   [[tx-hash egg-location] parsed-egg]
        parsed-from  [[from tx-hash] parsed-from]
        parsed-to    [[to tx-hash] parsed-to]
        egg-num      +(egg-num)
    ==
  --
--
