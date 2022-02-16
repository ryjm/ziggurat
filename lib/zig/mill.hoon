/+  *bink, *zig-sys-smart
|_  [validator-id=@ux =land now=time]
::
::  +mill-all: mills all eggs in mempool
::
++  mill-all
  |=  [helix-id=@ud =town mempool=(list egg)]
  =/  pending
    %+  sort  mempool
    |=  [a=egg b=egg]
    (gth rate.stamp.p.a rate.stamp.p.b)
  =|  result=(list [@ux egg])
          ::  'chunk' def
  =/  fee-bundle=(unit yolk)
    :^  ~  [validator-id +((~(got by q.town) validator-id))]
      *(set id)
    [~ %send *(map id (map id @ud))]
  =/  town-and-fee-bundle  [town fee-bundle]
  |-  ^-  [(list [@ux egg]) town]
  ?~  pending
    =.  town        -.town-and-fee-bundle
    =.  fee-bundle  +.town-and-fee-bundle
    ?~  fee-bundle  [result town]
    =/  fee-egg=egg  (~(invoice tax town) helix-id u.fee-bundle)
    =/  gan=granary  (~(pay tax town) fee-egg)
    :+  [[`@ux`(shax (jam fee-egg)) fee-egg] result]
      gan
    ?:  ?=(id caller.u.fee-bundle)  q.town
    (~(put by q.town) validator-id nonce.caller.u.fee-bundle)
  %_  $
    pending            t.pending
    result             [[`@ux`(shax (jam i.pending)) i.pending] result]
    town-and-fee-bundle  (mill helix-id town i.pending fee-bundle)
  ==
::  +mill: processes a single egg and returns updated town
::
++  mill
  |=  [town-id=@ud =town =egg fee-bundle=(unit yolk)]
  ^-  [town (unit egg)]
  ?.  ?=(user from.p.egg)  [town ~]
  ?~  curr-nonce=(~(get by q.town) id.from.p.egg)
    [town ~]  ::  missing user
  ?.  =(nonce.from.p.egg +(u.curr-nonce))
    [town ~]  ::  bad nonce
  ?.  (~(audit tax town) egg)
    [town ~]  ::  can't afford gas
  =+  [gan rem]=(~(work farm p.town) egg)
  =/  fee=@ud   (sub budget.stamp.p.egg rem)
  ?~  gan  [town ~]
  =.  q.town  (~(put by q.town) id.from.p.egg nonce.from.p.egg)
  =+  [gan-out fee-bundle-out]=(~(note-or-pay tax [u.gan q.town]) egg fee town-id fee-bundle)
  :-  :-  gan-out
    ?~  fee-bundle
      ?~  fee-bundle-out  q.town
      ?:  ?=(id caller.u.fee-bundle-out)  q.town
      %+  %~  put  by  q.town
        id.caller.u.fee-bundle-out
      nonce.caller.u.fee-bundle-out
    q.town
  fee-bundle-out
::
::  +tax: manage payment for contract execution in zigs
::
++  tax
  |_  =town
  ::  +audit: evaluate whether a caller can afford gas
  ++  audit
    |=  =egg
    ^-  ?
    =/  grains=(map id grain)  (fetch egg)
    ?~  fee-rice=(~(get by grains) fee.stamp.p.egg)  %.n
    ?.  ?=(%& -.germ.u.fee-rice)                     %.n
    ?.  =(zigs-wheat-id lord.u.fee-rice)             %.n
    =*  bal  data.p.germ.u.fee-rice
    ?.  ?=(@ud bal)                                  %.n
    (gth bal (mul rate.stamp.p.egg budget.stamp.p.egg))
  ::  +fetch: get grains for fee rice
  ++  fetch
    |=  =egg
    ^-  (map id grain)
    =|  =yolk
    =:  caller.yolk     from.p.egg
        args.yolk       ~
        grain-ids.yolk  (silt ~[fee.stamp.p.egg])
    ==
    =/  =scramble
      (~(fertilize farm p.town) yolk)
    grains.scramble
  ::  +note-or-pay: notes or pays fee as appropriate
  ++  note-or-pay
    |=  [=egg fee=@ud town-id=@ud fee-bundle=(unit yolk)]
    ^-  [granary (unit yolk)]
    ?~  fee-bundle
      =/  fee-egg=egg
        (invoice town-id (tally egg fee ~))
      [(pay fee-egg) fee-bundle]
    [p.town (note egg fee fee-bundle)]
  ::  +note: store gas fee for payment in accumulated tx
  ++  note
    |=  [=egg fee=@ud fee-bundle=(unit yolk)]
    ^-  (unit yolk)
    ?~  fee-bundle  ~
    =/  from=id
      ?:  ?=(id from.p.egg)  from.p.egg
      id.from.p.egg
    ::  bump nonce of fee-bundle if this tx was by validator
    =.  caller.u.fee-bundle
      ?:  ?=(id caller.u.fee-bundle)
        caller.u.fee-bundle
      :-  id.caller.u.fee-bundle
      ?.  =(validator-id from)
        nonce.caller.u.fee-bundle
      +(nonce.caller.u.fee-bundle)
    [~ (tally egg fee fee-bundle)]
  ::  +invoice: create egg for payment of fee
  ++  invoice
    |=  [town-id=@ud fee-bundle=yolk]
    ^-  egg
    =|  =shell
    =:  from.shell     caller.fee-bundle
        to.shell       zigs-wheat-id
        stamp.shell    *stamp  ::  unused placeholder
        town-id.shell  town-id
    ==
    [p=shell q=fee-bundle]
  ::  +tally: create yolk for payment of fee
  ++  tally
    |=  [=egg fee=@ud fee-bundle=(unit yolk)]
    ^-  yolk
    =/  grains=(map id grain)  (fetch egg)
    =/  from=id
      ?:  ?=(id from.p.egg)  from.p.egg
      id.from.p.egg
    =/  from-grain  (~(got by grains) from)
    ?>  ?=(%& -.germ.from-grain)
    =*  bal  data.p.germ.from-grain
    ?>  ?=(@ud bal)
    =/  transactions=(map id (map id @ud))
      %+  %~  put  by  *(map id (map id @ud))  from
      %-  %~  gas  by  *(map id @ud)
      ~[[validator-id fee] [change.stamp.p.egg (sub bal fee)]]
    =/  grain-ids=(set id)  (silt ~[from])
    ?~  fee-bundle
      :+  [validator-id +((~(got by q.town) validator-id))]
        [~ %send transactions]
      grain-ids
    :+  caller.u.fee-bundle
      :+  ~  %send
      ?~  args.u.fee-bundle  transactions
      =/  old-tx
        ;;((map id (map id @ud)) +.u.args.u.fee-bundle)
      ?~  (~(get by old-tx) from)
        (~(uni by old-tx) transactions)
      %+  %~  put  by  old-tx  from
      %-  %~  uni  by  (~(got by old-tx) from)
      (~(got by transactions) from)
    (~(uni in grain-ids.u.fee-bundle) grain-ids)
  ::  +pay: extract gas fee from caller's zigs balance
  ++  pay
    |=  fees=egg
    ^-  granary
    =+  [gan rem]=(~(work farm p.town) fees)
    ?~  gan  !!
    u.gan
  --
::
::  +farm: execute an egg to a contract within a wheat
::
++  farm
  |_  =granary
  ::
  ++  work
    |=  =egg
    ^-  [(unit ^granary) @ud]
    =/  crop
      (plant egg(budget.stamp.p (div budget.stamp.p.egg rate.stamp.p.egg)))
    :_  +.crop
    ?~  -.crop  ~
    ?.  ?=(%& -.u.-.crop)  ~
    (harvest p.u.-.crop to.p.egg)
  ::
  ++  plant
    |=  =egg
    ^-  [(unit chick) @ud]
    |^
    =/  args  (fertilize q.egg)
    ?~  con=(germinate to.p.egg)
      `budget.stamp.p.egg
    (grow u.con args egg)
    ::
    ++  germinate
      |=  find=id
      ^-  (unit contract)
      ?~  gra=(~(get by granary) find)  ~
      ?.  ?=(%| -.germ.u.gra)  ~
      ?~  cont.p.germ.u.gra  ~
      `!<(contract [-:!>(*contract) u.cont.p.germ.u.gra])
    --
  ::
  ++  fertilize
    |=  =yolk
    ^-  scramble
    :+  caller.yolk
      args.yolk
    %-  ~(gas by *(map id grain))
    %+  murn  ~(tap in grain-ids.yolk)
    |=  =id
    ?~  grain=(~(get by granary) id)  ~
    ?.  ?=(%& -.germ.u.grain)  ~
    `[id u.grain]
  ::
  ++  grow
    |=  [cont=contract args=scramble =egg]
    ^-  [(unit male) @ud]
    |^
    =+  [bran rem]=(weed cont to.p.egg args ~ budget.stamp.p.egg)
    ?~  bran  `rem
    ?:  ?=(%& -.u.bran)
      p.u.bran^rem
    |-
    =*  next  next.p.u.bran
    =*  mem   mem.p.u.bran
    =^  crop  rem
      (plant egg(from.p to.p.egg, to to.next, budget.stamp.p rem, q args.next))
    ?~  crop  `rem
    =/  gan  (harvest u.crop to.p.egg)
    ?~  gan  `rem
    =.  granary  u.gan
    =^  eve  rem
      (weed cont to.p.egg [%event u.crop] mem rem)
    ?:  ?=(%& -.eve)
      p.eve^rem
    %_  $
      next.p.u.bran  next.p.eve
      mem.p.u.bran   mem.p.eve
    ==
    ::
    ++  weed
      |=  [cont=contract to=id args=scramble mem=(unit vase) budget=@ud]
      ^-  [(unit chick) @ud]
      =+  [res bud]=(barn cont to args ~ budget)
      ?~  res             [%& ~]^bud
      ?:  ?=(%| -.u.res)  [%& ~]^bud
      ?:  ?=(%result -.p.u.res)
        ?.  ?|  &(?=(%read -.p.p.u.res) ?=(%read -.args))
                &(?=(%write -.p.p.u.res) ?=(%write -.args))
            ==
          [%& ~]^bud
        [%& `p.p.u.res]^bud
      [%| p.p.u.res]^bud
    ::
    ::  +barn: run contract formula with arguments and memory, bounded by bud
    ::
    ++  barn
      |=  [=contract to=id args=scramble mem=(unit vase) bud=@ud]
      ^-  [(unit (each chick (list tank))) @ud]
      %+  bull
        ?-  -.args
          %read   |.(;;(chick (~(read contract mem to) +.args)))
          %write  |.(;;(chick (~(write contract mem to) +.args)))
          %event  |.(;;(chick (~(event contract mem to) +.args)))
        ==
      bud
    --
  ::
  ++  harvest
    |=  [res=male lord=id]
    ^-  (unit ^granary)
    ::  null (unit grain)s in changed.res are removed
    ::  from granary; others are modified
    =/  changed  ~(tap by changed.res)
    =|  modified=(map id grain)
    =.  modified
    |-  ^-  (map id grain)
    ?~  changed  modified
    =*  id     p.i.changed
    =*  grain  q.i.changed
    ?~  grain
      =.  granary  (~(del by granary) id)
      $(changed t.changed)
    $(modified (~(put by modified) id u.grain), changed t.changed)
    =-  ?.  -  ~
        `(~(uni by granary) (~(uni by modified) issued.res))
    ?&  %-  ~(all in changed.res)
        |=  [=id grain=(unit grain)]
        ::  id in changed map must be equal to id in grain AND
        ::  all changed grains must already exist AND
        ::  no changed grains may also have been issued at same time AND
        ::  only grains that proclaim us lord may be changed
        ?&  ?~(grain %.y =(id id.u.grain))
            (~(has by granary) id)
            !(~(has by issued.res) id)
            =(lord lord:(~(got by granary) id))
        ==
      ::
        %-  ~(all in issued.res)
        |=  [=id =grain]
        ::  id in issued map must be equal to id in grain AND
        ::  all newly issued grains must not already exist
        ?&  =(id id.grain)
            !(~(has by granary) id.grain)
            =(lord lord.grain)
    ==  ==
  --
--
