/+  *zig-sys-smart
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
  =+  caller-id=(pin caller.inp)
  ?~  args.inp  !!
  (process (hole arguments +.u.args.inp))
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
        book=id           ::  pubkey of address book
        salt=@            ::  data added to hash for rice IDs of this token
    ==
  ::
  +$  address-book  (map id id)  ::  map of pubkey to account rice
  ::
  +$  account
    $:  balance=@ud  ::  the amount of tokens someone has
        ::  a map of pubkeys they've permitted to spend their tokens,
        allowances=(map sender=id @ud)  ::  and how much
        metadata=id  ::  address of the rice holding this token's metadata
        book=id      ::  address of the rice holding this token's address book
    ==
  ::
  ::  patterns of arguments supported by this contract
  ::  "args" in input must fit one of these molds
  ::
  +$  arguments
    $%  ::  token holder actions
        [%give to=id known=? amount=@ud]
        [%take to=id known=? from=id amount=@ud]
        [%set-allowance who=id amount=@ud]  ::  (to revoke, call with amount=0)
        ::  token management actions
        [%mint to=(set [id bal=@ud])]  ::  can only be called by minters, can't mint above cap
        $:  %deploy
            distribution=(set [id bal=@ud])  ::  sums to <= cap if mintable, == cap otherwise
            minters=(set id)  ::  ignored if !mintable, otherwise need at least one
            name=@t
            symbol=@t         ::  size limit?
            decimals=@ud      ::  min 0, max 18
            cap=@ud           ::  is equivalent to total supply unless token is mintable
            mintable=?
        ==
    ==
  ::
  ::  the actual execution arm. branches on argument type and returns final result
  ::  note that many of these lines will crash with bad input. this is good,
  ::  because we don't want failing transactions to waste more gas than required
  ::
  ++  process
    |=  args=arguments
    ?-    -.args
        %give
      ::  grab giver's rice from the input. it should be only rice in the map
      =/  giv=grain  -:~(val by grains.inp)
      ?>  &(=(lord.giv id) ?=(%& -.germ.giv))
      =/  giver=account  (hole account data.p.germ.giv)
      ?>  (gte balance.giver amount.args)
      ?:  known.args
        ::  if known, %give expects 2 rice, the giving account in zygote, and
        ::  the receiving one in owns.cart.
        =/  rec=grain  -:~(val by owns.cart)
        ?>  &(=(lord.rec id) ?=(%& -.germ.rec))
        =/  receiver=account  (hole account data.p.germ.rec)
        ::  alter the two balances inside the grains
        =:  data.p.germ.giv  giver(balance (sub balance.giver amount.args))
            data.p.germ.rec  receiver(balance (add balance.receiver amount.args))
        ==
        ::  return the result: two changed grains
        [%& (malt ~[[id.giv giv] [id.rec rec]]) ~]
      ::  if !known, we check the address book to see if rice exists.
      ::  if it does, we issue a %give to it, otherwise we issue a new rice and %give.
      =/  bok=grain  -:~(val by owns.cart)
      ?>  &(=(lord.bok id) ?=(%& -.germ.bok))
      =/  book=address-book  (hole address-book data.p.germ.bok)
      ?~  rec=(~(get by book) to.args)
        ::  create new rice for reciever and add it to state, passing it into
        ::  a continuation-call that will attempt to use %give on this new rice.
        =/  new-id=id  (fry-rice to.args me.cart town-id.cart salt.p.germ.giv)
        =/  new-grain=grain
          [new-id me.cart to.args town-id.cart [%& salt.p.germ.giv [0 ~ metadata.giver book.giver]]]
        :^  %|  ~
          :+  me.cart  town-id.cart
          [caller.inp `[%give to.args %.y amount.args] (silt ~[id.giv]) (silt ~[new-id])]
        [~ (malt ~[[new-id new-grain]])]
      ::  %give to rice found in book
      :^  %|  ~
        :+  me.cart  town-id.cart
        [caller.inp `[%give to.args %.y amount.args] (silt ~[id.giv]) (silt ~[u.rec])]
      [~ ~]
    ::
        %take
      !!
    ::
        %set-allowance
      !!
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
