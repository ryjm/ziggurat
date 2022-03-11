/+  smart=zig-sys-smart
|%
::  bug: multiple transactions in the same basket must
::  be ordered by nonce if submitted by same user!!
+$  basket   (set egg:smart)  ::  mempool
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
      [%receive eggs=(set egg:smart) blocknum=@ud chair=@ud]
  ==
::
+$  chain-action
  $%  [%leave-hall ~]
      [%receive-state =grain:smart]
      [%set-standard-lib =path]
      $:  %init
          town-id=@ud
          me=account:smart
          ::  will probably remove starting-state for persistent testnet
          starting-state=(unit town:smart)
          is-open=?
      ==
  ==
--