/+  *bink, tiny
|_  [validator-id=@ux =land:tiny now=time]
::
::  +mill-all: mills all calls in mempool
::
++  mill-all
  |=  [helix-id=@ud =town:tiny mempool=(list call:tiny)]
  =/  pending
    %+  sort  mempool
    |=  [a=call:tiny b=call:tiny]
    (gth rate.stamp.a rate.stamp.b)
  =|  result=(list [@ux call:tiny])
          ::  'chunk' def
  =/  fee-bundle=(unit call-input:tiny)
    :^  ~  [validator-id +((~(got by q.town) validator-id))]
      *(set id:tiny)
    [~ %send *(map id:tiny (map id:tiny @ud))]
  =/  town-and-fee-bundle  [town fee-bundle]
  |-  ^-  [(list [@ux call:tiny]) town:tiny]
  ?~  pending
    =.  town        -.town-and-fee-bundle
    =.  fee-bundle  +.town-and-fee-bundle
    ?~  fee-bundle  [result town]
    =/  fee-call=call:tiny  (~(invoice tax town) helix-id u.fee-bundle)
    =/  gan=granary:tiny  (~(pay tax town) fee-call)
    :+  [[`@ux`(shax (jam fee-call)) fee-call] result]
      gan
    ?:  ?=(id:tiny caller.u.fee-bundle)  q.town
    (~(put by q.town) validator-id nonce.caller.u.fee-bundle)
  %_  $
    pending            t.pending
    result             [[`@ux`(shax (jam i.pending)) i.pending] result]
    town-and-fee-bundle  (mill helix-id town i.pending fee-bundle)
  ==
::  +mill: processes a single call and returns updated town
::
++  mill
  |=  [town-id=@ud =town:tiny =call:tiny fee-bundle=(unit call-input:tiny)]
  ^-  [town:tiny (unit call-input:tiny)]
  ?.  ?=(user:tiny from.call)  [town ~]
  ?~  curr-nonce=(~(get by q.town) id.from.call)
    [town ~]  ::  missing user
  ?.  =(nonce.from.call +(u.curr-nonce))
    [town ~]  ::  bad nonce
  ?.  (~(audit tax town) call)
    [town ~]  ::  can't afford gas
  =+  [gan rem]=(~(work farm p.town) call)
  =/  fee=@ud   (sub budget.stamp.call rem)
  ?~  gan  [town ~]
  =.  q.town  (~(put by q.town) id.from.call nonce.from.call)
  =+  [gan-out fee-bundle-out]=(~(note-or-pay tax [u.gan q.town]) call fee town-id fee-bundle)
  :-  :-  gan-out
    ?~  fee-bundle
      ?~  fee-bundle-out  q.town
      ?:  ?=(id:tiny caller.u.fee-bundle-out)  q.town
      %+  %~  put  by  q.town
        id.caller.u.fee-bundle-out
      nonce.caller.u.fee-bundle-out
    q.town
  fee-bundle-out
::
::  +tax: manage payment for contract execution in zigs
::
++  tax
  |_  =town:tiny
  ::  +audit: evaluate whether a caller can afford gas
  ++  audit
    |=  =call:tiny
    ^-  ?
    =/  rices=contract-input-rice:tiny  (fetch call)
    ?~  fee-rice=(~(get by rices) fee.stamp.call)  %.n
    =*  bal  data.p.germ.u.fee-rice
    ?.  =(zigs-rice-id:tiny lord.u.fee-rice)       %.n
    ?.  ?=(@ud bal)                                %.n
    (gth bal (mul rate.stamp.call budget.stamp.call))
  ::  +fetch: get contract-input-rice for fee rice
  ++  fetch
    |=  =call:tiny
    ^-  contract-input-rice:tiny
    =/  =contract-args:tiny
      %-  %~  fertilize  farm  p.town
      [%write from.call (silt ~[fee.stamp.call]) ~]
      :: %-  fertilize.farm(granary p.town)
      :: [%write caller.call (silt ~[fee.stamp.call]) ~]
    ?>  ?=(%write -.contract-args)
    rice.+.contract-args
  ::  +note-or-pay: notes or pays fee as appropriate
  ++  note-or-pay
    |=  [=call:tiny fee=@ud town-id=@ud fee-bundle=(unit call-input:tiny)]
    ^-  [granary:tiny (unit call-input:tiny)]
    ?~  fee-bundle
      =/  fee-call=call:tiny
        (invoice town-id (tally call fee ~))
      [(pay fee-call) fee-bundle]
    [p.town (note call fee fee-bundle)]
  ::  +note: store gas fee for payment in accumulated tx
  ++  note
    |=  [=call:tiny fee=@ud fee-bundle=(unit call-input:tiny)]
    ^-  (unit call-input:tiny)
    ?~  fee-bundle  ~
    =/  from=id:tiny
      ?:  ?=(id:tiny from.call)  from.call
      id.from.call
    ::  bump nonce of fee-bundle if this tx was by validator
    =.  caller.u.fee-bundle
      ?:  ?=(id:tiny caller.u.fee-bundle)
        caller.u.fee-bundle
      :-  id.caller.u.fee-bundle
      ?.  =(validator-id from)
        nonce.caller.u.fee-bundle
      +(nonce.caller.u.fee-bundle)
    [~ (tally call fee fee-bundle)]
  ::  +invoice: create call for payment of fee
  ++  invoice
    |=  [town-id=@ud fee-bundle=call-input:tiny]
    ^-  call:tiny
    :*  from=caller.fee-bundle
        to=zigs-wheat-id:tiny
        stamp=*stamp:tiny  ::  unused
        town-id=town-id
        args=[%write fee-bundle]
    ==
  ::  +tally: create call-input for payment of fee
  ++  tally
    |=  [=call:tiny fee=@ud fee-bundle=(unit call-input:tiny)]
    ^-  call-input:tiny
    =/  rice=contract-input-rice:tiny  (fetch call)
    =/  from=id:tiny
      ?:  ?=(id:tiny from.call)  from.call
      id.from.call
    =/  from-grain  (~(got by rice) from)
    =*  bal  data.p.germ.from-grain
    ?>  ?=(@ud bal)
    =/  transactions=(map id:tiny (map id:tiny @ud))
      %+  %~  put  by  *(map id:tiny (map id:tiny @ud))  from
      %-  %~  gas  by  *(map id:tiny @ud)
      ~[[validator-id fee] [change.stamp.call (sub bal fee)]]
    =/  rice-ids=(set id:tiny)  (silt ~[from])
    ?~  fee-bundle
      :+  [validator-id +((~(got by q.town) validator-id))]
        rice-ids
      [~ %send transactions]
    =.  rice-ids.u.fee-bundle
      (~(uni in rice-ids.u.fee-bundle) rice-ids)
    :*  caller.u.fee-bundle
        rice-ids.u.fee-bundle
        ~
        %send
        ?~  args.u.fee-bundle  transactions
        =/  old-tx
          ;;((map id:tiny (map id:tiny @ud)) +.u.args.u.fee-bundle)
        ?~  (~(get by old-tx) from)
          (~(uni by old-tx) transactions)
        %+  %~  put  by  old-tx  from
        %-  %~  uni  by  (~(got by old-tx) from)
        (~(got by transactions) from)
    ==
  ::  +pay: extract gas fee from caller's zigs balance
  ++  pay
    |=  fees=call:tiny
    ^-  granary:tiny
    =+  [gan rem]=(~(work farm p.town) fees)
    ?~  gan  !!
    u.gan
  --
::
::  +farm: execute a call to a contract within a wheat
::
++  farm
  |_  =granary:tiny
  ::
  ++  work
    |=  =call:tiny
    ^-  [(unit granary:tiny) @ud]
    =/  crop  (plant call(budget.stamp (div budget.stamp.call rate.stamp.call)))
    :_  +.crop
    ?~  -.crop  ~
    (harvest u.-.crop to.call)
  ::
  ++  plant
    |=  =call:tiny
    ^-  [(unit contract-result:tiny) @ud]
    |^
    =/  args  (fertilize args.call)
    ?~  con=(germinate to.call)
      `budget.stamp.call
    (grow u.con args call)
    ::
    ++  germinate
      |=  find=id:tiny
      ^-  (unit contract:tiny)
      ?~  gra=(~(get by granary) find)  ~
      ?.  ?=(%| -.germ.u.gra)  ~
      ?~  p.germ.u.gra  ~
      `!<(contract:tiny [-:!>(*contract:tiny) u.p.germ.u.gra])
    --
  ::
  ++  fertilize
    |=  arg=call-args:tiny
    ^-  contract-args:tiny
    =*  inp  +.arg
    :-  -.arg
    :+  caller.inp
      args.inp
    %-  ~(gas by *contract-input-rice:tiny)
    %+  murn  ~(tap in rice-ids.inp)
    |=  =id:tiny
    ?~  res=(~(get by granary) id)  ~
    ?.  ?=(%& -.germ.u.res)  ~
    `[id u.res]
  ::
  ++  grow
    |=  [cont=contract:tiny args=contract-args:tiny =call:tiny]
    ^-  [(unit contract-result:tiny) @ud]
    |^
    =+  [bran rem]=(weed cont to.call args ~ budget.stamp.call)
    ?:  ?=(%& -.bran)
      p.bran^rem
    |-
    =*  next  next.p.bran
    =*  mem   mem.p.bran
    =^  crop  rem
      (plant call(from to.call, to to.next, budget.stamp rem, args args.next))
    ?~  crop  `rem
    =/  gan  (harvest u.crop to.call)
    ?~  gan  `rem
    =.  granary  u.gan
    =^  eve  rem
      (weed cont to.call [%event u.crop] mem rem)
    ?:  ?=(%& -.eve)
      p.eve^rem
    %_  $
      next.p.bran  next.p.eve
      mem.p.bran   mem.p.eve
    ==
    ::
    ++  weed
      |=  [cont=contract:tiny to=id:tiny args=contract-args:tiny mem=(unit vase) budget=@ud]
      ^-  [(each (unit contract-result:tiny) continuation:tiny) @ud]
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
      |=  [=contract:tiny to=id:tiny args=contract-args:tiny mem=(unit vase) bud=@ud]
      ^-  [(unit (each contract-output:tiny (list tank))) @ud]
      %+  bull
        ?-  -.args
          %read   |.(;;(contract-output:tiny (~(read contract mem to) +.args)))
          %write  |.(;;(contract-output:tiny (~(write contract mem to) +.args)))
          %event  |.(;;(contract-output:tiny (~(event contract mem to) +.args)))
        ==
      bud
    --
  ::
  ++  harvest
    |=  [res=contract-result:tiny lord=id:tiny]
    ^-  (unit granary:tiny)
    ?:  ?=(%read -.res)  `granary
    ::  null (unit grain)s in changed.res are removed
    ::  from granary; others are modified
    =/  changed  ~(tap by changed.res)
    =|  modified=(map id:tiny grain:tiny)
    =.  modified
    |-  ^-  [(map id:tiny grain:tiny)]
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
        |=  [=id:tiny grain=(unit grain:tiny)]
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
        |=  [=id:tiny =grain:tiny]
        ::  id in issued map must be equal to id in grain AND
        ::  all newly issued grains must not already exist
        ?&  =(id id.grain)
            !(~(has by granary) id.grain)
            =(lord lord.grain)
    ==  ==
  --
--
