/+  tiny
=>
  |%
    +$  write-args
      (unit %send transactions)
    ::
    +$  transactions
      %+  map  sender=id:tiny
      %+  map  recipient=id:tiny  amount=@ud
  --
|%
++  zigs-utxo-contract
  ^-  contract:tiny
  |_  [mem=(unit vase) me=id:tiny]
  ::
  ++  write
    |=  inp=contract-input:tiny
    |^
    ^-  contract-output:tiny
    ?.  ?=([~ @ *] args.inp)    *contract-output:tiny
    ?.  ?=(%send -.u.args.inp)  *contract-output:tiny
    =/  to=(list [id:tiny (map id:tiny @ud)])
      ~(tap by ;;(transactions +.u.args.inp))
    :^  %result  %write
      ::  build `changed`: delete spent zigs UTXOs/rices
      %-  ~(gas by *(map id:tiny (unit grain:tiny)))
      %+  turn  ~(tap in ~(key by rice.inp))
      |=  =id:tiny  [id ~]
    ::  build `issued`: recipient zigs UTXOs/rices
    =|  issued=(map id:tiny grain:tiny)
    |-  ^-  (map id:tiny grain:tiny)
    ?~  to  issued
    =*  sender  -.i.to
    =/  sends=(list [id:tiny @ud])  ~(tap by +.i.to)
    ::  require sender id be in contract-input-rice AND
    ::  require data be an amount of zigs
    =/  utxo-rice     (~(got by rice.inp) sender)
    =/  utxo-balance  data.p.germ.utxo-rice
    ?>  ?=(@ud utxo-balance)
    ::  require UTXO/rice balance == spend
    ?>  .=  utxo-balance
      (roll (turn sends |=([recp=id:tiny amt=@ud] amt)) add)
    %_  $
      to  t.to
      issued  (update-issued sends issued)
    ==
    ::
    ++  update-issued
      |=  [sends=(list [id:tiny @ud]) issued=(map id:tiny grain:tiny)]
      ^-  (map id:tiny grain:tiny)
      |-  ^-  (map id:tiny grain:tiny)
      ?~  sends  issued
      =*  recp  -.i.sends
      =*  amt   +.i.sends
      %_  $
        sends  t.sends
        issued
          =|  r=rice:tiny
          =|  g=grain:tiny
          =:  data.r
                ?.  (~(has by issued) recp)
                  amt
                =/  old  (~(got by issued) recp)
                ?>  ?=(%& -.germ.old)
                ?>  ?=(@ud data.p.germ.old)
                (add `@ud`data.p.germ.old amt)
              holder.r   recp
              holds.r    *(set id:tiny)
              id.g       recp
              lord.g     zigs-wheat-id:tiny
              town-id.g  0  ::  TODO: replace placeholder
              germ.g     [%& r]
          ==
          (~(put by issued) recp g)
      ==
    --
  ::
  ++  read
    |=  inp=contract-input:tiny
    ^-  contract-output:tiny
    *contract-output:tiny
  ::
  ++  event
    |=  inp=contract-result:tiny
    ^-  contract-output:tiny
    *contract-output:tiny
  --
--
