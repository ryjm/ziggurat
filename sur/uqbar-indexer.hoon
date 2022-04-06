/-  r=resource,
    zig=ziggurat
/+  smart=zig-sys-smart
::
|%
+$  query-type
  ?(%block-hash %chunk %egg %from %grain %slot %to %hash)
+$  query-payload
  ?(hash=@ux block-num=@ud [block-num=@ud town-id=@ud])
::
+$  location
  $?  block-location
      town-location
      egg-location
  ==
+$  block-location
  block-num=@ud
+$  town-location
  [block-num=@ud town-id=@ud]
+$  egg-location
  [block-num=@ud town-id=@ud egg-num=@ud]
::
+$  update
  $%  [%chunk location=town-location =chunk:zig]
      [%egg eggs=(set [location=egg-location =egg:smart])]
      [%grain grains=(set [location=town-location =grain:smart])]
      [%slot =slot:zig]
  ==
--
