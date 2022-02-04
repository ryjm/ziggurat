/+  tiny
=>  |%
    +$  token-data
      $:  total=@ud
          balances=(map id:tiny @ud)
          allowances=(map [owner=id:tiny sender=id:tiny] @ud)
          coinbase-rate=@ud
      ==
    --
|%
++  test-good-altcoin-contract
  ^-  contract:tiny
  |_  [mem=(unit vase) me=id:tiny]
  ++  write
    |=  inp=contract-input:tiny
    ^-  contract-output:tiny
    ?~  args.inp  *contract-output:tiny
    ?~  tgas=(~(get by rice.inp) me)  *contract-output:tiny
    =/  data  ;;(token-data data.germ.u.tgas)
    =/  caller-id=id:tiny
      ?:  ?=(@ux caller.inp)
        caller.inp
      id.caller.inp
    =*  args  +.u.args.inp
    =.  data.germ.u.tgas
      ?+    -.u.args.inp  data
          %give
        ::  expected args: id, amount
        ?.  ?=([=id:tiny amount=@ud] args)  data
        ::  check our balance to make sure we can afford spend
        ?~  curr-bal=(~(get by balances.data) id.args)  data
        ?:  (gth amount.args u.curr-bal)  data
        ::  add to receiver balance, subtract from ours
        =.  balances.data
          ::  this pattern could be a good stdlib function
          %+  %~  jab  by
              ?.  (~(has by balances.data) id.args)
                ::  if receiver's account doesn't have a balance, insert
                (~(put by balances.data) id.args amount.args)
              ::  otherwise, add to their existing balance
              (~(jab by balances.data) id.args |=(bal=@ud (add bal amount.args)))
            caller-id
          |=(bal=@ud (sub bal amount.args))
        data
      ::
          %take
        ::  expected args: from, to, amount
        ?.  ?=([from=id:tiny to=id:tiny amount=@ud] args)  data
        :: TODO: write %take
        data
      ::
          %set-allowance
        ::  expected args: sender, amount
        ?.  ?=([sender=id:tiny amount=@ud] args)  data
        :: TODO: write %set-allowance
        data
      ==
    *contract-output:tiny
  ::
  ++  read
    |=  inp=contract-input:tiny
    ^-  contract-output:tiny
    *contract-output:tiny
  ::
  ++  event
    |=  res=contract-result:tiny
    ^-  contract-output:tiny
    *contract-output:tiny
  --
--
