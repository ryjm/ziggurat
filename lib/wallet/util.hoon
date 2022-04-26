/-  *uqbar-wallet, uqbar-indexer
=>  |%
    +$  card  card:agent:gall
    --
|%
++  tx-update-card
  |=  [status=@ud hash=@ux]
  ^-  card
  [%give %fact ~[/tx-updates] %zig-wallet-update !>([%tx-status status hash])]
::
++  create-id-subscriptions
  |=  [keys=(set @ux) indexer=ship]
  ^-  (list card)
  %+  turn
    ~(tap in keys)
  |=  k=@ux
  =-  [%pass - %agent [indexer %uqbar-indexer] %watch -]
  /id/(scot %ux k)
::
++  create-holder-subscriptions
  |=  [pubkeys=(set @ux) indexer=ship]
  ^-  (list card)
  %+  turn
    ~(tap in pubkeys)
  |=  k=@ux
  =-  [%pass - %agent [indexer %uqbar-indexer] %watch -]
  /holder/(scot %ux k)
::
++  create-asset-subscriptions
  |=  [tokens=(map @ux =book) indexer=ship]
  ^-  (list card)
  %+  turn
    ::  find every grain in all our books
    ^-  (list [=token-type grain:smart])
    %-  zing
    %+  turn  ~(tap by tokens)
    |=  [@ux =book]
    ~(val by book)
  |=  [=token-type =grain:smart]
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
::
++  indexer-update-to-books
  |=  [=update:uqbar-indexer our=@ux =metadata-store]
  ::  get most recent version of the grain
  ::  TODO replace this with a (way) more efficient strategy
  ::  preferably adding a type to indexer that only contains
  ::  most recent data
  =/  =book  *book
  ?.  ?=(%grain -.update)  book
  =/  grains-list  `(list [=town-location:uqbar-indexer =grain:smart])`~(tap in grains.update)
  |-  ^-  ^book
  ?~  grains-list  book
  =/  =grain:smart  grain.i.grains-list
  ::  currently only storing owned *rice*
  ?.  ?=(%& -.germ.grain)  $(grains-list t.grains-list)
  ::  determine type token/nft/unknown
  =/  =token-type
    ?~  stored=(~(get by metadata-store) salt.p.germ.grain)
      %unknown
    -.u.stored
  %=    $
      book
    %+  ~(put by book)
      [town-id.grain lord.grain salt.p.germ.grain]
    [token-type grain]
    ::
    grains-list  t.grains-list
  ==
::
++  find-new-metadata
  |=  [=book our=ship =metadata-store]
  =/  book=(list [[town=@ud lord=id:smart salt=@] [=token-type =grain:smart]])  ~(tap by book)
  ~&  "searching for metadata"
  |-  ^-  (list card)
  ?~  book  ~
  ?:  (~(has by metadata-store) salt.i.book)  $(book t.book)
  ::  if we don't know the type of an asset, we need to try and fit it to
  ::  a mold we know of. this is not great and should be eventually provided
  ::  from some central authority
  ?.  ?=(%& -.germ.grain.i.book)  $(book t.book)
  =*  data  data.p.germ.grain.i.book
  =/  tok  (mule |.(;;(token-account data)))
  ?:  ?=(%& -.tok)
    :_  $(book t.book)
    [%pass /find/(scot %u salt.i.book) %agent [our %wallet] %poke %zig-wallet-poke !>([%fetch-metadata metadata.p.tok %token])]
  =/  nft  (mule |.(;;(nft-account data)))
  ~&  >>>  nft
  ?:  ?=(%& -.nft)
    :_  $(book t.book)
    [%pass /find/(scot %u salt.i.book) %agent [our %wallet] %poke %zig-wallet-poke !>([%fetch-metadata metadata.p.nft %nft])]
  $(book t.book)
--