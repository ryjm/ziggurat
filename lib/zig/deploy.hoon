/+  smart=zig-sys-smart
/*  smart-lib  %noun  /lib/zig/sys/smart-lib-2/noun
|_  [our=@p now=@da]
++  deploy
  |=  =path
  ^-  *
  =/  text  .^(@t %cx (weld /(scot %p our)/zig/(scot %da now) path))
  (text-deploy text)
++  text-deploy
  |=  text=@t
  ^-  *
  ::  this could be faster by creating another .noun
  ::  saving that for another day.
  =/  smart-txt  .^(@t %cx /(scot %p our)/zig/(scot %da now)/lib/zig/sys/smart/hoon)
  =/  hoon-txt  .^(@t %cx /(scot %p our)/base/(scot %da now)/sys/hoon/hoon)
  =/  hoe  (slap !>(~) (ream hoon-txt))
  =/  hoed  (slap hoe (ream smart-txt))
  =/  contract  (slap hoed (ream text))
  q:(slap contract (ream '-'))
--