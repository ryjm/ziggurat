/+  *bink, smart=zig-sys-smart
/*  smart-lib  %noun  /lib/zig/sys/smart-lib-2/noun
=,  smart
|_  library=*
++  mill
  |_  [miller=account town-id=@ud blocknum=@ud now=time]
  ::
  ::  +mill-all: mills all eggs in basket
  ::
  ++  mill-all
    |=  [=town basket=(list egg)]
    =/  pending
      %+  sort  basket
      |=  [a=egg b=egg]
      (gth rate.p.a rate.p.b)
    =|  [processed=(list [@ux egg]) reward=@ud]
    |-
    ^-  [(list [@ux egg]) ^town]
    ?~  pending
      [processed town(p (~(pay tax p.town) reward))]
    =+  [res fee]=(mill town i.pending)
    %_  $
      pending    t.pending
      processed  [[`@ux`(shax (jam i.pending)) i.pending] processed]
      town       res
      reward     (add reward fee)
    ==
  ::  +mill: processes a single egg and returns updated town
  ::
  ++  mill
    |=  [=town =egg]
    ^-  [^town fee=@ud]
    ?.  ?=(account from.p.egg)  [town 0]
    ::  validate transaction signature
    =/  them  (com:nu:crub:crypto id.from.p.egg)
    ?.  =(`(sham (jam q.egg)) (sure:as.them sig.p.egg))
      [town 0]  ::  bad signature
    ?~  curr-nonce=(~(get by q.town) id.from.p.egg)
      [town 0]  ::  missing account
    ?.  =(nonce.from.p.egg +(u.curr-nonce))
      ~&  >>>  "tx rejected; bad nonce"
      [town 0]  ::  bad nonce
    ?.  (~(audit tax p.town) egg)
      ~&  >>>  "tx rejected; not enough budget"
      [town 0]  ::  can't afford gas
    =+  [gan rem]=(~(work farm p.town) egg)
    =/  fee=@ud   (sub budget.p.egg rem)
    :_  fee
    :-  (~(charge tax ?~(gan p.town u.gan)) from.p.egg fee)
    (~(put by q.town) id.from.p.egg nonce.from.p.egg)
  ::
  ::  +tax: manage payment for egg in zigs
  ::
  ++  tax
    |_  =granary
    +$  account-mold
      $:  balance=@ud
          allowances=(map sender=id @ud)
      ==
    ::  +audit: evaluate whether a caller can afford gas
    ++  audit
      |=  =egg
      ^-  ?
      ?.  ?=(account from.p.egg)                    %.n
      ?~  zigs=(~(get by granary) zigs.from.p.egg)  %.n
      ?.  ?=(%& -.germ.u.zigs)                      %.n
      =/  acc  (hole account-mold data.p.germ.u.zigs)
      (gth balance.acc budget.p.egg)
    ::  +charge: extract gas fee from caller's zigs balance
    ++  charge
      |=  [payee=account fee=@ud]
      ^-  ^granary
      ?~  zigs=(~(get by granary) zigs.payee)  granary
      ?.  ?=(%& -.germ.u.zigs)                 granary
      =/  acc  (hole account-mold data.p.germ.u.zigs)
      =.  balance.acc  (sub balance.acc fee)
      =.  data.p.germ.u.zigs  acc
      (~(put by granary) zigs.payee u.zigs)
    ::  +pay: give fees from eggs to miller
    ++  pay
      |=  total=@ud
      ^-  ^granary
      ?~  zigs=(~(get by granary) zigs.miller)  granary
      ?.  ?=(%& -.germ.u.zigs)                  granary
      =/  acc  (hole account-mold data.p.germ.u.zigs)
      =.  balance.acc  (add balance.acc total)
      =.  data.p.germ.u.zigs  acc
      (~(put by granary) zigs.miller u.zigs)
    --
  ::
  ::  +farm: execute a call to a contract within a wheat
  ::
  ++  farm
    |_  =granary
    ::
    ++  work
      |=  =egg
      ^-  [(unit ^granary) @ud]
      =/  hatchling
        (incubate egg(budget.p (div budget.p.egg rate.p.egg)))
      :_  +.hatchling
      ?~  -.hatchling  ~
      (harvest u.-.hatchling to.p.egg from.p.egg)
    ::
    ++  incubate
      |=  =egg
      ^-  [(unit rooster) @ud]
      ~&  >>  "incubating"
      |^
      =/  args  (fertilize q.egg)
      ?~  stalk=(germinate to.p.egg cont-grains.q.egg)
        ~&  >>>  "failed to germinate"
        `budget.p.egg
      (grow u.stalk args egg)
      ::
      ++  fertilize
        |=  =yolk
        ^-  zygote
        ?.  ?=(account caller.yolk)  !!
        :+  caller.yolk
          args.yolk
        %-  ~(gas by *(map id grain))
        %+  murn  ~(tap in my-grains.yolk)
        |=  =id
        ?~  res=(~(get by granary) id)      ~
        ?.  ?=(%& -.germ.u.res)             ~
        ?.  =(holder.u.res id.caller.yolk)  ~
        ?.  =(town-id.u.res town-id)        ~
        `[id u.res]
      ::
      ++  germinate
        |=  [find=id grains=(set id)]
        ^-  (unit crop)
        ?~  gra=(~(get by granary) find)  ~
        ?.  ?=(%| -.germ.u.gra)           ~
        ?~  cont.p.germ.u.gra             ~
        :+  ~
          u.cont.p.germ.u.gra
        %-  ~(gas by *(map id grain))
        %+  murn  ~(tap in grains)
        |=  =id
        ?~  res=(~(get by granary) id)  ~
        ?.  ?=(%& -.germ.u.res)         ~
        ?.  =(lord.u.res find)          ~
        ?.  =(town-id.u.res town-id)    ~
        `[id u.res]
      ::
      ::  ++  compile
      ::    |=  nok=*
      ::    ^-  contract
      ::    ::=/  cued  (cue q.q.smart-lib)
      ::    ::  crazy weird issue: importing this way results in unjetted execution (my guess)
      ::    ::  ~&  >>>  "smart-lib size: {<(met 3 (jam cued))>}"
      ::    ::  ~&  >>>  "library size: {<(met 3 (jam library))>}"
      ::    ::  ~&  >>>  "are they equal? {<=(cued library)>}"
      ::    ::  contract execution with this is ~10x slower :/
      ::    (hole contract [nok library])
      --
    ::
    ++  grow
      |=  [=crop =zygote =egg]
      ~>  %bout
      ^-  [(unit rooster) @ud]
      |^
      =+  [chick rem]=(weed crop to.p.egg [%& zygote] ~ budget.p.egg)
      ?~  chick  `rem
      ?:  ?=(%& -.u.chick)
        ::  rooster result, finished growing
        [`p.u.chick rem]
      ::  hen result, continuation
      |-
      =*  next  next.p.u.chick
      =*  mem   mem.p.u.chick
      ::  make it so continuation calls can alter grains, this is important
      ?~  gan=(harvest roost.p.u.chick to.p.egg from.p.egg)
        `rem
      =.  granary  u.gan 
      =^  child  rem
        (incubate egg(from.p to.p.egg, to.p to.next, budget.p rem, q args.next))
      ?~  child  `rem
      ::  =/  gan  (harvest u.child to.p.egg from.p.egg)
      ::  ?~  gan  `rem
      [child rem]
      ::  this event trigger phase actually wipes the result of continuations,
      ::  no bueno. need to move the event trigger inside the above loop.
      ::  above always returns a result, anyways.
      ::  =.  granary  u.gan
      ::  =^  eve  rem
      ::    (weed crop to.p.egg [%| u.child] mem rem)
      ::  ?~  eve  `rem
      ::  ?:  ?=(%& -.u.eve)
      ::    [`p.u.eve rem]
      ::  %_  $
      ::    next.p.u.chick  next.p.u.eve
      ::    mem.p.u.chick   mem.p.u.eve
      ::  ==
      ::
      ++  weed
        |=  [=^crop to=id inp=embryo mem=(unit vase) budget=@ud]
        ^-  [(unit chick) @ud]
        =/  cart  [mem to blocknum town-id owns.crop]
        =+  [res bud]=(barn nok.crop inp cart budget)
        ?~  res               `bud
        ?:  ?=(%| -.u.res)  
          ~&  >>>  p.u.res    `bud
        ?:  ?=(%& -.p.u.res)  `bud
        ::  write or event result
        [`p.p.u.res bud]
      ::
      ::  +barn: run contract formula with arguments and memory, bounded by bud
      ::  [note: contract reads are scrys performed in sequencer]
      ++  barn
        |=  [nok=* inp=embryo =cart bud=@ud]
        ^-  [(unit (each (each * chick) (list tank))) @ud]
        ::  TODO figure out how to pre-cue this and get good results
        =/  =contract  (hole contract [nok +:(cue q.q.smart-lib)])
        |^
        ::~&  >>  "cart: {<cart>}"
        ::~&  >  "inp: {<inp>}" 
        ?:  ?=(%| -.inp)
          ::  event
          =/  res  (event p.inp)
          ::~&  >>>  "res: {<res>}"
          ?~  -.res  `+.res
          ?:  ?=(%& -.u.-.res)
            [`[%& %| p.u.-.res] +.res]
          [`[%| p.u.-.res] +.res]
        ::  write
        =/  res  (write p.inp)
        ::~&  >>>  "res: {<res>}"
        ?~  -.res  `+.res
        ?:  ?=(%& -.u.-.res)
          [`[%& %| p.u.-.res] +.res]
        [`[%| p.u.-.res] +.res]
        ::
        ++  write
          |=  =^zygote
          ^-  [(unit (each chick (list tank))) @ud]
          ::  need jet dashboard to run bull
          ::  (bull |.(;;(chick (~(write contract cart) zygote))) bud)
          :_  (sub bud 7)
          `(mule |.(;;(chick (~(write contract cart) zygote))))
        ++  event
          |=  =rooster
          ^-  [(unit (each chick (list tank))) @ud]
          ::  (bull |.(;;(chick (~(event contract cart) rooster))) bud)
          :_  (sub bud 8)
          `(mule |.(;;(chick (~(event contract cart) rooster))))
        --
      --
    ::
    ++  harvest
      |=  [res=rooster lord=id from=caller]
      ^-  (unit ^granary)
      =-  ?.  -  
            ~&  >>>  "harvest checks failed"  
            ~
          `(~(uni by granary) (~(uni by changed.res) issued.res))
      ?&  %-  ~(all in changed.res)
          |=  [=id =grain]
          ::  id in changed map must be equal to id in grain AND
          ::  all changed grains must already exist AND
          ::  no changed grains may also have been issued at same time AND
          ::  only grains that proclaim us lord may be changed
          ?&  =(id id.grain)
              (~(has by granary) id.grain)
              !(~(has by issued.res) id.grain)
              =(lord lord:(~(got by granary) id))
          ==
        ::
          %-  ~(all in issued.res)
          |=  [=id =grain]
          ::  id in issued map must be equal to id in grain AND
          ::  all newly issued grains must have properly-hashed id AND
          ::  lord of grain must be contract issuing it
          ::  (rice and wheat have different hashing functions)
          ?&  =(id id.grain)
              =(lord lord.grain)
              ?:  ?=(%& -.germ.grain)
                =(id (fry-rice holder.grain lord.grain town-id.grain salt.p.germ.grain))
              =(id (fry-contract lord.grain town-id.grain germ.grain))
      ==  ==
    --
  --
--
