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
  [now.bowl 0 (shuffle set (mug ~)) ~]
::
++  on-save  !>(state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  ::=/  old-state  !<(state-0 old-vase)
  =/  old-state=state-0  [%0 (silt ~[~zod]) ~ [now.bowl 0 ~[~zod] ~]]
  `this(state old-state)
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  !!
      [%validator ?(%catch-up %updates) ^]
    ~|  "only validators can listen to block production!"
    ?>  (~(has in validators) src.bowl)
    =*  kind  i.t.path
    ?-    kind
        %catch-up
      ::  TODO: issue fact containing missing epochs and then kick.
      ::
      `this
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
      (poke-zig-action vase)
    [cards this]
  ==
  ::
  ++  poke-zig-action
    |=  =^vase
    ^-  (quip card _state)
    =/  action  ;;(?(%start %end) q.vase)
    ?:  ?=(%end action)  !!
    =^  cards  current-epoch
      ~(catch-up epo current-epoch [our now]:bowl)
    [cards state]
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  `this
::
++  on-arvo
  |=  [=wire =sign-arvo:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-arvo:def wire sign-arvo)
      [%skip-block @ ~]
    ?>  ?=([%behn %wake *] sign-arvo)
    ?~  error.sign-arvo
      ~&  error.sign-arvo
      `this
    ::  TODO: skip this validator's turn, as we hit their timeout
    `this
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
