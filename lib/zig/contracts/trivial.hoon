^-  contract
|_  mem=(unit vase)
++  write
  |=  inp=contract-input
  ^-  output
  [%& ~ ~]
++  read
  |=  inp=contract-input
  ^-  *
  1
++  event
  |=  =event-args
  ^-  output
  [%& ~ ~]
--