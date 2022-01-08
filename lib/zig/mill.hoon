/-  *mill
|_  validator-id=@ux
::  +run-pool: executes all calls in mempool
++  run-pool
  |=  [helix-id=@ud =mill mempool=(list call)]
  ::  'chunk' def
  ^-  [(list [@ux call]) ^mill]  
  =/  to-run  (gather mempool)
  =+  result=*(list [@ux call])
  |-  ^-  [(list [@ux call]) ^mill]
  ?~  to-run
    [result mill]
  %_  $
    to-run  t.to-run
    result  [[`@ux`(shax (jam i.to-run)) i.to-run] result]
    mill    (execute helix-id mill i.to-run)
  ==
::  +execute: performs a single call and returns updated mill
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
++  gather
  |=  mempool=(list call)
  ^+  mempool
  %+  sort
    mempool
  |=  [a=call b=call]
  (gth rate.a rate.b)
++  create-id
  ^-  id
  0x0
--

