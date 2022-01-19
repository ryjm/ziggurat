=<  read
|%
++  read
  |=  n=@
  ^-  ^
  [13 26]
::
++  write
  |=  s=^
  ^-  @
  13
::  =/  l=(list @ud)
::    ~(tap in s)
::  =|  n=@ud
::  |-
::  ?~  l  n
::  $(n (add n i.l), l t.l)
--
