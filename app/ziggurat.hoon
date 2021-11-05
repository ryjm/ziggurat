::  ziggurat [uqbar-dao]
::
/-  *ziggurat
/+  default-agent, dbug, verb
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      validators=(set ship)
      epochs=(list epoch)
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
  =/  set  (silt ~[~zod ~bus ~nec])
  =-  `this(state -)
  ^-  state-0
  :+  %0  set
  [now.bowl 0 (shuffle set (mug ~)) ~]~
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
      [%validator @ ~]
    =/  =ship  (slav %p i.t.path)
    ~|  "only validators can listen to block production!"
    ?>  (~(has in validators) ship)
    `this
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?+    mark  !!
      %noun
    =^  cards  state
      (poke-noun vase)
    [cards this]
  ==
  ::
  ++  poke-noun
    |=  =^vase
    ^-  (quip card _state)
    =/  action  ;;(?(%start %end) q.vase)
    ?:  ?=(%end action)  !!
    :: TODO: start epoch state machine from here
    ~&  (shuffle validators eny.bowl)
    `state
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
  ::  TODO: set up behn timer after last block received such that you
  ::  know when to skip someone
  `this
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ~
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
