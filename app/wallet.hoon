::  wallet [uqbar-dao]
::
::  Uqbar wallet agent. Stores private key and facilitates signing
::  transactions, holding nonce values, and keeping track of owned data.
::
/-  uqbar-indexer
/+  *ziggurat, default-agent, dbug, verb, bip32, bip39
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      seed=byts  ::  encrypted with password
      keys=(map pub=@ux priv=@ux)  ::  keys created from master seed
      nodes=(map town=@ud =ship)  ::  the sequencer you submit txs to for each town
      nonces=(map pub=@ux (map town=@ud nonce=@ud))
      tokens=(map pub=@ux =book)
      metadata-store=(map =id:smart token-metadata)
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
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?.  ?=([%book-updates ~] path)  !!
    ?>  =(src.bowl our.bowl)
    ::  send frontend updates along this path
    :_  this
    ~[[%give %fact ~ %zig-wallet-update !>([%new-book tokens.state])]]
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
      =+  ?~(our-grains ~ (indexer-update-to-books u.our-grains))
      :_  state(tokens -)
      %+  weld  (clear-asset-subscriptions wex.bowl)
      (create-asset-subscriptions - (need indexer.state))
    ::
        %populate
      ::  populate wallet with fake data for testing
      ::  will WIPE previous wallet state!!
      ::
      ::  TODO replace this with a request to an indexer,
      ::  which will provide all rice/grains associated with pubkey(s) in wallet
      =+  core=(from-seed:bip32 [64 seed.act])
      =+  pub=public-key:core
      ::  =/  id-0  (fry-rice:smart pub `@ux`'zigs-contract' 0 `@`'zigs')
      ::  =/  id-1  (fry-rice:smart pub `@ux`'zigs-contract' 1 `@`'zigs')
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
      ::  get grains we hold from indexer (must run on our ship for now)
      =/  our-grains
        .^((unit update:uqbar-indexer) %gx /(scot %p our.bowl)/uqbar-indexer/(scot %da now.bowl)/holder/(scot %ux pub)/noun)
      ::  convert from update to book
      =+  ?~(our-grains ~ (indexer-update-to-books u.our-grains))
      :-  %+  weld  (clear-asset-subscriptions wex.bowl)
          (create-asset-subscriptions - (need indexer.state))
      %=  state
        seed    [64 eny.bowl]
        keys    (malt ~[[pub private-key:core]])
        nodes   (malt ~[[0 ~zod] [1 ~zod] [2 ~zod]])
        nonces  (malt ~[[pub (malt ~[[0 0] [1 0] [2 0]])]])
        tokens  -
        metadata-store  (malt ~[[`@ux`'zigs-metadata' zigs-metadata]])
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
          =/  metadata  (~(got by metadata-store.state) token.args.act)
          =/  our-account  (~(got by book) [town.act to.act salt.metadata])
          ::  TODO use block explorer to find rice if it exists and restructure this
          ::  to use known parameter to find other person's rice
          =/  their-account-id  (fry-rice:smart to.args.act to.act town.act salt.metadata)
          :+  ?:  =(to.act `@ux`'zigs-contract')  ::  zigs special case
                `[%give to.args.act `their-account-id amount.args.act bud.gas.act]
              `[%give to.args.act `their-account-id amount.args.act]
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
  ::
  ++  indexer-update-to-books
    |=  =update:uqbar-indexer
    ::  get most recent version of the grain
    ::  TODO replace this with a (way) more efficient strategy
    ::  preferably adding a type to indexer that only contains
    ::  most recent data
    =/  tokens  *(map @ =book)
    ?.  ?=(%grain -.update)  tokens
    =/  grains-list  `(list [=town-location:uqbar-indexer =grain:smart])`~(tap in grains.update)
    ^-  (map @ =book)
    |-
    ?~  grains-list  tokens
    =/  =grain:smart  grain.i.grains-list
    ::  currently only storing owned *rice*
    ?.  ?=(%& -.germ.grain)  $(grains-list t.grains-list)
    =/  =book  (~(gut by tokens) holder.grain ~)
    %=  $
      tokens  (~(put by tokens) holder.grain (~(put by book) [town-id.grain lord.grain salt.p.germ.grain] grain))
      grains-list  t.grains-list
    ==
  ::
  ++  create-asset-subscriptions
    |=  [tokens=(map @ux =book) indexer=ship]
    ^-  (list card)
    %+  turn
      ::  find every grain in all our books
      ^-  (list grain:smart)
      %-  zing
      %+  turn  ~(tap by tokens)
      |=  [@ux =book]
      ~(val by book)
    |=  =grain:smart
    =-  [%pass - %agent [indexer %uqbar-indexer] %watch -]
    /grain/(scot %ux id.grain)
  ::
  ++  clear-asset-subscriptions
    |=  wex=boat:gall
    ^-  (list card)
    %+  murn  ~(tap by wex)
    |=  [[=wire =ship =term] *]
    ^-  (unit card)
    ?.  ?=([%grain *] wire)  ~
    `[%pass wire %agent [ship term] %leave ~]
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%grain @ ~]
    ::  update to a grain received
    ~&  >  "wallet: got a grain update"
    ?:  ?=(%watch-ack -.sign)  (on-agent:def wire sign)
    ?.  ?=(%fact -.sign)       (on-agent:def wire sign)
    ?.  ?=(%uqbar-indexer-update p.cage.sign)  (on-agent:def wire sign)
    =/  update  !<(update:uqbar-indexer q.cage.sign)
    ?.  ?=(%grain -.update)  `this
    =/  new=grain:smart  +.-:~(tap in grains.update)
    ?.  ?=(%& -.germ.new)
      ::  stop watching this grain
      ~[[%pass wire %agent [(need indexer.this) %uqbar-indexer] %leave ~]]^this
    ?~  book=(~(get by tokens.this) holder.new)
      ::  no longer tracking holder, stop watching this grain
      ~[[%pass wire %agent [(need indexer.this) %uqbar-indexer] %leave ~]]^this
    =.  u.book
      (~(put by `^book`u.book) [town-id.new lord.new salt.p.germ.new] new)
    ::  place new grain state in our personal tracker,
    ::  and inform frontend of change
    :_  this(tokens (~(put by tokens) holder.new u.book))
    ~[[%give %fact ~[/book-updates] %zig-wallet-update !>([%new-book tokens.state])]]
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
