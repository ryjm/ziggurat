/-  *ziggurat
/+  zig-epo
|%
++  epo  epo:zig-epo
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
