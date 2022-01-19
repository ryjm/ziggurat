/-  *mill
/+  *bink, tiny
|_  [validator-id=@ux =town now=time]
++  call-trivial
  |=  trivial-hoon=hoon
  (blue trivial-hoon [%read 0xaa ~ ~] 1.000.000)
++  our-granary
  ^-  granary
  =/  contracts=(list (pair id grain))
    :~  [0x1 %| 0x1 `(ream .^(@t %cx /(scot %p ~zod)/zig/(scot %da now)/lib/zig/contracts/one/hoon))]
        [0x2 %| 0x2 `(ream .^(@t %cx /(scot %p ~zod)/zig/(scot %da now)/lib/zig/contracts/two/hoon))]
    ==
  (~(gas by *(map id grain)) contracts)^~
::  +blue:
::
++  blue
  |=  [for=hoon args=contract-args bud=@ud]
  ^-  [(unit loon) @ud]
  =.  for
    ?:  ?=(%read -.args)
      [%tsgr for [%wing ~[%read]]]
    [%tsgr for [%wing ~[%write]]]
  =/  gat
    q:(~(mint ut -:!>(tiny)) %noun for)
  =/  sam
    ?:  ?=(%read -.args)
      +.args
    +.args
  (bock [tiny [%9 2 %10 [6 %1 sam] gat]] bud)
::
++  call-to-contract
  |=  [inp=call-input =granary]
  ^-  contract-input
  :+  caller.inp
    %-  ~(gas by *(map id rice))
    %+  murn
      ~(tap in rice.inp)
    |=  =id
    ?~  res=(~(get by p.granary) id)  ~
    ?.  ?=(%& -.u.res)  ~
    `[id p.u.res]
  args.inp
::
++  exec
  |=  [us=id cont=hoon args=contract-args bud=@ud]
  ^-  [(unit result) @ud]
  =^  res  bud
    (blue cont args bud)
  ?~  res  [~ bud]
  ?:  ?=(%2 -.u.res)
    [~ bud]
  =/  out  ;;(output p.u.res)
  ?:  =(%& -.out)
    [~ bud]
  [~ bud]
  ::  =/  continue  ;;(continuation +.out)
  ::  =|  [mem=(unit vase) next=(list [to=id town-id=@ud args=contract-args])]
  ::  =:  mem
  ::    mem.continue
  ::  ::
  ::      next
  ::    %+  turn
  ::      next.continue
  ::    |=  [to=id town-id=@ud args=call-args]
  ::    :+  to
  ::      town-id
  ::    (call-to-contract args our-granary)
  ::  ==
  ::  ::?:  =(~ next)
  ::  ::  [~ bud]
  ::  =|  result=(unit result)
  ::  |-
  ::  ?~  next  [result bud]
  ::  =/  our-call=call
  ::    [us to 1 bud town-id args]
  ::  =/  found=grain  (~(got by p.our-granary) to)
  ::  ?>  ?=(%| -.found)
  ::  ?>  ?=(^ contract.p.found)
  ::  =^  result  bud
  ::    (exec to u.contract.p.found args bud)
  ::  ?~  result  [~ bud]
  ::  $(next t.next)
::
::  +mill-all: mills all calls in mempool
::
++  mill-all
  |=  [helix-id=@ud =granary mempool=(list call)]
  ::  'chunk' def
  =/  pending
    %+  sort  mempool
    |=  [a=call b=call]
    (gth rate.a rate.b)
  =|  result=(list [@ux call])
  |-  ^-  [(list [@ux call]) ^granary]
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
  |=  [town-id=@ud =granary =call]
  ^-  ^granary
  |^
  =^  fee  granary
    main
  (take-fee fee)
  ::
  ++  take-fee
    |=  fee=@ud
    ^-  ^granary
    ::  TODO: run the "take-fee" part of the zig contract
    ::  to give some money to our validator-id? or are zigs not in a
    ::  contract?
    ::
    =/  zigs  (~(got by p.granary) zigs-rice-id)
    ?.  ?=(%& -.zigs)  !!
    =/  data  ;;(zigs-token-data data.p.zigs)
    =.  balances.data
      %+  ~(jab by (~(jab by balances.data) to.call |=(bal=@ud (add bal fee))))
        from.call
      |=(bal=@ud (sub bal fee))
    =.  data.p.zigs  data
    [(~(put by p.granary) zigs-rice-id zigs) q.granary]
  ::
  ++  main
    ^-  [@ud ^granary]
    ::  TODO: confirm that from account actually has the amount
    ::  specified in "budget"
    =/  zigs  (~(got by p.granary) zigs-rice-id)
    ?.  ?=(%& -.zigs)  !!
    =/  data  ;;(zigs-token-data data.p.zigs)
    =/  caller-id
      ?:  ?=(@ux from.call)
        from.call
      id.from.call
    ?~  bal=(~(get by balances.data) caller-id)
      ::  account not found in zigs database
      [0 granary]
    ?:  (gth budget.call u.bal)
      ::  account lacks zigs to spend on gas
      [0 granary]
    ?:  ?=(%read -.args.call)
      ::  TODO: run +blue on a read call
      [0 granary]
    =/  inp  (call-to-contract +.args.call granary)
    ::  TODO: run +blue on a write call
    =/  op  *output
    ::  why can't we read faces in op???
    ~&  op
    ::?.  (check-changed changed.op to.call)
    ::  [0 granary]
    ::?.  (check-issued issued.op)
    ::  [0 granary]
    ::  TODO: check that mutated rice have that grain as their owner
    ::  add mutated rice and issued grains to granary
    ::=.  granary  (~(uni by p.granary) (~(uni by changed.op) issued.op))
    ::  TODO: run next calls
    [0 granary]
  ::
  ++  check-changed
    |=  [changed=(map id rice) claimed-lord=id]
    ^-  ?
    %-  ~(all in changed)
    |=  [=id =rice]
    ^-  ?
    ?.  =(id id.rice)                      %.n
    ?~  old-rice=(~(get by p.granary) id)  %.n
    ?.  ?=(%& -.u.old-rice)                %.n
    ?.  =(lord.p.u.old-rice claimed-lord)  %.n
    %.y
  ::
  ++  check-issued
    |=  issued=(map id grain)
    ^-  ?
    %+  levy
      ~(tap in ~(key by issued))
    |=(=id !(~(has by p.granary) id))
  --
::
++  zigs-token-data
  $:  total=@ud
      balances=(map id @ud)
      allowances=(map [owner=id sender=id] @ud)
      coinbase-rate=@ud
  ==
--

