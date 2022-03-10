/+  smart=zig-sys-smart
|_  [our=@p now=@da]
++  deploy
  |=  =path
  ^-  *
  =/  text  .^(@t %cx (weld /(scot %p our)/zig/(scot %da now) path))
  (text-deploy text)
++  text-deploy
  |=  text=@t
  ^-  *
  =/  contract  (slap !>(smart) (ream text))
  =/  our-hoon  (ream '-')
  q:(slap contract our-hoon)
--