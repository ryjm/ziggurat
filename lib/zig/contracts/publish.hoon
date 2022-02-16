/+  *tiny
|%
++  publish-contract
  |_  [mem=(unit vase) me=id]
  ++  write
    |=  inp=contract-input
    ^-  contract-output
    =*  fail  *contract-output
    ?~  args.inp  fail
    =*  args  +.u.args.inp
    ?+    -.u.args.inp  fail
        %publish
      ::  expected args: contract=*, (list rice)
      ::  need to determine way to submit list of something..
      ::  i mean, the contract can just fail if given bad inputs
      =*  cont  -.args
      =*  rices  +.args
      :^  %result  %write  ~
      %-  ~(gas by *(map id grain))
      ^-  (list [id grain])
      ::  TODO optionally assign lord from args
      =/  me  [0x0 0 [%| `cont]]
      =/  contract-id  (fry me)
      :-  i=[contract-id [contract-id me]]
      ^=  t  |-
      ?~  rices  ~
      ::  TODO: how does a contract know what helix it's in?
      ::  need to pass this in somewhere, using 0 for now
      ::  micmic is necessary here, I think
      =/  me  [contract-id 0 [%& ;;(rice -.rices)]]
      =/  my-id  (fry me)
      :-  i=[my-id [my-id me]]
      t=$(rices +.rices)
    ::
    ==
  ::
  ++  read
    |=  inp=contract-input
    ^-  contract-output
    !!
  ::
  ++  event
    |=  =contract-input
    ^-  contract-output
    !!
  --
--
