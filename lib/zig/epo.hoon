/-  *ziggurat
/+  *zig-util, sig=zig-sig
=>  |%
    +$  card  card:agent:gall
    --
|%
++  epo
  |_  [cur=epoch prev-hash=@uvH [our=ship now=time src=ship]]
  ::
  ::  +our-block: produce a block during our slot
  ::
  ++  our-block
    |=  data=chunks
    ^-  (quip card epoch)
    =/  [last-num=@ud last-slot=(unit slot)]
      (get-last-slot slots.cur)
    =/  next-num  ?~(last-slot 0 +(last-num))
    ?:  ?&(?=(^ (tap:sot slots.cur)) ?=(~ last-slot))
    ::  ?:  ?&((gth (lent (tap:sot slots.cur)) 1) ?=(~ last-slot))
      ~&  >>>  "%ziggurat: skipping own block, invalid slot configuration"
      skip-block
    ?~  our-num=(find our^~ order.cur)
      ~&  >>>  "%ziggurat: skipping own block, we're not included in this epoch"
      skip-block
    ?.  =(u.our-num next-num)
      ~&  >>>  "%ziggurat: skipping own block, it's not our turn"
      skip-block
    ?:  ?|  (gth now (deadline:epo start-time.cur u.our-num))
            ?=(~ data)
        ==
      ~&  >>>  "%ziggurat: skipping own block, we're late or have no chunks to package"
      skip-block
    ::  TODO: use full sha-256 instead of half sha-256 (sham)
    ::
    =/  prev-hed-hash
      ?~  last-slot  prev-hash
      (sham p.u.last-slot)
    =/  data-hash  (sham data)
    =/  =slot
      =+  hed=[next-num prev-hed-hash data-hash]
      [hed `[(sign:sig our now (sham hed)) data]]
    ~&  "producing a block size={<(met 3 (jam slot))>} at {<now>}"
    :_  cur(slots (put:sot slots.cur next-num slot))
    %+  weld
      (give-on-updates [%new-block num.cur p.slot (need q.slot)] q.slot)
    ::  if we're the final slot in epoch, trigger new one
    ?:  =((lent order.cur) +(next-num))
      (poke-new-epoch our +(num.cur))^~
    (notify-sequencer (snag +(next-num) order.cur))^~
  ::
  ::  +skip-slot: occurs when someone misses their turn
  ::
  ++  skip-block
    ^-  (quip card epoch)
    =/  [last-num=@ud last-slot=(unit slot)]
      (get-last-slot slots.cur)
    =/  next-num  ?~(last-slot 0 +(last-num))
    =/  prev-hed-hash
      ?~  last-slot  prev-hash
      (sham p.u.last-slot)
    :_  =-  cur(slots (put:sot slots.cur next-num -))
        ^-  slot
        [[next-num prev-hed-hash (sham ~)] ~]
    ?.  =((lent order.cur) +(next-num))  ~
    ::  start new epoch
    ::
    (poke-new-epoch our +(num.cur))^~
  ::
  ::  +their-block: occurs when someone takes their turn
  ::
  ++  their-block
    |=  [hed=block-header blk=(unit block)]
    ^-  (quip card epoch)
    =/  [last-num=@ud last-slot=(unit slot)]
      (get-last-slot slots.cur)
    =/  next-num  ?~(last-slot 0 +(last-num))
    ?:  ?&(?=(^ (tap:sot slots.cur)) ?=(~ last-slot))
    ::  ?:  ?&((gth (lent (tap:sot slots.cur)) 1) ?=(~ last-slot))
      ~&  >>>  "%ziggurat: ignoring their block, invalid slot configuration"
      skip-block
    =/  prev-hed-hash
      ?~  last-slot  prev-hash
      (sham p.u.last-slot)
    ?.  (lth now (deadline start-time.cur num.hed))
      ~&  >>>  "%ziggurat: ignoring their block, it was submitted late"
      skip-block
    ?.  =(next-num num.hed)
      ~&  >>>  "%ziggurat: ignoring their block, it was submitted out-of-order"
      skip-block
    ?.  =(src (snag num.hed order.cur))
      ~&  >>>  "%ziggurat: ignoring their block, it was submitted out-of-turn"
      skip-block
    ?.  ?|  ?=(~ blk)
            ?=(^ q.u.blk)
        ==
      ~&  >>>  "%ziggurat: ignoring their block, it was empty!"
      skip-block
    ?.  ?&  =(?~(blk (sham ~) (sham q.u.blk)) data-hash.hed)
            ?|(?=(~ blk) !=(data-hash.hed (sham ~)))
        ==
      ~&  >>>  "%ziggurat: ignoring their block, header hash was invalid"
      skip-block
    ::  TODO: replace with pubkeys in a helix
    ::~|  "their signature must be valid!"
    ::?>  ?~(blk %& (validate:sig our p.u.blk (sham hed) now))
    ?.  =(prev-hed-hash prev-header-hash.hed)
      ~&  >>>  "%ziggurat: received mismatching header hash, starting epoch catchup"
      [(start-epoch-catchup src num.cur)^~ cur]
    :_  cur(slots (put:sot slots.cur next-num [hed blk]))
    %+  weld
      ::  notify others we saw this block
      (give-on-updates [%saw-block num.cur hed] blk)
    ::  if that was the final slot in epoch, trigger new one
    ?.  =((lent order.cur) +(next-num))
      (notify-sequencer (snag +(next-num) order.cur))^~
    (poke-new-epoch our +(num.cur))^~
  ::
  ::  +see-block: occurs when we are notified that a validator
  ::  saw a particular block in a slot
  ::
  ++  see-block
    |=  [epoch-num=@ud hed=block-header]
    ^-  (list card)
    ?:  (gth epoch-num num.cur)
      ~&  >>>  "%ziggurat: saw block from future epoch, starting epoch catchup"
      (start-epoch-catchup src epoch-num)^~
    =/  slot=(unit slot)  (get:sot slots.cur num.hed)
    ?:  (lth epoch-num num.cur)  ~
    ?~  slot                     ~
    ?:  =(p.u.slot hed)          ~
    ~&  >>>  "%ziggurat: saw mismatching header hash, starting epoch catchup"
    (start-epoch-catchup src num.cur)^~
  --
--
