/-  *ziggurat
/+  *zig-util, sig=zig-sig, mill=zig-mill, smart=zig-sys-smart
=>  |%
    +$  card  card:agent:gall
    --
|%
::
::  create a new helix
::
++  form-helix
  |=  [helix-id=@ux validators=(set ship) eny=@]
  ^-  helix
  ::  some helices can be hardcoded at low ids for convenience?
  =/  order  (shuffle validators eny)
  [helix-id [~ ~] order -.order 0]
::
++  get-next-leader
  |=  [=helix hash=@uvH]
  ^+  helix
  ?:  (gte +(num.helix) (lent order.helix))
    =/  new-order  (shuffle (silt order.helix) hash)
    helix(order new-order, leader -.new-order, num 0)
  helix(leader (snag +(num.helix) order.helix), num +(num.helix))
::
++  lix
  |_  [=helix [our=ship now=time src=ship]]
  ::
  ::  when it's your turn, generate a chunk
  ::
  ++  produce
    |=  =mempool
    ^-  chunk
    =/  our-sender
      ::  TODO include this in agent state
      ::  validators should be initialized with account/wallet to store rewards
      [0xdead 0 0x1.dead]
    ::  run +mill
    =/  our-chunk
      ^-  [(list [@ux egg:smart]) town:smart]
      (~(mill-all mill our-sender 1 `@ud`id.helix now) state.helix ~(tap in mempool))
    [id.helix our-chunk]
  ::
  ::  send chunk to everyone in helix to sign
  ::
  ++  disperse
    |=  =chunk
    ^-  (list card)
    %+  turn
      (skip order.helix |=(p=@p =(p our)))
    |=  =ship
    :*  %pass  /chunk-gossip
        %agent  [ship %ziggurat]  %poke
        %zig-chunk-action  !>(`chunk-action`[%hear chunk])
    ==
  ::
  ::  sign a received chunk and return it to chunk producer
  ::
  ++  sign
    |=  =chunk
    ^-  card
    =/  hash  `@ux`(sham chunk)
    =/  our-sig  (sign:sig our now hash)
    :*  %pass  /chunk-gossip
        %agent  [leader.helix %ziggurat]  %poke
        %zig-chunk-action  !>(`chunk-action`[%signed helix-id.chunk our-sig hash])
    ==
  ::
  ::  chunk producer collates majority of signatures to submit to block
  ::  submit (to block producer)
  ::
  ++  submit
    |=  [sigs=(set signature) =chunk block-producer=ship]
    ^-  (list card)
    =/  chunk-hash  `@ux`(sham chunk)
    :_  ~
    :*  %pass  /chunk-submission
        %agent  [block-producer %ziggurat]  %poke
        %zig-chunk-action  !>(`chunk-action`[%submit sigs chunk])
    ==
  --
--