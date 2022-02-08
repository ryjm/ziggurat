^-  contract
|_  mem=(unit vase)
++  write
  |=  inp=contract-input
  ^-  contract-output
  [%result %write ~ ~]
++  read
  |=  inp=contract-input
  ^-  contract-output
  [%result %read ~]
++  event
  |=  =contract-input
  ^-  contract-output
  [%result %read ~]
--
