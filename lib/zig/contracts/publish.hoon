|_  mem=(unit vase)
++  write
  |=  inp=contract-input
  ^-  contract-output
  :^  %result  %write  ~
  %-  ~(gas by *(map id grain))
  =-  [- %| - 0x3 args.inp]^~   ::  hardcodes the location of the publish contract
  `@ux`(mug args.inp)        ::  TODO: replace with sha256
::
++  read
  |=  inp=contract-input
  ^-  contract-output
  !!
::
++  event
  |=  =event-args
  ^-  contract-output
  !!
--
