/-  *ziggurat
/+  zig-epo, zig-util
=>  |%
    ++  epo   epo:zig-epo
    ++  util  zig-util
    --
|%
::
::  +got-hed-hash: get last epoch and grab its last header hash,
::  otherwise if that epoch is empty, then use (sham ~)
::
++  got-hed-hash
  |=  [slot-num=@ud =epochs cur=epoch]
  ?:  ?&(=(slot-num 0) =(num.cur 0))
    (sham ~)
  ?.  =(slot-num 0)
    ::  grab last slot header hash in current epoch
    ::
    (sham p:(got:sot slots.cur (dec slot-num)))
  ::  grab last slot header hash in previous epoch
  ::
  =-  (sham p.-)
  `slot`+:(need (pry:sot slots:(got:poc epochs (dec num.cur))))
::
++  validate-history
  |=  [our=ship =epochs]
  |^  ^-  ?
  =/  prev=epoch  +:(need (ram:poc epochs))
  ?>  (validate-slots prev (sham ~) %.n)
  =/  pocs=(list (pair @ud epoch))  (bap:poc epochs)
  ?~  pocs  %.y
  (iterate-history prev t.pocs)
  ::
  ++  iterate-history
    |=  [prev=epoch pocs=(list (pair @ud epoch))]
    ^-  ?
    ?~  pocs  %.y
    ?.  ?&  =(p.i.pocs num.q.i.pocs)
            =(+(num.prev) num.q.i.pocs)
            %^  validate-slots  q.i.pocs
              (got-hed-hash 0 epochs q.i.pocs)
            =(~ t.pocs)
        ==
      %.n
    $(pocs t.pocs, prev q.i.pocs)
  ::
  ++  validate-slots
    |=  [=epoch prev-hash=@uvH is-last-epoch=?]
    ^-  ?
    =/  slots=(list (pair @ud slot))  (bap:sot slots.epoch)
    ~|  "slots are empty"
    ?<  ?&(=(~ slots) ?!(is-last-epoch))
    =/  test-epoch=^epoch  epoch(slots ~)
    |-  ^-  ?
    ?~  slots  %.y
    =*  hed  p.q.i.slots
    =*  blk  q.q.i.slots
    ?.  =(p.i.slots num.hed)  %.n
    =/  fake=[ship time ship]
      :+  our
        (dec (deadline:epo start-time.test-epoch num.hed))
      (snag num.hed order.epoch)
    =^  *  test-epoch
      (~(their-block epo test-epoch prev-hash fake) hed blk)
    $(slots t.slots, prev-hash (sham hed))
  --
--