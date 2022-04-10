::  zigs.hoon [uqbar-dao]
::
::  Contract for 'zigs' (official name TBD) token, the gas-payment
::  token for the Uqbar network.
::  This token is unique from those defined by the token standard
::  because %give must include their gas budget, in order for
::  zig spends to be guaranteed not to underflow.
::
::  /+  *zig-sys-smart
|_  =cart
++  write
  |=  inp=zygote
  ^-  chick
  |^
  ?~  args.inp  !!
  (process (hole arguments u.args.inp) (pin caller.inp))
  ::
  +$  token-metadata
    ::  will be automatically inserted into town state
    ::  at instantiation, along with this contract
    $:  name=@t
        symbol=@t
        decimals=@ud
        supply=@ud
        cap=(unit @ud)
        mintable=?  ::  will be unmintable, with zigs instead generated in mill
        minters=(set id)
        deployer=id  ::  will be 0x0
        salt=@  ::  'zigs'
    ==
  ::
  +$  account
    $:  balance=@ud
        allowances=(map sender=id @ud)
        metadata=id
    ==
  ::
  +$  arguments
    $%  [%give to=id to-rice=(unit id) amount=@ud budget=@ud]
        [%take to=id to-rice=(unit id) from-rice=id amount=@ud]
        [%set-allowance who=id amount=@ud]  ::  (to revoke, call with amount=0)
    ==
  ::
  ++  process
    |=  [args=arguments caller-id=id]
    ?-    -.args
        %give
      =/  giv=grain  -:~(val by grains.inp)
      ?>  &(=(lord.giv me.cart) ?=(%& -.germ.giv))
      =/  giver=account  (hole account data.p.germ.giv)
      ?>  (gte balance.giver (add amount.args budget.args))
      ?~  to-rice.args
        =+  (fry-rice to.args me.cart town-id.cart salt.p.germ.giv)
        =/  new=grain
          [- me.cart to.args town-id.cart [%& salt.p.germ.giv [0 ~ metadata.giver]]]
        :^  %|  ~
          :+  me.cart  town-id.cart
          [caller.inp `[%give to.args `id.new amount.args budget.args] (silt ~[id.giv]) (silt ~[id.new])]
        [~ (malt ~[[id.new new]])]
      =/  rec=grain  (~(got by owns.cart) u.to-rice.args)
      ?>  ?=(%& -.germ.rec)
      =/  receiver=account  (hole account data.p.germ.rec)
      ?>  =(metadata.receiver metadata.giver)
      =:  data.p.germ.giv  giver(balance (sub balance.giver amount.args))
          data.p.germ.rec  receiver(balance (add balance.receiver amount.args))
      ==
      [%& (malt ~[[id.giv giv] [id.rec rec]]) ~]
    ::
        %take
      =/  giv=grain  (~(got by owns.cart) from-rice.args)
      ?>  ?=(%& -.germ.giv)
      =/  giver=account  (hole account data.p.germ.giv)
      =/  allowance=@ud  (~(got by allowances.giver) caller-id)
      ?>  (gte balance.giver amount.args)
      ?>  (gte allowance amount.args)
      ?~  to-rice.args
        =+  (fry-rice to.args me.cart town-id.cart salt.p.germ.giv)
        =/  new=grain
          [- me.cart to.args town-id.cart [%& salt.p.germ.giv [amount.args ~ metadata.giver]]]
        :^  %|  ~
          :+  me.cart  town-id.cart
          [caller.inp `[%take to.args `id.new id.giv amount.args] ~ (silt ~[id.giv id.new])]
        [~ (malt ~[[id.new new]])]
      =/  rec=grain  (~(got by owns.cart) u.to-rice.args)
      ?>  ?=(%& -.germ.rec)
      =/  receiver=account  (hole account data.p.germ.rec)
      ?>  =(metadata.receiver metadata.giver)
      =.  allowances.giver
        %+  ~(jab by allowances.giver)  caller-id
        |=(old=@ud (sub old amount.args))
      =:  data.p.germ.rec  receiver(balance (add balance.receiver amount.args))
          data.p.germ.giv
        %=  giver
          balance  (sub balance.giver amount.args)
          allowances  (~(jab by allowances.giver) caller-id |=(old=@ud (sub old amount.args)))
        == 
      ==
      [%& (malt ~[[id.giv giv] [id.rec rec]]) ~]
    ::
        %set-allowance
      =/  acc=grain  -:~(val by grains.inp)
      ?>  &(=(lord.acc me.cart) ?=(%& -.germ.acc))
      =/  =account  (hole account data.p.germ.acc)
      =.  data.p.germ.acc
        account(allowances (~(put by allowances.account) who.args amount.args))
      [%& (malt ~[[id.acc acc]]) ~]
    ==
  --
::
::  not yet using these
::
++  read
  |=  inp=path
  ^-  *
  ~
::
++  event
  |=  inp=rooster
  ^-  chick
  *chick
--
