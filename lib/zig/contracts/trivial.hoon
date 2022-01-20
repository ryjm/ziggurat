^-  contract
|_  mem=(unit vase)
++  write
  |=  inp=contract-input
  ^-  output
  [%result %write ~ ~]
++  read
  |=  inp=contract-input
  ^-  output
  [%result %read ~]
++  event
  |=  =event-args
  ^-  output
  [%result %read ~]
--