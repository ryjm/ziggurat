/+  std=zig-sys-smart
=>  |%
    +$  write-args
      (unit %send transactions)
    ::
    +$  transactions
      %+  map  sender=id:std
      %+  map  recipient=id:std  amount=@ud
    --
|_  =cart:std
++  write
  |=  inp=scramble:std
  |^
  ^-  chick:std
  ?>  ?=([~ @ *] args.inp)
  ?>  ?=(%send -.u.args.inp)
  =/  txs=(list [id:std (map id:std @ud)])
    ~(tap by ;;(transactions +.u.args.inp))
  :+  %&
    ::  build `changed`: delete spent zigs UTXOs/rices
    %-  ~(gas by *(map id:std (unit grain:std)))
    %+  turn  ~(tap in ~(key by grains.inp))
    |=  =id:std  [id ~]
  ::  build `issued`: recipient zigs UTXOs/rices
  =|  issued=(map id:std grain:std)
  |-  ^-  (map id:std grain:std)
  ?~  txs  issued
  =*  sender  -.i.txs
  =/  sends=(list [id:std @ud])  ~(tap by +.i.txs)
  ::  require sender id be in grains AND
  ::  require data be an amount of zigs
  =/  sender-grain  (~(got by grains.inp) sender)
  ?>  ?=(%& -.germ.sender-grain)
  =/  balance  data.p.germ.sender-grain
  ?>  ?=(@ud balance)
  ::  require entire balance be spent
  ?>  .=  balance
    (roll (turn sends |=([recp=id:std amt=@ud] amt)) add)
  %_  $
    txs     t.txs
    issued  (update-issued-for-sender sends issued)
  ==
  ::
  ++  update-issued-for-sender
    |=  [sends=(list [id:std @ud]) issued=(map id:std grain:std)]
    ^-  (map id:std grain:std)
    |-  ^-  (map id:std grain:std)
    ?~  sends  issued
    =*  recp  -.i.sends
    =*  amt   +.i.sends
    %_  $
      sends  t.sends
      issued
        =/  data=@ud
          ?.  (~(has by issued) recp)
            amt
          =/  old  (~(got by issued) recp)
          ?>  ?=(%& -.germ.old)
          ?>  ?=(@ud data.p.germ.old)
          (add `@ud`data.p.germ.old amt)
        =|  =rice:std
        =:  format.rice  `@ud
            data.rice    data
        ==
        =/  =germ:std  [%& rice]
        =/  =id:std
          (fry:std zigs-wheat-id:std town-id:cart germ)
        =|  =grain:std
        =:
            id.grain       id
            lord.grain     zigs-wheat-id:std
            holder.grain   recp
            town-id.grain  town-id.cart
            germ.grain     germ
        ==
        :: ~&  >  "fry (zigs-utxo): {<(fry:std zigs-wheat-id:std town-id:cart germ)>}"
        (~(put by issued) id grain)
    ==
  --
::
++  read
  |=  inp=path:std
  ^-  noun
  *noun
::
++  event
  |=  inp=male:std
  ^-  chick:std
  *chick:std
--
