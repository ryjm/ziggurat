|_  mem=(unit vase)
++  write
  |=  inp=contract-input
  ^-  contract-output
  [%result %write ~ ~]
++  read
  |=  inp=contract-input
  ^-  contract-output
  =/  a  (sub 1.000 500)
  [%result %read `a]
++  event
  |=  =contract-result
  ^-  contract-output
  [%result %read ~]
--
