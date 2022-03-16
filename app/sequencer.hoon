::  sequencer [uqbar-dao]
::
::  Agent for managing a single Uqbar town. Publishes blocks
::  of transaction data to main chain agent, Ziggurat.
::
/-  *sequencer, ziggurat
/+  default-agent, dbug, verb, smart=zig-sys-smart, mill=zig-mill
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      town-id=(unit @ud)
      =town:smart
      hall=(unit hall)
      =basket:smart
      library=(unit *)
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
++  on-init  `this(state [%0 ~ [~ ~] ~ ~ ~])
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
      =/  current-producer  (snag chair.hall order.hall)
      ?:  =(current-producer our.bowl)
        `state(basket (~(uni in basket) eggs.act))
      ~&  >>  "forwarding eggs"
      :_  state(basket ~)
      :_  ~
      :*  %pass  /basket-gossip
          %agent  [current-producer %sequencer]
          %poke  %zig-basket-action
          !>([%receive (~(uni in eggs.act) basket.state)])
      ==
    ::
        %receive
      ::  should only accept from other validators
      ?>  (~(has by council.hall) src.bowl)
      ~&  >>  "received gossiped eggs from {<src.bowl>}: {<eggs.act>}"
      `state(basket (~(uni in basket) eggs.act))
    ==
  ::
  ++  poke-chain-action
    |=  act=chain-action
    ^-  (quip card _state)
    ?>  (lte (met 3 src.bowl) 4)
    ?-    -.act
        %set-standard-lib
      ?>  =(src.bowl our.bowl)
      =/  blob  .^([p=path q=[p=@ud q=@]] %cx (weld /(scot %p our.bowl)/zig/(scot %da now.bowl) path.act))
      =/  cued  (cue q.q.blob)
      `state(library `cued)
    ::
        %init
      ?>  =(src.bowl our.bowl)
      ::  assert that we're active in main chain
      ?.  .^(? %gx /(scot %p our.bowl)/ziggurat/(scot %da now.bowl)/active/noun)
        ~|("can't run a town, ziggurat not active" !!)
      ::  assert we're not already running a town
      ?^  hall.state     ~|("can't init a town, already active in one" !!)
      ?~  library.state  ~|("can't init a town, no standard library for contracts" !!)
      ::  TODO submit tx to ziggurat for inclusion in next epoch
      ~&  >>  "sequencer initialized"
      :_  state(town ?~(starting-state.act [~ ~] u.starting-state.act), town-id `town-id.act)
          ::  subscribe to updates from ziggurat
      :~  :*  %pass   /sequencer/updates
              %agent  [our.bowl %ziggurat]
              %watch  /sequencer/updates
      ==  ==
    ::
        %leave-hall
      ?>  =(src.bowl our.bowl)
      ?<  ?=(~ hall.state)
      ::  TODO submit tx indicating our absence. wait for ack to actually leave
      :_  state(hall ~, town [~ ~], basket ~, library ~)
      %+  murn  ~(tap by wex.bowl)
      |=  [[=wire =ship =term] *]
      ^-  (unit card)
      ?.  ?=([%sequencer %updates *] wire)  ~
      `[%pass wire %agent [ship term] %leave ~]
    ==
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%chunk-gossip ~]
    ::  TODO manage rejected chunks here.
    ::  try and submit them to the next producer?
    `this
      [%sequencer %updates ~]
    ?:  ?=(%watch-ack -.sign)              (on-agent:def wire sign)
    ?.  ?=(%fact -.sign)                   (on-agent:def wire sign)
    ?.  ?=(%sequencer-update p.cage.sign)  (on-agent:def wire sign)
    =/  update  !<(sequencer-update:ziggurat q.cage.sign)
    ?-    -.update
        %new-hall
      ::  receive this at beginning of epoch, update our hall-state
      ::  shuffle council (necessary?) ???? (TODO)
      ?~  hall.this  `this
      `this(council.u.hall council.update, order.u.hall ~(tap in ~(key by council.update)))
    ::
        %next-producer
      ::  if we can, produce a chunk!
      =/  slot-num  .^(@ud %gx /(scot %p our.bowl)/ziggurat/(scot %da now.bowl)/slot/noun)
      ?:  ?|  ?=(~ hall.this)
              ::?=(~ order.u.hall.state)
              !=(our.bowl (snag (mod (lent order.u.hall.state) slot-num) order.u.hall.this))
          ==
        ~&  >>  "ignoring request"
        `this
      =*  hall  u.hall.state
      ::  create and send our chunk to them
      =/  me  .^(account:smart %gx /(scot %p our.bowl)/ziggurat/(scot %da now.bowl)/account/noun)
      =/  our-chunk=chunk:smart
        %+  ~(mill-all mill me (need library.state) (need town-id.state) 0 now.bowl)  ::  TODO blocknum
          town.state
        ~(tap in basket.state)
      ~&  >>  "chunk size: {<(met 3 (jam our-chunk))>} bytes"
      ::
      ::  find who will be next in town to produce chunk
      =/  next-chair=@ud
        ?:  (gte +(chair.hall) ~(wyt by council.hall))
          0
        +(chair.hall)
      ::  currently clearing mempool with every chunk, but
      ::  this is not necessary: we forward our basket
      ~&  >>  "submitting chunk to producer {<ship.update>}"
      :_  %=  this
              basket           ~
              town             +.our-chunk
              chair.u.hall     next-chair
          ==
      :~  :*  %pass  /chunk-gossip
              %agent  [ship.update %ziggurat]  %poke
              %zig-action  !>([%receive-chunk (need town-id.state) our-chunk])
          ==
          :*  %pass  /basket-gossip
              %agent  [our.bowl %sequencer]  %poke
              %zig-basket-action  !>([%forward ~])
          ==
      ==
    ==
  ==
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
  ?.  =(%x -.path)  ~
  ?+    +.path  (on-peek:def path)
      [%active ~]
    ``noun+!>(`?`!=(~ hall.state))
  ::
      [%town-id ~]
    ``noun+!>(`(unit @ud)`town-id.state)
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
    ::  TODO make way for reads to get some rice input!
    ::  =/  owns
    ::    %-  ~(gas by *(map:smart id:smart grain:smart))
    ::    %+  murn  ~(tap in owns.p.germ.u.res)
    ::    |=  find=id:smart
    ::    ?~  found=(~(get by p.town.state) find)  ~
    ::    ?.  ?=(%& -.germ.u.found)                ~
    ::    ?.  =(lord.u.found id)                   ~
    ::    `[find u.res]
    =/  cont  (hole:smart contract:smart u.cont.p.germ.u.res)
    =/  cart  [~ id 0 (need town-id.state) ~] ::  TODO blocknum
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
