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
      keys=(unit acru:ames)
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
++  on-init  `this(state [%0 ~ ~ ~])
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
      `state(keys `(pit:nu:crub:crypto 256 seed.act))
    ::
        %set-zigs
      `state(zig-rice (~(put by zig-rice) town.act addr.act))
    ::
        %submit
      ::  submit a transaction
      ::  create an egg and sign it, then poke a sequencer
      ::  ultimately, this should poke an explorer that has
      ::  the ABI of the contract they're calling, which will
      ::  give the wallet instructions as to what kind of 
      ::  data this transaction will require. for now, user
      ::  must manually provide addresses of rice.
      ::  also manually providing sequencer to submit tx to.
      =/  nonce  (~(gut by nonces.state) town.act 0)
      =/  our-zigs  (~(got by zig-rice.state) town.act)     
      =/  =caller:smart
        [pub:ex:(need keys.state) nonce our-zigs]
      =/  =egg:smart
        :-  [caller to.act rate.gas.act bud.gas.act town.act]
        [caller args.act my-grains.act cont-grains.act]
      :_  state(nonces (~(put by nonces) town.act +(nonce)))
      :~  :*  %pass  /submit-tx
              %agent  [sequencer.act %sequencer]
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
      [%address ~]
    =/  pubkey  pub:ex:(need keys.state)
    ``noun+!>(`@ux`(pubkey-to-addr:zig-sig pubkey))
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
