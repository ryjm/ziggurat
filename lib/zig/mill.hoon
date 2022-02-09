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
    (gth rate.a rate.b)
  =|  result=(list [@ux call:tiny])
          ::  'chunk' def
  =/  fee-bundle=(unit call-input:tiny)
    :^  ~  [validator-id +((~(got by q.town) validator-id))]
      ~
    [~ %send *(map id (map id @ud))]
  |-  ^-  [(list [@ux call:tiny]) town:tiny]
  ?~  pending
    ?~  fee-bundle  [result town]
    =/  gan  (~(pay tax p.town) u.fee-bundle)
    :+  [[`@ux`(shax (jam u.fee-bundle)) u.fee-bundle] result]
      gan
    (~(put by q.town) validator-id nonce.caller.u.fee-bundle)
  %_  $
    pending  t.pending
    result   [[`@ux`(shax (jam i.pending)) i.pending] result]
    town     (mill helix-id town i.pending fee-bundle)
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
  ?.  (~(audit tax p.town) call)
    [town ~]  ::  can't afford gas
  =+  [gan rem]=(~(work farm p.town) call)
  =/  fee=@ud   (sub budget.call rem)
  =+  [gan-out fee-bundle-out]=(~(note-or-pay tax gan) call fee fee-bundle)
  :+  gan-out
    %-  %~  gas  by  q.town
    :*  [id.from.call nonce.from.call]
        ?~  fee-bundle
          [[id.caller.u.fee-bundle nonce.caller.u.fee-bundle] ~]
        ~
    ==
  fee-bundle-out
::
::  +tax: manage payment for contract execution in zigs
::
++  tax
  |_  =granary:tiny
  ::  +audit: evaluate whether a caller can afford gas
  ++  audit
    |=  =call:tiny
    ^-  ?
    =/  rice=contract-input-rice:tiny  (fetch call)
    =*  fee-rice  (~(get by rice) fee.stamp.call)
    ?.  ?=(zigs-rice-id:tiny lord.fee-rice)  %.n
    ?.  ?=(@ud bal=data.p.germ.fee-rice)     %.n
    (gth balance (mul rate.stamp.call budget.stamp.call))
  ::  +fetch: get contract-input-rice for fee rice
  ++  fetch
    |=  =call:tiny
    ^-  contract-input-rice:tiny
    =/  =contract-args:tiny
      %-  %~  fertilize.plant  farm  granary
      [%write caller.call (silt ~[fee.stamp.call]) ~]
    rice.+.contact-args
  ::  +note-or-pay: notes or pays fee as appropriate
  ++  note-or-pay
    |=  [=call:tiny fee=@ud fee-bundle=(unit call-input:tiny)]
    ^-  [granary:tiny (unit call-input:tiny)]
    ?~  fee-bundle  [(pay id.from.call fee) ~]
    [granary (note call fee fee-bundle)]
  ::  +note: store gas fee for payment in accumulated tx
  ++  note
    |=  [=call:tiny fee=@ud fee-bundle=(unit call-input:tiny)]
    ^-  (unit call-input:tiny)
    ?~  fee-bundle  ~
    =/  rice=contract-input-rice:tiny  (fetch call)
    =/  from=id:tiny
      ?:  ?=(id:tiny from.call)  from.call
      id.from.call
    =/  from-grain  (~(got by rice) from)
    =*  bal  data.p.germ.from-grain
    ?.  ?=(@ud bal)  ~
    ::  bump nonce of fee-bundle if this tx was by validator
    =.  caller.u.fee-bundle
    ?.  ?=(id:tiny caller.u.fee-bundle)
      caller.u.fee-bundle
    ?.  =(validator-id from)
      nonce.caller.u.fee-bundle
    +(nonce.caller.u.fee-bundle)
    ::  build addition to args
    =*  transactions  +.u.args.u.fee-bundle
    ?~  args.u.fee-bundle  ~
    =.  transactions
    %+  %~  put  by  transactions  from
    %-  %~  gas  by
      ?~  old-tx=(~(get by transactions) from)
        *(map id @ud)
      old-tx
    ~[[validator-id fee] [change.stamp.call (sub bal fee)]]
    fee-bundle
  ::  +pay: extract gas fee from caller's zigs balance
  ++  pay
    |=  fee-bundle=call:tiny
    ^-  granary:tiny
    =+  [gan rem]=(~(work farm granary) fee-bundle)
    gan
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
    =/  crop  (plant call(budget (div budget.call rate.call)))
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
    ++  germinate
      |=  find=id:tiny
      ^-  (unit contract:tiny)
      ?~  gra=(~(get by granary) find)  ~
      ?.  ?=(%| -.germ.u.gra)  ~
      ?~  p.germ.u.gra  ~
      `!<(contract:tiny [-:!>(*contract:tiny) u.p.germ.u.gra])
    --
  ::
  ++  grow
    |=  [cont=contract:tiny args=contract-args:tiny =call:tiny]
    ^-  [(unit contract-result:tiny) @ud]
    |^
    =+  [bran rem]=(weed cont to.call args ~ budget.call)
    ?:  ?=(%& -.bran)
      p.bran^rem
    |-
    =*  next  next.p.bran
    =*  mem   mem.p.bran
    =^  crop  rem
      (plant call(from to.call, to to.next, budget rem, args args.next))
    ?~  crop  `rem
    =/  gan  (harvest u.crop to.call from.call)
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
    =-  ?.  -  ~
        `(~(uni by granary) (~(uni by changed.res) issued.res))
    ?&  %-  ~(all in changed.res)
        |=  [=id:tiny =grain:tiny]
        ::  id in changed map must be equal to id in grain AND
        ::  all changed grains must already exist AND
        ::  no changed grains may also have been issued at same time AND
        ::  only grains that proclaim us lord may be changed
        ?&  =(id id.grain)
            (~(has by granary) id.grain)
            !(~(has by issued.res) id.grain)
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
