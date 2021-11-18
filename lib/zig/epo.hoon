/-  *ziggurat
/+  sig=zig-sig
=>  |%
    +$  card  card:agent:gall
    ++  give-on-updates
      |=  =update
      ^-  card
      =-  [%give %fact - %zig-update !>(update)]
      ~[/validator/updates /fisherman/updates]
    ::
    ++  wait
      |=  [epoch-num=@ud slot-num=@ud epoch-start=@da offset=(unit @dr)]
      ^-  card
      =/  =time
        (deadline epoch-start slot-num)
      =?  time  ?=(^ offset)
        (add time u.offset)
      =-  [%pass - %arvo %b %wait time]
      /timers/slot/(scot %ud epoch-num)/(scot %ud slot-num)
    ::
    ++  rest
      |=  [epoch-num=@ud slot-num=@ud epoch-start=@da offset=(unit @dr)]
      ^-  card
      =/  =time
        (deadline epoch-start slot-num)
      =?  time  ?=(^ offset)
        (add time u.offset)
      =-  [%pass - %arvo %b %rest time]
      /timers/slot/(scot %ud epoch-num)/(scot %ud slot-num)
    ::
    ++  deadline
      |=  [start-time=@da num=@ud]
      ^-  @da
      %+  add  start-time
      (mul num epoch-interval)
    ::
    ++  get-last-slot
      |=  =slots
      ^-  [@ud (unit slot)]
      ?~  p=(pry:sot slots)
        [0 ~]
      [-.u.p `+.u.p]
    ::
    ++  epoch-catchup
      |=  [src=ship epoch-num=@ud]
      ^-  card
      =/  =wire  /validator/epoch-catchup/(scot %ud epoch-num)
      [%pass (snoc wire (scot %p src)) %agent [src %ziggurat] %watch wire]
    ::
    ++  poke-new-epoch
      |=  [our=ship epoch-num=@ud]
      ^-  card
      =-  [%pass /new-epoch/(scot %ud epoch-num) %agent [our %ziggurat] %poke -]
      zig-action+!>(`action`[%new-epoch ~])
    ::
    ++  shuffle
      |=  [set=(set ship) eny=@]
      ^-  (list ship)
      =/  lis=(list ship)  ~(tap in set)
      =/  len  (lent lis)
      =/  rng  ~(. og eny)
      =|  shuffled=(list ship)
      |-
      ?~  lis
        shuffled
      =^  num  rng
        (rads:rng len)
      %_  $
        shuffled  [(snag num `(list ship)`lis) shuffled]
        len       (dec len)
        lis       (oust [num 1] `(list ship)`lis)
      ==
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
    ~|  "we must be a validator in this epoch and it must be our turn"
    =/  our-num=@ud  (need (find our^~ order.cur))
    ?>  =(our-num next-num)
    ::  TODO: use full sha-256 instead of half sha-256 (sham)
    ::
    =/  prev-hed-hash
      ?~  last-slot  prev-hash
      (sham p.u.last-slot)
    =/  data-hash  (sham data)
    =/  =slot
      =/  hed=block-header  [next-num prev-hed-hash data-hash]
      [hed `[(sign:sig our now (sham hed)) data]]
    :_  cur(slots (put:sot slots.cur next-num slot))
    :-  (give-on-updates [%new-block num.cur p.slot (need q.slot)])
    ?:  =((lent order.cur) +(next-num))
      ::  start new epoch
      ::
      (poke-new-epoch our +(num.cur))^~
    ::  set new block deadline timer
    ::
    (wait num.cur +(next-num) start-time.cur ~)^~
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
    :-  ?:  =((lent order.cur) +(next-num))
          ::  start new epoch
          ::
          (poke-new-epoch our +(num.cur))^~
        ::  set new block deadline timer
        ::
        (wait num.cur +(next-num) start-time.cur ~)^~
    =-  cur(slots (put:sot slots.cur next-num -))
    ^-  slot
    [[next-num prev-hed-hash (sham ~)] ~]
  ::
  ::  +their-block: occurs when someone takes their turn
  ::
  ++  their-block
    |=  [hed=block-header blk=(unit block)]
    ^-  (quip card epoch)
    =/  [last-num=@ud last-slot=(unit slot)]
      (get-last-slot slots.cur)
    =/  next-num  ?~(last-slot 0 +(last-num))
    =/  prev-hed-hash
      ?~  last-slot  prev-hash
      (sham p.u.last-slot)
    ~|  "everyone must take their turn in order!"
    ?>  =(next-num num.hed)
    ~|  "transmitted blocks must have data or have been skipped!"
    ?>  ?|  ?=(~ blk)
            ?=(^ q.u.blk)
        ==
    ~|  "their previous header hash must equal our previous header hash!"
    ?>  =(prev-hed-hash prev-header-hash.hed)
    ~|  "their data hash must be valid!"
    ?>  =(?~(blk (sham ~) (sham q.u.blk)) data-hash.hed)
    ~|  "their signature must be valid!"
    ?>  ?~(blk %& (validate:sig our p.u.blk (sham hed) now))
    :_  cur(slots (put:sot slots.cur next-num [hed blk]))
  :+    ::  send block header to others
        ::
        (give-on-updates [%saw-block num.cur hed])
      ::  cancel old block deadline timer
      ::
      (rest num.cur next-num start-time.cur ~)
    ?:  =((lent order.cur) +(next-num))
      ::  start new epoch
      ::
      (poke-new-epoch our +(num.cur))^~
    ::  set new block deadline timer
    ::
    (wait num.cur +(next-num) start-time.cur ~)^~
  ::
  ::  +see-block: occurs when we are notified that a validator
  ::  saw a particular block in a slot
  ::
  ++  see-block
    |=  hed=block-header
    ^-  (list card)
    =/  slot=(unit slot)  (get:sot slots.cur num.hed)
    ?~  slot  ~
    ?:  =(p.u.slot hed)  ~
    (epoch-catchup src num.cur)^~
  ::
  ++  new-epoch
    |=  =epochs
    ^-  [epoch ^epochs]
    :_  (put:poc epochs num.cur cur)
    ^-  epoch
    :^    +(num.cur)
        (deadline start-time.cur +((lent order.cur)))
      (shuffle (silt order.cur) (mug slots))
    ~
  --
--

