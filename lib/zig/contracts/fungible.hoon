::
::  Fungible token standard. Any new token that wishes to use this standard
::  format can be issued through this contract. The contract uses an account
::  model, where each pubkey holds one rice that contains their balance and
::  alllowances. (Allowances permit a certain pubkey to spend tokens on your
::  behalf.) When issuing a new token, you can either designate a pubkey or
::  pubkeys who is permitted to mint, or set a permanent supply, all of which
::  must be distributed at first issuance.
::
::  Each newly issued token also issues a single rice which stores metadata
::  about the token, which this contract both holds and is lord of, and must
::  be included in any transactions involving that token.
::
::  Many tokens that perform various utilities will want to retain control
::  over minting, burning, and sending. They can of course write their own
::  contract to custom-handle all of these scenarios, or write a manager
::  which performs custom logic but calls back to this contract for the
::  base token actions. Any token that maintains the same metadata and account
::  format, even if using a different contract (such as zigs) should be
::  composable among tools designed to this standard.
::
::  Tokens that wish to be properly displayed and handled with no additional
::  work in the wallet agent should implement the same structure for their
::  rice. In the future we can look to support other modes of data management,
::  such as UTXOs, single balance sheets, or hybrid models.
::
::  I will heavily comment this contract in order to make it a good example
::  for others to use.
::
|_  =cart
++  write
  |=  inp=zygote
  ^-  chick
  |^
  ?~  args.inp  !!
  (process (hole arguments u.args.inp) (pin caller.inp))
  ::
  ::  molds used by writes to this contract
  ::
  +$  token-metadata
    $:  name=@t           ::  the name of a token (not unique!)
        symbol=@t         ::  abbreviation (also not unique)
        decimals=@ud      ::  granularity, minimum 0, maximum 18
        supply=@ud        ::  total amount of token in existence
        cap=(unit @ud)    ::  supply cap (~ if mintable is false)
        mintable=?        ::  whether or not more can be minted
        minters=(set id)  ::  pubkeys permitted to mint, if any
        deployer=id       ::  pubkey which first deployed token
        salt=@            ::  data added to hash for rice IDs of this token
                          ::  (currently hashed: symbol+deployer)
    ==
  ::
  +$  account
    $:  balance=@ud                     ::  the amount of tokens someone has
        allowances=(map sender=id @ud)  ::  a map of pubkeys they've permitted to spend their tokens and how much
        metadata=id                     ::  address of the rice holding this token's metadata
    ==
  ::
  ::  patterns of arguments supported by this contract
  ::  "args" in input must fit one of these molds
  ::
  +$  arguments
    $%  ::  token holder actions
        ::
        [%give to=id to-rice=(unit id) amount=@ud]  
        [%take to=id to-rice=(unit id) from-rice=id amount=@ud]
        [%set-allowance who=id amount=@ud]  ::  (to revoke, call with amount=0)
        ::  token management actions
        ::
        [%mint to=(set [id bal=@ud])]  ::  can only be called by minters, can't mint above cap
        $:  %deploy
            distribution=(set [id bal=@ud])  ::  sums to <= cap if mintable, == cap otherwise
            minters=(set id)                 ::  ignored if !mintable, otherwise need at least one
            name=@t
            symbol=@t                        ::  size limit?
            decimals=@ud                     ::  min 0, max 18
            cap=@ud                          ::  is equivalent to total supply unless token is mintable
            mintable=?
        ==
    ==
  ::
  ::  the actual execution arm. branches on argument type and returns final result
  ::  note that many of these lines will crash with bad input. this is good,
  ::  because we don't want failing transactions to waste more gas than required
  ::
  ++  process
    |=  [args=arguments caller-id=id]
    ?-    -.args
        %give
      ::  grab giver's rice from the input. it should be only rice in the map
      =/  giv=grain  -:~(val by grains.inp)
      ?>  &(=(lord.giv me.cart) ?=(%& -.germ.giv))
      =/  giver=account  (hole account data.p.germ.giv)
      ?>  (gte balance.giver amount.args)
      ?~  to-rice.args
        ::  create new rice for reciever and add it to state
        =+  (fry-rice to.args me.cart town-id.cart salt.p.germ.giv)
        =/  new=grain
          [- me.cart to.args town-id.cart [%& salt.p.germ.giv [amount.args ~ metadata.giver]]]
        ::  continuation call: %give to rice we issued
        :^  %|  ~
          :+  me.cart  town-id.cart
          [caller.inp `[%give to.args `id.new amount.args] (silt ~[id.giv]) (silt ~[id.new])]
        [~ (malt ~[[id.new new]])]
      ::  if known, %give expects 2 rice, the giving account in zygote, and
      ::  the receiving one in owns.cart.
      =/  rec=grain  (~(got by owns.cart) u.to-rice.args)
      ?>  ?=(%& -.germ.rec)
      =/  receiver=account  (hole account data.p.germ.rec)
      ::  assert that tokens match
      ?>  =(metadata.receiver metadata.giver)
      ::  alter the two balances inside the grains
      =:  data.p.germ.giv  giver(balance (sub balance.giver amount.args))
          data.p.germ.rec  receiver(balance (add balance.receiver amount.args))
      ==
      ::  return the result: two changed grains
      [%& (malt ~[[id.giv giv] [id.rec rec]]) ~]
    ::
        %take
      ::  %take expects the account that will be taken from in owns.cart
      ::  if the receiving account is known, it will also be in owns.cart, otherwise
      ::  the address book should be there to find it, like in %give.
      =/  giv=grain  (~(got by owns.cart) from-rice.args)
      ?>  ?=(%& -.germ.giv)
      =/  giver=account  (hole account data.p.germ.giv)
      =/  allowance=@ud  (~(got by allowances.giver) caller-id)
      ::  assert caller is permitted to spend this amount of token
      ?>  (gte allowance amount.args)
      ?~  to-rice.args
        ::  create new rice for reciever and add it to state
        =+  (fry-rice to.args me.cart town-id.cart salt.p.germ.giv)
        =/  new=grain
          [- me.cart to.args town-id.cart [%& salt.p.germ.giv [amount.args ~ metadata.giver]]]
        ::  continuation call: %take to rice found in book
        :^  %|  ~
          :+  me.cart  town-id.cart
          [caller.inp `[%take to.args `id.new id.giv amount.args] ~ (silt ~[id.giv id.new])]
        [~ (malt ~[[id.new new]])]
      ::  direct send
      =/  rec=grain  (~(got by owns.cart) u.to-rice.args)
      ?>  ?=(%& -.germ.rec)
      =/  receiver=account  (hole account data.p.germ.rec)
      ?>  =(metadata.receiver metadata.giver)
      ::  update the allowance of taker
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
      ::  let some pubkey spend tokens on your behalf
      ::  note that you can arbitrarily allow as much spend as you want,
      ::  but spends will still be constrained by token balance
      ::  single rice expected, account
      =/  acc=grain  -:~(val by grains.inp)
      ?>  &(=(lord.acc me.cart) ?=(%& -.germ.acc))
      =/  =account  (hole account data.p.germ.acc)
      =.  data.p.germ.acc
        account(allowances (~(put by allowances.account) who.args amount.args))
      ::  return single changed rice
      [%& (malt ~[[id.acc acc]]) ~]
    ::
        %mint
      !!
    ::
        %deploy
      !!
    ::
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
