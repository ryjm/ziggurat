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
  |=  [next-slot-num=@ud =epochs cur=epoch]
  ?.  =(next-slot-num 0)
    (sham p:(got:sot slots.cur (dec next-slot-num)))
  ?:  =(num.cur 0)  (sham ~)
  =-  (sham p.-)
  `slot`+:(need (pry:sot slots:(got:poc epochs (dec num.cur))))
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
      =/  start=(unit @ud)
        =-  ?:(=(- 0) ~ `(dec -))
        (slav %ud i.t.t.path)
      :_  this
      :+  =-  [%give %fact ~ %zig-update !>(-)]
          ^-  update
          [%epochs-catchup (lot:poc epochs start ~)]
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
            ~|  "we must be a validator in this epoch"
            =/  our-slot=@ud  (need (find our.bowl^~ order.cur))
            :_  ~  %^  wait:epo  0
              our-slot
            [(sub start-time.cur epoch-interval) `(div epoch-interval 3)]
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
      =/  next-slot-num
        ?~  p=(bind (pry:sot slots.cur) head)
          0
        +(u.p)
      =/  prev-hash
        (got-prv-hed-hash next-slot-num epochs cur)
      =^  new-epoch  epochs
        (~(new-epoch epo cur prev-hash [our now src]:bowl) epochs)
      :_  state(epochs (put:poc epochs num.new-epoch new-epoch))
      %+  weld  (watch-updates (silt order.new-epoch))
      =-  (wait:epo num.new-epoch 0 - ~)^~
      ?:  =(our.bowl (snag 0 order.new-epoch))
        ::  set a timer to produce our block
        ::
        now.bowl
      ::  set a timer for the next deadline
      ::
      start-time.new-epoch
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
    %+  murn  ~(tap by wex.bowl)
    |=  [[=wire =ship =term] *]
    ^-  (unit card)
    ?.  ?=([%validator %updates *] wire)  ~
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
      ?~  p=(bind (pry:sot slots.cur) head)
        0
      +(u.p)
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
    ~|  "we only care if a validator saw a block in the current epoch"
    ?>  =(num.cur epoch-num.update)
    :_  state
    (~(see-block epo cur prev-hash [our now src]:bowl) header.update)
  ::
  ++  epoch-catchup
    |=  =update
    ^-  (quip card _state)
    ~|  "must be an %epoch-catchup update"
    ?>  ?=(%epochs-catchup -.update)
    ?~  epochs.update  `state
    ::  TODO: full chain selection across epochs and slots here
    ::
    `state
  ::
  ++  validate-history
    |=  =^epochs
    ^-  ?
    =/  prev=epoch  +:(need (ram:poc epochs))
    ?>  (validate-slots slots.prev order.prev)
    =/  pocs=(list (pair @ud epoch))  (tap:poc epochs)
    |-  ^-  ?
    ?~  pocs  %.y
    =*  p  p.i.pocs
    =*  q  q.i.pocs
    ?&  =(p num.q)
    ==
  ::
  ++  validate-slots
    |=  [=slots order=(list ship)]
    ^-  ?
    ?<  =(~ slots)
    |-  ^-  ?
    ?~  slots  %.y
    =*  n  p.i.slots
    =*  s  q.i.slots
    =*  hed  p.s
    =*  blk  q.s
::    =^  cards  cur
::      (~(their-block epo [cur [our now src]:bowl]) hed blk)
    %.y
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
    ~&  slot-timer+[epoch-num slot-num]
    ~|  "we can only skip blocks in the current epoch"
    =/  cur=epoch  +:(need (pry:poc epochs))
    ?>  =(num.cur epoch-num)
    =/  next-slot-num
      ?~  p=(bind (pry:sot slots.cur) head)
        0
      +(u.p)
    =/  =ship  (snag slot-num order.cur)
    ~|  "we can only add the next block, not past or future blocks"
    ?>  =(next-slot-num slot-num)
    =/  prev-hash
      (got-prv-hed-hash slot-num epochs cur)
    ?:  ?&(=(ship our.bowl) (lth now.bowl (deadline:epo start-time.cur slot-num)))
      =^  cards  cur
        (~(our-block epo cur prev-hash [our now src]:bowl) *chunks)
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
