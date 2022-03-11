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
++  notify-sequencer
  |=  =ship
  ^-  card
  :-  %give
  :^  %fact  ~[/sequencer/updates]
      %sequencer-update  !>([%next-producer ship])
::
::  +wait: create %behn timer cards for a given epoch-slot
::
++  wait
  |=  [epoch-num=@ud slot-num=@ud epoch-start=@da our-block=?]
  ^-  card
  =/  =time
    ::  if we're the block producer for this slot,
    ::  make our timer pop early so we don't miss the deadline
    ::  otherwise, just set timer for slot deadline
    ::  (currently: try to produce block 1/2 of way to deadline)
    =-  ?.(our-block - (sub - (div epoch-interval 2)))
    (deadline epoch-start slot-num)
  ~&  timer+[[%our our-block] epoch-num slot-num time]
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
  ~&  >  "starting epoch catchup"  ::  printout
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
