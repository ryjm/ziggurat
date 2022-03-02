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
  $%  [%receive egg=egg:smart]
      [%hear egg=egg:smart]
      [%forward-set to=ship eggs=(set egg:smart)]
      [%receive-set eggs=(set egg:smart)]
  ==
::
+$  chain-action
  $%  [%submit ~]
      [%init town-id=@ud me=account:smart starting-state=town:smart]
      [%leave-town ~]
      [%receive-state =grain:smart]
  ==
--