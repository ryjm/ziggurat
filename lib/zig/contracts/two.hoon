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
  |=  =contract-input
  ^-  contract-output
  [%result %read ~ ~]
--
