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
  |=  [=update:uqbar-indexer =metadata-store]
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
  ::  determine type token/nft/unknown
  ::  TODO: ..how do we do this better..
  =/  =token-type
    ?~  stored=(~(get by metadata-store) ;;(@ux -.data.p.germ.grain))
      %unknown
    token-type.u.stored 
  %=    $
      tokens
    %+  ~(put by tokens)
      holder.grain
    %+  ~(put by `book`(~(gut by tokens) holder.grain ~))
      [town-id.grain lord.grain salt.p.germ.grain]
    [token-type grain]
    ::
    grains-list  t.grains-list
  ==
--