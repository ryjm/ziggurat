/-  *ziggurat
=>  |%
    +$  card  card:agent:gall
    --
|%
++  give-on-updates
  |=  =update
  ^-  card
  =-  [%give %fact - %zig-update !>(update)]
  ~[/validator/updates /fisherman/updates]
::
++  wait
  |=  [epoch-num=@ud slot-num=@ud epoch-start=@da our-block=?]
  ^-  card
  =/  =time
    =-  ?.(our-block - (sub - (mul 8 (div epoch-interval 10))))
    (deadline epoch-start slot-num)
  ~&  timer+[[%our our-block] epoch-num slot-num]
  =-  [%pass - %arvo %b %wait time]
  /timers/slot/(scot %ud epoch-num)/(scot %ud slot-num)
::
++  deadline
  |=  [start-time=@da num=@ud]
  ^-  @da
  %+  add  start-time
  (mul +(num) epoch-interval)
::
++  get-last-slot
  |=  =slots
  ^-  [@ud (unit slot)]
  ?~  p=(pry:sot slots)
    [0 ~]
  [-.u.p `+.u.p]
::
++  start-epoch-catchup
  |=  [src=ship epoch-num=@ud]
  ^-  card
  =/  =wire  /validator/epoch-catchup/(scot %ud epoch-num)
  [%pass (snoc wire (scot %p src)) %agent [src %ziggurat] %watch wire]
::
++  poke-new-epoch
  |=  [our=ship epoch-num=@ud]
  ^-  card
  =-  [%pass /new-epoch/(scot %ud epoch-num) %agent [our %ziggurat] %poke -]
  zig-action+!>(`action`[%new-epoch ~])
::
++  shuffle
  |=  [set=(set ship) eny=@]
  ^-  (list ship)
  =/  lis=(list ship)  ~(tap in set)
  =/  len  (lent lis)
  =/  rng  ~(. og eny)
  =|  shuffled=(list ship)
  |-
  ?~  lis
    shuffled
  =^  num  rng
    (rads:rng len)
  %_  $
    shuffled  [(snag num `(list ship)`lis) shuffled]
    len       (dec len)
    lis       (oust [num 1] `(list ship)`lis)
  ==
--
