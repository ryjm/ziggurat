::  ziggurat [uqbar-dao]
::
/+  *ziggurat, default-agent, dbug, verb
/*  smart-lib  %noun  /lib/zig/sys/smart-lib/noun
=,  util
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      mode=?(%fisherman %validator %none)
      me=(unit account:smart)
      =epochs
      =chunks
      ::  TODO need to make sure this design is acceptable in terms of
      ::  data availability and censorship. last validator in epoch is random,
      ::  but there's still only 1 per epoch and they could censor. since
      ::  the set of possible transactions in the town contract is so narrow,
      ::  possibly we can show that no logic can result in unwanted secret
      ::  manipulation
      =basket           ::  accept town mgmt txs from stars
      globe=town:smart  ::  store town hall info; update once per epoch
  ==
+$  inflated-state-0  [state-0 =mil]
+$  mil  $_  ~(mill mill 0) 
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
=|  inflated-state-0
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init  `this(state [[%0 %none ~ ~ ~ ~ [~ ~]] ~(mill mill +:(cue q.q.smart-lib))])
::
++  on-save  !>(-.state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  =/  old-state  !<(state-0 old-vase)
  =/  mil   ~(mill mill +:(cue q.q.smart-lib))
  `this(state [old-state mil])
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  !!
      [%validator ?([%epoch-catchup @ ~] [%updates ~])]
    ?:  =(mode %none)
      `this
    ?>  (allowed-participant [src our now]:bowl)
    ::  ~|  "only validators can listen to block production!"
    ::  =/  validator-set
    ::      =/  found  (~(got by p.globe.state) `@ux`'ziggurat')
    ::      ?.  ?=(%& -.germ.found)  !!
    ::      ~(key by (hole:smart ,(map ship [@ux @p life]) data.p.germ.found))
    ::  ?>  (~(has in validator-set) src.bowl)
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
      ~&  >  "got a watch on %epoch-catchup, sharing epochs"
      :_  this
      :+  =-  [%give %fact ~ %zig-update !>(-)]
          ^-  update
          [%epochs-catchup epochs]
        [%give %kick ~ ~]
      ~
    ==
  ::
      [%sequencer %updates ~]
    ~|  "only stars and star-moons can be sequencers"
    ?>  (allowed-participant [src our now]:bowl)
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
      %zig-chain-poke
    =^  cards  state
      (poke-chain !<(chain-poke vase))
    [cards this]
    ::
      %zig-weave-poke
    =^  cards  state
      (poke-basket !<(weave-poke vase))
    [cards this]
    ::
      %noun
    ::  TODO this poke should be gated by something, right?
    ?>  (lte (met 3 src.bowl) 2)
    ?>  (validate-history our.bowl epochs)
    `this
  ==
  ::
  ++  poke-chain
    |=  act=chain-poke
    ^-  (quip card _state)
    ?-    -.act
        %key
      ::  store private key where? jael?
      ?>  =(src.bowl our.bowl)
      `state(me `account.act)
    ::
        %start
      ?>  =(src.bowl our.bowl)
      ~|  "ziggurat must be run on a star or star-moon"
      ?>  (allowed-participant our.bowl our.bowl now.bowl)
      ~|  "we have already started in this mode"
      ?<  =(mode mode.act)
      =?  epochs  ?=(^ history.act)
        history.act
      ?:  ?=(%fisherman mode.act)
        :_  state(mode %fisherman)
        (subscriptions-cleanup wex.bowl sup.bowl)
      ::  become a validator
      ?>  ?|(?=(^ epochs) ?=(^ validators.act))
      ?~  others=~(tap in (~(del in validators.act) our.bowl))
        ::  single-validator new chain
        ~&  >  "initializing new blockchain"
        :_  state(mode %validator, globe starting-state.act)
        %-  zing
        :~  (subscriptions-cleanup wex.bowl sup.bowl)
            ?~  epochs  ~
            (new-epoch-timers +:(need (pry:poc epochs)) our.bowl)
        ==
      ::  joining the existing blockchain
      ::  give ourselves a dummy epoch, but immediately start
      ::  %epoch-catchup from one of the other known validators
      ~&  >  "attempting to join main chain"
      =/  dummy=^epochs
        (gas:poc ~ [0 [0 *@da ~(tap in validators.act) ~]]^~)
      =/  me  (need me.state)
      =/  sig  (sign:zig-sig our.bowl now.bowl (sham me))
      :_  state(mode %validator, globe starting-state.act, epochs dummy)
      ::  make tx to add ourselves, send to another validator
      %+  snoc  %-  zing
                :~  (subscriptions-cleanup wex.bowl sup.bowl)
                    (watch-updates validators.act)
                    ~[(start-epoch-catchup i.others 0)]
                ==
      :*  %pass  /submit-tx
          %agent  [i.others %ziggurat]
          %poke  %zig-weave-poke
          !>  :-  %forward
              %-  silt  :_  ~
              :*  [me(nonce +(nonce.me)) `@ux`'capitol' 1 10.000 0]
                  me(nonce +(nonce.me))
                  `[%become-validator sig]
                  ~
                  (silt ~[`@ux`'ziggurat'])
              ==
      ==
    ::
        %stop
      ?>  =(src.bowl our.bowl)
      =/  me  (need me.state)
      =/  sig  (sign:zig-sig our.bowl now.bowl (sham me))
      :_  state
      %+  snoc  (subscriptions-cleanup wex.bowl sup.bowl)
      :*  %pass  /submit-tx
          %agent  [our.bowl %ziggurat]
          %poke  %zig-weave-poke
          !>  :-  %forward
              %-  silt  :_  ~
              :*  [me(nonce +(nonce.me)) `@ux`'capitol' 1 10.000 0]
                  me(nonce +(nonce.me))
                  `[%stop-validating sig]
                  ~
                  (silt ~[`@ux`'ziggurat'])
              ==
      ==
    ::
        %new-epoch
      ?>  =(src.bowl our.bowl)
      =/  cur=epoch  +:(need (pry:poc epochs))
      =/  last-slot-num=@ud
        (need (bind (pry:sot slots.cur) head))
      =/  prev-hash
        (got-hed-hash last-slot-num epochs cur)
      ::  BIG change: reading validator set from capitol contract
      ::
      =/  new-validator-set
        =/  found  (~(got by p.globe.state) `@ux`'ziggurat')
        ?.  ?=(%& -.germ.found)  !!
        ~(key by (hole:smart ,(map ship [@ux @p life]) data.p.germ.found))
      ~&  >  "new validator set: {<new-validator-set>}"
      ::  if we're no longer in validator set, leave the chain
      ?.  (~(has in new-validator-set) our.bowl)
        :-  (subscriptions-cleanup wex.bowl sup.bowl)
        state(mode %none, me ~, epochs ~, chunks ~, basket ~, globe [~ ~])
      =/  new-epoch=epoch
        :^    +(num.cur)
            (deadline start-time.cur (dec (lent order.cur)))
          (shuffle new-validator-set (mug prev-hash))
        ~
      =/  validators=(list ship)
        ~(tap in (~(del in new-validator-set) our.bowl))
      ?:  ?&  ?=(^ validators)
              %+  lth  start-time.new-epoch
              (sub now.bowl (mul +((lent order.new-epoch)) epoch-interval))
          ==
        ::  there are other validators, and we're behind them, must catch up
        :_  state
        (start-epoch-catchup i.validators num.cur)^~
      ::  either on-time to start epoch, or solo validator
      ~&  num.new-epoch^(sham epochs)
      ::  set our timers for all the slots in this epoch,
      ::  subscribe to all the other validator ships,
      ::  and alert subscribing sequencers of the next block producer
      :_  state(epochs (put:poc epochs num.new-epoch new-epoch))
      =/  town-id  .^((unit @ud) %gx /(scot %p our.bowl)/sequencer/(scot %da now.bowl)/town-id/noun)
      %-  zing
        :~  ?~  hall-card=(hall-update-card town-id)
              ~[(notify-sequencer -.order.new-epoch)]
            ~[u.hall-card (notify-sequencer -.order.new-epoch)]
            (watch-updates (silt (murn order.new-epoch filter-by-wex)))
            (new-epoch-timers new-epoch our.bowl)
        ==
    ::
        %receive-chunk
      ?>  (lte (met 3 src.bowl) 2)
      ::  only accept chunks from sequencers in on-chain council
      ~|  "error: ziggurat couldn't find hall on chain"
      =/  found  (~(got by p.globe.state) `@ux`'world')
      ?.  ?=(%& -.germ.found)                           !!
      =/  world  (hole:smart ,(map @ud (map ship [@ux [@ux @p life]])) data.p.germ.found)
      ?~  hall=(~(get by world) town-id.act)            !!
      ~|  "only registered sequencers are allowed to submit a chunk!"
      ?.  (~(has by u.hall) src.bowl)                   !!
      =/  cur=epoch  +:(need (pry:poc epochs))
      ?>  ?~  slot-num=(bind (pry:sot slots.cur) head)
            =(our.bowl -.order.cur)
          =(our.bowl (snag +(u.slot-num) order.cur))
      `state(chunks (~(put by chunks.state) town-id.act chunk.act))
    ==
  ::
  ++  poke-basket
    |=  act=weave-poke
    ^-  (quip card _state)
    ?-    -.act
        %forward
      ::  only accepts transactions from possible validators/sequencers
      ?>  (allowed-participant our.bowl our.bowl now.bowl)
      =/  cur=epoch  +:(need (pry:poc epochs))
      =/  last-producer  (rear order.cur)  ::  TODO is this optimal? or -:(flop ..)?
      ?:  =(our.bowl last-producer)
        `state(basket (~(uni in basket) eggs.act))
      :_  state(basket ~)
      :_  ~
      :*  %pass  /basket-gossip
          %agent  [last-producer %ziggurat]
          %poke  %zig-weave-poke
          !>([%receive (~(uni in eggs.act) basket.state)])
      ==
    ::
        %receive
      ?>  (allowed-participant our.bowl our.bowl now.bowl)
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
  ::  +hall-update: give sequencer updated hall for their town at start of new epoch
  ::
  ++  hall-update-card
    |=  town-id=(unit @ud)
    ^-  (unit card)
    ?~  town-id  ~
    ::  grab on-chain data for that hall in this epoch
    ?~  found=(~(get by p.globe.state) `@ux`'world')      ~
    ?.  ?=(%& -.germ.u.found)                             ~
    =/  world  (hole:smart ,(map @ud (map ship [@ux [@ux @p life]])) data.p.germ.u.found)
    ?~  hall=(~(get by world) u.town-id)                  ~
    ~&  >  "giving sequencer hall status update"
    :-  ~  :-  %give
    :^  %fact  ~[/sequencer/updates]
        %sequencer-update  !>([%new-hall u.hall])
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
        ~&  >  "got a watch-ack on %epoch-catchup"
        ?.  ?=(^ p.sign)    `this
        =/  cur=epoch  +:(need (pry:poc epochs))
        =/  validators=(list ship)
          ?:  (gth 2 (lent order.cur))
            ::  in a 2-ship testnet, this results in empty validator set -> crash
            ~(tap in (~(del in (~(del in (silt order.cur)) our.bowl)) src.bowl))
          ~(tap in (~(del in (silt order.cur)) our.bowl))
        ?>  ?=(^ validators)
        `this
        ::  :_  this
        ::  (start-epoch-catchup i.validators num.cur)^~
      ?>  ?=(%fact -.sign)
      ~&  >  "got a fact on %epoch-catchup"
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
      :-  cards
      ?.  =(next-slot-num (dec (lent order.cur)))
        state(epochs (put:poc epochs num.cur cur))
      ::  update globe state if last block in epoch
      =-  state(epochs (put:poc epochs num.cur cur), globe -)
      +:(~(got by `^chunks`+.block.update) 0)
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
    |-  ^-  (quip card _state)
    ?~  a
      ~&  %picked-our-history
      `state
    ?~  b
      ~&  %picked-their-history
      ::  if we pick their history, clear old timers if any exist
      ::  and set new ones based on latest epoch
      :_  state(epochs epochs.update)
      (new-epoch-timers +:(need (pry:poc epochs.update)) our.bowl)
    ?:  =(i.a i.b)
      $(a t.a, b t.b)
    =/  a-s=(list (pair @ud slot))  (tap:sot slots.q.i.a)
    =/  b-s=(list (pair @ud slot))  (tap:sot slots.q.i.b)
    |-  ^-  (quip card _state)
    ?~  a-s        ^$(a t.a, b t.b)
    ?~  b-s        ^$(a t.a, b t.b)
    ?~  q.q.i.a-s  ~&  %picked-our-history  `state
    ?~  q.q.i.b-s  
      ~&  %picked-their-history
      :_  state(epochs epochs.update)
      (new-epoch-timers +:(need (pry:poc epochs.update)) our.bowl)
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
    ~&  >>>  "slot timer pop"
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
      ?.  =(our.bowl (rear order.cur))
        ::  normal block
        =^  cards  cur
          (~(our-block epo cur prev-hash [our now src]:bowl) chunks.state)
        [cards state(epochs (put:poc epochs num.cur cur), chunks ~)]
      ::  if this is the last block in the epoch,
      ::  perform global-level transactions
      ::  insert transaction to advance
      ?~  me.state
        ~&  >  "ziggurat: failed to produce epoch-ending block: no account"
        `state
      =/  globe-chunk
        %+  ~(mill-all mil (need me) 0 0 now.bowl)
          globe.state
        ~(tap in basket.state)
      =:  globe.state   +.globe-chunk
          basket.state  ~
          chunks.state  (~(put by chunks.state) relay-town-id globe-chunk)
          u.me.state    u.me(nonce (~(got by q.+.globe-chunk) id.u.me.state))
      ==
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
