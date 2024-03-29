/-  r=resource,
    zig=ziggurat
/+  smart=zig-sys-smart
::
|%
+$  query-type
  ?(%block-hash %chunk %egg %from %grain %holder %lord %slot %to %hash)
+$  query-payload
  ?(@ux location)
::
+$  location
  $?  second-order-location
      block-location
      town-location
      egg-location
  ==
+$  second-order-location  id:smart
+$  block-location
  [epoch-num=@ud block-num=@ud]
+$  town-location
  [epoch-num=@ud block-num=@ud town-id=@ud]
+$  egg-location
  [epoch-num=@ud block-num=@ud town-id=@ud egg-num=@ud]
::
+$  update
  $%  [%chunk location=town-location =chunk:zig]
      [%egg eggs=(set [location=egg-location =egg:smart])]
      [%grain grains=(set [location=town-location =grain:smart])]
      [%slot =slot:zig]
  ==
--
