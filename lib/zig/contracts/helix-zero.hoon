/+  *tiny
=>  |%
    +$  helix-data
      $:  =id
          validators=(map ship id)
          order=(list ship)
          leader=ship
          epoch=@ud
          ::  this could also hold zig STAKES if desired.
          ::  stakes=(map ship @ud)
          ::  total-staked=@ud
      ==
    --
::
::  Helix runner contract
::
::  A helix runner contract can be deployed for each helix on
::  Uqbar. The contract is responsible for validator registration
::  and providing on-chain data about the nature of a given helix.
::  This is one option for implementing helices, but it could also
::  be done purely in a library run by the validator agent. Either
::  way, storing this data somewhere on-chain is useful for other
::  contracts to use, and if validators are to stake tokens for PoS,
::  this would be a good place to store those tokens.
::
|%
++  helix-contract
  ^-  contract
  |_  mem=(unit vase)
  ++  write
    |=  inp=contract-input
    ^-  contract-output
    ?~  args.inp  *contract-output
    =/  caller-id
      ^-  id
      ?:  ?=(@ux caller.inp)
        caller.inp
      id.caller.inp
    =*  args  +.u.args.inp
    =.  data.u.our-rice
      ?+    -.u.args.inp  data
          %register
        :: expected args: @p, stake??
        data
      ::
          %exit
        ::  no args needed
        data
      ::
          %increment-epoch
        ::  expected args: hash of last block or something
        ::  only leader can perform
        ::  triggers shuffle of order
        data
      ==
    :*  %result
        %write
        changed=(malt ~[[0x0 [%& u.our-rice]]])
        issued=~
    ==
  ::
  ++  read
    |=  inp=contract-input
    ^-  contract-output
    :+  %result
      %read
    ?~  args.inp  ~
    =*  args  +.u.args.inp
    ?+    -.u.args.inp  ~

    ==
  ::
  ++  event
    |=  inp=contract-input
    ^-  contract-output
    ?~  args.inp  *contract-output
    =/  caller-id
      ^-  id
      ?:  ?=(@ux caller.inp)
        caller.inp
      id.caller.inp
    =*  args  +.u.args.inp
    ?+    -.u.args.inp  *contract-output
        %next-leader
      ::  grab next from order list
      *contract-output
    ::
        %next-epoch
      ::  shuffle order, assign first leader
      *contract-output
    ::
    ==
  --
--
