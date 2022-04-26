::  wallet [uqbar-dao]
::
::  Uqbar wallet agent. Stores private key and facilitates signing
::  transactions, holding nonce values, and keeping track of owned data.
::
/-  uqbar-indexer
/+  *ziggurat, *wallet-util, default-agent, dbug, verb, bip32, bip39
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      seed=[mnem=tape pass=tape]
      keys=(map pub=@ux priv=@ux)  ::  keys created from master seed
      nodes=(map town=@ud =ship)  ::  the sequencer you submit txs to for each town
      nonces=(map pub=@ux (map town=@ud nonce=@ud))
      tokens=(map pub=@ux =book)
      =transaction-store
      =metadata-store
      =type-store
      indexer=(unit ship)
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
++  on-init  `this(state [%0 ["" ""] ~ ~ ~ ~ ~ ~ ~ `our.bowl])
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
  ?+    path  !!
      [%book-updates ~]
    ?>  =(src.bowl our.bowl)
    ::  send frontend updates along this path
    :_  this
    ~[[%give %fact ~ %zig-wallet-update !>([%new-book tokens.state])]]
  ::
      [%tx-updates ~]
    ?>  =(src.bowl our.bowl)
    ::  provide updates about submitted transactions
    `this
  ==
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
      `state(seed [mnemonic.act password.act], keys (malt ~[[public-key:core private-key:core]]))
    ::
        %create
      ::  will lose seed in current wallet, should warn on frontend!
      ::  creates a new wallet from entropy derived on-urbit
      ::  TODO set up password here, currently bad
      =+  mnem=(from-entropy:bip39 [32 eny.bowl])
      =+  core=(from-seed:bip32 [64 (to-seed:bip39 mnem password.act)])
      ::  TODO look on block explorer for pubkeys associated with this seed!
      `state(seed [mnem password.act], keys (malt ~[[public-key:core private-key:core]]))
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
      :_  state(indexer `ship.act)
      %+  weld  (clear-asset-subscriptions wex.bowl)
      (create-asset-subscriptions tokens.state ship.act)
    ::
        %set-nonce  ::  for testing
      =+  acc=(~(got by nonces.state) address.act)
      `state(nonces (~(put by nonces) address.act (~(put by acc) town.act new.act)))
    ::
        %fetch-our-rice
      ::  temporary until we can subscribe to indexer by-holder
      =/  our-grains
        .^((unit update:uqbar-indexer) %gx /(scot %p our.bowl)/uqbar-indexer/(scot %da now.bowl)/holder/(scot %ux pubkey.act)/noun)
      =+  ?~(our-grains ~ (indexer-update-to-books u.our-grains type-store.state))
      :_  state(tokens -)
      ~[[%give %fact ~[/book-updates] %zig-wallet-update !>([%new-book -])]]
    ::
        %populate
      ::  populate wallet with fake data for testing
      ::  will WIPE previous wallet state!!
      ::
      =+  mnem=(from-entropy:bip39 [32 seed.act])
      =+  core=(from-seed:bip32 [64 (to-seed:bip39 mnem "")])
      =+  pub=public-key:core
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
      =/  keys  (malt ~[[pub private-key:core]])
      :-  ;:  welp
              (create-holder-subscriptions (silt ~[pub]) (need indexer.state))
              (create-id-subscriptions ~(key by keys) (need indexer.state))
          ==
      %=  state
        seed    [mnem ""]
        keys    keys
        nodes   (malt ~[[0 ~zod] [1 ~zod] [2 ~zod]])
        nonces  (malt ~[[pub (malt ~[[0 0] [1 0] [2 0]])]])
        tokens  ~
        transaction-store  ~
        metadata-store  (malt ~[[`@ux`'zigs-metadata' [%token zigs-metadata]]])
        type-store  (malt ~[[`@`'zigs' `@tas`%token] [`@`'nftsalt' `@tas`%nft]])
      ==
    ::
        %submit-custom
      =/  our-nonces     (~(gut by nonces.state) from.act ~)
      =/  nonce=@ud      (~(gut by our-nonces) town.act 0)
      =/  node=ship      (~(gut by nodes.state) town.act our.bowl)
      =/  =caller:smart
        [from.act +(nonce) (fry-rice:smart from.act `@ux`'zigs-contract' town.act `@`'zigs')]
      ::  submit a transaction, with frontend-defined everything
      =/  =yolk:smart   [caller `(ream args.act) my-grains.act cont-grains.act]          
      =/  =egg:smart
        :_  yolk
        :*  caller
            %+  ecdsa-raw-sign:secp256k1:secp:crypto
              (sham (jam yolk))
            (~(got by keys.state) from.act)
            to.act
            rate.gas.act
            bud.gas.act
            town.act
            0
        ==
      =/  egg-hash=@ux  (shax (jam egg))
      =/  our-txs
        ?~  o=(~(get by transaction-store) from.act)
          [(malt ~[[egg-hash [egg [%custom args.act]]]]) ~]
        u.o(sent (~(put by sent.u.o) egg-hash [egg [%custom args.act]]))
      ~&  >>  "wallet: submitting tx"
      :_  %=  state
            transaction-store  (~(put by transaction-store) from.act our-txs)
            nonces  (~(put by nonces) from.act (~(put by our-nonces) town.act +(nonce)))
          ==
      :~  (tx-update-card status=100 egg-hash)
          :*  %pass  /submit-tx/(scot %ux egg-hash)
              %agent  [node ?:(=(0 town.act) %ziggurat %sequencer)]
              %poke  %zig-weave-poke
              !>([%forward (silt ~[egg])])
          ==
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
        [from.act +(nonce) (fry-rice:smart from.act `@ux`'zigs-contract' town.act `@`'zigs')]
      ::  need to check transaction type and collect rice based on it
      ::  only supporting small subset of contract calls, for tokens and NFTs
      =/  formatted=[args=(unit *) our-grains=(set @ux) cont-grains=(set @ux)]
        ?-    -.args.act
            %give
          ~|  "wallet can't find metadata for that token!"
          =/  metadata  (~(got by metadata-store.state) token.args.act)
          ~|  "wallet can't find our zigs account for that town!"
          =/  our-account=grain:smart  +:(~(got by book) [town.act to.act salt.metadata])
          ::  TODO use block explorer to find rice if it exists and restructure this
          ::  to use known parameter to find other person's rice
          =/  their-account-id  (fry-rice:smart to.args.act to.act town.act salt.metadata)
          :+  ?:  =(to.act `@ux`'zigs-contract')  ::  zigs special case
                `[%give to.args.act `their-account-id amount.args.act bud.gas.act]
              `[%give to.args.act `their-account-id amount.args.act]
            (silt ~[id.our-account])
          (silt ~[their-account-id])
        ::  ONLT difference between this and token give is amount vs. item-id.
        ::  therefore should figure out way to just unify them.
            %give-nft
          ~|  "wallet can't find metadata for that token!"
          =/  metadata  (~(got by metadata-store.state) token.args.act)
          ~|  "wallet can't find our zigs account for that town!"
          =/  our-account=grain:smart  +:(~(got by book) [town.act to.act salt.metadata])
          ::  TODO use block explorer to find rice if it exists and restructure this
          ::  to use known parameter to find other person's rice
          =/  their-account-id  (fry-rice:smart to.args.act to.act town.act salt.metadata)
          :+  `[%give to.args.act `their-account-id item-id.args.act]
            (silt ~[id.our-account])
          (silt ~[their-account-id])
        ::
          %become-validator  [`args.act ~ (silt ~[`@ux`'ziggurat'])]
          %stop-validating   [`args.act ~ (silt ~[`@ux`'ziggurat'])]
          %init  [`args.act ~ (silt ~[`@ux`'world'])]
          %join  [`args.act ~ (silt ~[`@ux`'world'])]
          %exit  [`args.act ~ (silt ~[`@ux`'world'])]
          %custom  !!
        ==
      =/  =yolk:smart   [caller args.formatted our-grains.formatted cont-grains.formatted]
      =/  signer        (~(got by keys.state) from.act)
      =/  sig           (ecdsa-raw-sign:secp256k1:secp:crypto (sham (jam yolk)) signer)
      =/  =egg:smart    [[caller sig to.act rate.gas.act bud.gas.act town.act 0] yolk]
      =/  egg-hash=@ux  (shax (jam egg))
      =/  our-txs
        ?~  o=(~(get by transaction-store) from.act)
          [(malt ~[[egg-hash [egg args.act]]]) ~]
        u.o(sent (~(put by sent.u.o) egg-hash [egg args.act]))
      ~&  >>  "wallet: submitting tx"
      :_  %=  state
            transaction-store  (~(put by transaction-store) from.act our-txs)
            nonces  (~(put by nonces) from.act (~(put by our-nonces) town.act +(nonce)))
          ==
      :~  (tx-update-card status=100 egg-hash)
          :*  %pass  /submit-tx/(scot %ux egg-hash)
              %agent  [node ?:(=(0 town.act) %ziggurat %sequencer)]
              %poke  %zig-weave-poke
              !>([%forward (silt ~[egg])])
          ==
      ==
    ==
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%submit-tx @ ~]
    ::  check to see if our tx was received by sequencer
    =/  hash=@ux  (slav %ux i.t.wire)
    ?:  ?=(%poke-ack -.sign)
      ?~  p.sign
        ::  got it
        ~&  >>  "wallet: tx was received by sequencer"
        ~[(tx-update-card status=101 hash)]^this
      ::  failed
      ~&  >>>  "wallet: tx was rejected by sequencer"
      ~[(tx-update-card status=103 hash)]^this
    `this
  ::
      [%holder @ ~]
    ?:  ?=(%watch-ack -.sign)  (on-agent:def wire sign)
    ?.  ?=(%fact -.sign)       (on-agent:def wire sign)
    ?.  ?=(%uqbar-indexer-update p.cage.sign)  (on-agent:def wire sign)
    =/  update  !<(update:uqbar-indexer q.cage.sign)
    =+  (indexer-update-to-books update type-store.state)
    :_  this(tokens -)
    ~[[%give %fact ~[/book-updates] %zig-wallet-update !>([%new-book -])]]
  ::
      [%id @ ~]
    ::  update to a tracked account
    ?:  ?=(%watch-ack -.sign)  (on-agent:def wire sign)
    ?.  ?=(%fact -.sign)       (on-agent:def wire sign)
    ?.  ?=(%uqbar-indexer-update p.cage.sign)  (on-agent:def wire sign)
    =/  update  !<(update:uqbar-indexer q.cage.sign)
    ::  ~&  >>>  "wallet: id update: {<update>}"
    ?.  ?=(%egg -.update)  `this
    ::  this will give us updates to transactions we send
    ::
    =/  our-id=@ux  (slav %ux i.t.wire)
    =+  our-txs=(~(gut by transaction-store.state) our-id [sent=~ received=~])
    =/  eggs=(list [@ux =egg:smart])
      %~  tap  in
      ^-  (set [@ux =egg:smart])
      %-  ~(run in eggs.update)
      |=  [=egg-location:uqbar-indexer =egg:smart]
      [`@ux`(shax (jam egg)) egg]
    =^  tx-status-cards=(list card)  our-txs
      %^  spin  eggs  our-txs
      |=  [[hash=@ux =egg:smart] _our-txs]
      ?.  =(our-id (pin:smart from.p.egg))
        ::  ~&  >>  our-id
        ::  ~&  >  from.p.egg
        ::  this is a transaction sent to us / not from us
        ^-  [card _our-txs]
        :-  (tx-update-card status=105 hash)
        our-txs(received (~(put by received.our-txs) hash egg))
      ::  tx sent by us, update status code and send to frontend
      ::  following error code spec in smart.hoon, eventually
      ^-  [card _our-txs]
      :-  (tx-update-card status.p.egg hash)
      %=    our-txs
          sent
        %+  ~(jab by sent.our-txs)  hash
        |=([p=egg:smart q=supported-args] [p(status.p status.p.egg) q])
      ==
    :_  this(transaction-store (~(put by transaction-store) our-id our-txs))
    %+  snoc  tx-status-cards
    [%pass /fetch-rice %agent [our.bowl %wallet] %poke %zig-wallet-poke !>([%fetch-our-rice our-id])]
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
      [%seed ~]
    =;  =json  ``json+!>(json)
    =,  enjs:format
    %-  pairs
    :~  ['mnemonic' (tape mnem.seed.state)]
        ['password' (tape pass.seed.state)]
    ==
  ::
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
    =+  (fry-rice:smart pub `@ux`'zigs-contract' town-id `@`'zigs')
    ``noun+!>(`account:smart`[pub nonce -])
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
    |=  [* [=token-type =grain:smart]]
    ?.  ?=(%& -.germ.grain)  !!
    :-  (scot %ux id.grain)
    %-  pairs
    :~  ['id' (tape (scow %ux id.grain))]
        ['lord' (tape (scow %ux lord.grain))]
        ['holder' (tape (scow %ux holder.grain))]
        ['town' (numb town-id.grain)]
        ['token_type' (tape (scow %tas token-type))]
        :-  'data'
        %-  pairs
        ?+    token-type  ~[['unknown_data_structure' (tape "?")]]
            %token
          =+  ;;(token-account data.p.germ.grain)
          :~  ['balance' (numb balance.-)]
              ['metadata' (tape (scow %ux metadata.-))]
          ==
        ::
            %nft
          =+  ;;(nft-account data.p.germ.grain)
          :~  ['metadata' (tape (scow %ux metadata.-))]
              :-  'items'
              %-  pairs
              %+  turn  ~(tap by items.-)
              |=  [id=@ud =item]
              :-  (scot %ud id)
              %-  pairs
              :~  ['desc' (tape desc.item)]
                  ['URI' (tape uri.item)]
              ==
          ==
        ==
    ==
  ::
      [%token-metadata ~]
    ::  return entire metadata-store
    =;  =json  ``json+!>(json)
    =,  enjs:format
    %-  pairs
    %+  turn  ~(tap by metadata-store.state)
    |=  [id=@ux [=token-type d=token-metadata]]
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
  ::
      [%transactions @ ~]
    ::  return transaction store for given pubkey
    =/  pub  (slav %ux i.t.t.path)
    =/  our-txs=(map @ux [=egg:smart args=supported-args])
      -:(~(gut by transaction-store.state) pub [~ ~])
    =;  =json  ``json+!>(json)
    =,  enjs:format
    %-  pairs
    %+  turn  ~(tap by our-txs)
    |=  [hash=@ux [t=egg:smart args=supported-args]]
    ?.  ?=(account:smart from.p.t)  !!
    :-  (scot %ux hash)
    %-  pairs
    :~  ['from' (tape (scow %ux id.from.p.t))]
        ['nonce' (numb nonce.from.p.t)]
        ['to' (tape (scow %ux to.p.t))]
        ['rate' (numb rate.p.t)]
        ['budget' (numb budget.p.t)]
        ['town' (numb town-id.p.t)]
        ['status' (numb status.p.t)]  ::  just 0 for now
        :-  'args'
        %-  frond
        :-  (scot %tas -.args)
        %-  pairs
        ?-    -.args
            %give
          :~  ['token' (tape (scow %ux token.args))]
              ['to' (tape (scow %ux to.args))]
              ['amount' (numb amount.args)]
          ==
            %give-nft
          :~  ['token' (tape (scow %ux token.args))]
              ['to' (tape (scow %ux to.args))]
              ['item-id' (numb item-id.args)]
          ==
        ::
            ?(%become-validator %stop-validating)
          ~[['signature' (tape (scow %p q.signature.args))]]
        ::
            ?(%init %join %exit)
          ~[['signature' (tape (scow %p q.signature.args))] ['town' (numb town.args)]]
        ::
            %custom
          ~[['args' (tape (scow %t args.args))]]
        ==
    ==
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
