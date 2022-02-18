/+  *zig-sys-smart
=>  |%
    +$  account
      $:  balance=@ud
          allowances=(map sender=id @ud)
      ==
    --
|_  =cart
++  write
  |=  inp=zygote
  ^-  chick
  =/  caller-id  (pin caller.inp)
  ?~  args.inp  !!
  =*  args  +.u.args.inp
  ?:  ?=(%give -.u.args.inp)
    ::  expects 2 rice -- giver in zygote, and givee in owns.cart
    ::  expects to-id, amount and budget as arguments
    ?.  ?=([to=id amount=@ud budget=@ud] args)  !!
    =/  giv=grain  -:~(val by grains.inp)
    =/  rec=grain  -:~(val by owns.cart)
    ?>  =(holder.giv caller-id)
    ?>  &(=(lord.giv me.cart) =(lord.rec me.cart))
    ?>  &(?=(%& -.germ.giv) ?=(%& -.germ.rec))
    =/  giver  (hole account data.p.germ.giv)
    =/  receiver  (hole account data.p.germ.rec)
    ?>  (gte balance.giver (add amount.args budget.args))
    =:  balance.giver  (sub balance.giver amount.args)
        balance.receiver  (add balance.receiver amount.args)
    ==
    =:  data.p.germ.giv  giver
        data.p.germ.rec  receiver
    ==
    [%& (malt ~[[id.giv giv] [id.rec rec]]) ~]
  ?:  ?=(%take -.u.args.inp)
    :: XX
    [%& ~ ~]
  ?:  ?=(%set-allowance -.u.args.inp)
    ::  expects 1 rice -- setter in zygote
    ::  expects id and amount as arguments
    ?.  ?=([sender=id amount=@ud] args)  !!
    =/  acc=grain  -:~(val by grains.inp)
    ?>  =(lord.acc me.cart)
    ?>  ?=(%& -.germ.acc)
    =/  account  (hole account data.p.germ.acc)
    ?>  (gte balance.account amount.args)
    =.  allowances.account
      (~(put by allowances.account) sender.args amount.args)
    =.  data.p.germ.acc  account
    [%& (malt ~[[id.acc acc]]) ~]
  !!
::
++  read
  |=  inp=path
  ^-  *
  "TBD"
::
++  event
  |=  inp=rooster
  ^-  chick
  ::
  ::  TBD
  ::
  *chick
--
