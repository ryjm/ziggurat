/+  smart=zig-sys-smart
|%
::  bug: multiple transactions in the same basket must
::  be ordered by nonce if submitted by same user!!
::
+$  hall  ::  runs a town
  $:  council=(map ship id:smart)
      order=(list ship)
  ==
::
+$  basket-action
  $%  [%forward eggs=(set egg:smart)]
      [%receive eggs=(set egg:smart)]
  ==
::
+$  chain-action
  $%  ::  will remove starting-state for persistent testnet
      [%init town-id=@ud starting-state=(unit town:smart) gas=[rate=@ud bud=@ud]]
      [%join town-id=@ud gas=[rate=@ud bud=@ud]]
      [%exit gas=[rate=@ud bud=@ud]]
      [%clear-state ~]
  ==
--