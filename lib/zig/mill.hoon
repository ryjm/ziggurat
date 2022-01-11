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
    result   [[`@ux`(shax (jam i.to-run)) i.pending] result]
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
    =/  from-acct  (~(got by granary) from.call)
    =/  to-acct    (~(got by granary) to.call)
    granary
  ::
  ++  main
    ^-  [@ud ^granary]
    ::  TODO: confirm that from account actually has the amount
    ::  specified in "budget"
    ?:  ?=(%read -.args.call)
      ::  TODO: run +bink on a read call
      [0 granary]
    ::  TODO: run +bink on a write call
    =/  =output  *output
    =/  validated  (check-changed changed.output to.call)
    ::  TODO: check that mutated rice have that grain as their owner
    ::  TODO: create any newly issued grains
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
++  zigs  `rice`[0x0 0x0 0 0 ~]
--

