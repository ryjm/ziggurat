::  wallet [uqbar-dao]
::
::  Uqbar hot-wallet agent. Stores private key and facilitates signing
::  transactions, holding nonce values, and keeping track of owned data.
::
/+  *ziggurat, default-agent, dbug, verb
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      ::  address=(unit @ux)
      keys=(unit acru:ames)
      nodes=(map town=@ud =ship)  ::  the sequencer you submit txs to for each town
      nonces=(map town=@ud nonce=@ud)
      zig-rice=(map town=@ud address=@ux)
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
++  on-init  `this(state [%0 ~ ~ ~ ~])
::
++  on-save  !>(state)
++  on-load
  |=  =old=vase
  ^-  (quip card _this)
  =/  old-state  !<(state-0 old-vase)
  `this(state old-state)
::
++  on-watch  on-watch:def
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?+    mark  !!
      %zig-wallet-poke
    =^  cards  state
      (poke-wallet !<(wallet-poke vase))
    [cards this]
  ==
  ::
  ++  poke-wallet
    |=  act=wallet-poke
    ^-  (quip card _state)
    ?>  =(src.bowl our.bowl)
    ?-    -.act
        %set-keys
      ::  import wallet from secret key
      ::  poking this will lose/override existing key!!
      =/  new-keys  (pit:nu:crub:crypto 256 seed.act)
      `state(keys `new-keys)
    ::
        %set-zigs
      `state(zig-rice (~(put by zig-rice) town.act addr.act))
    ::
        %set-node
      `state(nodes (~(put by nodes) town.act ship.act))
    ::
        %inc-nonce
      ::  for when an external application performs a transaction
      =/  curr  (~(gut by nonces.state) town.act 0)
      `state(nonces (~(put by nonces) town.act +(curr)))
    ::
        %set-nonce  ::  mostly for testing
      `state(nonces (~(put by nonces) town.act new.act))
    ::
        %submit
      ::  submit a transaction
      ::  create an egg and sign it, then poke a sequencer
      ::  ultimately, this should poke an explorer that has
      ::  the ABI of the contract they're calling, which will
      ::  give the wallet instructions as to what kind of 
      ::  data this transaction will require. for now, user
      ::  must manually provide addresses of rice.
      =/  node-type      ?:(=(0 town.act) %ziggurat %sequencer)
      =/  nonce          (~(gut by nonces.state) town.act 0)
      =/  our-zigs       (~(got by zig-rice.state) town.act)
      =/  =caller:smart  [pub:ex:(need keys.state) +(nonce) our-zigs]
      =/  =yolk:smart    [caller args.act my-grains.act cont-grains.act]
      =/  sig=@          (sign:as:(need keys.state) (sham (jam yolk)))
      =/  =egg:smart
        :-  [caller sig to.act rate.gas.act bud.gas.act town.act]
        yolk
      =/  node=ship      
        ?~  sequencer.act
          (~(got by nodes.state) town.act)
        u.sequencer.act
      :_  state(nonces (~(put by nonces) town.act +(nonce)))
      :~  :*  %pass  /submit-tx
              %agent  [node node-type]
              %poke  %zig-weave-poke
              !>([%forward (silt ~[egg])])
      ==  ==
    ==
  --
::
++  on-agent  on-agent:def
::
++  on-arvo  on-arvo:def
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ::
  ::  scries for sequencer agent
  ::
  ?.  =(%x -.path)  ~
  ?+    +.path  (on-peek:def path)
      [%pubkey ~]
    ``noun+!>(`@ux`pub:ex:(need keys.state))
  ::
      [%zigs @ ~]
    ::  returns our zigs account for a given town
    =/  town-id  (slav %ud i.t.t.path)
    ``noun+!>(`@ux`(~(got by zig-rice.state) town-id))
      [%account @ ~]
    ::  returns our account for the town-id given
    =/  town-id  (slav %ud i.t.t.path)
    =/  nonce  (~(gut by nonces.state) town-id 0)
    =/  zigs  (~(gut by zig-rice.state) town-id 0x0)
    ``noun+!>(`account:smart`[`@ux`pub:ex:(need keys.state) nonce zigs])
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
