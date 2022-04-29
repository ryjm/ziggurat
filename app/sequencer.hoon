::  sequencer [uqbar-dao]
::
::  Agent for managing a single Uqbar town. Publishes blocks
::  of transaction data to main chain agent, Ziggurat.
::
/+  *ziggurat, default-agent, dbug, verb
::  Choose which library smart contracts are executed against here
::
/*  smart-lib  %noun  /lib/zig/compiled/smart-lib/noun
=,  util
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      town-id=(unit @ud)
      =town:smart
      hall=(unit hall)
      =basket
  ==
+$  inflated-state-0  [state-0 =mil]
+$  mil  $_  ~(mill mill 0)
--
::
=|  inflated-state-0 
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
  :-  ~[(sequencer-sub-card our.bowl)]
  this(state [[%0 ~ [~ ~] ~ ~] ~(mill mill +:(cue q.q.smart-lib))])
::
++  on-save  !>(-.state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  ::  on-load: pre-cue our compiled smart contract library
  ::  (not yet able to use, but will switch to this)
  =+  ~(mill mill +:(cue q.q.smart-lib))
  :_  this(state [!<(state-0 old-vase) -])
  ::  connect to our %ziggurat agent
  ?:  (~(has by wex.bowl) [/sequencer/updates our.bowl %ziggurat])  ~
  ~[(sequencer-sub-card our.bowl)]
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?.  ?=([%new-chunk ~] path)  ~|("%sequencer: error: got erroneous %watch" !!)
  ?~  hall.state  ~|("%sequencer: error: got watch while not active in a hall" !!)
  ?>  (allowed-participant:util [src our now]:bowl)
  `this
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?+    mark  ~|("%sequencer: error: got erroneous %poke" !!)
      %zig-weave-poke
    =^  cards  state
      (poke-basket !<(weave-poke vase))
    [cards this]
  ::
      %zig-hall-poke
    =^  cards  state
      (poke-hall !<(hall-poke vase))
    [cards this]
  ==
  ::
  ++  poke-basket
    |=  act=weave-poke
    ^-  (quip card _state)
    ?>  (allowed-participant:util [src our now]:bowl)
    ?~  hall.state
      ~&  >>  "ignoring tx, we're not active in a council"
      [~ state]
    ?-    -.act
        %forward
      ::  getting an egg from user / eggs from fellow sequencer
      ::  add to our basket after ensuring each egg is to our town
      =.  eggs.act  (filter:util eggs.act |=(=egg:smart =((need town-id.state) town-id.p.egg)))
      =/  slot-num  .^(@ud %gx /(scot %p our.bowl)/ziggurat/(scot %da now.bowl)/slot/noun)
      =/  current-producer  (snag (mod slot-num (lent order.u.hall.state)) order.u.hall.state)
      ?:  =(our.bowl current-producer)
        `state(basket (~(uni in basket) eggs.act))
      ~&  >>  "forwarding eggs"
      :_  state(basket ~)
      :_  ~
      :*  %pass  /basket-gossip
          %agent  [current-producer %sequencer]
          %poke  %zig-weave-poke
          !>([%receive (~(uni in eggs.act) basket.state)])
      ==
    ::
        %receive
      ::  should only accept from other validators
      ?>  (~(has by council:(need hall.state)) src.bowl)
      ~&  >>  "received gossiped eggs from {<src.bowl>}: {<eggs.act>}"
      `state(basket (~(uni in basket) eggs.act))
    ==
  ::
  ++  poke-hall
    |=  act=hall-poke
    ^-  (quip card _state)
    ?>  =(src.bowl our.bowl)
    ::  assert that we're active in relay chain
    ?.  .^(? %gx /(scot %p our.bowl)/ziggurat/(scot %da now.bowl)/active/noun)
      ~|("can't run a town, ziggurat not active" !!)
    =/  our-address
      .^((unit id:smart) %gx /(scot %p our.bowl)/ziggurat/(scot %da now.bowl)/address/noun)
    ?~  our-address  ~|("sequencer requires an associated public key from ziggurat" !!)
    =/  sig  (sign:zig-sig our.bowl now.bowl 'attestation')
    ?-    -.act
        %init
      ?^  hall.state  ~|("can't init a town, already active in one" !!)
      =+  [%init sig town-id.act]
      :_  state(town ?~(starting-state.act [~ ~] u.starting-state.act), town-id `town-id.act)
      :-  (poke-capitol our.bowl u.our-address [rate.gas.act bud.gas.act] -)
      ?.  (~(has by wex.bowl) [/sequencer/updates our.bowl %ziggurat])
        ~[(sequencer-sub-card our.bowl)]
      ~
    ::
        %join
      ?^  hall.state  ~|("can't join a town, already active in one" !!)
      :_  state(town-id `town-id.act)
      =+  [%join sig town-id.act]
      :-  (poke-capitol our.bowl u.our-address [rate.gas.act bud.gas.act] -)
      ?.  (~(has by wex.bowl) [/sequencer/updates our.bowl %ziggurat])
        ~[(sequencer-sub-card our.bowl)]
      ~
    ::
        %exit
      ::  submit tx indicating our absence. wait for ack to actually leave!
      ?~  town-id.state  ~|("can't exit a town, not in one" !!)
      =+  [%exit sig u.town-id.state]
      :_  state
      ~[(poke-capitol our.bowl u.our-address [rate.gas.act bud.gas.act] -)]
    ::
        %clear-state
      :_  state(town-id ~, town [~ ~], hall ~, basket ~)
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
    ~&  "%sequencer: our chunk was rejected by relay chain?"
    `this
  ::
      [%new-chunk ~]
    ::  update our town state with latest chunk
    ?:  ?=(%watch-ack -.sign)              (on-agent:def wire sign)
    ?.  ?=(%fact -.sign)                   (on-agent:def wire sign)
    ?.  ?=(%zig-chunk-update p.cage.sign)  (on-agent:def wire sign)
    =/  update  !<(chunk-update q.cage.sign)
    ?~  hall.state  ~|("%sequencer: error: got chunk update while not in a hall" !!)
    ?>  (~(has by council.u.hall.state) src.bowl)
    ::  TODO add some validation of the new chunk here so we can reject bad ones
    ::  currently assuming sequencers are working together like friends :)
    `this(town town.update)
  ::
      [%sequencer %updates ~]
    ?:  ?=(%watch-ack -.sign)              (on-agent:def wire sign)
    ?.  ?=(%fact -.sign)                   (on-agent:def wire sign)
    ?.  ?=(%sequencer-update p.cage.sign)  (on-agent:def wire sign)
    =/  update  !<(sequencer-update q.cage.sign)
    ?-    -.update
        %new-hall
      ::  receive this at beginning of epoch, update our hall-state
      ::  shuffle with root of globe / something each epoch
      ?.  (~(has by council.update) our.bowl)
        ::  if we're not in the hall, reset our state
        :_  this
        ~[[%pass /clear %agent [our.bowl %sequencer] %poke %zig-hall-poke !>([%clear-state ~])]]
      =/  sequencers  ~(key by council.update)
      =/  not-yet-subbed  (~(del in sequencers) our.bowl)
      :_  this(hall `[council.update ~(tap in sequencers)]) ::  NOT SHUFFLED ATM
      ?~  sub=~(tap in not-yet-subbed)  ~
      ::  subscribe to other sequencers in town
      ^-  (list card)
      %+  murn  `(list ship)`sub
      |=  s=ship
      ^-  (unit card)
      ?:  %-  ~(any in ~(key by wex.bowl))
          |=([* =ship *] =(s ship))
        ~
      `[%pass /new-chunk %agent [s %sequencer] %watch /new-chunk]
    ::
        %next-producer
      ::  if we can, produce a chunk!
      =/  z  /(scot %p our.bowl)/ziggurat/(scot %da now.bowl)
      =/  slot-num  .^(@ud %gx (weld z /slot/noun))
      ?:  ?|  ?=(~ hall.this)
              !=(our.bowl (snag (mod slot-num (lent order.u.hall.this)) order.u.hall.this))
          ==
        `this
      ::  create and send our chunk to them
      ~&  >>  "sequencer: attempting to produce a chunk"
      =/  our-address  .^((unit id:smart) %gx (weld z /address/noun))
      =+  /(scot %p our.bowl)/wallet/(scot %da now.bowl)/account
      =/  me  .^(account:smart %gx (weld - /(scot %ux (need our-address))/(scot %ud (need town-id.state))/noun))
      =/  our-chunk=chunk
        %+  ~(mill-all mil me (need town-id.state) 0 now.bowl)
          town.state
        ~(tap in basket.state)
      ::  currently clearing mempool with every chunk, but
      ::  this is not necessary: we forward our basket
      :_  this(basket ~, town +.our-chunk)
      :~  :*  %pass  /chunk-gossip
              %agent  [ship.update %ziggurat]  %poke
              %zig-chain-poke  !>([%receive-chunk (need town-id.state) our-chunk])
          ==
          :*  %pass  /basket-gossip
              %agent  [our.bowl %sequencer]  %poke
              %zig-weave-poke  !>([%forward ~])
          ==
          :*  %give  %fact
              ~[/new-chunk]  %zig-chunk-update
              !>([%new-chunk +.our-chunk])
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
      [%available @ ~]  ::  see if grain exists in state
    =/  id  (slav %ux i.t.t.path)
    ?~  res=(~(get by p.town.state) id)
      ``noun+!>(%.n)
    ``noun+!>(%.y)
  ::
      [%rice @ ~]
    =/  id  (slav %ux i.t.t.path)
    ?~  res=(~(get by p.town.state) id)
      ``noun+!>(~)
    ?.  ?=(%& -.germ.u.res)
      ``noun+!>(~)
    ``noun+!>(``rice:smart`p.germ.u.res)
  ::
      [%wheat @ @ta ^]
    (read-contract path 0 (need town-id.state) p.town.state)
  ::
      [%sizeof @ ~]
    ::  give size of item in town granary
    =/  id  (slav %ux i.t.t.path)
    ?~  res=(~(get by p.town.state) id)  ``noun+!>(~)
    ``noun+!>(`(met 3 (jam res)))
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
