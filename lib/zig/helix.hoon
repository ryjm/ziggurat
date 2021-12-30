/-  *ziggurat, tx
/+  *zig-util, sig=zig-sig, add=zig-add-tx
=>  |%
    +$  card  card:agent:gall
    --
|%
::
::  create a new helix
::
++  form-helix
  |=  [starting-state=state:tx validators=(set ship) eny=@]
  ^-  helix
  ::  some helices can be hardcoded at low ids for convenience?
  =/  new-id  `@ux`(sham starting-state)
  =/  order  (shuffle validators eny)
  :^  new-id
      starting-state
      order
      -.order
::
++  lix
  |_  [=helix =mempool [our=ship now=time src=ship]]
  ::
  ::  when it's your turn, generate a chunk
  ::
  ++  produce
    ^-  chunk
    =/  our-sender
      ::  TODO include this in agent state
      ::  validators should be initialized with account
      [0x1234 nonce=1 feerate=1 pubkey=0x1234 sig=[0xaa 0xbb %schnorr]]
    [id.helix (txs-to-chunk:add state.helix mempool our-sender)]
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
        %zig-chunk-action  !>(`chunk-action`[%signed our-sig hash])
    ==
  ::
  ::  chunk producer collates majority of signatures to submit to block
  ::  submit (to block producer)
  ::
  ++  submit
    |=  [sigs=(list signature) =chunk block-producer=ship]
    ^-  (list card)
    =/  chunk-hash  `@ux`(sham chunk)
    :_  ~
    :*  %pass  /chunk-submission
        %agent  [block-producer %ziggurat]  %poke
        %zig-chunk-action  !>(`chunk-action`[%submit sigs chunk])
    ==
  --
--