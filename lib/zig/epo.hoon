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
      |=  [epoch-num=@ud block-num=@ud epoch-start=@da]
      ^-  card
      =-  [%pass - %arvo %b %wait (deadline epoch-start block-num)]
      /timers/block/(scot %ud epoch-num)/(scot %ud block-num)
    ::
    ++  rest
      |=  [epoch-num=@ud block-num=@ud epoch-start=@da]
      ^-  card
      =-  [%pass - %arvo %b %rest (deadline epoch-start block-num)]
      /timers/block/(scot %ud epoch-num)/(scot %ud block-num)
    ::
    ++  deadline
      |=  [start-time=@da num=@ud]
      ^-  @da
      %+  add  start-time
      (mul num epoch-interval)
    --
|%
++  epo
  |_  [cur=epoch [our=ship now=time]]
  ++  our-turn
    |=  =chunks
    ^-  (quip card epoch)
    =/  [next-num=@ud last-block=(unit block)]
      ?~(p=(pry:bok blocks.cur) [0 ~] [+(-.u.p) `+.u.p])
    ::  TODO: use full sha-256 instead of half sha-256 (sham)
    ::
    =/  prev-header-hash
      ?~  last-block  (sham ~)
      (sham p.u.last-block)
    =/  data-hash  (sham chunks)
    =/  blk=block
      =/  =block-header  [next-num prev-header-hash data-hash]
      :-  block-header
      `[(sign:sig our now (sham block-header)) chunks]
    :-  (give-on-updates [%new-block num.cur blk])^~
    cur(blocks (put:bok blocks.cur next-num blk))
  ::
  ++  their-turn
    |=  blk=(unit block)
    ^-  (quip card epoch)
    =/  [next-num=@ud last-block=(unit block)]
      ?~(p=(pry:bok blocks.cur) [0 ~] [+(-.u.p) `+.u.p])
    =/  prev-header-hash
      ?~  last-block  (sham ~)
      (sham p.u.last-block)
    ?~  blk
      ::  this case occurs when someone misses their turn
      ::
      =/  =block  [[next-num prev-header-hash (sham ~)] ~]
      `cur(blocks (put:bok blocks.cur next-num block))
    ::  this case occurs when someone takes their turn
    ::
    ~|  "everyone must take their turn in order!"
    ?>  =(next-num num.p.u.blk)
    ~|  "transmitted blocks must have data!"
    ?>  ?=(^ q.u.blk)
    =*  hed  p.u.blk
    =*  syg  p.u.q.u.blk
    =*  dat  q.u.q.u.blk
    ~|  "their previous header hash must equal our previous header hash!"
    ?>  =(prev-header-hash prev-header-hash.hed)
    ~|  "there must be at least one chunk!"
    ?>  ?=(^ dat)
    =/  data-hash  (sham dat)
    ~|  "their data hash must be valid!"
    ?>  =(data-hash data-hash.hed)
    ~|  "their signature must be valid!"
    ?>  (validate:sig our syg (sham hed) now)
    :_  cur(blocks (put:bok blocks.cur next-num u.blk))
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
  --
--

