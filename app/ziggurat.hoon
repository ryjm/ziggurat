::  ziggurat [uqbar-dao]
::
/+  *ziggurat, default-agent, dbug, verb
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      mode=?(%fisherman %validator %none)
      =epochs
  ==
::
::  +got-prv-hed-hash: get last epoch and grab its last header hash,
::  otherwise if that epoch is empty, then use (sham ~)
::
++  got-prv-hed-hash
  |=  [slot-num=@ud =epochs cur=epoch]
  ?:  ?&(=(slot-num 0) =(num.cur 0))
    (sham ~)
  ?.  =(slot-num 0)
    ::  grab last slot header hash in current epoch
    ::
    (sham p:(got:sot slots.cur (dec slot-num)))
  ::  grab last slot header hash in previous epoch
  ::
  =-  (sham p.-)
  `slot`+:(need (pry:sot slots:(got:poc epochs (dec num.cur))))
::
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
    (wait:epo num.epoch i start-time.epoch =(our i.order))
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
++  on-init  `this(state [%0 %none ~])
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
        (got-prv-hed-hash last-slot-num epochs cur)
      =/  new-epoch=epoch
        :^    +(num.cur)
            (deadline:epo start-time.cur +((lent order.cur)))
          (shuffle:epo (silt order.cur) (mug slots))
        ~
      :_  state(epochs (put:poc epochs num.new-epoch new-epoch))
      ::  TODO: resubscribe to any ships that we are no longer
      ::  subscribed to
      (new-epoch-timers new-epoch our.bowl)
    ==
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
        ::  TODO: watch someone else
        `this
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
      (got-prv-hed-hash next-slot-num epochs cur)
    ?:  ?=(%new-block -.update)
      ~|  "new blocks can only be applied to the current epoch"
      ?>  =(num.cur epoch-num.update)
      =^  cards  cur
        %-  ~(their-block epo cur prev-hash [our now src]:bowl)
        [header `block]:update
      [cards state(epochs (put:poc epochs num.cur cur))]
    ?.  ?=(%saw-block -.update)  !!
    :_  state
    %+  ~(see-block epo cur prev-hash [our now src]:bowl)
      epoch-num.update
    header.update
  ::
  ++  epoch-catchup
    |=  =update
    ^-  (quip card _state)
    ~|  "must be an %epoch-catchup update"
    ?>  ?=(%epochs-catchup -.update)
    =/  a=(list (pair @ud epoch))  (bap:poc epochs.update)
    =/  b=(list (pair @ud epoch))  (bap:poc epochs)
    ?~  epochs.update  `state
    ?~  epochs
      ?>  (validate-history epochs.update)
      `state(epochs epochs.update)
    ~|  "invalid history"
    ?>  (validate-history epochs.update)
    :-  ~
    |-  ^-  _state
    ?~  a
      state
    ?~  b
      state(epochs epochs.update)
    ?:  =(i.a i.b)
      $(a t.a, b t.b)
    =/  a-s=(list (pair @ud slot))  (tap:sot slots.q.i.a)
    =/  b-s=(list (pair @ud slot))  (tap:sot slots.q.i.b)
    |-  ^-  _state
    ?~  a-s
      state
    ?~  b-s
      state(epochs epochs.update)
    ?:  =(i.a-s i.b-s)
      $(a-s t.a-s, b-s t.b-s)
    ?~  q.q.i.a-s
      state
    ?~  q.q.i.b-s
      state(epochs epochs.update)
    ::  TODO: what to do if neither one is shorter nor does either
    ::  skip a block first?
    ~|  "is this a possible case?"
    !!
  ::
  ++  validate-history
    |=  =^epochs
    |^  ^-  ?
    =/  prev=epoch  +:(need (ram:poc epochs))
    ?>  (validate-slots prev (sham ~))
    =/  pocs=(list (pair @ud epoch))  (bap:poc epochs)
    ?~  pocs  %.y
    (iterate-history prev t.pocs)
    ::
    ++  iterate-history
      |=  [prev=epoch pocs=(list (pair @ud epoch))]
      ^-  ?
      ?~  pocs  %.y
      ?.  ?&  =(p.i.pocs num.q.i.pocs)
              =(+(num.prev) num.q.i.pocs)
              %+  validate-slots  q.i.pocs
              (got-prv-hed-hash 0 epochs q.i.pocs)
          ==
        %.n
      $(pocs t.pocs, prev q.i.pocs)
    ::
    ++  validate-slots
      |=  [=epoch prev-hash=@uvH]
      ^-  ?
      =/  slots=(list (pair @ud slot))  (bap:sot slots.epoch)
      ?<  =(~ slots)
      =/  test-epoch=^epoch  epoch(slots ~)
      |-  ^-  ?
      ?~  slots  %.y
      =*  hed  p.q.i.slots
      =*  blk  q.q.i.slots
      ?.  =(p.i.slots num.hed)  %.n
      =/  fake=[ship time ship]
        :+  our.bowl
          (dec (deadline:epo start-time.test-epoch num.hed))
        (snag num.hed order.epoch)
      =^  *  test-epoch
        (~(their-block epo test-epoch prev-hash fake) hed blk)
      $(slots t.slots, prev-hash (sham hed))
    --
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
      `state
    =/  next-slot-num
      ?~(p=(bind (pry:sot slots.cur) head) 0 +(u.p))
    =/  =ship  (snag slot-num order.cur)
    ?.  =(next-slot-num slot-num)
      ?.  =(ship our.bowl)  `state
      ~|("we can only produce the next block, not past or future blocks" !!)
    =/  prev-hash
      (got-prv-hed-hash slot-num epochs cur)
    ?:  =(ship our.bowl)
      =^  cards  cur
        (~(our-block epo cur prev-hash [our now src]:bowl) eny.bowl^~)
      [cards state(epochs (put:poc epochs num.cur cur))]
    =/  cur=epoch  +:(need (pry:poc epochs))
    =^  cards  cur
      ~(skip-block epo cur prev-hash [our now src]:bowl)
    [cards state(epochs (put:poc epochs num.cur cur))]
  --
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ~
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
