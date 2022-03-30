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
      keys=(unit acru:ames)  ::  private key-store
      nodes=(map town=@ud =ship)  ::  the sequencer you submit txs to for each town
      nonces=(map town=@ud nonce=@ud)
      =book  ::  "address book" of rice
      ::  TODO add block explorer hookup here, can subscribe for changes
      ::  potential to do cool stuff with %pals integration here
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
        %populate
      ::  populate wallet with fake data for testing
      =/  new-keys  (pit:nu:crub:crypto 256 eny.bowl)
      =/  pub  pub:ex:new-keys
      =/  fake-grain-1=grain:smart
        :*  (fry-rice:smart pub 0x0 1 `@`'zigs')
            0x0
            pub
            1
            [%& `@`'zigs' [100.000.000 ~]]
        ==
      =/  fake-grain-2=grain:smart
        :*  (fry-rice:smart pub `@ux`'fake-token' 1 `@`'wETH')
            `@ux`'fake-token'
            pub
            1
            [%& `@`'wETH' [173.000 ~]]
        ==
      :-  ~
      %=  state
        keys  `new-keys
        nodes  (malt ~[[0 ~zod] [1 ~bus] [2 ~nec]])
        nonces  (malt ~[[0 0] [1 0] [2 0]])
        book  (malt ~[[1 (malt ~[[id.fake-grain-1 fake-grain-1] [id.fake-grain-2 fake-grain-2]])]])
      ==
    ::
        %set-keys
      ::  import wallet from secret key
      ::  poking this will lose/override existing key!!
      =/  new-keys  (pit:nu:crub:crypto 256 seed.act)
      `state(keys `new-keys)
    ::
        %set-node
      `state(nodes (~(put by nodes) town.act ship.act))
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
      ::  must already know what to provide.
      ::
      ::  things to expose on frontend:
      ::  town select, gas (rate & budget), transaction type (acquired from ABI..)
      ::  dropdown or something from our address book for rice-select
      =/  node-type      ?:(=(0 town.act) %ziggurat %sequencer)
      =/  nonce          (~(gut by nonces.state) town.act 0)
      =/  our-zigs       (fry-rice:smart pub:ex:(need keys.state) 0x0 town.act 'zigs')
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
  ?.  =(%x -.path)  ~
  ?+    +.path  (on-peek:def path)
      [%pubkey ~]
    ``noun+!>(`@ux`pub:ex:(need keys.state))
  ::
      [%account @ ~]
    ::  returns our account for the town-id given
    =/  town-id  (slav %ud i.t.t.path)
    =/  nonce  (~(gut by nonces.state) town-id 0)
    =/  zigs=id:smart
      (fry-rice:smart `@ux`pub:ex:(need keys.state) 0x0 town-id 'zigs')
    ``noun+!>(`account:smart`[`@ux`pub:ex:(need keys.state) nonce zigs])
  ::
      [%book ~]
    ::  return entire book map for wallet frontend
    =;  =json  ``json+!>(json)
    =,  enjs:format
    %-  pairs
    %+  turn  ~(tap by book.state)
    |=  [town-id=@ud q=(map =id:smart =grain:smart)]
    :-  (scot %ud town-id)
    %-  pairs
    %+  turn  ~(tap by q)
    |=  [=id:smart =grain:smart]
    =/  bal=@ud
      ?.  ?=(%& -.germ.grain)  0
      ;;(@ud -.data.p.germ.grain)
    :-  (scot %ux id)
    %-  pairs
    :~  ['id' (numb id.grain)]
        ['lord' (numb lord.grain)]
        ['holder' (numb holder.grain)]
        ['town' (numb town-id.grain)]
        ::  note: need to use 'token standard' here
        ::  to guarantee properly parsed data
        ['data' (frond 'balance' (numb bal))]
    ==
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
