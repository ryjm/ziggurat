::  wallet [uqbar-dao]
::
::  Uqbar wallet agent. Stores private key and facilitates signing
::  transactions, holding nonce values, and keeping track of owned data.
::
/+  *ziggurat, default-agent, dbug, verb, bip32, bip39
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      seed=byts  ::  encrypted with password
      keys=(map pub=@ priv=@)  ::  keys created from master seed
      nodes=(map town=@ud =ship)  ::  the sequencer you submit txs to for each town
      nonces=(map pub=@ (map town=@ud nonce=@ud))
      tokens=(map pub=@ =book)
      metadata-store=(map =id:smart token-metadata)
      ::  TODO add block explorer hookup here, can subscribe for changes
      indexer=(unit ship)
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
++  on-init  `this(state [%0 *byts ~ ~ ~ ~ ~ `our.bowl])
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
    ::
        %import
      ::  will lose seed in current wallet, should warn on frontend!
      ::  stores the default keypair in map
      ::  import takes in a seed phrase and password to encrypt with
      =+  seed=(to-seed:bip39 mnemonic.act password.act)
      =+  core=(from-seed:bip32 [64 seed])
      ::  TODO look on block explorer for pubkeys associated with this seed!
      `state(seed [64 seed], keys (malt ~[[public-key:core private-key:core]]))
    ::
        %create
      ::  will lose seed in current wallet, should warn on frontend!
      ::  creates a new wallet from entropy derived on-urbit
      ::  TODO set up password here, currently bad
      =+  core=(from-seed:bip32 [64 eny.bowl])
      ::  TODO look on block explorer for pubkeys associated with this seed!
      `state(seed [64 eny.bowl], keys (malt ~[[public-key:core private-key:core]]))
    ::
        %delete
      ::  can recover by re-deriving same path
      :-  ~  %=  state
        keys    (~(del by keys) pubkey.act)
        nonces  (~(del by nonces) pubkey.act)
        tokens  (~(del by tokens) pubkey.act)
      ==
    ::
        %set-node
      `state(nodes (~(put by nodes) town.act ship.act))
    ::
        %set-indexer
      ::  defaults to our ship, so for testing, just run indexer on same ship
      `state(indexer `ship.act)
    ::
        %set-nonce  ::  for testing
      =+  acc=(~(got by nonces.state) address.act)
      `state(nonces (~(put by nonces) address.act (~(put by acc) town.act new.act)))
    ::
        %populate
      ::  populate wallet with fake data for testing
      ::  will WIPE previous wallet state!!
      ::
      ::  TODO replace this with a request to an indexer,
      ::  which will provide all rice/grains associated with pubkey(s) in wallet
      =+  core=(from-seed:bip32 [64 seed.act])
      =+  pub=public-key:core
      =/  id-0  (fry-rice:smart pub 0x0 0 `@`'zigs')
      =/  fake-0
        :-  [0 0x0 'zigs']
        :*  id-0
            0x0  pub  0
            [%& `@`'zigs' [300.000.000 ~ `@ux`'zigs-metadata']]
        ==
      =/  id-1  (fry-rice:smart pub `@ux`'fungible' 1 `@`'zigs')
      =/  fake-1
        :-  [1 `@ux`'fungible' 'zigs']
        :*  id-1
            `@ux`'fungible'  pub  1
            [%& `@`'zigs' [100.000.000 ~ `@ux`'zigs-metadata']]
        ==
      =/  id-2  (fry-rice:smart pub `@ux`'fungible' 1 `@`'wETH')
      =/  fake-2
        :-  [1 `@ux`'fungible' 'wETH']
        :*  id-2
            `@ux`'fungible'  pub  1
            [%& `@`'wETH' [173.000 ~ `@ux`'wETH-metadata']]
        ==
      =/  zigs-metadata
        :*  name='Uqbar Tokens'
            symbol='ZIG'
            decimals=18
            supply=1.000.000.000.000.000.000.000.000
            cap=~
            mintable=%.n
            minters=~
            deployer=0x0
            salt=`@`'zigs'
        ==
      =/  weth-metadata
        :*  name='Wrapped Ether'
            symbol='wETH'
            decimals=18
            supply=9.000.000.000.000.000.000.000.000
            cap=~
            mintable=%.n
            minters=~
            deployer=0x1234.5678
            salt=`@`'wETH'
        ==
      :-  (create-asset-subscriptions ~[id-0 id-1 id-2] (need indexer.state))
      %=  state
        seed    [64 eny.bowl]
        keys    (malt ~[[pub private-key:core]])
        nodes   (malt ~[[0 ~zod] [1 ~zod] [2 ~zod]])
        nonces  (malt ~[[pub (malt ~[[0 0] [1 0] [2 0]])]])
        tokens  (malt ~[[pub (malt ~[[fake-1] [fake-2] [fake-0]])]])
        metadata-store  (malt ~[[`@ux`'zigs-metadata' zigs-metadata] [`@ux`'wETH-metadata' weth-metadata]])
      ==        
    ::
        %submit
      ::  submit a transaction
      ::  create an egg and sign it, then poke a sequencer
      ::
      ::  things to expose on frontend:
      ::  'from' address, contract 'to' address, town select, 
      ::  gas (rate & budget), transaction type (acquired from ABI..?)
      ::  
      =/  our-nonces     (~(gut by nonces.state) from.act ~)
      =/  nonce=@ud      (~(gut by our-nonces) town.act 0)
      =/  node=ship      (~(gut by nodes.state) town.act our.bowl)
      =/  =book  (~(got by tokens.state) from.act)
      =/  =caller:smart
        ::  TODO fix
        ?:  =(town.act 0)
          [from.act +(nonce) id:(~(got by book) [town.act 0x0 `@`'zigs'])]
        [from.act +(nonce) id:(~(got by book) [town.act `@ux`'fungible' `@`'zigs'])]
      ::  need to check transaction type and collect rice based on it
      ::  only supporting small subset of contract calls, for tokens and NFTs
      =/  formatted=[args=(unit *) our-grains=(set @ux) cont-grains=(set @ux)]
        ?-    -.args.act
            %give
          ::  TODO use block explorer to find rice if it exists and restructure this
          ::  to use known parameter to find other person's rice
          =/  metadata  (~(got by metadata-store.state) token.args.act)
          =/  our-account  (~(got by book) [town.act to.act salt.metadata])
          =/  their-account-id  (fry-rice:smart to.args.act `@ux`'fungible' town.act salt.metadata)
          :+  `[%give to.args.act `their-account-id amount.args.act]
            (silt ~[id.our-account])
          (silt ~[their-account-id])
        ::
          %become-validator  [`args.act ~ (silt ~[`@ux`'ziggurat'])]
          %stop-validating   [`args.act ~ (silt ~[`@ux`'ziggurat'])]
          %init  [`args.act ~ (silt ~[`@ux`'world'])]
          %join  [`args.act ~ (silt ~[`@ux`'world'])]
          %exit  [`args.act ~ (silt ~[`@ux`'world'])]
        ==
      =/  =yolk:smart    [caller args.formatted our-grains.formatted cont-grains.formatted]
      =/  signer         (~(got by keys.state) from.act)
      =/  sig            (ecdsa-raw-sign:secp256k1:secp:crypto (sham (jam yolk)) signer)
      =/  =egg:smart     [[caller sig to.act rate.gas.act bud.gas.act town.act] yolk]
      :_  state(nonces (~(put by nonces) from.act (~(put by our-nonces) town.act +(nonce))))
      :~  :*  %pass  /submit-tx
              %agent  [node ?:(=(0 town.act) %ziggurat %sequencer)]
              %poke  %zig-weave-poke
              !>([%forward (silt ~[egg])])
      ==  ==
    ==
  ++  create-asset-subscriptions
    |=  [ids=(list id:smart) indexer=ship]
    ^-  (list card)
    %+  turn  ids
    |=  =id:smart
    =-  [%pass - %agent [indexer %uqbar-indexer] %watch -]
    /grain/(scot %ux id)
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%grain @ ~]
    ::  update to a grain received
    ~&  >  "wallet: got a grain update"
    `this
  ==
::
++  on-arvo  on-arvo:def
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?.  =(%x -.path)  ~
  ::  TODO move JSON parsing stuff into a helper lib
  ?+    +.path  (on-peek:def path)
      [%accounts ~]
    =;  =json  ``json+!>(json)
    =,  enjs:format
    %-  pairs
    %+  turn  ~(tap by keys.state)
    |=  [pub=@ux priv=@ux]
    :-  (scot %ux pub)
    %-  pairs
    :~  ['pubkey' (tape (scow %ux pub))]
        ['privkey' (tape (scow %ux priv))]
        :-  'nonces'
        %-  pairs
        %+  turn  ~(tap by (~(gut by nonces.state) pub ~))
        |=  [town=@ud nonce=@ud]
        [(crip (scow %ud town)) (numb nonce)]
    ==
  ::
      [%account @ @ ~]
    ::  returns our account for the pubkey and town-id given
    ::  for validator & sequencer use, to execute mill
    =/  pub  (slav %ux i.t.t.path)
    =/  town-id  (slav %ud i.t.t.t.path)
    =/  nonce  (~(gut by (~(got by nonces.state) pub)) town-id 0)
    =/  zigs=id:smart
      (fry-rice:smart pub 0x0 town-id 'zigs')
    ``noun+!>(`account:smart`[pub nonce zigs])
  ::
      [%book ~]
    ::  return entire book map for wallet frontend
    =;  =json  ``json+!>(json)
    =,  enjs:format
    %-  pairs
    %+  turn  ~(tap by tokens.state)
    |=  [pub=@ux =book]
    :-  (scot %ux pub)
    %-  pairs
    %+  turn  ~(tap by book)
    |=  [* =grain:smart]
    ?.  ?=(%& -.germ.grain)  !!
    =/  data  ;;(token-account data.p.germ.grain)
    :-  (scot %ux id.grain)
    %-  pairs
    :~  ['id' (tape (scow %ux id.grain))]
        ['lord' (tape (scow %ux lord.grain))]
        ['holder' (tape (scow %ux holder.grain))]
        ['town' (numb town-id.grain)]
        ::  note: need to use 'token standard' here
        ::  to guarantee properly parsed data
        :-  'data'
        %-  pairs
        :~  ['balance' (numb balance.data)]
            ['metadata' (tape (scow %ux metadata.data))]
        ==
    ==
  ::
      [%token-metadata ~]
    ::  return entire metadata-store
    =;  =json  ``json+!>(json)
    =,  enjs:format
    %-  pairs
    %+  turn  ~(tap by metadata-store.state)
    |=  [id=@ux d=token-metadata]
    :-  (scot %ux id)
    %-  pairs
    :~  ['name' (tape (trip name.d))]
        ['symbol' (tape (trip symbol.d))]
        ['decimals' (numb decimals.d)]
        ['supply' (numb supply.d)]
        ['cap' (numb (fall cap.d 0))]
        ['mintable' [%b mintable.d]]
        ['deployer' (tape (scow %ux deployer.d))]
        ['salt' (tape (scow %ux salt.d))]
    ==
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
