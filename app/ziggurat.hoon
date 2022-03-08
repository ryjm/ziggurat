::  ziggurat [uqbar-dao]
::
/+  *ziggurat, default-agent, dbug, verb
=,  util
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      mode=?(%fisherman %validator %none)
      =epochs
      producer=(unit ship)
      =chunks
      known-halls=(map @ud =chain-hall)
      updated-halls=(set @ud)
  ==
++  new-epoch-timers
  |=  [=epoch our=ship]
  ^-  (list card)
  =/  order  order.epoch
  =/  i  0
  =|  cards=(list card)
  |-  ^-  (list card)
  ?~  order  cards
  %_    $
    i      +(i)
    order  t.order
  ::
      cards
    :_  cards
    (wait num.epoch i start-time.epoch =(our i.order))
  ==
--
::
=|  state-0
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init  `this(state [%0 %none ~ ~ ~ ~ ~])
::
++  on-save  !>(state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  =/  old-state  !<(state-0 old-vase)
  `this(state old-state)
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  !!
      [%validator ?([%epoch-catchup @ ~] [%updates ~])]
    ?:  =(mode %none)
      `this
    ~|  "only validators can listen to block production!"
    =/  cur=epoch  +:(need (pry:poc epochs))
    ?>  (~(has in (silt order.cur)) src.bowl)
    =*  kind  i.t.path
    ?-    kind
        %updates
      ::  do nothing here, but send all new blocks and epochs on this path
      `this
    ::
        %epoch-catchup
      ~|  "we must be a validator to be listened to on this path!"
      ?>  =(mode %validator)
      ::  TODO: figure out whether to use this number or not
      ::=/  start=(unit @ud)
      ::  =-  ?:(=(- 0) ~ `(dec -))
      ::  (slav %ud i.t.t.path)
      :_  this
      :+  =-  [%give %fact ~ %zig-update !>(-)]
          ^-  update
          [%epochs-catchup epochs]
        [%give %kick ~ ~]
      ~
    ==
  ::
      [%fisherman %updates ~]
    ~|  "comets and moons may not be fishermen, tiny dos protection"
    ?>  (lte (met 3 src.bowl) 4)
    ::  do nothing here, but send all new blocks and epochs on this path
    `this
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?+    mark  !!
      %zig-action
    =^  cards  state
      (poke-zig-action !<(action vase))
    [cards this]
      %noun
    ::  TODO this poke should be gated by something, right?
    ?>  (validate-history our.bowl epochs)
    `this
  ==
  ::
  ++  poke-zig-action
    |=  =action
    ^-  (quip card _state)
    ?-    -.action
        %start
      ?>  =(src.bowl our.bowl)
      ~|  "we have already started in this mode"
      ?<  =(mode mode.action)
      =?  epochs  ?=(^ history.action)
        history.action
      ?:  ?=(%validator mode.action)
        ?>  ?|(?=(^ epochs) ?=(^ validators.action))
        :_  state(mode %validator)
        %-  zing
        :~  cleanup-fisherman
            cleanup-validator
            (watch-updates validators.action)
            ?~  epochs  ~
            =/  cur=epoch  +:(need (pry:poc epochs))
            (new-epoch-timers cur our.bowl)
        ==
      :_  state(mode %fisherman)
      (weld cleanup-validator cleanup-fisherman)
    ::
        %stop
      ?>  =(src.bowl our.bowl)
      :_  state(mode %none, epochs ~)
      (weld cleanup-validator cleanup-fisherman)
    ::
        %new-epoch
      ?>  =(src.bowl our.bowl)
      =/  cur=epoch  +:(need (pry:poc epochs))
      =/  last-slot-num=@ud
        (need (bind (pry:sot slots.cur) head))
      =/  prev-hash
        (got-hed-hash last-slot-num epochs cur)
      =/  new-epoch=epoch
        :^    +(num.cur)
            (deadline start-time.cur +((lent order.cur)))
          (shuffle (silt order.cur) (mug prev-hash))
        ~
      =/  validators=(list ship)
        ~(tap in (~(del in (silt order.cur)) our.bowl))
      ?:  ?&  ?=(^ validators)
              %+  lth  start-time.new-epoch
              (sub now.bowl (mul +((lent order.new-epoch)) epoch-interval))
          ==
        ::  there are other validators, and we're behind them, must catch up
        :_  state
        (start-epoch-catchup i.validators num.cur)^~
      ::  either on-time to start epoch, or solo validator -- go ahead
      ~&  num.new-epoch^(sham epochs)
      :_  %=  state
              epochs        (put:poc epochs num.new-epoch new-epoch)
              producer      `-.order.new-epoch
              updated-halls  ~
          ==
      %+  weld
        (notify-sequencer our.bowl)^hall-updates
      %+  weld
        (watch-updates (silt (murn order.new-epoch filter-by-wex)))
      (new-epoch-timers new-epoch our.bowl)
    ::
        %receive-chunk
      ::  TODO make this town-running-stars only once that info is known
      ::  TODO handle poke-ack for the case where two validators
      ::  each think the other is producer, and are sending a chunk
      ::  back and forth to each other.
      ?>  (lte (met 3 src.bowl) 2)
      ~&  >>  "chunk received"
      ?~  to=producer.state
        ~|("can't accept chunk, no known block producer" !!)
      ?:  =(our.bowl u.to)
        ~&  >>  "chunk stored"
        `state(chunks chunk.action^chunks)
      ~&  >>  "chunk forwarded"
      :_  state
      :_  ~
      :*  %pass  /chunk-gossip/(scot %ud num:`epoch`+:(need (pry:poc epochs)))
          %agent  [u.to %ziggurat]  %poke
          %zig-action  !>([%receive-chunk chunk.action])
      ==
    ::
        %new-hall
      ?>  =(src.bowl our.bowl)
      ?:  (~(has by known-halls.state) id.action)  !!
      :-  ~
      %=  state
          updated-halls  (~(put in updated-halls) id.action)
          known-halls    %+  ~(put by known-halls)
                           id.action
                         chain-hall.action
      ==
    ::
        %add-to-hall
      ?>  =(src.bowl our.bowl)
      =/  hall=chain-hall  (~(got by known-halls.state) id.action)
      ?.  is-open.hall  !!
      :-  ~
      %=  state
          updated-halls  (~(put in updated-halls) id.action)
          known-halls    %+  ~(put by known-halls)
                           id.action
                         hall(council (~(put in council.hall) src.bowl))
      ==
    ::
        %remove-from-hall
      ?>  =(src.bowl our.bowl)
      =/  hall=chain-hall  (~(got by known-halls.state) id.action)
      :-  ~
      %=  state
          updated-halls  (~(put in updated-halls) id.action)
          known-halls    %+  ~(put by known-halls)
                           id.action
                         hall(council (~(del in council.hall) src.bowl))
      ==
    ==
  ::
  ++  filter-by-wex
    |=  shp=ship
    ^-  (unit ship)
    ?:  %-  ~(any in ~(key by wex.bowl))
        |=([* =ship *] =(shp ship))
      ~
    `shp
  ::
  ++  watch-updates
    |=  validators=(set ship)
    ^-  (list card)
    =.  validators  (~(del in validators) our.bowl)
    %+  turn  ~(tap in validators)
    |=  s=ship
    ^-  card
    =/  =^wire  /validator/updates/(scot %p s)
    [%pass wire %agent [s %ziggurat] %watch /validator/updates]
  ::
  ::  +hall-updates: give subscribers updated halls we've been poked with
  ::
  ++  hall-updates
    ^-  (list card)
    %+  turn  ~(tap in updated-halls.state)
    |=  n=@ud
    ^-  card
    =/  new-hall=chain-hall  (~(got by known-halls.state) n)
    =-  [%give %fact - %zig-update !>([%hall-update n new-hall])]
    ~[/validator/updates /fisherman/updates]
  ::
  ++  cleanup-validator
    ^-  (list card)
    %+  weld
      %+  murn  ~(tap by wex.bowl)
      |=  [[=wire =ship =term] *]
      ^-  (unit card)
      ?.  ?=([%validator %updates *] wire)  ~
      `[%pass wire %agent [ship term] %leave ~]
    %+  murn  ~(tap by sup.bowl)
    |=  [* [p=ship q=path]]
    ^-  (unit card)
    ?.  ?=([%validator *] q)  ~
    `[%give %kick q^~ `p]
  ::
  ++  cleanup-fisherman
    ^-  (list card)
    %+  murn  ~(tap by wex.bowl)
    |=  [[=wire =ship =term] *]
    ^-  (unit card)
    ?.  ?=([%fisherman %updates *] wire)  ~
    `[%pass wire %agent [ship term] %leave ~]
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  |^
  ?+    wire  (on-agent:def wire sign)
      [%validator ?([%epoch-catchup @ @ ~] [%updates @ ~])]
    ~|  "can only receive validator updates when we are a validator!"
    ?>  =(mode %validator)
    =*  kind  i.t.wire
    ?-    kind
        %updates
      ?<  ?=(%poke-ack -.sign)
      ?:  ?=(%watch-ack -.sign)
        ?~  p.sign
          `this
        ~&  u.p.sign
        `this
      ?:  ?=(%kick -.sign)
        ::  resubscribe to validators for updates if kicked
        ::
        :_  this
        [%pass wire %agent [src.bowl %ziggurat] %watch (snip `path`wire)]~
      =^  cards  state
        (update-fact !<(update q.cage.sign))
      [cards this]
    ::
        %epoch-catchup
      ?<  ?=(%poke-ack -.sign)
      ?:  ?=(%kick -.sign)  `this
      ?:  ?=(%watch-ack -.sign)
        ?.  ?=(^ p.sign)    `this
        =/  cur=epoch  +:(need (pry:poc epochs))
        =/  validators=(list ship)
          ~(tap in (~(del in (~(del in (silt order.cur)) our.bowl)) src.bowl))
        ?>  ?=(^ validators)
        :_  this
        (start-epoch-catchup i.validators num.cur)^~
      ?>  ?=(%fact -.sign)
      =^  cards  state
        (epoch-catchup !<(update q.cage.sign))
      [cards this]
    ==
  ::
      [%fisherman %updates ~]
    ~|  "can only receive fisherman updates when we are a fisherman!"
    ?>  =(%fisherman mode)
    `this
  ==
  ::
  ++  update-fact
    |=  =update
    ^-  (quip card _state)
    =/  cur=epoch  +:(need (pry:poc epochs))
    =/  next-slot-num
      ?~(p=(bind (pry:sot slots.cur) head) 0 +(u.p))
    =/  prev-hash
      (got-hed-hash next-slot-num epochs cur)
    ?+    -.update  !!
        %new-block
      ~|  "new blocks cannot be applied to past epochs"
      ?<  (lth epoch-num.update num.cur)
      ?:  (gth epoch-num.update num.cur)
        ::  the new block is from an epoch beyond what we have as current,
        ::  determine who and whether to try and catch up
        =/  validators=(list ship)
          ?:  (gth 2 (lent order.cur))
            ::  in a 2-ship testnet, this results in empty validator set -> crash
            ~(tap in (~(del in (~(del in (silt order.cur)) our.bowl)) src.bowl))
          ~(tap in (~(del in (silt order.cur)) our.bowl))
        ?>  ?=(^ validators)
        :_  state
        (start-epoch-catchup i.validators num.cur)^~
      ::  incorporate new-block into our epoch
      =/  next-producer
        ?:  (gte +(next-slot-num) (lent order.cur))  ~
        `(snag +(next-slot-num) order.cur)
      =^  cards  cur
        %-  ~(their-block epo cur prev-hash [our now src]:bowl)
        [header `block]:update
      [cards state(epochs (put:poc epochs num.cur cur), producer next-producer)]
    ::
        %saw-block
      :_  state
      %+  ~(see-block epo cur prev-hash [our now src]:bowl)
        epoch-num.update
      header.update
    ::
        %hall-update
      `state(known-halls (~(put by known-halls.state) id.update chain-hall.update))
    ==
  ::
  ++  epoch-catchup
    |=  =update
    ^-  (quip card _state)
    ~|  "must be an %epoch-catchup update"
    ?>  ?=(%epochs-catchup -.update)
    ~&  catching-up-to+src.bowl
    =/  a=(list (pair @ud epoch))  (bap:poc epochs.update)
    =/  b=(list (pair @ud epoch))  (bap:poc epochs)
    ?~  epochs.update  `state
    ?~  epochs
      ?>  (validate-history our.bowl epochs.update)
      `state(epochs epochs.update)
    ~|  "invalid history"
    ?>  (validate-history our.bowl epochs.update)
    :-  ~
    |-  ^-  _state
    ?~  a
      ~&  %picked-our-history
      state
    ?~  b
      ~&  %picked-their-history
      state(epochs epochs.update)
    ?:  =(i.a i.b)
      $(a t.a, b t.b)
    =/  a-s=(list (pair @ud slot))  (tap:sot slots.q.i.a)
    =/  b-s=(list (pair @ud slot))  (tap:sot slots.q.i.b)
    |-  ^-  _state
    ?~  a-s        ^$(a t.a, b t.b)
    ?~  b-s        ^$(a t.a, b t.b)
    ?~  q.q.i.a-s  ~&  %picked-our-history    state
    ?~  q.q.i.b-s  ~&  %picked-their-history  state(epochs epochs.update)
    $(a-s t.a-s, b-s t.b-s)
  --
::
++  on-arvo
  |=  [=wire =sign-arvo:agent:gall]
  |^  ^-  (quip card _this)
  ?+    wire  (on-arvo:def wire sign-arvo)
      [%timers ?([%slot @ @ ~] [%epoch-catchup @ @ ~])]
    ~|  "these timers are only relevant for validators!"
    ?>  =(%validator mode)
    =*  kind  i.t.wire
    ?:  ?=(%epoch-catchup kind)
      `this
    =/  epoch-num  (slav %ud i.t.t.wire)
    =/  slot-num  (slav %ud i.t.t.t.wire)
    ?>  ?=([%behn %wake *] sign-arvo)
    ?^  error.sign-arvo
      ~&  error.sign-arvo
      `this
    =^  cards  state
      (slot-timer epoch-num slot-num)
    [cards this]
  ==
  ::
  ++  slot-timer
    |=  [epoch-num=@ud slot-num=@ud]
    ^-  (quip card _state)
    =/  cur=epoch  +:(need (pry:poc epochs))
    ?.  =(num.cur epoch-num)
      ::  timer is from an epoch that we don't view as current, ignore
      `state
    =/  next-slot-num
      ?~(p=(bind (pry:sot slots.cur) head) 0 +(u.p))
    ::  see which ship is responsible for this slot
    =/  =ship  (snag slot-num order.cur)
    ?.  =(next-slot-num slot-num)
      ::  timer does not match slot we view as currently open, ignore
      ?.  =(ship our.bowl)  `state
      ~|("we can only produce the next block, not past or future blocks" !!)
    =/  prev-hash
      (got-hed-hash slot-num epochs cur)
    ?:  =(ship our.bowl)
      ::  we are responsible for producing a block in this slot
      =/  next-producer
        ?:  (gte +(slot-num) (lent order.cur))  ~
        `(snag +(slot-num) order.cur)
      ::  ?~  chunks.state
      ::    ::  we have no data to put in a block, just skip
      ::    =^  cards  cur
      ::      ~(skip-block epo cur prev-hash [our now src]:bowl)
      ::    ~&  skip-block-no-data+[num.cur slot-num]
      ::    [cards state(epochs (put:poc epochs num.cur cur))]
      ::  produce block
      =^  cards  cur
        (~(our-block epo cur prev-hash [our now src]:bowl) chunks.state)
      [cards state(epochs (put:poc epochs num.cur cur), producer next-producer)]
    ::  someone else is responsible for producing this block,
    ::  but they have not done so
    =^  cards  cur
      ~(skip-block epo cur prev-hash [our now src]:bowl)
    ~&  skip-block+[num.cur slot-num]
    [cards state(epochs (put:poc epochs num.cur cur))]
  --
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ::  handle scries from sequencer agent
  ?.  =(%x -.path)  ~
  ?+    +.path  (on-peek:def path)
      [%active ~]
    ``noun+!>(`?`=(%validator mode.state))
  ::
      [%producer ~]
    ``noun+!>(`@p`(need producer.state))
  ::
      [%epoch ~]
    =/  cur=epoch  +:(need (pry:poc epochs))
    ``noun+!>(`@ud`num.cur)
  ::
      [%slot ~]
    =/  cur=epoch  +:(need (pry:poc epochs))
    ``noun+!>(`@ud`?~(p=(bind (pry:sot slots.cur) head) 0 +(u.p)))
  ::
      [%get-hall @ ~]
    =/  res  (~(get by known-halls.state) (slav %ud i.t.t.path))
    ``noun+!>(`(unit chain-hall)`res)
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
