/+  *tiny
=>  |%
    +$  helix-data
      $:  =id
          validators=(map id ship)
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
    =/  our-rice=rice  -:~(val by rice.inp)
    =/  data  ;;(helix-data data.our-rice)
    =*  args  +.u.args.inp
    =.  data.our-rice
      ?+    -.u.args.inp  data
          %register
        ::  expected args: @p. future: stake?
        ?.  ?=(=ship args)  data
        ::  must be a star
        ?.  =((met 3 ship.args) 2)  data
        ::  new ship will start in order on next epoch.
        data(validators (~(put by validators.data) caller-id ship.args))
      ::
          %exit
        ::  no args needed
        ::  exit will be reflected in next epoch
        data(validators (~(del by validators.data) caller-id))
      ::
          %increment-epoch
        ::  expected args: hash of last block or something
        ::  only leader can perform
        ::  triggers shuffle of order
        data
      ==
    :*  %result
        %write
        changed=(malt ~[[0x0 [%& our-rice]]])
        issued=~
    ==
  ::
  ++  read
    |=  inp=contract-input
    ^-  contract-output
    :+  %result
      %read
    ?~  args.inp  ~
    =/  our-rice=rice  -:~(val by rice.inp)
    =/  data  ;;(helix-data data.our-rice)
    =*  args  +.u.args.inp
    :+  %result  %read
    ^-  *
    ?+    -.u.args.inp  ~
        %get-validator-ship
      ::  expected args: id, returns @p
      ?.  ?=([=id] args)  ~
      (~(get by validators.data) `@ux`id.args)
    :: 
        %get-order
      ::  expected args: none
      order.data
    ::
        %get-leader
      ::  expected args: none
      leader.data
    ::
        %get-epoch
      ::  expected args: none
      epoch.data
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
