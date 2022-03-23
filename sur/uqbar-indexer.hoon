/-  r=resource,
    zig=ziggurat
/+  smart=zig-sys-smart
::
|%
+$  blocks  (list [=block-header:zig =block:zig])
+$  query-type  ?(%block %grain %to %from %egg)
+$  query-payload  ?(id:smart block-num=@ud)
+$  location
  $?  [block-num=@ud town-id=@ud]              :: rice, wheat
      [block-num=@ud town-id=@ud egg-num=@ud]  :: to, from, egg
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
