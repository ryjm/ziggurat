/+  *tiny
|%
++  zigs-utxo-contract
  ^-  contract
  |_  [mem=(unit vase) me=id]
  ::
  +$  write-args
    %-  unit
    :-  %send
    transactions
  ::
  +$  transactions
    %+  map  sender=id
    %+  map  recipient=id  amount=@ud
  ::
  ++  write
    |=  inp=contract-input
    ^-  contract-output
    ?>  ?=([~ @ *] args.inp)
    ?>  ?=(%send -.u.args.inp)
    =/  to  ~(tap by ;;(transactions +.u.args.inp))
    :^  %result  %write
      ::  build `changed`: delete spent zigs UTXOs/rices
      %-  ~(gas by *(map id (unit grain)))
      %+  turn
        ~(tap in ~(key by sender.inp))
      |=  =id  [id ~]
    ::  build `issued`: recipient zigs UTXOs/rices
    =|  issued=(map id grain)
    |-
    ?~  to  issued
    =*  sender   p.i.to
    =*  sends    ~(tap by q.i.to)
    ::  require sender id be in contract-input AND
    ::  require data be an amount of zigs
    ?>  ?=(@ud utxo-balance=data.p.germ.(~(got by sender) rice.inp))
    ::  require UTXO/rice balance == spend
    ?>  =(utxo-balance (roll (turn sends |=([recp=id amt=@ud] amt)) add))
    ::
    |-
    ?~  sends  issued  ::  ?
    =*  recp  p.i.send
    =*  amt   q.i.send
    =.  issued
      ?~  (~(get by issued) recp)
        (~(put by issued) recp amt)
      (~(jab by issued) recp |=(x=@ud (add x amt)))
    $(sends t.sends)
    ::
    $(to t.to)
  ::
  ++  read
    |=  inp=contract-input
    ^-  contract-output
    !!
    :: *contract-output
  ::
  ++  event
    |=  inp=contract-result
    ^-  contract-output
    !!
    :: *contract-output
  --
--
