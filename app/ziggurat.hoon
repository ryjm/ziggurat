::  ziggurat [uqbar-dao]
::
/+  *ziggurat, default-agent, dbug, verb
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      validators=(set ship)
      =epochs
      =current=epoch
  ==
::
++  shuffle
  |=  [set=(set ship) eny=@]
  ^-  (list ship)
  =/  lis=(list ship)  ~(tap in set)
  =/  len  (lent lis)
  =/  rng  ~(. og eny)
  =|  shuffled=(list ship)
  |-
  ?~  lis
    shuffled
  =^  num  rng
    (rads:rng len)
  %_  $
    shuffled  [(snag num `(list ship)`lis) shuffled]
    len       (dec len)
    lis       (oust [num 1] `(list ship)`lis)
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
  :^  %0  set
    ~
  [0 now.bowl (shuffle set (mug ~)) ~]
::
++  on-save  !>(state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  ::=/  old-state  !<(state-0 old-vase)
  =/  old-state=state-0  [%0 (silt ~[~zod]) ~ [0 now.bowl ~[~zod] ~]]
  `this(state old-state)
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  !!
      [%validator ?([%catch-up @ ~] [%updates ~])]
    ~|  "only validators can listen to block production!"
    ?>  (~(has in validators) src.bowl)
    =*  kind  i.t.path
    ?-    kind
        %catch-up
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
        %start-epoch
      `state
    ==
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%validator ?(%catch-up %updates) ^]
    =*  kind  i.t.wire
    ?-    kind
        %catch-up
      ::  TODO: pick a random validator from list and %watch his
      ::  catchup path. set a timer, and wait for him to send you
      ::  data. if he doesn't send it within a specified time,
      ::  pick a random other validator to ask for the data from.
      ::  rinse and repeat until you have caught up to the latest
      ::  epoch.
      ::
      ::  TODO: handle %kicks, etc
      ?>  ?=(%fact -.sign)
      =/  =update  !<(update q.cage.sign)
      `this
    ::
        %updates
      ::  TODO: handle %kicks, etc
      ?>  ?=(%fact -.sign)
      =/  =update  !<(update q.cage.sign)
      ~|  "updates must be new blocks"
      ?>  ?=(%new-block -.update)
      ~|  "new blocks can only be applied to the current epoch"
      ?>  =(num.current-epoch epoch-num.update)
      =^  cards  current-epoch
        (~(their-turn epo [current-epoch [our now]:bowl]) `block.update)
      [cards this]
    ==
  ==
::
++  on-arvo
  |=  [=wire =sign-arvo:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-arvo:def wire sign-arvo)
      [%timer @ @ ~]
    =/  epoch-num  (slav %ud i.t.wire)
    =/  block-num  (slav %ud i.t.t.wire)
    ?>  ?=([%behn %wake *] sign-arvo)
    ?~  error.sign-arvo
      ~&  error.sign-arvo
      `this
    ~|  "we can only skip blocks in the current epoch"
    ?>  =(num.current-epoch epoch-num)
    =/  current-block-num
      ?~  p=(bind (pry:bok blocks.current-epoch) head)
        0
      +(u.p)
    ~|  "we can only skip the next block, not past or future blocks"
    ?>  =(current-block-num block-num)
    =^  cards  current-epoch
      (~(their-turn epo [current-epoch [our now]:bowl]) ~)
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
