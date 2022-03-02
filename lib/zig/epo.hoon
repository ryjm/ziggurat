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
    |=  data=(list *)
    ~>  %bout
    ^-  (quip card epoch)
    ~&  >  "creating block"  ::  printout
    :: TODO: check time and if necessary skip our own block
    :: (lth now.bowl (deadline:epo start-time.cur slot-num))
    =/  [last-num=@ud last-slot=(unit slot)]
      (get-last-slot slots.cur)
    ?<  ?&((gth (lent (tap:sot slots.cur)) 1) ?=(~ last-slot))
    =/  next-num  ?~(last-slot 0 +(last-num))
    ~|  "we must be a validator in this epoch and it must be our turn"
    =/  our-num=@ud  (need (find our^~ order.cur))
    ?>  =(our-num next-num)
    ::  TODO: use full sha-256 instead of half sha-256 (sham)
    ::
    =/  prev-hed-hash
      ?~  last-slot  prev-hash
      (sham p.u.last-slot)
    ::  TODO temporary: make a fake block if no data, just so as to not skip all
    =?  data  ?=(~ data)  `(list @)`"fake-data"
    =/  jammed-data
      %+  turn  data
      |=([chunk=*] (jam chunk))
    =/  data-hash  (sham jammed-data)
    =/  =slot
      =/  hed=block-header  [next-num prev-hed-hash data-hash]
      [hed `[(sign:sig our now (sham hed)) jammed-data]]
    :_  cur(slots (put:sot slots.cur next-num slot))
    :-  (give-on-updates [%new-block num.cur p.slot (need q.slot)])
    ?.  =((lent order.cur) +(next-num))  ~
    ::  start new epoch
    ::
    (poke-new-epoch our +(num.cur))^~
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
    ~&  >  "it's {<src>}'s block"  ::  printout
    =/  [last-num=@ud last-slot=(unit slot)]
      (get-last-slot slots.cur)
    ::~&  num.hed^[last-num last-slot]
    ?<  ?&((gth (lent (tap:sot slots.cur)) 1) ?=(~ last-slot))
    =/  next-num  ?~(last-slot 0 +(last-num))
    =/  prev-hed-hash
      ?~  last-slot  prev-hash
      (sham p.u.last-slot)
    ~|  "must not be submitted past the deadline!"
    ?>  (lth now (deadline start-time.cur num.hed))
    ~|  "everyone must take their turn in order!"
    ?>  =(next-num num.hed)
    ~|  "each ship must take their own turn"
    ?>  =(src (snag num.hed order.cur))
    ~|  "transmitted blocks must have data or have been skipped!"
    ?>  ?|  ?=(~ blk)
            ?=(^ q.u.blk)
        ==
    ~|  "their data hash must be valid!"
    ?>  ?&  =(?~(blk (sham ~) (sham q.u.blk)) data-hash.hed)
            ?|(?=(~ blk) !=(data-hash.hed (sham ~)))
        ==
    ::  TODO: replace with pubkeys in a helix
    ::~|  "their signature must be valid!"
    ::?>  ?~(blk %& (validate:sig our p.u.blk (sham hed) now))
    ~|  "their previous header hash must equal our previous header hash!"
    ?.  =(prev-hed-hash prev-header-hash.hed)
      :_  cur
      (start-epoch-catchup src num.cur)^~
    :_  cur(slots (put:sot slots.cur next-num [hed blk]))
    :-  ::  send block header to others
        ::
        (give-on-updates [%saw-block num.cur hed])
    ?.  =((lent order.cur) +(next-num))  ~
    ::  start new epoch
    ::
    (poke-new-epoch our +(num.cur))^~
  ::
  ::  +see-block: occurs when we are notified that a validator
  ::  saw a particular block in a slot
  ::
  ++  see-block
    |=  [epoch-num=@ud hed=block-header]
    ^-  (list card)
    ?:  (gth epoch-num num.cur)
      (start-epoch-catchup src epoch-num)^~
    ?:  (lth epoch-num num.cur)
      ~
    =/  slot=(unit slot)  (get:sot slots.cur num.hed)
    ?~  slot  ~
    ?:  =(p.u.slot hed)
      ~
    (start-epoch-catchup src num.cur)^~
  --
--
