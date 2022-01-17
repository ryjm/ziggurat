/-  *mill
|%
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