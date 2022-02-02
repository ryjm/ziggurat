/-  *mill
/+  *bink, tiny
|_  [validator-id=@ux =town now=time]
::
::  +mill-all: mills all calls in mempool
::
++  mill-all
  |=  [helix-id=@ud =granary mempool=(list call:tiny)]
  =/  pending
    %+  sort  mempool
    |=  [a=call:tiny b=call:tiny]
    (gth rate.a rate.b)
  =|  result=(list [@ux call:tiny])
          ::  'chunk' def
  |-  ^-  [(list [@ux call:tiny]) ^granary]
  ?~  pending
    [result granary]
  %_  $
    pending  t.pending
    result   [[`@ux`(shax (jam i.pending)) i.pending] result]
    granary  (mill helix-id granary i.pending)
  ==
::  +mill: processes a single call and returns updated granary
::
++  mill
  |=  [town-id=@ud =granary =call:tiny]
  ^-  ^granary
  |^
  =^  fee  granary
    main
  (take-fee from.call fee)
  ::
  ++  take-fee
    |=  [=caller:tiny fee=@ud]
    ^-  ^granary
    =/  caller-id
      ?:  ?=(@ux caller)  caller  id.caller
    =/  fee-args
      ^-  call-args:tiny
      [%write validator-id (silt ~[zigs-rice-id:tiny]) [~ %fee caller-id fee]]
    ::  TODO: call 'fee' event with fee-args in zigs contract here
    granary
  ::
  ++  main
    ^-  [@ud ^granary]
    ::  a caller to main *must* have a nonce
    ::  only contract callbacks in +exec are sole IDs
    ?.  ?=(user:tiny from.call)  [0 granary]
    ?~  curr-nonce=(~(get by q.granary) id.from.call)
      [0 granary]  ::  missing user
    ?.  =(nonce.from.call +(u.curr-nonce))
      [0 granary]  ::  bad nonce
    ::  confirm that from account actually has the amount
    ::  specified in "budget"
    =/  zigs  (~(got by p.granary) zigs-rice-id)
    ?.  ?=(%& -.zigs)  !!
    ::=/  data  ;;(zigs-token-data data.p.zigs)
    ::  ?~  bal=(~(get by balances.data) id.from.call)
    ::    ::  account not found in zigs database
    ::  [0 granary]
    ::?:  (gth budget.call u.bal)
    ::  ::  account lacks zigs to spend on gas
    ::  [0 granary]
    ::  run +exec on call and validate results
    =+  [res leftover]=(exec call granary)
    =/  fee=@ud  (sub budget.call leftover)
    ::  if no mutations from call, finish
    ?~  res  [fee granary]
    =/  red=contract-result:tiny  u.res
    ?:  ?=(%read -.red)
      ::  %read result, no mods to granary
      [fee granary]
    ::  otherwise go through changed & issued and perform validation
    ?.  (check-changed changed.red id.from.call)
      [fee granary]
    ?.  (check-issued issued.red)
      [fee granary]
    ::  valid, now
    :+  fee
        ::  add mutated and issued to granary
        ::  key collisions: issued overwrites changed which overwrites original
        ::  validation *should* ensure no issued have collisions with existing
      %-  ~(uni by p.granary)
      (~(uni by changed.red) issued.red)
    ::  update nonce of caller
    (~(put by q.granary) id.from.call nonce.from.call)
  ::
  ++  check-changed
    |=  [changed=(map id grain:tiny) claimed-lord=id]
    ^-  ?
    %-  ~(all in changed)
    |=  [=id grain=grain:tiny]
    ^-  ?
    ?.  =(id id.p.grain)                    %.n
    ?~  old-grain=(~(get by p.granary) id)  %.n
    ?.  ?=(%& -.u.old-grain)                %.n
    ?.  =(lord.p.u.old-grain claimed-lord)  %.n
    %.y
  ::
  ++  check-issued
    |=  issued=(map id grain:tiny)
    ^-  ?
    ::  probably need further validation of lord here for rice
    %+  levy
      ~(tap in ~(key by issued))
    |=(=id !(~(has by p.granary) id))
  --
::
::  +farm: execute a call to a contract within a wheat
::
++  farm
  |_  =granary
  ::
  ++  work
    |=  =call:tiny
    ^-  [(unit ^granary) @ud]
    (harvest (plant call))
  ::
  ++  plant
    |=  =call:tiny
    ^-  [(unit contract-result:tiny) @ud]
    =/  args  (call-args-to-contract args.call %.n)
    ?~  cont=(find-contract to.call)  (harvest budget.call ~)
    (grow u.cont to.call args budget.call)
  ::
  ++  grow
    |=  [cont=contract:tiny to=@ux args=contract-args:tiny budget=@ud]
    ^-  [(unit contract-result:tiny) @ud]
    =+  [res bud]=(blue cont args ~ budget)
    ?~  res             [~ bud]
    ?:  ?=(%| -.u.res)  [~ bud]
    ?:  ?=(%result -.p.u.res)
      ?.  ?|  &(?=(%read -.p.p.u.res) ?=(%read -.args))
              &(?=(%write -.p.p.u.res) ?=(%write -.args))
          ==
        [~ bud]
      [`p.p.u.res bud]
    |-
    =*  next  next.p.p.u.res
    =*  mem  mem.p.p.u.res
    =^  pan  bud
      (plant call(from to, to to.next, budget bud, args args.next))
    ?~  pan  [~ bud]
    =^  gan  bud
      (harvest `u.pan bud)
    ?~  gan  [~ bud]
    =.  granary  u.gan
    =^  eve  bud
      (blue cont [%event u.pan] mem bud)
    ?~  eve             [~ bud]
    ?:  ?=(%| -.u.eve)  [~ bud]
    ?:  ?=(%result -.p.u.eve)
      ?.  ?|  &(?=(%read -.p.p.u.eve) ?=(%read -.args.next))
              &(?=(%write -.p.p.u.eve) ?=(%write -.args.next))
          ==
        [~ bud]
      [`p.p.u.eve bud]
    %_  $
      next.p.p.u.res  next.p.p.u.eve
      mem.p.p.u.res   mem.p.p.u.eve
    ==
  ::
  ++  harvest
    |=  [res=(unit contract:result) bud=@ud]
    ^-  [(unit ^granary) @ud]
    ::  apply results to granary
    :_  bud
    ?~  res  ~
    ?:  ?=(%read -.u.res)
      `granary
    ::  TODO: validate and apply results to granary
    `granary
  ::
  ::  +blue: run contract formula with arguments and memory, bounded by bud
  ::
  ++  blue
    |=  [=contract:tiny args=contract-args:tiny mem=(unit vase) bud=@ud]
    ^-  [(unit (each contract-output:tiny (list tank))) @ud]
    %+  bull
      ?-    -.args
          %read
        |.(;;(contract-output:tiny (~(read contract mem) +.args)))
          %write
        |.(;;(contract-output:tiny (~(write contract mem) +.args)))
          %event
        |.(;;(contract-output:tiny (~(event contract mem) +.args)))
      ==
    bud
  ::
  ++  find-contract
    |=  find=id
    ^-  (unit contract:tiny)
    ?~  found=(~(get by p.granary) find)  ~
    ?.  ?=(%| -.u.found)  ~
    ?~  contract.p.u.found  ~
    `!<(contract:tiny [-:!>(*contract:tiny) u.contract.p.u.found])
  ::
  ++  call-args-to-contract
    |=  [arg=call-args:tiny is-event=?]
    ^-  contract-args:tiny
    =*  inp  +.arg
    :-  ?:  is-event  %event  -.arg
    :+  caller.inp
      %-  ~(gas by *(map id rice:tiny))
      %+  murn
        ~(tap in rice.inp)
      |=  =id
      ?~  res=(~(get by p.granary) id)  ~
      ?.  ?=(%& -.u.res)  ~
      `[id p.u.res]
    args.inp
  --
--
