/-  *mill
/+  *bink
|_  [validator-id=@ux =town]
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
    =/  inp  (call-to-contract +.args.call)
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
  ++  call-to-contract
    |=  inp=call-input
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
::
++  zigs-rice
  ^-  rice
  :*  0x1      ::  id/holder/lord
      zigs-rice-id  
      zigs-rice-id
      0        ::  helix 0
      :*  total=*@ud
          balances=*(map id @ud)
          allowances=*(map [owner=id sender=id] @ud)
          coinbase-rate=50  ::  # of tokens granted in +coinbase
      ==
      ~    ::  doesn't hold any other rice
  ==
::
++  zigs-contract
  ::^-  wheat
  :::-  zigs-wheat
  :::-  ~
  ::^-  contract
  |%
  ++  write
    |=  inp=contract-input
    ^-  output
    ?~  args.inp  *output
    =/  zigs  (~(got by rice.inp) zigs-rice-id)
    =/  data  ;;(zigs-token-data data.zigs)
    =/  caller-id
      ^-  @ux
      ?:  ?=(@ux caller.inp)
        caller.inp
      id.caller.inp
    =*  args  +.u.args.inp
    ?+    -.u.args.inp  *output
        %give
      ::  expected args: id, amount
      ?.  ?=([id=@ux amount=@ud] args)  !!
      ::  TODO check balance for enough, etc
      =.  balances.data
      %+  ~(jab by (~(jab by balances.data) id.args |=(bal=@ud (add bal amount.args))))
        caller-id
      |=(bal=@ud (sub bal amount.args))  
      =.  data.zigs  data
      *output
      ::  not working for some reason
      ::  ^-  output
      ::  +  changed=(malt ~[[zigs-rice-id zigs]]) 
      ::    issued=~ 
      ::  next=~
    ::
        %take
      ::  expected args: from, to, amount
      ?.  ?=([from=@ux to=@ux amount=@ud] args)  !!
      ::  TODO validation checks
      =:  allowances.data
        %+  ~(jab by allowances.data)
          [from.args caller-id]
        |=(bal=@ud (sub bal amount.args))
      ::
          balances.data
        %+  ~(jab by balances.data)
          to.args
        |=(bal=@ud (add bal amount.args))
      ==
      =.  data.zigs  data
      *output
    ::
        %set-allow
      ::  expected args: sender, amount
      ?.  ?=([sender=@ux amount=@ud] args)  !!
      ::  TODO validation checks
      =.  allowances.data
        %+  ~(jab by allowances.data)
          [caller-id sender.args]
        |=(bal=@ud (add bal amount.args))
      =.  data.zigs  data
      *output
    ==
  ++  read
    ::  read might need args for diff types of 'reads'
    |=  =id
    *(unit grain)
  --
--

