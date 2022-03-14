/+  smart=zig-sys-smart
|%
::  bug: multiple transactions in the same basket must
::  be ordered by nonce if submitted by same user!!
::
+$  hall  ::  runs a town
  $:  id=@ud
      blocknum=@ud
      council=(set ship)
      order=(list ship)
      chair=@ud  :: position of leader in order
  ==
::
+$  basket-action
  $%  [%forward eggs=(set egg:smart)]
      [%receive eggs=(set egg:smart)]
  ==
::
+$  chain-action
  $%  [%leave-hall ~]
      ::  can fold this into init
      [%set-standard-lib =path]
      ::  TODO make this send a transaction to town mgmt contract
      ::  via a validator!
      ::  will remove starting-state for persistent testnet
      [%init town-id=@ud starting-state=(unit town:smart)]
  ==
--