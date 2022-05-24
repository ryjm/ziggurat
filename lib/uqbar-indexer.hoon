/-  ui=uqbar-indexer,
    zig=ziggurat
/+  smart=zig-sys-smart
::
|%
++  enjs
  =,  enjs:format
  |%
  ++  update
    |=  =update:ui
    ^-  json
    ?-    -.update
    ::
        %chunk
      %+  frond  %chunk
      %-  pairs
      :+  [%location (town-location location.update)]
        [%chunk (chunk chunk.update)]
      ~
    ::
        %egg
      (frond %egg (eggs eggs.update))
    ::
        %grain
      (frond %grain (grains grains.update))
    ::
        %hash
      %+  frond  %hash
      %-  pairs
      :+  [%egg (eggs eggs.update)]
        [%grain (grains grains.update)]
      ~
    ::
        %slot
      (frond %slot (slot slot.update))
    ::
    ==
  ::
  ++  town-location
    |=  =town-location:ui
    ^-  json
    %-  pairs
    :^    [%epoch-num (numb epoch-num.town-location)]
        [%block-num (numb block-num.town-location)]
      [%town-id (numb town-id.town-location)]
    ~
  ::
  ++  egg-location
    |=  =egg-location:ui
    ^-  json
    %-  pairs
    :~  [%epoch-num (numb epoch-num.egg-location)]
        [%block-num (numb block-num.egg-location)]
        [%town-id (numb town-id.egg-location)]
        [%egg-num (numb egg-num.egg-location)]
    ==
  ::
  ++  chunks
    |=  =chunks:zig
    ^-  json
    %-  pairs
    %+  turn  ~(tap by chunks)
    |=  [town-id=@ud c=chunk:zig]
    [(scot %ud town-id) (chunk c)]
  ::
  ++  chunk
    |=  =chunk:zig
    ^-  json
    %-  pairs
    :+  [%transactions (transactions -.chunk)]
      [%town (town +.chunk)]
    ~
  ::
  ++  transactions
    |=  transactions=(list [@ux egg:smart])
    ^-  json
    :-  %a
    %+  turn  transactions
    |=  [hash=@ux e=egg:smart]
    %-  pairs
    :+  [%hash %s (scot %ux hash)]
      [%egg (egg e)]
    ~
  ::
  ++  eggs
    |=  eggs=(map egg-id=id:smart [location=egg-location:ui =egg:smart])
    ^-  json
    %-  pairs
    %+  turn  ~(tap by eggs)
    |=  [=id:smart location=egg-location:ui e=egg:smart]
    :-  (scot %ux id)
    %-  pairs
    :+  [%location (egg-location location)]
      [%egg (egg e)]
    ~
  ::
  ++  egg
    |=  =egg:smart
    ^-  json
    %-  pairs
    :+  [%shell (shell p.egg)]
      [%yolk (yolk q.egg)]
    ~
  ::
  ++  shell
    |=  =shell:smart
    ^-  json
    ?>  ?=(account:smart from.shell)
    %-  pairs
    :~  [%from (account from.shell)]
        [%sig (signature sig.shell)]
        [%to %s (scot %ux to.shell)]
        [%rate (numb rate.shell)]
        [%budget (numb budget.shell)]
        [%town-id (numb town-id.shell)]
    ==
  ::
  ++  yolk
    |=  =yolk:smart
    ^-  json
    ?>  ?=(account:smart caller.yolk)
    %-  pairs
    :~  [%caller (account caller.yolk)]
        [%args ~]  :: TODO: rewrite when can mold
        [%my-grains (ids my-grains.yolk)]
        [%cont-grains (ids cont-grains.yolk)]
    ==
  ::
  ++  account
    |=  =account:smart
    ^-  json
    %-  pairs
    :^    [%id %s (scot %ux id.account)]
        [%nonce (numb nonce.account)]
      [%zigs (numb zigs.account)]
    ~
  ::
  ++  signature
    |=  =signature:zig
    ^-  json
    %-  pairs
    :^    [%hash %s (scot %ux p.signature)]
        [%ship %s (scot %p q.signature)]
      [%life (numb r.signature)]
    ~
  ::
  ++  ids
    |=  ids=(set id:smart)
    ^-  json
    :-  %a
    %+  turn  ~(tap in ids)
    |=  =id:smart
    [%s (scot %ux id)]
  ::
  ++  grains
    |=  grains=(map grain-id=id:smart [location=town-location:ui =grain:smart])
    ^-  json
    %-  pairs
    %+  turn  ~(tap by grains)
    |=  [=id:smart location=town-location:ui g=grain:smart]
    :-  (scot %ux id)
    %-  pairs
    :+  [%location (town-location location)]
      [%grain (grain g)]
    ~
  ::
  ++  grain
    |=  =grain:smart
    ^-  json
    %-  pairs
    :~  [%id %s (scot %ux id.grain)]
        [%lord %s (scot %ux lord.grain)]
        [%holder %s (scot %ux holder.grain)]
        [%town-id (numb town-id.grain)]
        [%germ (germ germ.grain)]
    ==
  ::
  ++  germ
    ::  TODO: rewrite when can get data/cont molds
    |=  =germ:smart
    ^-  json
    ?:  ?=(%& -.germ)
      %-  pairs
      :^    [%is-rice %b %&]
          [%salt (numb salt.p.germ)]
        [%data (numb 0)]
      ~
    %-  pairs
    :^    [%is-rice %b %|]
        [%cont ~]
      [%owns (ids owns.p.germ)]
    ~
  ::
  ++  slot
    |=  =slot:zig
    ^-  json
    %-  pairs
    :+  [%header (block-header p.slot)]
      [%block (block q.slot)]
    ~
  ::
  ++  block-header
    |=  =block-header:zig
    ^-  json
    %-  pairs
    :^    [%num (numb num.block-header)]
        :+  %prev-header-hash  %s
        (scot %ux prev-header-hash.block-header)
      [%data-hash %s (scot %ux data-hash.block-header)]
    ~
  ::
  ++  block
    |=  block=(unit block:zig)
    ^-  json
    ?~  block  ~
    %-  pairs
    :+  [%signature (signature p.u.block)]
      [%chunks (chunks q.u.block)]
    ~
  ::
  ++  town
    |=  =town:smart
    ^-  json
    %-  pairs
    :+  [%granary (granary p.town)]
      [%populace (populace q.town)]
    ~
  ::
  ++  granary
    |=  =granary:smart
    ^-  json
    %-  pairs
    %+  turn  ~(tap by granary)
    |=  [=id:smart g=grain:smart]
    [(scot %ux id) (grain g)]
  ::
  ++  populace
    |=  =populace:smart
    ^-  json
    %-  pairs
    %+  turn  ~(tap by populace)
    |=  [=id:smart nonce=@ud]
    [(scot %ux id) (numb nonce)]
  ::
  ++  headers
    |=  headers=(list [epoch-num=@ud bh=block-header:zig])
    ^-  json
    %-  pairs
    :_  ~
    :-  %headers
    :-  %a
    %+  turn  headers
    |=  [epoch-num=@ud bh=block-header:zig]
    %-  pairs
    :+  [%epoch-num (numb epoch-num)]
      [%block-header (block-header bh)]
    ~
  ::
  --
++  dejs
  =,  dejs:format
  |%
  ++  update
    |=  jon=json
    ^-  update:ui
    %.  jon
    %-  of
    :~  [%chunk (ot ~[[%location town-location] [%chunk chunk]])]
        [%egg eggs]
        [%grain grains]
        [%hash (ot ~[[%egg eggs] [%grain grains]])]
        [%slot slot]
    ==
  ::
  ++  town-location
    |=  jon=json
    ^-  town-location:ui
    %.  jon
    %-  ot
    :^    [%epoch-num ni]
        [%block-num ni]
      [%town-id ni]
    ~
  ::
  ++  egg-location
    |=  jon=json
    ^-  egg-location:ui
    %.  jon
    %-  ot
    :~  [%epoch-num ni]
        [%block-num ni]
        [%town-id ni]
        [%egg-num ni]
    ==
  ::
  ++  chunks
    |=  jon=json
    ^-  chunks:zig
    %.  jon
    (op dem chunk)
  ::
  ++  chunk
    |=  jon=json
    ^-  chunk:zig
    %.  jon
    %-  ot
    :+  [%transactions transactions]
      [%town town]
    ~
  ::
  ++  transactions
    |=  jon=json
    ^-  (list [@ux egg:smart])
    %.  jon
    %-  ar
    (at ~[nu egg])
  ::
  ++  eggs
    |=  jon=json
    ^-  (map egg-id=id:smart [location=egg-location:ui =egg:smart])
    %.  jon
    %+  op  hex
    %-  ot
    :+  [%location egg-location]
      [%egg egg]
    ~
  ::
  ++  egg
    |=  jon=json
    ^-  egg:smart
    %.  jon
    %-  ot
    :+  [%shell shell]
      [%yolk yolk]
    ~
  ::
  ++  shell
    |=  jon=json
    ^-  shell:smart
    %.  jon
    %-  ot
    :~  [%from account]  :: always account?
        [%sig signature]
        [%to nu]
        [%rate ni]
        [%budget ni]
        [%town-id ni]
    ==
  ::
  ++  yolk
    |=  jon=json
    ^-  yolk:smart
    :+  %.  jon
        %-  ot
        :-  [%caller account]  :: always account?
        ~
      ~    :: TODO: rewrite when can mold args
    %.  jon
    %-  ot
    :+  [%my-grains ids]
      [%cont-grains ids]
    ~
  ::
  ++  account
    |=  jon=json
    ^-  account:smart
    %.  jon
    %-  ot
    :^    [%id nu]
        [%nonce ni]
      [%zigs ni]
    ~
  ::
  ++  signature
    |=  jon=json
    ^-  signature:zig
    %.  jon
    %-  ot
    :^    [%hash nu]
        [%ship nu]
      [%life ni]
    ~
  ::
  ++  ids
    |=  jon=json
    ^-  (set id:smart)
    %.  jon
    (as nu)
  ::
  ++  grains
    |=  jon=json
    ^-  (map grain-id=id:smart [location=town-location:ui =grain:smart])
    %.  jon
    %+  op  hex
    %-  ot
    :+  [%location town-location]
      [%grain grain]
    ~
  ::
  ++  grain
    |=  jon=json
    ^-  grain:smart
    %.  jon
    %-  ot
    :~  [%id nu]
        [%lord nu]
        [%holder nu]
        [%town-id ni]
        [%germ germ]
    ==
  ::
  ++  germ
    ::  TODO: rewrite when can get data/cont molds
    |=  jon=json
    ^-  germ:smart
    ?>  ?=(%o -.jon)
    =/  is-rice  (~(got by p.jon) %is-rice)
    ?<  ?=(~ is-rice)
    ?>  ?=(%b -.is-rice)
    ?:  p.is-rice
      :+  %&
        %.  jon
        %-  ot
        :-  [%salt ni]
        ~
      `*`0
    ::  is wheat
    :+  %|
      ~
    %.  jon
    %-  ot
    :-  [%owns ids]
    ~
  ::
  ++  slot
    |=  jon=json
    ^-  slot:zig
    %.  jon
    %-  ot
    :+  [%header block-header]
      [%block block]
    ~
  ::
  ++  block-header
    |=  jon=json
    ^-  block-header:zig
    %.  jon
    %-  ot
    :^    [%num ni]
        [%prev-header-hash nu]
      [%data-hash nu]
    ~
  ::
  ++  block
    |=  jon=json
    ^-  (unit block:zig)
    ?~  jon  ~
    :-  ~
    %.  jon
    %-  ot
    :+  [%signature signature]
      [%chunks chunks]
    ~
  ::
  ++  town
    |=  jon=json
    ^-  town:smart
    %.  jon
    %-  ot
    :+  [%granary granary]
      [%populace populace]
    ~
  ::
  ++  granary
    |=  jon=json
    ^-  granary:smart
    %.  jon
    (op hex grain)
  ::
  ++  populace
    |=  jon=json
    ^-  populace:smart
    %.  jon
    (op hex ni)
  ::
  --
--
