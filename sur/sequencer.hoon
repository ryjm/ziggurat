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
      is-open=?
  ==
::
+$  basket-action
  $%  [%forward eggs=(set egg:smart)]
      [%receive eggs=(set egg:smart)]
  ==
::
+$  chain-action
  $%  [%leave-hall ~]
      [%set-standard-lib =path]
      $:  %init
          ::  TODO make this send a transaction to town mgmt contract
          ::  via a validator!
          town-id=@ud
          ::  TODO will remove for persistent testnet
          starting-state=(unit town:smart)
          is-open=?
      ==
  ==
--