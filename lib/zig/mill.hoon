/+  *bink, *zig-sys-smart
|_  [validator-id=@ux town-id=@ud] :: now=time]
::
::  +mill-all: mills all eggs in mempool
::
++  mill-all
  |=  [=town mempool=(list egg) block=@ud]
  =/  pending
    %+  sort  mempool
    |=  [a=egg b=egg]
    (gth rate.stamp.p.a rate.stamp.p.b)
  =|  result=(list [@ux egg])
          ::  'chunk' def
  =/  fee-bundle=(unit yolk)
    :^  ~  [validator-id +((~(got by q.town) validator-id))]
      [~ %send *(map id (map id @ud))]
    *(set id)
  =/  town-and-fee-bundle  [town fee-bundle]
  |-  ^-  [(list [@ux egg]) ^town]
  ?~  pending
    =.  town        -.town-and-fee-bundle
    =.  fee-bundle  +.town-and-fee-bundle
    ?~  fee-bundle  [result town]
    =/  fee-egg=egg  (~(invoice tax town block) town-id u.fee-bundle)
    =/  gan=granary  (~(pay tax town block) fee-egg)
    :+  [[`@ux`(shax (jam fee-egg)) fee-egg] result]
      gan
    ?:  ?=(id caller.u.fee-bundle)  q.town
    (~(put by q.town) validator-id nonce.caller.u.fee-bundle)
  %_  $
    pending              t.pending
    result               [[`@ux`(shax (jam i.pending)) i.pending] result]
    town-and-fee-bundle  (mill town i.pending block fee-bundle)
  ==
::  +mill: processes a single egg and returns updated town
::
++  mill
  |=  [=town =egg block=@ud fee-bundle=(unit yolk)]
  ^-  [^town (unit yolk)]
  ?.  ?=(user from.p.egg)  [town ~]
  ?~  curr-nonce=(~(get by q.town) id.from.p.egg)
    [town ~]  ::  missing user
  ?.  =(nonce.from.p.egg +(u.curr-nonce))
    [town ~]  ::  bad nonce
  ?.  (~(audit tax town block) egg)
    [town ~]  ::  can't afford gas
  =+  [gan rem]=(~(work farm p.town block) egg)
  =/  fee=@ud   (sub budget.stamp.p.egg rem)
  ?~  gan  [town ~]
  =.  q.town  (~(put by q.town) id.from.p.egg nonce.from.p.egg)
  =+  [gan-out fee-bundle-out]=(~(note-or-pay tax [u.gan q.town] block) egg fee town-id fee-bundle)
  :-  :-  gan-out
    ?~  fee-bundle
      ?~  fee-bundle-out  q.town
      ?:  ?=(id caller.u.fee-bundle-out)  q.town
      %+  %~  put  by  q.town
        id.caller.u.fee-bundle-out
      nonce.caller.u.fee-bundle-out
    q.town
  fee-bundle-out
::
::  +tax: manage payment for contract execution in zigs
::
++  tax
  |_  [=town block=@ud]
  ::  +audit: evaluate whether a caller can afford gas
  ++  audit
    |=  =egg
    ^-  ?
    =/  grains=(map id grain)  (fetch egg)
    ~&  >  "auditing"
    ?~  fee-rice=(~(get by grains) fee.stamp.p.egg)  %.n
    ?.  ?=(%& -.germ.u.fee-rice)                     %.n
    ?.  =(zigs-wheat-id lord.u.fee-rice)             %.n
    =*  bal  data.p.germ.u.fee-rice
    ?.  ?=(@ud bal)                                  %.n
    ~&  >>  bal
    (gth bal (mul rate.stamp.p.egg budget.stamp.p.egg))
  ::  +fetch: get grains for fee rice
  ++  fetch
    |=  =egg
    ^-  (map id grain)
    =|  =yolk
    ?.  ?=(user from.p.egg)  *(map id grain)
    =:  caller.yolk     from.p.egg
        args.yolk       ~
        grain-ids.yolk  (silt ~[fee.stamp.p.egg change.stamp.p.egg])
    ==
    =/  =scramble
      (~(cook farm p.town block) yolk)
    grains.scramble
  ::  +note-or-pay: notes or pays fee as appropriate
  ++  note-or-pay
    |=  [=egg fee=@ud town-id=@ud fee-bundle=(unit yolk)]
    ^-  [granary (unit yolk)]
    ?~  fee-bundle
      =/  fee-egg=^egg
        (invoice town-id (tally egg fee ~))
      [(pay fee-egg) fee-bundle]
    [p.town (note egg fee fee-bundle)]
  ::  +note: store gas fee for payment in accumulated tx
  ++  note
    |=  [=egg fee=@ud fee-bundle=(unit yolk)]
    ^-  (unit yolk)
    ?~  fee-bundle  ~
    =/  from=id
      ?:  ?=(id from.p.egg)  from.p.egg
      id.from.p.egg
    ::  bump nonce of fee-bundle if this tx was by validator
    =.  caller.u.fee-bundle
      ?:  ?=(id caller.u.fee-bundle)
        caller.u.fee-bundle
      :-  id.caller.u.fee-bundle
      ?.  =(validator-id from)
        nonce.caller.u.fee-bundle
      +(nonce.caller.u.fee-bundle)
    [~ (tally egg fee fee-bundle)]
  ::  +invoice: create egg for payment of fee
  ++  invoice
    |=  [town-id=@ud fee-bundle=yolk]
    ^-  egg
    =|  =shell
    =:  from.shell     caller.fee-bundle
        to.shell       zigs-wheat-id
        stamp.shell    *stamp  ::  unused placeholder
        town-id.shell  town-id
    ==
    [p=shell q=fee-bundle]
  ::  +tally: create yolk for payment of fee
  ++  tally
    |=  [=egg fee=@ud fee-bundle=(unit yolk)]
    ^-  yolk
    =/  grains=(map id grain)  (fetch egg)
    =/  from=id
      ?:  ?=(id from.p.egg)  from.p.egg
      id.from.p.egg
    =/  from-grain  (~(got by grains) from)
    ?>  ?=(%& -.germ.from-grain)
    =*  bal  data.p.germ.from-grain
    ?>  ?=(@ud bal)
    =/  transactions=(map id (map id @ud))
      %+  %~  put  by  *(map id (map id @ud))  from
      %-  %~  gas  by  *(map id @ud)
      ~[[validator-id fee] [change.stamp.p.egg (sub bal fee)]]
    =/  grain-ids=(set id)  (silt ~[from])
    ?~  fee-bundle
      :+  [validator-id +((~(got by q.town) validator-id))]
        [~ %send transactions]
      grain-ids
    :+  caller.u.fee-bundle
      :+  ~  %send
      ?~  args.u.fee-bundle  transactions
      =/  old-tx
        ;;((map id (map id @ud)) +.u.args.u.fee-bundle)
      ?~  (~(get by old-tx) from)
        (~(uni by old-tx) transactions)
      %+  %~  put  by  old-tx  from
      %-  %~  uni  by  (~(got by old-tx) from)
      (~(got by transactions) from)
    (~(uni in grain-ids.u.fee-bundle) grain-ids)
  ::  +pay: extract gas fee from caller's zigs balance
  ++  pay
    |=  fees=egg
    ^-  granary
    ~&  >  "paying taxes"
    =+  [gan rem]=(~(work farm p.town block) fees)
    ?~  gan  !!
    u.gan
  --
::
::  +farm: execute an egg to a contract within a wheat
::
++  farm
  |_  [=granary block=@ud]
  ::
  ++  work
    |=  =egg
    ^-  [(unit ^granary) @ud]
    =/  crop  (incubate egg(budget.stamp.p (div budget.stamp.p.egg rate.stamp.p.egg)))
    :_  +.crop
    ?~  -.crop  ~
    (harvest u.-.crop to.p.egg)
  ::
  ++  incubate
    |=  =egg
    ^-  [(unit male) @ud]
    |^
    =/  args  (cook q.egg)
    ?~  stalk=(germinate to.p.egg)
      `budget.stamp.p.egg
    (grow u.stalk args egg)
    ::  might move these out of farm to be used everywhere
    ::  also TODO fix mixed metaphor here
    ++  germinate
      |=  find=id
      ^-  (unit crop)
      ?~  gra=(~(get by granary) find)  ~
      ?.  ?=(%| -.germ.u.gra)  ~
      ?~  cont.p.germ.u.gra  ~
      `[(hole contract u.cont.p.germ.u.gra) owns.p.germ.u.gra]
    --
  ::
  ++  cook
    |=  =yolk
    ^-  scramble
    ?.  ?=(user caller.yolk)  !!
    :+  caller.yolk
      args.yolk
    %-  ~(gas by *(map id grain))
    %+  murn  ~(tap in grain-ids.yolk)
    |=  =id
    ?~  grain=(~(get by granary) id)  ~
    ?.  ?=(%& -.germ.u.grain)  ~
    ::  check that caller holds all input grain
    ?.  =(holder.u.grain id.caller.yolk)  ~
    `[id u.grain]
  ::
  ++  grow
    |=  [=crop =scramble =egg]
    ^-  [(unit male) @ud]
    |^
    =+  [chick rem]=(weed crop to.p.egg [%& scramble] ~ budget.stamp.p.egg)
    ~&  >  "1st weeding successful"
    ?~  chick  `rem
    ?:  ?=(%& -.u.chick)
      ::  male result, finished growing
      [`p.u.chick rem]
    ::  female result, continuation
    |-
    =*  next  next.p.u.chick
    =*  mem   mem.p.u.chick
    =^  child  rem
      (incubate egg(from.p to.p.egg, to.p to.next, budget.stamp.p rem, q args.next))
    ?~  child  `rem
    =/  gan  (harvest u.child to.p.egg)
    ?~  gan  `rem
    =.  granary  u.gan
    =^  eve  rem
      (weed crop to.p.egg [%| u.child] mem rem)
    ?~  eve  `rem
    ?:  ?=(%& -.u.eve)
      [`p.u.eve rem]
    %_  $
      next.p.u.chick  next.p.u.eve
      mem.p.u.chick   mem.p.u.eve
    ==
    ::
    ++  weed
      |=  [=^crop to=id inp=maybe-hatched mem=(unit vase) budget=@ud]
      ^-  [(unit chick) @ud]
      =/  owned
        %-  ~(gas by *(map id grain))
        %+  murn  ~(tap in owns.crop)
        |=  =id
        ?~  res=(~(get by granary) id)   ~
        ?.  =(holder.u.res to)  ~
        `[id u.res]
      =/  cart  [mem to block town-id -]
      =+  [res bud]=(barn contract.crop inp cart budget)
      ?~  res               `bud
      ?:  ?=(%| -.u.res)    `bud
      ?:  ?=(%& -.p.u.res)  `bud
      ::  write or event result
      [`p.p.u.res bud]
    ::
    ::  +barn: run contract formula with arguments and memory, bounded by bud
    ::  (takes yolk and runs write)
    ++  barn
      |=  [=contract inp=maybe-hatched =cart bud=@ud]
      ^-  [(unit (each (each * chick) (list tank))) @ud]
      |^
      ::  hellaciously ugly
      ?:  ?=(%| -.inp)
        ::  event
        =/  res  (event p.inp)
        ?~  -.res  `+.res
        ?:  ?=(%& -.u.-.res)
          [`[%& %| p.u.-.res] +.res]
        [`[%| p.u.-.res] +.res]
      ::  write
      =/  res  (write p.inp)
      ?~  -.res  `+.res
      ?:  ?=(%& -.u.-.res)
        [`[%& %| p.u.-.res] +.res]
      [`[%| p.u.-.res] +.res]
      ::  TODO read (scry)
      ::  =/  res  (read ;;(path +.args.p.inp))
      ::  ?~  -.res  `+.res
      ::  ?:  ?=(%& -.u.-.res)
      ::    [`[%& %& p.u.-.res] +.res]
      ::  [`[%| p.u.-.res] +.res]
      ::
      ::  note:  i believe the way we're using ;; here destroys
      ::  any trace data we may get out of the contract. the
      ::  output trace ends up resolving at the ;; rather than
      ::  wherever in the contract caused a stack trace.
      ::
      ::  using +mule here and charging no gas until jet dashboard for +bink
      ++  write
        |=  =^scramble
        ^-  [(unit (each chick (list tank))) @ud]
        ~&  >  "barn performing %write call"
        :_  bud
        `(mule |.(;;(chick (~(write contract cart) scramble))))
      ++  read
        |=  =path
        ^-  [(unit (each * (list tank))) @ud]
        ~&  >  "barn performing %read call"
        (bull |.((~(read contract cart) path)) bud)
      ++  event
        |=  =male
        ^-  [(unit (each chick (list tank))) @ud]
        ~&  >  "barn performing %event call"
        (bull |.(;;(chick (~(event contract cart) male))) bud)
      --
    --
  ::
  ++  harvest
    |=  [res=male lord=id]
    ^-  (unit ^granary)
    ::  null (unit grain)s in changed.res are removed
    ::  from granary; others are modified
    =/  changed  ~(tap by changed.res)
    =|  modified=(map id grain)
    =.  modified
    |-  ^-  (map id grain)
    ?~  changed  modified
    =*  id     p.i.changed
    =*  grain  q.i.changed
    ?~  grain
      =.  granary  (~(del by granary) id)  ::  TODO: will del happen on harvest check fail? If yes: fix
      $(changed t.changed)
    $(modified (~(put by modified) id u.grain), changed t.changed)
    =-  ?.  -  ~
        ~&  >  "passed harvest checks"
        `(~(uni by granary) (~(uni by modified) issued.res))
    ?&  %-  ~(all in changed.res)
        |=  [=id grain=(unit grain)]
        ::  id in changed map must be equal to id in grain AND
        ::  all changed grains must already exist AND
        ::  no changed grains may also have been issued at same time AND
        ::  only grains that proclaim us lord may be changed
        ?&  ?~(grain %.y =(id id.u.grain))
            (~(has by granary) id)
            !(~(has by issued.res) id)
            =(lord lord:(~(got by granary) id))
        ==
      ::
        %-  ~(all in issued.res)
        |=  [=id =grain]
        ::  id in issued map must be equal to id in grain AND
        ::  all newly issued grains must have properly-hashed id AND
        ::  lord of grain must be contract issuing it
        ?&  =(id id.grain)
            =((fry lord.grain town-id.grain germ.grain) id.grain)
            =(lord lord.grain)
    ==  ==
  --
--
