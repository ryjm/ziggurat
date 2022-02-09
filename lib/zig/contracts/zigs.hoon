/+  *tiny
=>  |%
    +$  token-data
      $:  total=@ud
          balances=(map id @ud)
          allowances=(map [owner=id sender=id] @ud)
          coinbase-rate=@ud
      ==
    --
|%
++  zigs-contract
  ^-  contract
  |_  [mem=(unit vase) me=id]
  ++  write
    |=  inp=contract-input
    ^-  contract-output
    ?~  args.inp  *contract-output
    ?~  zigs=(~(get by rice.inp) zigs-rice-id)  *contract-output
    ?>  =(lord.u.zigs me)
    =/  data  !<(token-data [-:!>(*token-data) data.germ.u.zigs])
    =/  caller-id
      ^-  id
      ?:  ?=(@ux caller.inp)
        caller.inp
      id.caller.inp
    =*  args  +.u.args.inp
    =.  data.germ.u.zigs
      ?+    -.u.args.inp  data
          %give
        ::  expected args: id, amount, budget
        ?.  ?=([=id amount=@ud bud=@ud] args)  data
        ::  check our balance to make sure we can afford spend + fee
        ?~  curr-bal=(~(get by balances.data) id.args)  data
        ?:  (lth u.curr-bal (add bud.args amount.args))  data
        ::  add to receiver balance, subtract from ours
        =.  balances.data
          ::  this pattern [52:60] could be a good stdlib function
          ?.  (~(has by balances.data) id.args)
            ::  if receiver's account doesn't have a balance, insert
            %+  ~(jab by (~(put by balances.data) id.args amount.args))
              caller-id
            |=(bal=@ud (sub bal amount.args))
          ::  otherwise, add to their existing balance
          %+  ~(jab by (~(jab by balances.data) id.args |=(bal=@ud (add bal amount.args))))
            caller-id
          |=(bal=@ud (sub bal amount.args))
        data
      ::
          %take
        ::  expected args: from, to, amount
        ?.  ?=([from=id to=id amount=@ud] args)  data
        ::  check our allowance to make sure we're approved to spend
        ?~  curr-allow=(~(get by allowances.data) [from.args caller-id])
          data
        ?:  (gth amount.args u.curr-allow)  data
        ::  check owner's balance to make sure they can afford spend
        ?~  curr-bal=(~(get by balances.data) from.args)  data
        ?:  (gth amount.args u.curr-bal)  data
        ::  adjust allowance and balances to reflect spend
        =:  allowances.data
          %+  ~(jab by allowances.data)
            [from.args caller-id]
          |=(bal=@ud (sub bal amount.args))
        ::
            balances.data
          ?.  (~(has by balances.data) to.args)
            ::  if receiver's account doesn't have a balance, insert
            %+  ~(jab by (~(put by balances.data) to.args amount.args))
              from.args
            |=(bal=@ud (sub bal amount.args))
          ::  otherwise, add to their existing balance
          %+  ~(jab by (~(jab by balances.data) to.args |=(bal=@ud (add bal amount.args))))
            from.args
          |=(bal=@ud (sub bal amount.args))
        ==
        data
      ::
          %set-allowance
        ::  expected args: sender, amount
        ?.  ?=([sender=id amount=@ud] args)  data
        data(allowances (~(put by allowances.data) [caller-id sender.args] amount.args))
      ==
    :-  %result
    [%write (malt ~[[zigs-rice-id u.zigs]]) ~]
  ::
  ++  read
    |=  inp=contract-input
    ^-  contract-output
    :+  %result
      %read
    ?~  args.inp  ~
    ?~  zigs=(~(get by rice.inp) zigs-rice-id)  ~
    ?>  =(lord.u.zigs me)
    =/  data  !<(token-data [-:!>(*token-data) data.germ.u.zigs])
    =*  args  +.u.args.inp
    ?+    -.u.args.inp  ~
        %get-balance
      ::  expected args: id
      ?.  ?=(=id args)  ~
      (~(get by balances.data) id.args)
    ::
        %get-allowance
      ::  expected args: owner, sender
      ?.  ?=([owner=id sender=id] args)  ~
      (~(get by allowances.data) [owner.args sender.args])
    ::
        %get-total
      ::  expected args: none
      total.data
    ==
  ::
  ++  event
    |=  inp=contract-result
    ^-  contract-output
    *contract-output
    ::  
    ::  TBD
    ::
  --
--
