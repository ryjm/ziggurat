::  sequencer [uqbar-dao]
::
::  Agent for managing a single Uqbar town. Publishes blocks
::  of transaction data to main chain agent, Ziggurat.
::
::  calls out to ziggurat agent and gets timer for block submission
::
/+  default-agent, dbug, verb, smart=zig-sys-smart
/-  ziggurat
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      me=(unit account:smart)
      =town:smart
      hall=(unit hall:ziggurat)
      =basket:ziggurat
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
++  on-init  `this(state [%0 ~ [~ ~] ~ ~])
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
  !!
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?+    mark  !!
      %zig-basket-action
    =^  cards  state
      (poke-basket-action !<(basket-action vase))
    [cards this]
  ::
      %zig-chain-action
    =^  cards  state
      (poke-chain-action !<(chain-action vase))
    [cards this]
  ==
  ::
  ++  poke-basket-action
    |=  act=basket-action
    ^-  (quip card _state)
    ?>  (lte (met 3 src.bowl) 4)
    ?~  hall.state
      ~&  >>  "ignoring tx, we're not active in a council"
      [~ state]
    ?-    -.act
        %receive
      ::  getting an egg from user
      ::  add to our basket
      ~&  >  "received an egg: {<egg.act>}"
      ~&  >>  "adding egg to basket"
      :_  state
      :_  ~
      :*  %pass  /basket-gossip
          %agent  [chair.u.hall.state %ziggurat]  %poke
          %zig-basket-action  !>([%hear egg.act])
      ==
    ::
        %hear
      ::  should only accept from other validators
      ?>  (~(has in council.u.hall.state) src.bowl)
      ~&  >  "received a gossiped egg from {<src.bowl>}: {<egg.act>}"
      `state(basket (~(put in basket) egg.act)
    ::
        %forward-set
      ?>  =(src.bowl our.bowl)
      ?>  (~(has in council.u.hall.state) to.act)
      ::  forward our basket to another validator
      ::  used when we pass producer status to a new
      ::  validator, give them existing basket
      ::  clear basket for ourselves
      :_  state(basket ~)
      :_  ~
      :*  %pass  /basket-gossip
          %agent  [to.act %ziggurat]  %poke
          %zig-basket-action  !>([%receive-set basket.state])
      ==
    ::
        %receive-set
      ::  integrate a set of eggs into our basket
      ::  should only accept from other validators
      ?>  (~(has in council.u.hall.state) src.bowl)
      `state(basket (~(uni in basket) eggs.act)
    ==
  ::
  ++  poke-chain-action
    |=  act=chain-action
    ^-  (quip card _state)
    ?>  (lte (met 3 src.bowl) 4)
    ?~  hall.state
      ~&  >>  "ignoring poke, we're not active in a council"
      [~ state]
    ?-    -.act
        %receive-state
      ::  TODO only let main chain ships give this to you
      ::  add grain to our town
      `state(p.town (~(put in p.town) id.grain.act grain.act))
    ==
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  !!
::
++  on-arvo
  |=  [=wire =sign-arvo:agent:gall]
  |^  ^-  (quip card _this)
  ?+    wire  (on-arvo:def wire sign-arvo)
      [%timers [%slot @ @ ~]]
    =/  epoch-num  (slav %ud i.t.t.wire)
    =/  slot-num  (slav %ud i.t.t.t.wire)
    ?>  ?=([%behn %wake *] sign-arvo)
    =^  cards  state
      (slot-timer epoch-num slot-num)
    [cards this]
  ==
  ::
  ++  slot-timer
    |=  [epoch-num=@ud slot-num=@ud]
    ^-  (quip card _state)
    ::  TODO make this create a block
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
      (got-hed-hash slot-num epochs cur)
    ?:  =(ship our.bowl)
      =^  cards  cur
        (~(our-block epo cur prev-hash [our now src]:bowl) eny.bowl^~)
      [cards state(epochs (put:poc epochs num.cur cur))]
    =/  cur=epoch  +:(need (pry:poc epochs))
    =^  cards  cur
      ~(skip-block epo cur prev-hash [our now src]:bowl)
    ~&  skip-block+[num.cur slot-num]
    [cards state(epochs (put:poc epochs num.cur cur))]
  --
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ::  handle scry calls to granary here
  ::  look for rice, contracts, etc
  ::  if rice, return all data
  ::  if wheat,
  ::  call read arm here based on path
  ::  args stored in path
  ~
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
