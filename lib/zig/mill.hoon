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
    =/  zigs  (~(got by p.granary) zigs-id)
    ::  how do we get the shape of this rice?
    ::  maybe lord/contract stores it
    ::  =.  balances.data.zigs  (~(jab by balances.data.zigs) from.call |=(bal=@ud (sub bal fee)))
    ::  =.  balances.data.zigs  (~(jab by balances.data.zigs) to.call |=(bal=@ud (add bal fee)))
    [(~(put by p.granary) zigs-id zigs) q.granary]
  ::
  ++  main
    ^-  [@ud ^granary]
    ::  TODO: confirm that from account actually has the amount
    ::  specified in "budget"
    =/  zigs  (~(got by granary) zigs-rice)
    ::  call 'read-balance' arm in zigs contract
    ?~  bal=(~(get by -.+.data) from.call)
      ::  account not found in zigs database
      [0 granary]
    ?:  (gth budget.call bal)
      ::  account lacks zigs to spend on gas
      [0 granary]
    ?:  ?=(%read -.args.call)
      ::  TODO: run +blue on a read call
      [0 granary]
    ::  TODO: run +blue on a write call
    =/  =output  *output
    ?.  (check-changed changed.output to.call)
      [0 granary]
    ::  TODO: check that mutated rice have that grain as their owner
    ::  add mutated rice and issued grains to granary
    =.  granary  (~(uni by granary) (~(uni by changed.output) issued.output))
    ::  TODO: run next calls
    [0 granary]
  ::
  ++  check-changed
    |=  [changed=(map id rice) claimed-lord=id]
    ^-  ?
    %-  ~(all in changed)
    |=  [=id =rice]
    ^-  ?
    ?.  =(id id.rice)                    %.n
    ?~  old-rice=(~(get by granary) id)  %.n
    ?.  =(lord.u.old-rice claimed-lord)  %.n
    %.y
  --
::
++  zigs-rice
  ^-  rice
  :*  0x1      ::  id/holder/lord
      zigs-rice  
      zigs-rice
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
  ^-  wheat
  :-  zigs-wheat
  :-  ~
  |%
  ++  write
    |~  input  ::  doing this wrong, not sure
    ^-  output
    ?~  args.input  *output
    ?+    -.u.args.input  *output
        %give
      ::  expected args: id, amount
      ::=/  tok  
      ::  stdlib functions: 
      ::  ?>  (balance zigs.rice.input )
      ::  (add-balance zigs.rice.input id.args.input amount.args.input)
      ::  (sub-balance zigs.rice.input )
      ::  etc, etc
      *output
    ::
        %take
      *output
    ::
        %set-allow
      *output
    ==
  ++  read
    ::  read might need args for diff types of 'reads'
    |~  id
    *(unit grain)
  --
--

