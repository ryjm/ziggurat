/-  r=resource,
    zig=ziggurat
/+  smart=zig-sys-smart
::
|%
+$  blocks  (list [=block-header:zig =block:zig])
+$  query-type  ?(%block %block-hash %egg %from %grain %to %hash)
+$  query-payload  ?(@ux block-num=@ud)
+$  location
  $?  block-num=@ud                            :: block-hash
      [block-num=@ud town-id=@ud]              :: grain
      [block-num=@ud town-id=@ud egg-num=@ud]  :: egg, from, to
  ==
+$  index
  %+  map  query-type
  %+  map  id:smart
  location
+$  update
  $%  [%block =block-header:zig =block:zig]
      [%chunk =chunk:zig]
      [%egg =egg:smart]
      [%grain =grain:smart]
  ==
--
