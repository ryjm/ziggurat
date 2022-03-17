::  sequencer [uqbar-dao]
::
::  Agent for managing a single Uqbar town. Publishes blocks
::  of transaction data to main chain agent, Ziggurat.
::
/-  *sequencer, ziggurat
/+  default-agent, dbug, verb, smart=zig-sys-smart, mill=zig-mill, sig=zig-sig
/*  smart-lib  %noun  /lib/zig/sys/smart-lib/noun
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      town-id=(unit @ud)
      =town:smart
      hall=(unit hall)
      =basket:smart
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
++  on-init  `this(state [[%0 ~ [~ ~] ~ ~] ~(mill mill +:(cue q.q.smart-lib))])
::
++  on-save  !>(-.state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  =/  old-state  !<(state-0 old-vase)
  =/  mil   ~(mill mill +:(cue q.q.smart-lib))
  `this(state [old-state mil])
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
      ::  FAKE EASY MILLING FOR TEST PURPOSES
      ::  =/  milled
      ::      %+  ~(mill-all mil [0xdead 0 0x1.dead] (need town-id.state) 0 now.bowl)
      ::        town.state
      ::      ~(tap in eggs.act)
      =/  slot-num  .^(@ud %gx /(scot %p our.bowl)/ziggurat/(scot %da now.bowl)/slot/noun)
      =/  current-producer  (snag (mod slot-num (lent order.u.hall.state)) order.u.hall.this)
      ?:  =(our.bowl ~zod)
        `state(basket (~(uni in basket) eggs.act))
      ~&  >>  "forwarding eggs"
      :_  state(basket ~)
      :_  ~
      :*  %pass  /basket-gossip
          %agent  [~zod %sequencer]
          %poke  %zig-basket-action
          !>([%receive (~(uni in eggs.act) basket.state)])
      ==
    ::
        %receive
      ::  should only accept from other validators
      ::  ?>  (~(has by council.hall) src.bowl)
      ~&  >>  "received gossiped eggs from {<src.bowl>}: {<eggs.act>}"
      `state(basket (~(uni in basket) eggs.act))
    ==
  ::
  ++  poke-chain-action
    |=  act=chain-action
    ^-  (quip card _state)
    ?>  =(src.bowl our.bowl)
    ::  assert that we're active in main chain
    ?.  .^(? %gx /(scot %p our.bowl)/ziggurat/(scot %da now.bowl)/active/noun)
      ~|("can't run a town, ziggurat not active" !!)
    =/  me  .^(account:smart %gx /(scot %p our.bowl)/ziggurat/(scot %da now.bowl)/account/noun)
    =/  sig  (sign:sig our.bowl now.bowl (sham me))
    ?-    -.act
        %init
      ::  assert we're not already running a town
      ?^  hall.state  ~|("can't init a town, already active in one" !!)
      ::  submit tx to ziggurat for inclusion in next epoch
      :_  state(town ?~(starting-state.act [~ ~] u.starting-state.act), town-id `town-id.act)
      ::  subscribe to updates from ziggurat
      :~  :*  %pass   /sequencer/updates
              %agent  [our.bowl %ziggurat]
              %watch  /sequencer/updates
          ==
          :*  %pass  /submit-tx
              %agent  [our.bowl %ziggurat]
              %poke  %zig-basket-action
              !>  :-  %forward
                  %-  silt  :_  ~
                  :*  [me(nonce +(nonce.me)) `@ux`'capitol' rate.gas.act bud.gas.act 0]
                      me(nonce +(nonce.me))
                      `[%init sig town-id.act]
                      ~
                      (silt ~[`@ux`'world'])
                  ==
          ==
      ==
    ::
        %join
      ::  assert we're not already running a town
      ?^  hall.state  ~|("can't join a town, already active in one" !!)
      ::  submit tx to ziggurat for inclusion in next epoch
      :_  state(town-id `town-id.act)
          ::  subscribe to updates from ziggurat
      :~  :*  %pass   /sequencer/updates
              %agent  [our.bowl %ziggurat]
              %watch  /sequencer/updates
          ==
          :*  %pass  /submit-tx
              %agent  [our.bowl %ziggurat]
              %poke  %zig-basket-action
              !>  :-  %forward
                  %-  silt  :_  ~
                  :*  [me(nonce +(nonce.me)) `@ux`'capitol' rate.gas.act bud.gas.act 0]
                      me(nonce +(nonce.me))
                      `[%join sig town-id.act]
                      ~
                      (silt ~[`@ux`'world'])
                  ==
          ==
      ==
    ::
        %exit
      ::  submit tx indicating our absence. wait for ack to actually leave
      ::  assert we're running a town
      ?~  town-id.state  ~|("can't exit a town, not in one" !!)
      ::  submit tx to ziggurat for inclusion in next epoch
      :_  state
      :~  :*  %pass  /submit-tx
              %agent  [our.bowl %ziggurat]
              %poke  %zig-basket-action
              !>  :-  %forward
                  %-  silt  :_  ~
                  :*  [me(nonce +(nonce.me)) `@ux`'capitol' rate.gas.act bud.gas.act 0]
                      me(nonce +(nonce.me))
                      `[%exit sig u.town-id.state]
                      ~
                      (silt ~[`@ux`'world'])
                  ==
          ==
      ==
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
    `this
      [%sequencer %updates ~]
    ?:  ?=(%watch-ack -.sign)              (on-agent:def wire sign)
    ?.  ?=(%fact -.sign)                   (on-agent:def wire sign)
    ?.  ?=(%sequencer-update p.cage.sign)  (on-agent:def wire sign)
    =/  update  !<(sequencer-update:ziggurat q.cage.sign)
    ?-    -.update
        %new-hall
      ::  receive this at beginning of epoch, update our hall-state
      ::  shuffle with root of globe / something each epoch
      ~&  >>  "received hall update"
      `this(hall `[council.update ~(tap in ~(key by council.update))])
    ::
        %next-producer
      ::  if we can, produce a chunk!
      =/  slot-num  .^(@ud %gx /(scot %p our.bowl)/ziggurat/(scot %da now.bowl)/slot/noun)
      ?:  ?|  ?=(~ hall.this)
              !=(our.bowl (snag (mod slot-num (lent order.u.hall.this)) order.u.hall.this))
          ==
        ~&  >>  "ignoring request"
        `this
      ::  create and send our chunk to them
      =/  me  .^(account:smart %gx /(scot %p our.bowl)/ziggurat/(scot %da now.bowl)/account/noun)
      =/  our-chunk=chunk:smart
        %+  ~(mill-all mil me (need town-id.state) 0 now.bowl)
          town.state
        ~(tap in basket.state)
      ~&  >>  "chunk size: {<(met 3 (jam our-chunk))>} bytes"
      ::  currently clearing mempool with every chunk, but
      ::  this is not necessary: we forward our basket
      ~&  >>  "submitting chunk to producer {<ship.update>}"
      :_  %=  this
              basket           ~
              town             +.our-chunk
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
