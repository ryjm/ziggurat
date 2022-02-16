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
  ?.  ?=([~ @ *] args.inp)    *chick:std
  ?.  ?=(%send -.u.args.inp)  *chick:std
  =/  to=(list [id:std (map id:std @ud)])
    ~(tap by ;;(transactions +.u.args.inp))
  :+  %&
    ::  build `changed`: delete spent zigs UTXOs/rices
    %-  ~(gas by *(map id:std (unit grain:std)))
    %+  turn  ~(tap in ~(key by grains.inp))
    |=  =id:std  [id ~]
  ::  build `issued`: recipient zigs UTXOs/rices
  =|  issued=(map id:std grain:std)
  |-  ^-  (map id:std grain:std)
  ?~  to  issued
  =*  sender  -.i.to
  =/  sends=(list [id:std @ud])  ~(tap by +.i.to)
  ::  require sender id be in contract-input-rice AND
  ::  require data be an amount of zigs
  =/  utxo-rice     (~(got by grains.inp) sender)
  ?>  ?=(%& -.germ.utxo-rice)
  =/  utxo-balance  data.p.germ.utxo-rice
  ?>  ?=(@ud utxo-balance)
  ::  require UTXO/rice balance == spend
  ?>  .=  utxo-balance
    (roll (turn sends |=([recp=id:std amt=@ud] amt)) add)
  %_  $
    to  t.to
    issued  (update-issued sends issued)
  ==
  ::
  ++  update-issued
    |=  [sends=(list [id:std @ud]) issued=(map id:std grain:std)]
    ^-  (map id:std grain:std)
    |-  ^-  (map id:std grain:std)
    ?~  sends  issued
    =*  recp  -.i.sends
    =*  amt   +.i.sends
    %_  $
      sends  t.sends
      issued
        =|  r=rice:std
        =|  g=grain:std
        =:  data.r
              ?.  (~(has by issued) recp)
                amt
              =/  old  (~(got by issued) recp)
              ?>  ?=(%& -.germ.old)
              ?>  ?=(@ud data.p.germ.old)
              (add `@ud`data.p.germ.old amt)
            format.r   `@ud
            id.g       recp  ::  TODO: wrong? Seems like this should be a hash
            lord.g     zigs-wheat-id:std
            holder.g   recp
            town-id.g  town-id.cart
            germ.g     [%& r]
        ==
        (~(put by issued) recp g)
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
