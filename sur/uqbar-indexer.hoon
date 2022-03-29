/-  r=resource,
    zig=ziggurat
/+  smart=zig-sys-smart
::
|%
+$  blocks  (list [=block-header:zig =block:zig])
+$  query-type
  ?(%block %block-hash %chunk %egg %from %grain %to %hash)
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
  $%  [%block =block-header:zig =block:zig]
      [%chunk location=town-location =chunk:zig]
      [%egg eggs=(set [location=egg-location =egg:smart])]
      [%grain grains=(set [location=town-location =grain:smart])]
  ==
--
