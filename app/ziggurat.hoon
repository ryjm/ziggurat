::  ziggurat [uqbar-dao]
::
/-  sequencer
/+  *ziggurat, default-agent, dbug, verb, smart=zig-sys-smart, mill=zig-mill
/*  smart-lib  %noun  /lib/zig/sys/smart-lib/noun
=,  util
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      mode=?(%fisherman %validator %none)
      me=(unit account:smart)
      library=(unit *)
      =epochs
      =chunks
      ::  TODO need to make sure this design is acceptable in terms of
      ::  data availability and censorship. last validator in epoch is random,
      ::  but there's still only 1 per epoch and they could censor. since
      ::  the set of possible transactions in the town contract is so narrow,
      ::  possibly we can show that no logic can result in unwanted secret
      ::  manipulation
      =basket:smart     ::  accept town mgmt txs from stars
      globe=town:smart  ::  store town hall info; update once per epoch
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
++  on-init  `this(state [%0 %none ~ ~ ~ ~ ~ [~ ~]])
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
      [%sequencer %updates ~]
    ~|  "comets and moons may not be sequencers"
    ?>  (lte (met 3 src.bowl) 4)
    ~&  >  "got a sequencer subscription"
    ::  send next-producer on this path for sequencers
    `this
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
    ::
      %zig-basket-action
    =^  cards  state
      (poke-basket-action !<(basket-action:sequencer vase))
    [cards this]
    ::
      %noun
    ::  TODO this poke should be gated by something, right?
    ?>  (lte (met 3 src.bowl) 2)
    ?>  (validate-history our.bowl epochs)
    `this
  ==
  ::
  ++  poke-zig-action
    |=  =action
    ^-  (quip card _state)
    ?-    -.action
        %set-standard-lib
      ?>  =(src.bowl our.bowl)
      =/  blob  .^([p=path q=[p=@ud q=@]] %cx (weld /(scot %p our.bowl)/zig/(scot %da now.bowl) path.action))
      =/  cued  (cue q.q.blob)
      `state(library `cued)
    ::
        %set-pubkey
      ::  store private key where? jael?
      ?>  =(src.bowl our.bowl)
      `state(me `account.action)
    ::
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
            cleanup-sequencer
            (watch-updates validators.action)
            ?~  epochs  ~
            =/  cur=epoch  +:(need (pry:poc epochs))
            (new-epoch-timers cur our.bowl)
        ==
      :_  state(mode %fisherman)
      (weld cleanup-validator (weld cleanup-sequencer cleanup-fisherman))
    ::
        %stop
      ?>  =(src.bowl our.bowl)
      :-  (weld cleanup-validator (weld cleanup-sequencer cleanup-fisherman))
      state(mode %none, epochs ~, chunks ~, basket ~, globe [~ ~])
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
            (deadline start-time.cur (dec (lent order.cur)))
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
          ==
      ::  alert other validators of any new towns made known to us,
      ::  set our timers for all the slots in this epoch,
      ::  subscribe to all the other validator ships,
      ::  and alert subscribing sequencers of the next block producer
      %-  zing
      :~  hall-updates
          ~[(notify-sequencer -.order.new-epoch)]
          (watch-updates (silt (murn order.new-epoch filter-by-wex)))
          (new-epoch-timers new-epoch our.bowl)
      ==
    ::
        %receive-chunk
      ::  TODO make this town-running-stars only once that info is known
      ?>  (lte (met 3 src.bowl) 2)
      =/  cur=epoch  +:(need (pry:poc epochs))
      ?>  ?~  slot-num=(bind (pry:sot slots.cur) head)
            =(our.bowl -.order.cur)
          =(our.bowl (snag u.slot-num order.cur))
      ::  TODO check town id
      ~&  >  "chunk received"
      `state(chunks (~(put by chunks.state) town-id.action chunk.action))
    ==
  ::
  ++  poke-basket-action
    |=  act=basket-action:sequencer
    ^-  (quip card _state)
    ?-    -.act
        %forward
      ?>  (lte (met 3 src.bowl) 2)
      ::  getting an egg from sequencer
      ::  TODO enforce that these transactions are part of
      ::  a hardcoded subet -- the init/join/leave/stake/etc
      ::  write calls to the pre-written town contract.
      =/  cur=epoch  +:(need (pry:poc epochs))
      =/  last-slot-num=@ud
        (need (bind (pry:sot slots.cur) head))
      =/  last-producer  (rear order.cur)  ::  TODO is this optimal? or -:(flop ..)?
      ?:  =(our.bowl last-producer)
        `state(basket (~(uni in basket) eggs.act))
      ~&  >  "forwarding eggs to {<last-producer>}"
      :_  state(basket ~)
      :_  ~
      :*  %pass  /basket-gossip
          %agent  [last-producer %ziggurat]
          %poke  %zig-basket-action
          !>([%receive (~(uni in eggs.act) basket.state)])
      ==
    ::
        %receive
      ?>  (lte (met 3 src.bowl) 2)
      =/  cur=epoch  +:(need (pry:poc epochs))
      ?~  (find [src.bowl]~ order.cur)
        ~|("can only receive eggs from known validators" !!)
      ~|  "rejected basket: we're not the last validator"
      ?>  =(our.bowl (rear order.cur))
      `state(basket (~(uni in basket) eggs.act))
    ==
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
    ~  :: TODO refactor
  ::
  ::  cleanup arms: close subscriptions of our various watchers
  ::  TODO can probably merge these into a single arm and single +murn
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
  ++  cleanup-sequencer
    ^-  (list card)
    %+  murn  ~(tap by wex.bowl)
    |=  [[=wire =ship =term] *]
    ^-  (unit card)
    ?.  ?=([%sequencer %updates *] wire)  ~
    `[%pass wire %agent [ship term] %leave ~]
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
      =^  cards  cur
        %-  ~(their-block epo cur prev-hash [our now src]:bowl)
        [header `block]:update
      [cards state(epochs (put:poc epochs num.cur cur))]
    ::
        %saw-block
      :_  state
      %+  ~(see-block epo cur prev-hash [our now src]:bowl)
        epoch-num.update
      header.update
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
      =?  chunks.state  =(our.bowl (rear order.cur))
        ::  if this is the last block in the epoch,
        ::  perform global-level transactions
        %+  ~(put by chunks.state)
          relay-town-id  ::  0
        %+  ~(mill-all mill (need me.state) (need library.state) relay-town-id 0 now.bowl)
          globe.state
        ~(tap in basket.state)
      =^  cards  cur
        (~(our-block epo cur prev-hash [our now src]:bowl) chunks.state)
      [cards state(epochs (put:poc epochs num.cur cur), chunks ~)]
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
  ::
  ::  scries for sequencer agent
  ::
  ?.  =(%x -.path)  ~
  ?+    +.path  (on-peek:def path)
      [%active ~]
    ``noun+!>(`?`=(%validator mode.state))
  ::
      [%epoch ~]
    =/  cur=epoch  +:(need (pry:poc epochs))
    ``noun+!>(`@ud`num.cur)
  ::
      [%slot ~]
    =/  cur=epoch  +:(need (pry:poc epochs))
    ``noun+!>(`@ud`?~(p=(bind (pry:sot slots.cur) head) 0 +(u.p)))
  ::
      [%account ~]
    ``noun+!>(`account:smart`(need me.state))
  ::
      [%library ~]
    ::  TODO is this too big of a scry? are big scrys okay?
    ``noun+!>(`*`(need library.state))
  ::
  ::  scries for contracts
  ::
      [%rice @ ~]
    =/  id  (slav %ux i.t.t.path)
    ?~  res=(~(get by p.globe.state) id)
      [~ ~]
    ?.  ?=(%& -.germ.u.res)
      [~ ~]
    ``noun+!>(`rice:smart`p.germ.u.res)
  ::
      [%wheat @ @ta ~]
    ::  call read arm of contract
    =/  id  (slav %ux i.t.t.path)
    =/  arg=^path  [i.t.t.t.path ~]
    ?~  res=(~(get by p.globe.state) id)  [~ ~]
    ?.  ?=(%| -.germ.u.res)               [~ ~]
    ?~  cont.p.germ.u.res                 [~ ~]
    ::  TODO make way for reads to get some rice input..
    ::  =/  owns
    ::    %-  ~(gas by *(map:smart id:smart grain:smart))
    ::    %+  murn  ~(tap in owns.p.germ.u.res)
    ::    |=  find=id:smart
    ::    ?~  found=(~(get by p.town.state) find)  ~
    ::    ?.  ?=(%& -.germ.u.found)                ~
    ::    ?.  =(lord.u.found id)                   ~
    ::    `[find u.res]
    =/  cont  (hole:smart contract:smart u.cont.p.germ.u.res)
    =/  cart  [~ id 0 relay-town-id ~]
    ``noun+!>((~(read cont cart) path))
  ::
      [%sizeof @ ~]
    ::  give size of item in global granary
    =/  id  (slav %ux i.t.t.path)
    ?~  res=(~(get by p.globe.state) id)  [~ ~]
    ``noun+!>((met 3 (jam res)))
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
