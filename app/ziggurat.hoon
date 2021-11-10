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
      [%validator ?([%catchup @ ~] [%updates ~])]
    ~|  "only validators can listen to block production!"
    ?>  (~(has in validators) src.bowl)
    =*  kind  i.t.path
    ?-    kind
        %catchup
      =/  start=@ud  (slav %ud i.t.t.path)
      :_  this
      :+  =-  [%give %fact ~ %zig-update !>(-)]
          ^-  update
          [%epochs-catchup (lot:poc epochs `start ~)]
        [%give %kick ~ ~]
      ~
    ::
        %updates
      ::  do nothing here, but send all new blocks and epochs on this path
      `this
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
      ~|  "we have already started in this mode"
      ?<  =(mode mode.action)
      ?:  ?=(%validator mode)
        =/  =ship
          =/  rng  ~(. og eny.bowl)
          =/  ran  (rad:rng ~(wyt in validators))
          (snag ran ~(tap in validators))
        =/  epoch-num=@ud
          ?~(p=(bind (pry:poc epochs) head) 0 +(u.p))
        =/  =wire  /validator/catchup/(scot %ud epoch-num)
        :_  state(mode %validator)
        :+  =-  [%pass - %arvo %b %wait (add now.bowl ~m1)]
            /timers/catchup/(scot %ud epoch-num)/(scot %p ship)
          [%pass (snoc wire (scot %p ship)) %agent [ship %ziggurat] %watch wire]
        cleanup-fisherman
      :_  state(mode %fisherman)
      cleanup-validator
    ::
        %stop
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
      [%validator ?([%catchup @ @ ~] [%updates ~])]
    ~|  "can only receive validator updates when we are a validator!"
    ?>  ?=(%validator mode)
    =*  kind  i.t.wire
    ?-    kind
        %catchup
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
      ?>  ?=(%new-block -.update)
      ~|  "new blocks can only be applied to the current epoch"
      ?>  =(num.current-epoch epoch-num.update)
      =*  cur  current-epoch
      =^  cards  cur
        (~(their-turn epo [cur [our now]:bowl]) [header block]:update)
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
      [%timers ?([%slot @ @ ~] [%catchup @ @ ~])]
    ~|  "these timers are only relevant for validators!"
    ?>  ?=(%validator mode)
    =*  kind  i.t.wire
    ?:  ?=(%catchup kind)
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
    =^  cards  current-epoch
      ~(skip-turn epo [current-epoch [our now]:bowl])
    [cards this]
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
