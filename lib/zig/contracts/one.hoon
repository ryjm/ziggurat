^-  contract
|_  mem=(unit vase)
++  write
  |=  inp=contract-input
  ^-  contract-output
  [%result ~ ~]
++  read
  |=  inp=contract-input
  ^-  contract-output
  [%result ~ ~]
++  event
  |=  =event-args
  ^-  contract-output
  [%result ~ ~]
--
