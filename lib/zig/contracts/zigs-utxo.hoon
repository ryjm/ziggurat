/+  std=zig-sys-smart
=>
  |%
    +$  write-args
      (unit %send transactions)
    ::
    +$  transactions
      %+  map  sender=id:std
      %+  map  recipient=id:std  amount=@ud
  --
|%
++  zigs-utxo-contract
  ^-  contract:std
  |_  [mem=(unit vase) me=id:std]
  ::
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
              holder.r   recp
              holds.r    *(set id:std)
              id.g       recp
              lord.g     zigs-wheat-id:std
              town-id.g  0  ::  TODO: replace placeholder
              germ.g     [%& r]
          ==
          (~(put by issued) recp g)
      ==
    --
  ::
  ++  read
    |=  inp=scramble:std
    ^-  chick:std
    *chick:std
  ::
  ++  event
    |=  inp=scramble:std
    ^-  chick:std
    *chick:std
  --
--
