/-  *mill
/+  *bink, tiny
|_  [validator-id=@ux =town now=time]
::
++  our-granary
  ^-  granary
  =/  contracts=(list (pair id grain:tiny))
    :~  [0x1 %| 0x1 `!<(contract:tiny (slap !>(tiny) (ream .^(@t %cx /(scot %p ~zod)/zig/(scot %da now)/lib/zig/contracts/one/hoon))))]
        [0x2 %| 0x2 `!<(contract:tiny (slap !>(tiny) (ream .^(@t %cx /(scot %p ~zod)/zig/(scot %da now)/lib/zig/contracts/two/hoon))))]
    ==
  (~(gas by *(map id grain:tiny)) contracts)^~
::  +blue: run contract formula with arguments and memory, bounded by bud
::
++  blue
  |=  [=contract:tiny args=contract-args:tiny mem=(unit vase) bud=@ud]
  ^-  [(unit (each contract-output:tiny (list tank))) @ud]
  ::=/  dor=vase  (slap !>(tiny) for)
  ::=/  =contract:tiny  !<(contract:tiny dor)
  %+  bull
    ?:  ?=(%read -.args)
      |.((~(read contract mem) +.args))
    |.((~(write contract mem) +.args))
  bud
::  TODO: move the 3 below arms into +mill-all
::  so they can be run with shared granary
::  (left outside for testing with fake granary)
++  call-args-to-contract
  |=  [arg=call-args:tiny =granary]
  ^-  contract-args:tiny
  =*  inp  +.arg
  :-  -.arg
  :+  caller.inp
    %-  ~(gas by *(map id rice:tiny))
    %+  murn
      ~(tap in rice.inp)
    |=  =id
    ?~  res=(~(get by p.granary) id)  ~
    ?.  ?=(%& -.u.res)  ~
    `[id p.u.res]
  args.inp
::
++  grab-hoon
  |=  [find=id =granary]
  ^-  (unit contract:tiny)
  ?~  found=(~(get by p.granary) find)  ~
  ?.  ?=(%| -.u.found)  ~
  +.p.u.found
::
++  exec
  |=  [=call:tiny mem=(unit vase)]
  ^-  [(unit result:tiny) @ud]
  ?~  cont=(grab-hoon to.call our-granary)  [~ budget.call]
  =/  args  (call-args-to-contract args.call our-granary)
  =+  [res bud]=(blue u.cont args mem budget.call)
  ?~  res  [~ bud]
  ?:  ?=(%| -.u.res)
    [~ bud]
  ?:  ?=(%result -.p.u.res)
    :_  bud
    ?.  ?|  &(?=(%read -.p.p.u.res) ?=(%read -.args))
            &(?=(%write -.p.p.u.res) ?=(%write -.args))
        ==
      ~
    `p.p.u.res
  =*  fwd  p.p.u.res
  =|  ult=(unit result:tiny)
  |-
  ?~  next.fwd
    [ult bud]
  =^  ult  bud
    %+  exec
      [to.call to.i.next.fwd 1 bud town-id.i.next.fwd args.i.next.fwd]
    mem.fwd
  ?~  ult  [~ bud]
  $(next.fwd t.next.fwd)
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
      %+  ~(jab by (~(jab by balances.data) validator-id |=(bal=@ud (add bal fee))))
        from.call
      |=(bal=@ud (sub bal fee))
    =.  data.p.zigs  data
    [(~(put by p.granary) zigs-rice-id zigs) q.granary]
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
    =/  data  ;;(zigs-token-data data.p.zigs)
    ?~  bal=(~(get by balances.data) id.from.call)
      ::  account not found in zigs database
      [0 granary]
    ?:  (gth budget.call u.bal)
      ::  account lacks zigs to spend on gas
      [0 granary]
    ::  run +exec on call and validate results
    =+  [res leftover]=(exec call ~)
    =/  fee=@ud  (sub budget.call leftover)
    ::  if no mutations from call, finish
    ?~  res  [fee granary]
    ?:  =(%read -.u.res)
      ::  %read result, no mods to granary
      [fee granary]
    ::  gotta get rid of this somehow
    =/  write-res  ;;([%write changed=(map id rice:tiny) issued=(map id grain:tiny)] u.res)
    ::  otherwise go through changed & issued and perform validation
    ?.  (check-changed changed.write-res id.from.call)
      [fee granary]
    ?.  (check-issued issued.write-res)
      [fee granary]
    ::  valid, now
    ::  TODO: take-fee should probably be folded in here
    ::  so as to make use of the zigs-rice we've already
    ::  grabbed from granary, and to minimize granary updates
    =/  changed=(map id grain:tiny)
      (~(run by changed.write-res) |=(a=rice:tiny [%& a]))
    :-  fee
        ::  add mutated and issued to granary
        ::  key collisions: issued overwrites changed which overwrites original
        ::  validation *should* ensure no issued have collisions with existing
    :-  %-  ~(uni by p.granary)
        (~(uni by changed) issued.write-res)
        ::  update nonce of caller
        (~(put by q.granary) id.from.call nonce.from.call)
  ::
  ++  check-changed
    |=  [changed=(map id rice:tiny) claimed-lord=id]
    ^-  ?
    %-  ~(all in changed)
    |=  [=id =rice:tiny]
    ^-  ?
    ?.  =(id id.rice)                      %.n
    ?~  old-rice=(~(get by p.granary) id)  %.n
    ?.  ?=(%& -.u.old-rice)                %.n
    ?.  =(lord.p.u.old-rice claimed-lord)  %.n
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
++  zigs-token-data
  $:  total=@ud
      balances=(map id @ud)
      allowances=(map [owner=id sender=id] @ud)
      coinbase-rate=@ud
  ==
--

