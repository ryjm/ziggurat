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
    =*  hall  u.hall.state
    ?-    -.act
        %forward
      ::  getting an egg from user / eggs from fellow sequencer
      ::  add to our basket
      ~&  >>  "received eggs: {<eggs.act>}"
      =/  current-producer  (snag chair.hall order.hall)
      ?:  =(current-producer our.bowl)
        ~&  >>  "adding eggs to basket"
        `state(basket (~(uni in basket) eggs.act))
      ~&  >>  "forwarding eggs"
      :_  state(basket ~)
      :_  ~
      :*  %pass  /basket-gossip
          %agent  [current-producer %sequencer]
          %poke  %zig-basket-action
          !>([%receive (~(uni in eggs.act) basket.state) blocknum.hall chair.hall])
      ==
    ::
        %receive
      ::  should only accept from other validators
      ?>  (~(has in council.hall) src.bowl)
      ~&  >>  "received gossiped eggs from {<src.bowl>}: {<eggs.act>}"
      :-  ~
      %=  state
        basket           (~(uni in basket) eggs.act)
        blocknum.u.hall  blocknum.act
        chair.u.hall     chair.act
      ==
    ==
  ::
  ++  poke-chain-action
    |=  act=chain-action
    ^-  (quip card _state)
    ?>  (lte (met 3 src.bowl) 4)
    ?-    -.act
        %submit
      ~&  >>  "received request to submit chunk from {<src.bowl>}"
      ?>  =(src.bowl our.bowl)
      =/  producer  .^(@p %gx /(scot %p our.bowl)/ziggurat/(scot %da now.bowl)/producer/noun)
      ?:  ?|  ?=(~ hall.state)
              ?=(~ me.state)
              !=(our.bowl (snag chair.u.hall.state order.u.hall.state))
          ==
        ~&  >>  "ignoring request"
        `state
      =*  hall  u.hall.state
      ~&  >>  "submitting chunk to producer {<producer>}"
      ::  create and send our chunk to them
      =/  our-chunk=[(list [@ux egg:smart]) town:smart]
        %+  ~(mill-all mill u.me.state id.hall blocknum.hall now)
          town.state
        ~(tap in basket.state)
      ~&  >>  "town size: {<(met 3 (jam +.our-chunk))>}"
      ::
      ::  find who will be next in town to produce chunk
      =/  next-chair=@ud
        ?:  (gte +(chair.hall) ~(wyt in council.hall))
          0
        +(chair.hall)
      ~&  >>  "the next sequencer to make a chunk is {<next-chair>}, {<(snag next-chair order.hall)>}"
      ::  currently clearing mempool with every chunk, but
      ::  this is not necessary: we forward our basket
      :_  %=  state
              basket           ~
              town             +.our-chunk
              blocknum.u.hall  +(blocknum.hall)
              chair.u.hall     next-chair
          ==
      :~  :*  %pass  /chunk-gossip
              %agent  [producer %ziggurat]  %poke
              %zig-action  !>([%receive-chunk id.hall our-chunk])
          ==
          :*  %pass  /basket-gossip
              %agent  [our.bowl %sequencer]  %poke
              %zig-basket-action  !>([%forward ~])
          ==
      ==
    ::
        %init
      ?>  =(src.bowl our.bowl)
      ::  assert that we're active in main chain
      ?.  .^(? %gx /(scot %p our.bowl)/ziggurat/(scot %da now.bowl)/active/noun)
        ~|("can't run a town, ziggurat not active" !!)
      ::  assert we're not already running a town
      ?^  hall.state
        ~|("can't init a town, already active in one" !!)
      ::  check main chain for existence of that town,
      ::  join if we can, fail if we can't, make new town
      ::  if it doesn't exist
      =/  existing-town  .^((unit chain-hall:ziggurat) %gx /(scot %p our.bowl)/ziggurat/(scot %da now.bowl)/get-hall/(scot %ud town-id.act)/noun)
      ~&  >  existing-town
      ~&  >>  "sequencer initialized"
      :-  ~
      %=  state
          hall  `[town-id.act 0 (silt ~[our.bowl]) ~[our.bowl] 0 is-open.act]
          me    `me.act
          town  ?~(starting-state.act [~ ~] u.starting-state.act)
      ==
      ::  ?~  existing-town
      ::    ::  new hall
      ::    =/  council  (silt ~[our.bowl])
      ::    :-  :_  ~
      ::        :*  %pass  /hall-modify
      ::            %agent  [our.bowl %ziggurat]
      ::            %poke  %zig-action  !>([%new-hall town-id.act council is-open.act])
      ::        ==
      ::    ~&  >>  "sequencer initialized"
      ::    %=  state
      ::        hall  `[town-id.act 0 council ~[our.bowl] 0 is-open.act]
      ::        me    `me.act
      ::        town  ?~(starting-state.act [~ ~] u.starting-state.act)
      ::    ==
      ::  ?:  is-open.u.existing-town
      ::    ::  it is open, join it
      ::    :-  :_  ~
      ::        :*  %pass  /hall-modify
      ::            %agent  [our.bowl %ziggurat]
      ::            %poke  %zig-action  !>([%add-to-hall town-id.act])
      ::        ==
      ::    %=  state
      ::      ::  will get real town state and order at beginning of next epoch
      ::      hall  `[town-id.act 0 (~(put in council.u.existing-town) our.bowl) ~ 0 is-open.u.existing-town]
      ::      me    `me.act
      ::      town  [~ ~]
      ::    ==
      ::  ::  it is closed, fail
      ::  ~|("that town is closed to you!" !!)
    ::
        %leave-hall
      ?>  =(src.bowl our.bowl)
      ?<  ?=(~ hall.state)
      :_  state(hall ~, town [~ ~], basket ~)
      :_  ~
      :*  %pass  /hall-modify
          %agent  [our.bowl %ziggurat]
          %poke  %zig-action  !>([%remove-from-hall id.u.hall.state])
      ==
    ::  ::
    ::      %hall-update  ::  we'll get these from our ziggurat agent
    ::    ?>  =(src.bowl our.bowl)
    ::    ?~  hall.state
    ::      ~&  >>  "ignoring poke, we're not active in a council"
    ::      [~ state]
    ::    ::  TODO maybe don't accept these uncritically?
    ::    `state(council.u.hall council.act)
    ::
        %receive-state  ::  we'll get these from our ziggurat agent
      ?>  =(src.bowl our.bowl)
      ?~  hall.state
        ~&  >>  "ignoring poke, we're not active in a council"
        [~ state]
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
  ^-  (quip card _this)
  (on-arvo:def wire sign-arvo)
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
      [%active ~]
    ``noun+!>(`?`!=(~ hall.state))
  ::
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
    ?~  res=(~(get by p.town.state) id)  [~ ~]
    ?.  ?=(%| -.germ.u.res)              [~ ~]
    ?~  cont.p.germ.u.res                [~ ~]
    ::  TODO make way for reads to get some rice input
    ::  =/  owns
    ::    %-  ~(gas by *(map:smart id:smart grain:smart))
    ::    %+  murn  ~(tap in owns.p.germ.u.res)
    ::    |=  find=id:smart
    ::    ?~  found=(~(get by p.town.state) find)  ~
    ::    ?.  ?=(%& -.germ.u.found)                ~
    ::    ?.  =(lord.u.found id)                   ~
    ::    `[find u.res]
    =/  cont  (hole contract.smart u.cont.p.germ.u.res)
    =/  cart  [~ id blocknum.u.hall.state id.u.hall.state ~]
    ``noun+!>((~(read cont cart) path))
  ::
      [%sizeof @ ~]
    ::  give size of item in town granary
    =/  id  (slav %ux i.t.t.path)
    ?~  res=(~(get by p.town.state) id)  [~ ~]
    ``noun+!>((met 3 (jam res)))
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
