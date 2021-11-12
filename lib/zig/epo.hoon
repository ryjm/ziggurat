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
      |=  [epoch-num=@ud slot-num=@ud epoch-start=@da]
      ^-  card
      =-  [%pass - %arvo %b %wait (deadline epoch-start slot-num)]
      /timers/slot/(scot %ud epoch-num)/(scot %ud slot-num)
    ::
    ++  rest
      |=  [epoch-num=@ud slot-num=@ud epoch-start=@da]
      ^-  card
      =-  [%pass - %arvo %b %rest (deadline epoch-start slot-num)]
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
    ++  block-catchup
      |=  [src=ship epoch-num=@ud]
      ^-  card
      =/  =wire  /validator/block-catchup/(scot %ud epoch-num)
      [%pass (snoc wire (scot %p src)) %agent [src %ziggurat] %watch wire]
    --
|%
++  epo
  |_  [cur=epoch [our=ship now=time src=ship]]
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
      ?~  last-slot  (sham ~)
      (sham p.u.last-slot)
    =/  data-hash  (sham data)
    =/  =slot
      =/  hed=block-header  [next-num prev-hed-hash data-hash]
      [hed `[(sign:sig our now (sham hed)) data]]
    :-  (give-on-updates [%new-block num.cur p.slot (need q.slot)])^~
    cur(slots (put:sot slots.cur next-num slot))
  ::
  ::  +skip-slot: occurs when someone misses their turn
  ::
  ++  skip-block
    ^-  (quip card epoch)
    =/  [last-num=@ud last-slot=(unit slot)]
      (get-last-slot slots.cur)
    =/  next-num  ?~(last-slot 0 +(last-num))
    =/  prev-hed-hash
      ?~  last-slot  (sham ~)
      (sham p.u.last-slot)
    =-  `cur(slots (put:sot slots.cur next-num -))
    ^-  slot
    [[next-num prev-hed-hash (sham ~)] ~]

  ::
  ::  +their-block: occurs when someone takes their turn
  ::
  ++  their-block
    |=  [hed=block-header blk=block]
    ^-  (quip card epoch)
    =/  [last-num=@ud last-slot=(unit slot)]
      (get-last-slot slots.cur)
    =/  next-num  ?~(last-slot 0 +(last-num))
    =/  prev-hed-hash
      ?~  last-slot  (sham ~)
      (sham p.u.last-slot)
    ~|  "everyone must take their turn in order!"
    ?>  =(next-num num.hed)
    ~|  "transmitted blocks must have data!"
    ?>  ?=(^ q.blk)
    ~|  "their previous header hash must equal our previous header hash!"
    ?>  =(prev-hed-hash prev-header-hash.hed)
    ~|  "there must be at least one chunk!"
    ?>  ?=(^ q.blk)
    ~|  "their data hash must be valid!"
    ?>  =((sham q.blk) data-hash.hed)
    ~|  "their signature must be valid!"
    ?>  (validate:sig our p.blk (sham hed) now)
    :_  cur(slots (put:sot slots.cur next-num [hed `blk]))
    :~  ::  send block header to others
        ::
        (give-on-updates [%saw-block num.cur hed])
        ::  cancel old block deadline timer
        ::
        (rest num.cur next-num start-time.cur)
        ::  set new block deadline timer
        ::
        %-  wait
        ?:  =((lent order.cur) +(next-num))
          [+(num.cur) 0 (deadline start-time.cur +(next-num))]
        [num.cur +(next-num) start-time.cur]
    ==
  ::
  ::  +see-block: occurs when we are notified that a validator
  ::  saw a particular block in a slot
  ::
  ++  see-block
    |=  hed=block-header
    ^-  (quip card epoch)
    ::  TODO: check if their block header for this particular slot
    ::  matches ours, and if not, ask them for more data
    ::
    =/  slot=(unit slot)  (get:sot slots.cur num.hed)
    :_  cur
    ?~  slot  ~
    ?:  =(p.u.slot hed)
      ::  note: everything checked out, they have the same history we do
      ~
    (block-catchup src num.cur)^~
  --
--

