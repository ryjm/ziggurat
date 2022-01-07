/-  *mill
|_  validator-id=@ux
++  execute
  |=  [helix-id=@ud =mill =call]
  ^-  ^mill
  mill
::  =<  =^  fee  mill
::        $
::      (take-fee mill fee)
::  |-
::  ^-  [fee=@ud ^mill]
::  [0 *mill]
::
++  take-fee
  |=  [=mill fee=@ud]
  ^-  ^mill
  ::  TODO: give some money to our validator-id
  mill
--
