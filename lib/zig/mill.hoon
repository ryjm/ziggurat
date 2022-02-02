/-  *mill
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
  |-  ^-  [(list [@ux call:tiny]) town:tiny]
  ?~  pending
    [result town]
  %_  $
    pending  t.pending
    result   [[`@ux`(shax (jam i.pending)) i.pending] result]
    town  (mill helix-id town i.pending)
  ==
::  +mill: processes a single call and returns updated granary
::
++  mill
  |=  [town-id=@ud =town:tiny =call:tiny]
  ^-  town:tiny
  |^
  =^  fee  town
    main
  (take-fee from.call fee)
  ::
  ++  take-fee
    |=  [=caller:tiny fee=@ud]
    ^-  town:tiny
    =/  caller-id
      ?:  ?=(@ux caller)  caller  id.caller
    =/  fee-args
      ^-  call-args:tiny
      [%write validator-id (silt ~[zigs-rice-id:tiny]) [~ %fee caller-id fee]]
    ::  TODO: call 'fee' event with fee-args in zigs contract here
    town
  ::
  ++  main
    ^-  [@ud town:tiny]
    ::  a caller to main *must* have a nonce
    ::  only contract callbacks in +exec are sole IDs
    ?.  ?=(user:tiny from.call)  [0 town]
    ?~  curr-nonce=(~(get by q.town) id.from.call)
      [0 town]  ::  missing user
    ?.  =(nonce.from.call +(u.curr-nonce))
      [0 town]  ::  bad nonce
    ::  confirm that from account actually has the amount
    ::  specified in "budget"
    =/  zigs  (~(got by p.town) zigs-rice-id)
    ?.  ?=(%& -.zigs)  !!
    ::=/  data  ;;(zigs-token-data data.p.zigs)
    ::  ?~  bal=(~(get by balances.data) id.from.call)
    ::    ::  account not found in zigs database
    ::  [0 granary]
    ::?:  (gth budget.call u.bal)
    ::  ::  account lacks zigs to spend on gas
    ::  [0 granary]
    =+  [gan rem]=(~(work farm p.town) call)
    =/  fee=@ud   (sub budget.call rem)
    :+  fee
      ?~(gan p.town u.gan)
    (~(put by q.town) id.from.call nonce.from.call)
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
    =/  pan  (plant call)
    (harvest -:pan +:pan to.call from.call)
  ::
  ++  plant
    |=  =call:tiny
    ^-  [(unit contract-result:tiny) @ud]
    |^
    =/  args  (call-args-to-contract args.call %.n)
    ?~  con=(find-contract to.call)  `budget.call
    (grow u.con args call)
    ::
    ++  find-contract
      |=  find=id
      ^-  (unit contract=contract:tiny)
      ?~  gra=(~(get by granary) find)  ~
      ?.  ?=(%| -.germ.u.gra)  ~
      ?~  p.germ.u.gra  ~
      `!<(contract:tiny [-:!>(*contract:tiny) u.p.germ.u.gra])
    ::
    ++  call-args-to-contract
      |=  [arg=call-args:tiny is-event=?]
      ^-  contract-args:tiny
      =*  inp  +.arg
      :-  -.arg
      :+  caller.inp
        args.inp
      %-  ~(gas by *contract-input-rice:tiny)
      %+  murn
        ~(tap in rice.inp)
      |=  =id
      ?~  res=(~(get by granary) id)  ~
      ?.  ?=(%& -.germ.u.res)  ~
      `[id u.res]
    --
  ::
  ++  grow
    |=  [cont=contract:tiny args=contract-args:tiny =call:tiny]
    ^-  [(unit contract-result:tiny) @ud]
    |^
    =+  [res bud]=(blue cont args ~ budget.call)
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
      (plant call(from to.call, to to.next, budget bud, args args.next))
    ?~  pan  [~ bud]
    =^  gan  bud
      (harvest `u.pan bud to.call from.call)
    ?~  gan  [~ bud]
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
    --
  ::
  ++  harvest
    |=  [res=(unit contract-result:tiny) bud=@ud lord=id from=caller:tiny]
    ^-  [(unit granary:tiny) @ud]
    ::  apply results to granary
    :_  bud
    ?~  res  ~
    ?:  ?=(%read -.u.res)  `granary
    ?.  %-  ~(all by changed.u.res)
        |=  =grain:tiny
        (~(has by granary) id.grain)
      `granary
    ?.  %-  ~(all by issued.u.res)
        |=  =grain:tiny
        !(~(has by granary) id.grain)
      `granary
    ?.  %-  ~(all by changed.u.res)
        |=  =grain:tiny
        !(~(has by issued.u.res) id.grain)
      `granary
    ?.  %-  ~(all in changed.u.res)
        |=  [=id =grain:tiny]
        ^-  ?
        ?.  =(id id.grain)  %.n
        =/  old  (~(got by granary) id)
        =(lord.old lord)
      `granary
    `(~(uni by granary) (~(uni by changed.u.res) issued.u.res))
  --
--
