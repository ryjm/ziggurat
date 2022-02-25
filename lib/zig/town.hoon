/-  ziggurat
/+  *zig-util, sig=zig-sig, mill=zig-mill, smart=zig-sys-smart
=>  |%
    +$  card  card:agent:gall
    --
|%
::
++  set-next-chair
  |=  hall=hall:ziggurat
  ^-  hall:ziggurat
  ?:  (gte +(chair.hall) ~(wyt in council.hall))
    =-  hall(order -, chair 0)
    (shuffle council.hall `@ux`blocknum.hall)
  hall(chair +(chair.hall))
::
++  assemble
  |_  [=hall:ziggurat [our=ship now=time src=ship]]
  ::
  ::  when it's your turn, generate a chunk
  ::
  ++  produce
    |=  [=town:smart =basket:ziggurat me=account:smart]
    ^-  chunk:ziggurat
    ::  run +mill
    :-  id.hall
    ^-  [(list [@ux egg:smart]) town:smart]
    (~(mill-all mill me id.hall blocknum.hall now) town ~(tap in basket))
  ::
  ::  send chunk to everyone in town to sign
  ::
  ::  ++  disperse
  ::    |=  =chunk
  ::    ^-  (list card)
  ::    %+  turn
  ::      (skip order.town |=(p=@p =(p our)))
  ::    |=  =ship
  ::    :*  %pass  /chunk-gossip
  ::        %agent  [ship %ziggurat]  %poke
  ::        %zig-chunk-action  !>(`chunk-action`[%hear chunk])
  ::    ==
  ::  ::
  ::  ::  sign a received chunk and return it to chunk producer
  ::  ::
  ::  ++  sign
  ::    |=  =chunk
  ::    ^-  card
  ::    =/  hash  `@ux`(sham chunk)
  ::    =/  our-sig  (sign:sig our now hash)
  ::    :*  %pass  /chunk-gossip
  ::        %agent  [leader.town %ziggurat]  %poke
  ::        %zig-chunk-action  !>(`chunk-action`[%signed town-id.chunk our-sig hash])
  ::    ==
  ::
  ::  ::  chunk producer collates majority of signatures to submit to block
  ::  ::  submit (to block producer)
  ::  ::
  ::  ++  submit
  ::    |=  [sigs=(set signature) =chunk block-producer=ship]
  ::    ^-  (list card)
  ::    =/  chunk-hash  `@ux`(sham chunk)
  ::    :_  ~
  ::    :*  %pass  /chunk-submission
  ::        %agent  [block-producer %ziggurat]  %poke
  ::        %zig-chain-action  !>(`chain-action`[%submit sigs chunk])
  ::    ==
  --
--