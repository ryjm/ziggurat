::  ziggurat [uqbar-dao]
::
/+  *ziggurat, default-agent, dbug, verb
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      mode=?(%fisherman %validator %none)
      validators=(set ship)
      =epochs
      =current=epoch
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
++  on-init
  =/  set  (silt ~[~zod])
  =-  `this(state -)
  ^-  state-0
  :^  %0  %none  set
  `[0 now.bowl (shuffle set (mug ~)) ~]
::
++  on-save  !>(state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  ::=/  old-state  !<(state-0 old-vase)
  =/  old-state=state-0  [%0 %none (silt ~[~zod]) `[0 now.bowl ~[~zod] ~]]
  `this(state old-state)
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  !!
      [%validator ?([%epoch-catchup @ ~] [%block-catchup @ ~] [%updates ~])]
    ~|  "only validators can listen to block production!"
    ?>  (~(has in validators) src.bowl)
    =*  kind  i.t.path
    ?-    kind
        %updates
      ::  do nothing here, but send all new blocks and epochs on this path
      `this
    ::
        %epoch-catchup
      =/  start=@ud  (slav %ud i.t.t.path)
      :_  this
      :+  =-  [%give %fact ~ %zig-update !>(-)]
          ^-  update
          [%epochs-catchup (lot:poc epochs `start ~)]
        [%give %kick ~ ~]
      ~
    ::
        %block-catchup
      =/  epoch-num  (slav %ud i.t.t.path)
      ?>  =(epoch-num num.current-epoch)
      :_  this
      :+  =-  [%give %fact ~ %zig-update !>(-)]
          ^-  update
          [%blocks-catchup [num slots]:current-epoch]
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
      ?:  ?=(%validator mode)
        =/  =ship
          =/  rng  ~(. og eny.bowl)
          =/  ran  (rad:rng ~(wyt in validators))
          (snag ran ~(tap in validators))
        =/  epoch-num=@ud
          ?~(p=(bind (pry:poc epochs) head) 0 +(u.p))
        =/  =wire  /validator/epoch-catchup/(scot %ud epoch-num)
        :_  state(mode %validator)
        :+  =-  [%pass - %arvo %b %wait (add now.bowl ~m1)]
            /timers/epoch-catchup/(scot %ud epoch-num)/(scot %p ship)
          [%pass (snoc wire (scot %p ship)) %agent [ship %ziggurat] %watch wire]
        cleanup-fisherman
      :_  state(mode %fisherman)
      cleanup-validator
    ::
        %stop
      ?>  =(src.bowl our.bowl)
      :_  state(mode %none)
      (weld cleanup-validator cleanup-fisherman)
    ==
  ::
  ++  cleanup-validator
    ^-  (list card)
    %+  murn  ~(tap by wex.bowl)
    |=  [[=wire =ship =term] *]
    ^-  (unit card)
    ?.  ?=([%fisherman %updates *] wire)  ~
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
  ?+    wire  (on-agent:def wire sign)
      [%validator ?([%epoch-catchup @ @ ~] [%block-catchup @ @ ~] [%updates ~])]
    ~|  "can only receive validator updates when we are a validator!"
    ?>  ?=(%validator mode)
    =*  kind  i.t.wire
    ?-    kind
        %epoch-catchup
      ::  TODO: handle chain selection for epochs here
      ::  TODO: handle %kicks, etc
      ::
      ?>  ?=(%fact -.sign)
      =/  =update  !<(update q.cage.sign)
::      ?:  ?|(?=(~ epochs.update) ?=(~ epochs))
::        ::  get started producing blocks
::        ?>  ?=(^ order.cur)
::        :_  this
::        =/  =wire  /timer
::        =-  [%pass wire %arvo %b %rest -]
::        ?:  =(i.order.cur our.bowl)
::          now.bowl
::
      `this
    ::
        %block-catchup
      ::  TODO: handle chain selection here
      ::  TODO: handle %kicks, etc
      ::
      ?>  ?=(%fact -.sign)
      =/  =update  !<(update q.cage.sign)
      `this
    ::
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
      =/  =update  !<(update q.cage.sign)
      ~|  "updates must be new blocks"
      ?:  ?=(%new-block -.update)
        ~|  "new blocks can only be applied to the current epoch"
        ?>  =(num.current-epoch epoch-num.update)
        =*  cur  current-epoch
        =^  cards  cur
          (~(their-block epo [cur [our now src]:bowl]) [header block]:update)
        =*  slot-num  num.header.update
        ?.  ?&  (lth +(slot-num) (lent order.cur))
                =(our.bowl (snag +(slot-num) order.cur))
            ==
          ::  we are not the next block producer
          ::
          [cards this]
        ::  our turn to produce a block, produce it immediately
        ::
        =^  cards2  cur
          (~(our-block epo [cur [our now src]:bowl]) *chunks)
        [(weld cards cards2) this]
      ?.  ?=(%saw-block -.update)  !!
      ~|  "we only care if a validator saw a block in the current epoch"
      ?>  =(num.current-epoch epoch-num.update)
      =*  cur  current-epoch
      =^  cards  cur
        (~(see-block epo [cur [our now src]:bowl]) header.update)
      [cards this]
    ==
  ::
      [%fisherman %updates ~]
    ~|  "can only receive fisherman updates when we are a fisherman!"
    ?>  ?=(%fisherman mode)
    `this
  ==
::
++  on-arvo
  |=  [=wire =sign-arvo:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-arvo:def wire sign-arvo)
      [%timers ?([%slot @ @ ~] [%epoch-catchup @ @ ~])]
    ~|  "these timers are only relevant for validators!"
    ?>  ?=(%validator mode)
    =*  kind  i.t.wire
    ?:  ?=(%epoch-catchup kind)
      `this
    =/  epoch-num  (slav %ud i.t.t.wire)
    =/  slot-num  (slav %ud i.t.t.t.wire)
    ?>  ?=([%behn %wake *] sign-arvo)
    ?~  error.sign-arvo
      ~&  error.sign-arvo
      `this
    ~|  "we can only skip blocks in the current epoch"
    ?>  =(num.current-epoch epoch-num)
    =/  next-slot-num
      ?~  p=(bind (pry:sot slots.current-epoch) head)
        0
      +(u.p)
    ~|  "we can only skip the next block, not past or future blocks"
    ?>  =(next-slot-num slot-num)
    =*  cur  current-epoch
    =^  cards  cur
      ~(skip-block epo [cur [our now src]:bowl])
    ?.  ?&  (lth +(slot-num) (lent order.cur))
            =(our.bowl (snag +(slot-num) order.cur))
        ==
      ::  we are not the next block producer
      ::
      [cards this]
    ::  our turn to produce a block, produce it immediately
    ::
    =^  cards2  cur
      (~(our-block epo [cur [our now src]:bowl]) *chunks)
    [(weld cards cards2) this]
  ==
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ~
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
