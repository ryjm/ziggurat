/+  *bink, smart=zig-sys-smart, ethereum
/*  smart-lib  %noun  /lib/zig/compiled/smart-lib/noun
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
    ^-  [(list [@ux egg]) ^town]  ::  TODO add 'crow's to chunk -- list of announcements
    ?~  pending
      [processed town(p (~(pay tax p.town) reward))]
    =+  [res fee err]=(mill town i.pending)
    =+  i.pending(status.p err)
    %_  $
      pending    t.pending
      processed  [[`@ux`(shax (jam -)) -] processed]
      town       res
      reward     (add reward fee)
    ==
  ::
  ::  +mill: processes a single egg and returns updated town
  ::
  ++  mill
    |=  [=town =egg]
    ^-  [^town fee=@ud errorcode=@ud]
    ?.  ?=(account from.p.egg)  [town 0 1]
    ::  validate transaction signature
    ::  using ecdsa-raw-sign in wallet, TODO review this
    ::  comment this out for tests
    =?  v.sig.p.egg  (gte v.sig.p.egg 27)  (sub v.sig.p.egg 27)
    ~&  >>  egg
    ::  ecdsa-raw-recover crashes so we virtualize
    =/  recovered
      ?~  eth-hash.p.egg
        %-  mule
        |.
        %-  compress-point:secp256k1:secp:crypto
        %+  ecdsa-raw-recover:secp256k1:secp:crypto
          (sham (jam q.egg))
        sig.p.egg
      %-  mule
      |.
      %-  address-from-pub:key:ethereum
      %-  serialize-point:secp256k1:secp:crypto
      %+  ecdsa-raw-recover:secp256k1:secp:crypto
        u.eth-hash.p.egg
      sig.p.egg
    ?:  ?=(%| -.recovered)
      ~&  >>>  "FAILED TX"
      [town 0 2]  ::  signature is broken in some way
    ?.  =(id.from.p.egg p.recovered)
    ~&  >>>  "mismatch: {<id.from.p.egg>}, {<`@ux`p.recovered>}"
      [town 0 2]  ::  signed tx doesn't match account
    =/  curr-nonce=@ud  (~(gut by q.town) id.from.p.egg 0)
    ?.  =(nonce.from.p.egg +(curr-nonce))
      ~&  >>>  "tx rejected; bad nonce"
      [town 0 3]  ::  bad nonce
    ?.  (~(audit tax p.town) egg)
      ~&  >>>  "tx rejected; not enough budget"
      [town 0 4]  ::  can't afford gas
    =+  [gan rem err]=(~(work farm p.town) egg)
    =/  fee=@ud   (sub budget.p.egg rem)
    :_  [fee err]
    :-  (~(charge tax ?~(gan p.town u.gan)) from.p.egg fee)
    (~(put by q.town) id.from.p.egg nonce.from.p.egg)
  ::
  ::  +tax: manage payment for egg in zigs
  ::
  ++  tax
    |_  =granary
    +$  token-account
      $:  balance=@ud
          allowances=(map sender=id:smart @ud)
          metadata=id:smart
      ==
    ::  +audit: evaluate whether a caller can afford gas
    ++  audit
      |=  =egg
      ^-  ?
      ?.  ?=(account from.p.egg)                    %.n
      ?~  zigs=(~(get by granary) zigs.from.p.egg)  %.n
      ?.  =(zigs-wheat-id lord.u.zigs)              %.n
      ?.  ?=(%& -.germ.u.zigs)                      %.n
      =/  acc  (hole token-account data.p.germ.u.zigs)
      (gth balance.acc budget.p.egg)
    ::  +charge: extract gas fee from caller's zigs balance
    ++  charge
      |=  [payee=account fee=@ud]
      ^-  ^granary
      ?~  zigs=(~(get by granary) zigs.payee)  granary
      ?.  ?=(%& -.germ.u.zigs)                 granary
      =/  acc  (hole token-account data.p.germ.u.zigs)
      =.  balance.acc  (sub balance.acc fee)
      =.  data.p.germ.u.zigs  acc
      (~(put by granary) zigs.payee u.zigs)
    ::  +pay: give fees from eggs to miller
    ++  pay
      |=  total=@ud
      ^-  ^granary
      ?~  zigs=(~(get by granary) zigs.miller)  granary
      ?.  ?=(%& -.germ.u.zigs)                  granary
      =/  acc  (hole token-account data.p.germ.u.zigs)
      ?.  =(`@ux`'zigs-metadata' metadata.acc)  granary
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
      ^-  [(unit ^granary) rem=@ud errorcode=@ud]
      =/  hatchling
        (incubate egg(budget.p (div budget.p.egg rate.p.egg)))
      ?~  final.hatchling
        [~ rem.hatchling errorcode.hatchling]
      +.hatchling
    ::
    ++  incubate
      |=  =egg
      ^-  [(unit rooster) final=(unit ^granary) rem=@ud errorcode=@ud]
      |^
      =/  args  (fertilize q.egg)
      ?~  stalk=(germinate to.p.egg cont-grains.q.egg)
        ~&  >>>  "failed to germinate"
        [~ ~ budget.p.egg 5]
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
      :::   idea:  run this in mule outside mill
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
      ^-  [(unit rooster) final=(unit ^granary) rem=@ud errorcode=@ud]
      |^
      =+  [chick rem err]=(weed to.p.egg ~ budget.p.egg)
      ?~  chick  [~ ~ rem err]
      ?:  ?=(%& -.u.chick)
        ::  rooster result, finished growing
        ?~  gan=(harvest p.u.chick to.p.egg from.p.egg)
          [~ ~ rem 7]
        [`p.u.chick gan rem err]
      ::  hen result, continuation
      =*  next  next.p.u.chick
      =*  mem   mem.p.u.chick  :: FIX! USE THIS SOMEWHERE??
      ::  continuation calls can alter grains
      ?~  gan=(harvest roost.p.u.chick to.p.egg from.p.egg)
        [~ ~ rem 7]
      ::  =.  granary  u.gan  ::  ??
      %-  ~(incubate farm u.gan)
      egg(from.p to.p.egg, to.p to.next, budget.p rem, q args.next)
      ::
      ::  +weed: run contract formula with arguments and memory, bounded by bud
      ::
      ++  weed
        |=  [to=id mem=(unit vase) budget=@ud]
        ^-  [(unit chick) rem=@ud errorcode=@ud]
        =/  cart  [mem to blocknum town-id owns.crop]
        ::  TODO figure out how to pre-cue this and get good results
        ::
        =/  =contract  (hole contract [nok.crop +:(cue q.q.smart-lib)])
        =/  res
          ::  need jet dashboard to run bull:
          ::  (bull |.(;;(chick (~(write contract cart) zygote))) bud)
          (mule |.(;;(chick (~(write contract cart) zygote))))^(sub budget 7)
        ~&  >>  "write result: {<res>}"
        ?:  ?=(%| -.-.res)
          ::  error in contract execution
          [~ budget 6]
        ::  chick result
        [`p.-.res budget 0]
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
              =(id (fry-contract lord.grain town-id.grain cont.p.germ.grain))
      ==  ==
    --
  --
--
