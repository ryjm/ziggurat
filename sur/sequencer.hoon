/+  smart=zig-sys-smart
|%
+$  basket   (set egg:smart)  ::  mempool
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
  $%  [%submit ~]
      [%init town-id=@ud me=account:smart starting-state=town:smart]
      [%leave-town ~]
      [%receive-state =grain:smart]
  ==
--