::  sequencer [uqbar-dao]
::
::  Agent for managing a single Uqbar town. Publishes blocks
::  of transaction data to main chain agent, Ziggurat.
::
/+  default-agent, dbug, verb, smart=zig-sys-smart
/-  ziggurat
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      me=id
      blocknum=@ud
      =town:smart
      =mempool:ziggurat
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
++  on-init  `this(state [%0 0x0 0 [~ ~] ~])
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
      %zig-mempool-action
    =^  cards  state
      (poke-mempool-action !<(mempool-action vase))
    [cards this]
  ::
      %zig-chain-action
    =^  cards  state
      (poke-chain-action !<(chain-action vase))
    [cards this]
  ==
  ::
  ++  poke-mempool-action
    |=  act=mempool-action
    ^-  (quip card _state)
    ?>  (lte (met 3 src.bowl) 4)
    ?-    -.act
        %receive
      ::  getting a tx from user
      ::  send to our helix chunk producer
      ~&  >  "received a tx: {<tx.act>}"
      ?~  helix=(~(get by helices.state) helix-id.act)
        ~&  >>  "ignoring tx, we're not active in that helix"
        [~ state]
      ~&  >  "forwarding to {<leader.u.helix>}'s mempool"
      :_  state
      :_  ~
      :*  %pass  /mempool-gossip
          %agent  [leader.u.helix %ziggurat]  %poke
          %zig-mempool-action  !>(`mempool-action`[%hear helix-id.act tx.act])
      ==
    ::
        %hear
      ::  :ziggurat &mempool [%hear [%send [0x1 100 10 0x1234 [0xa 0xb %schnorr]] 0x2 (malt ~[[0x0 [%tok 0x0 500]]])]]
      ::  getting tx from other validator
      ::  should only accept from other validators
      =/  cur=epoch  +:(need (pry:poc epochs))
      ?~  (find [src.bowl]~ order.cur)  !!
      ::  don't need to gossip forward
      ~&  >  "received a gossiped tx from {<src.bowl>}: {<tx.act>}"
      ?.  (~(has by helices.state) helix-id.act)
        ~&  >>  "ignoring tx, we're not active in that helix"
        [~ state]
      :-  ~
      =-  state(mempools (~(jab by mempools) helix-id.act -))
      |=(=mempool (~(put in mempool) tx.act))
      
    ::
        %forward-set
      ?>  =(src.bowl our.bowl)
      ::  forward our mempool to another validator
      ::  used when we pass producer status to a new
      ::  validator, give them existing mempool
      ::  clear mempool for ourselves
      =/  to-send=(set egg:smart)  (~(gut by mempools) helix-id.act ~)
      :_  state(mempools (~(put by mempools) helix-id.act ~))
      :_  ~
      :*  %pass  /mempool-gossip
          %agent  [to.act %ziggurat]  %poke
          %zig-mempool-action  !>(`mempool-action`[%receive-set helix-id.act to-send])
      ==
    ::
        %receive-set
      ::  integrate a set of txs into our mempool
      ::  should only accept from other validators
      =/  cur=epoch  +:(need (pry:poc epochs))
      ?~  (find [src.bowl]~ order.cur)  !!
      :-  ~
      =-  state(mempools (~(jab by mempools) helix-id.act -))
      |=(=mempool (~(uni in mempool) txs.act))
    ==
  ::
  ++  poke-chain-action
    |=  act=chain-action
    ^-  (quip card _state)
    ?>  (lte (met 3 src.bowl) 4)
    ?-    -.act
        %hear
      ::  receiving chunk to be signed from chunk leader
      ?~  helix=(~(get by helices.state) helix-id.chunk.act)
        ~|("ignoring received chunk, not active in a helix" !!)
      ::  only accept from our helix leader
      ?>  =(src.bowl leader.u.helix)
      ::  sign chunk and return it
      ::  TODO validate chunk here if even needed
      :_  state
      :_  ~
      (~(sign lix u.helix [our now src]:bowl) chunk.act)
    ::
        %signed
      ?~  helix=(~(get by helices.state) helix-id.act)
        ~|("ignoring received sig, not active in a helix" !!)
      ~|  "ship submitting signature is absent from helix"
      ?~  (find [src.bowl]~ order.u.helix)  !!
      ?~  our-chunk=(~(get by our-chunks.state) helix-id.act)
        ~|("ignoring received sig, don't have a chunk to get signed" !!)
      ?.  =(hash.act (sham u.our-chunk))
        ~|("ignoring chunk signature, hash doesn't match our chunk" !!)
      ~|  "received invalid signature on chunk"
      ?>  (validate:zig-sig our.bowl signature.act hash.act now.bowl)
      :-  ~
      =-  state(seen-sigs (~(jab by seen-sigs) helix-id.act -))
      |=(seen=(set signature) (~(put in seen) signature.act))
    ::
        %submit
      ::  TODO should only get this as a block producer
      ::  TODO perform validation?
      ::  add chunk to our seen set
      ~^state(seen-chunks (~(put in seen-chunks) (jam chunk.act)))
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
    =/  cur=epoch  +:(need (pry:poc epochs))
    ?.  =(num.cur epoch-num)
      `state
    =/  next-slot-num
      ?~(p=(bind (pry:sot slots.cur) head) 0 +(u.p))
    =/  block-producer=ship  (snag slot-num order.cur)
    =/  next-producer=ship  (snag next-slot-num order.cur)
    ?.  =(next-slot-num slot-num)
      ?.  =(block-producer our.bowl)  `state
      ~|("we can only produce the next block, not past or future blocks" !!)
    =/  prev-hash
      (got-hed-hash slot-num epochs cur)
    ::  check if we're chunk producer for any helix
    ::  and create a chunk for that helix if so
    ::  update state to hold our chunk
    =/  helix-cards
      ::  cards for chunk signing AND submitting (if already signed)
      =/  helices  ~(val by helices.state)
      =|  cards=(list card)
      |-  ^+  cards
      ?~  helices  cards
      =*  helix  i.helices
      ?:  =(leader.helix our.bowl)
        =/  mempool  (~(gut by mempools.state) id.helix ~)
        =/  our-chunk  (~(produce lix helix [our now src]:bowl) mempool)
        %_  $
          helices  t.helices
          cards  (weld (~(disperse lix helix [our now src]:bowl) our-chunk) cards)
        ==
      ?~  sigs=(~(get by seen-sigs.state) id.helix)
        $(helices t.helices)
      ::  if we have enough signatures, submit chunk to block producer
      ?:  (gte ~(wyt in u.sigs) (div (lent order.helix) 2))
        %_  $
          helices  t.helices
          cards  (weld (~(submit lix helix [our now src]:bowl) u.sigs (~(got by our-chunks.state) id.helix) block-producer) cards)
        ==
      $(helices t.helices)
    ::  increment all our helices
    ::  =.  helices.state
    ::    %+  turn
    ::      helices.state
    ::    
    ?:  =(block-producer our.bowl)
      =^  cards  cur
        (~(our-block epo cur prev-hash [our now src]:bowl) seen-chunks) 
      [(weld cards helix-cards) state(epochs (put:poc epochs num.cur cur))]
    =/  cur=epoch  +:(need (pry:poc epochs))
    =^  cards  cur
      ~(skip-block epo cur prev-hash [our now src]:bowl)
    ~&  skip-block+[num.cur slot-num]
    [(weld cards helix-cards) state(epochs (put:poc epochs num.cur cur))]
  --
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ~
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
