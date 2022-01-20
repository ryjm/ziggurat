^-  contract
|_  mem=(unit vase)
++  write
  |=  inp=contract-input
  ^-  output
  [%result ~ ~]
++  read
  |=  inp=contract-input
  ^-  *
  1
++  event
  |=  =event-args
  ^-  output
  [%result ~ ~]
--