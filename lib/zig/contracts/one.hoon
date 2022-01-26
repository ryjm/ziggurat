|_  mem=(unit vase)
++  write
  |=  inp=contract-input
  ^-  contract-output
  [%result %read ~]
++  read
  |=  inp=contract-input
  ^-  contract-output
  [%result %read ~]
++  event
  |=  =event-args
  ^-  contract-output
  [%result %read ~]
--
