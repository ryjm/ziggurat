|_  mem=(unit vase)
++  write
  |=  inp=contract-input
  ^-  contract-output
  [%result %read ~ ~]
++  read
  |=  inp=contract-input
  ^-  @
  1
++  event
  |=  =event-args
  ^-  contract-output
  [%result %read ~ ~]
--
