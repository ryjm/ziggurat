|_  =cart
++  write
  |=  inp=zygote
  ^-  chick
  |^
  =/  caller-id  (pin caller.inp)
  ?~  args.inp  !!
  =*  args  +.u.args.inp
  ?+    -.u.args.inp  !!
      %give
    ::  expects 2 rice -- giver in zygote, and givee in owns.cart
    ::  expects to-id, amount and budget as arguments
    ?.  ?=([to=id known=? amount=@ud budget=@ud] args)  !!
    =/  giv=grain  -:~(val by grains.inp)
    ?>  &(=(lord.giv me.cart) ?=(%& -.germ.giv))
    =/  giver  (hole account data.p.germ.giv)
    ?>  (gte balance.giver (add amount.args budget.args))
    ?:  known.args
      ::  if receiver is known, get rice from owns.cart
      =/  rec  `grain`-:~(val by owns.cart)
      ?>  &(=(holder.rec to.args) =(lord.rec me.cart) ?=(%& -.germ.rec))
      =/  receiver  (hole account data.p.germ.rec)
      =:  data.p.germ.giv  giver(balance (sub balance.giver amount.args))
          data.p.germ.rec  receiver(balance (add balance.receiver amount.args))
      ==
      [%& (malt ~[[id.giv giv] [id.rec rec]]) ~]
    ::  otherwise, try to make one
    =/  new-id  (fry-rice to.args me.cart town-id.cart 'zigs')
    =.  data.p.germ.giv  giver(balance (sub balance.giver amount.args))
    =+  [new-id me.cart to.args town-id.cart [%& 'zigs' [balance=amount.args allowances=~]]]
    [%& (malt ~[[id.giv giv]]) (malt ~[[new-id -]])]
  ::
      %take
    ::  expects the rice to take from in owns.cart,
    ::  produces a continuation call %give with caller set to
    ::  account to be taken from.
    ::  TODO
    !!
    ::  ?.  ?=([from=id amount=@ud to=id] args)  !!
    ::  =/  giv=grain  -:~(val by owns.cart)
    ::  ?>  &(=(holder.giv from.args) =(lord.giv me.cart) ?=(%& -.germ.giv))
    ::  =/  giver  (hole account data.p.germ.giv)
    ::  =/  allowance=@ud  (~(got by allowances.giver) caller-id)
    ::  ?>  (gte allowance amount.args)
    ::  ::  configure %give based on whether to.args is in address book
    ::  =/  bok   (~(got by owns.cart) `@ux`'address-book')
    ::  ?>  &(=(lord.bok me.cart) ?=(%& -.germ.bok))
    ::  =/  book  (hole address-book data.p.germ.bok)
    ::  ?~  rec=(~(get by book) to.args)
    ::      ::  make new account
    ::  ::  known account
    ::  =-  [%| mem=~ next=[me.cart town-id.cart -]]
    ::  [caller.inp `[%give to.args %.n amount.args budget.args] (silt ~[id.giv]) (silt ~[u.rec])]
  ::
      %set-allowance
    ::  expects 1 rice -- setter in zygote
    ::  expects id and amount as arguments
    ?.  ?=([sender=id amount=@ud] args)  !!
    =/  acc=grain  -:~(val by grains.inp)
    ?>  &(=(lord.acc me.cart) ?=(%& -.germ.acc))
    =/  account  (hole account data.p.germ.acc)
    ?>  (gte balance.account amount.args)
    =.  data.p.germ.acc
      account(allowances (~(put by allowances.account) sender.args amount.args))
    [%& (malt ~[[id.acc acc]]) ~]
  ==
  ::
  ::  molds used by writes to this contract
  ::
  +$  account
    $:  balance=@ud
        allowances=(map sender=id @ud)
    ==
  ::
  +$  address-book
    ::  this is to prevent fracturing of zigs account balances.
    ::  if a sender does not know the address of the account,
    ::  they can look it up here. a new rice is created for
    ::  accounts with no zigs, of course, but if an account has
    ::  a known zigs balance here, sends must be added to that.
    (map address=id zigs=id)
  --
::
++  read
  |=  inp=path
  ^-  *
  ::  give the balance of a zigs account in our address book?
  "XX"
::
++  event
  |=  inp=rooster
  ^-  chick
  ::
  ::  just return input for now to get proper granary behavior
  ::
  [%& inp]
--
