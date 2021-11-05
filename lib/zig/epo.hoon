/-  *ziggurat
/+  sig=zig-sig
=>  |%
    +$  card  card:agent:gall
    ++  give-validator-update
      |=  =update
      ^-  card
      [%give %fact /validator/updates^~ %zig-update !>(update)]
    --
|%
++  epo
  |_  [cur=epoch [our=ship now=time]]
  ++  catch-up
    ^-  (quip card epoch)
    ?>  ?=(~ blocks.cur)
    ::  TODO: pick a random validator from list and %watch his
    ::  catchup path. set a timer, and wait for him to send you
    ::  data. if he doesn't send it within a specified time,
    ::  pick a random other validator to ask for the data from.
    ::  rinse and repeat until you have caught up to the latest
    ::  epoch.
    ::
    ~&  cur
    `cur
  ::
  ++  move-forward
    |%
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
      :-  (give-validator-update [%new-block num.cur blk])^~
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
        ::  NOTE: this case occurs when someone misses their turn
        ::
        `cur(blocks (put:bok blocks.cur num [num ~]))
      ~|  "everyone must take their turn in order!"
      ?>  =(num num.u.blk)
      ::  NOTE: this case occurs when someone takes their turn
      ::
      ?>  ?=(^ data.u.blk)
      =/  hash  (mug q.u.data.u.blk)
      ~|  "validator's signature must be valid!"
      ?>  (validate:sig our p.u.data.u.blk hash now)
      :-  ~  ::  TODO: cancel %behn timer
      cur(blocks (put:bok blocks.cur num u.blk))
    --
  --
--

