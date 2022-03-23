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
+$  location
  $?  block-num=@ud                            :: block-hash
      [block-num=@ud town-id=@ud]              :: grain
      [block-num=@ud town-id=@ud egg-num=@ud]  :: egg, from, to
  ==
+$  index
  %+  map  query-type
  %+  jug  @ux
  location
+$  update
  $%  [%block =block-header:zig =block:zig]
      [%chunk =location =chunk:zig]
      [%egg eggs=(set [=location =egg:smart])]
      [%grain grains=(set [=location =grain:smart])]
  ==
--
