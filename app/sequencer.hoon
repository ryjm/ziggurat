::  sequencer [uqbar-dao]
::
::  Agent for managing a single Uqbar town. Publishes blocks
::  of transaction data to main chain agent, Ziggurat.
::
::  calls out to ziggurat agent and gets timer for block submission
::
/-  *sequencer, ziggurat
/+  default-agent, dbug, verb, smart=zig-sys-smart, *zig-mill
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      me=(unit account:smart)
      =town:smart
      hall=(unit hall)
      =basket
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
  (on-watch:def path)
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
          %agent  [(snag chair.u.hall.state order.u.hall.state) %sequencer]  %poke
          %zig-basket-action  !>([%hear egg.act])
      ==
    ::
        %hear
      ::  should only accept from other validators
      ?>  (~(has in council.u.hall.state) src.bowl)
      ~&  >  "received a gossiped egg from {<src.bowl>}: {<egg.act>}"
      `state(basket (~(put in basket) egg.act))
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
          %agent  [to.act %sequencer]  %poke
          %zig-basket-action  !>([%receive-set basket.state])
      ==
    ::
        %receive-set
      ::  integrate a set of eggs into our basket
      ::  should only accept from other validators
      ?>  (~(has in council.u.hall.state) src.bowl)
      `state(basket (~(uni in basket) eggs.act))
    ==
  ::
  ++  poke-chain-action
    |=  act=chain-action
    ^-  (quip card _state)
    ?>  (lte (met 3 src.bowl) 4)
    ?-    -.act
        %submit
      ?>  =(src.bowl our.bowl)
      ::  find current block producer from ziggurat
      =/  producer  .^(@p %gx /(scot %p our.bowl)/ziggurat/(scot %da now.bowl)/producer/noun)
      ::  create and send our chunk to them
      =/  our-chunk  ::  *chunk:ziggurat
        %+  ~(mill-all mill (need me.state) id:(need hall.state) 1 now)
          town.state
        ~(tap in basket.state)
      :_  state(basket ~)
      :_  ~
      :*  %pass  /chunk-gossip
          %agent  [producer %ziggurat]  %poke
          %zig-action  !>([%receive-chunk (jam our-chunk)])
      ==
    ::
        %init
      ?>  =(src.bowl our.bowl)
      ::  assert that we're active in main chain
      ?.  .^(? %gx /(scot %p our.bowl)/ziggurat/(scot %da now.bowl)/active/noun)
        ~|("can't run a town, ziggurat not active" !!)
      ?^  hall.state
        ~|("can't init a town, already active in one" !!)
      :-  ~
      %=  state
          hall  `[town-id.act 0 (silt ~[our.bowl]) ~[our.bowl] 0]
          me    `me.act
          town  starting-state.act
      ==
    ::
        %leave-town
      ?>  =(src.bowl our.bowl)
      `state(hall ~, town [~ ~], basket ~)
    ::
        %receive-state
      ?~  hall.state
        ~&  >>  "ignoring poke, we're not active in a council"
        [~ state]
      ::  TODO only let main chain ships give this to you
      ::  add grain to our town
      `state(p.town (~(put in p.town) id.grain.act grain.act))
    ==
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  (on-agent:def wire sign)
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
    !!
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
  ?~  hall.state    ~
  ?.  =(%x -.path)  ~
  ?+    +.path  (on-peek:def path)
      [%rice @ ~]
    =/  id  (slav %ux i.t.t.path)
    ?~  res=(~(get by p.town.state) id)
      [~ ~]
    ?.  ?=(%& -.germ.u.res)
      [~ ~]
    ``noun+!>(`rice:smart`p.germ.u.res)
  ::
      [%wheat @ @ta ~]
    ::  call read arm of contract
    =/  id  (slav %ux i.t.t.path)
    =/  arg=^path  [i.t.t.t.path ~]
    ?~  res=(~(get by p.town.state) id)
      [~ ~]
    ?.  ?=(%| -.germ.u.res)
      [~ ~]
    =/  cont  (hole:smart contract:smart p.germ.u.res)
    =/  owns
      %-  ~(gas by *(map:smart id:smart grain:smart))
      %+  murn  ~(tap in owns.p.germ.u.res)
      |=  find=id:smart
      ?~  found=(~(get by p.town.state) find)  ~
      ?.  ?=(%& -.germ.u.found)                ~
      ?.  =(lord.u.found id)                   ~
      `[find u.res]
    =/  cart  [~ id blocknum.u.hall.state id.u.hall.state owns]
    ``noun+!>(`noun`(~(read cont cart) arg))
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
