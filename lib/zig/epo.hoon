/-  *ziggurat
/+  sig=zig-sig
=>  |%
    +$  card  card:agent:gall
    ++  give-on-updates
      |=  =update
      ^-  card
      [%give %fact /validator/updates^~ %zig-update !>(update)]
    ::
    ++  wait
      |=  [epoch-num=@ud block-num=@ud epoch-start=@da]
      ^-  card
      =-  [%pass - %arvo %b %wait (deadline epoch-start block-num)]
      /timer/(scot %ud epoch-num)/(scot %ud block-num)
    ::
    ++  rest
      |=  [epoch-num=@ud block-num=@ud epoch-start=@da]
      ^-  card
      =-  [%pass - %arvo %b %rest (deadline epoch-start block-num)]
      /timer/(scot %ud epoch-num)/(scot %ud block-num)
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
    =/  num=@ud
      ?~  p=(bind (pry:bok blocks.cur) head)
        0
      +(u.p)
    =/  hash  (mug chunks)
    =/  blk=block
      [num `[(sign:sig our now hash) chunks]]
    ::  TODO: kick off next epoch if we are the last block producer
    :-  (give-on-updates [%new-block num.cur blk])^~
    cur(blocks (put:bok blocks.cur num blk))
  ::
  ++  their-turn
    |=  blk=(unit block)
    ^-  (quip card epoch)
    =/  num=@ud
      ?~  p=(bind (pry:bok blocks.cur) head)
        0
      +(u.p)
    ?~  blk
      ::  this case occurs when someone misses their turn
      ::
      `cur(blocks (put:bok blocks.cur num [num ~]))
    ~|  "everyone must take their turn in order!"
    ?>  =(num num.u.blk)
    ::  this case occurs when someone takes their turn
    ::
    ?>  ?=(^ data.u.blk)
    =/  hash  (mug q.u.data.u.blk)
    ~|  "validator's signature must be valid!"
    ?>  (validate:sig our p.u.data.u.blk hash now)
    :_  cur(blocks (put:bok blocks.cur num u.blk))
    :+  ::  cancel old block deadline timer
        ::
        (rest num.cur num start-time.cur)
      ::  set new block deadline timer
      ::
      %-  wait
      ?:  =((lent order.cur) +(num))
        [+(num.cur) 0 (deadline start-time.cur +(num))]
      [num.cur +(num) start-time.cur]
    ::  TODO: send out erasure code showing that you've seen this
    ::  data
    ~
  --
--

