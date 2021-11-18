/+  erasure
=,  erasure
:-  %say
|=  [[* eny=@uv *] *]

:: =/  msg  'this is still a short message'
=/  long-msg  'This is a very long message: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Sed turpis tincidunt id aliquet risus feugiat in. Sit amet est placerat in egestas erat imperdiet sed euismod. A pellentesque sit amet porttitor eget dolor morbi. Eget gravida cum sociis natoque. Massa tempor nec feugiat nisl pretium fusce. Posuere sollicitudin aliquam ultrices sagittis. Fringilla est ullamcorper eget nulla facilisi etiam. Mauris pharetra et ultrices neque ornare aenean euismod elementum. Non sodales neque sodales ut etiam. Lorem mollis aliquam ut porttitor leo a diam sollicitudin tempor. Pulvinar pellentesque habitant morbi tristique senectus. At urna condimentum mattis pellentesque id nibh. Amet nisl suscipit adipiscing bibendum est. Etiam erat velit scelerisque in. Eu sem integer vitae justo eget magna fermentum iaculis eu. Tellus cras adipiscing enim eu turpis egestas pretium. Sed augue lacus viverra vitae congue eu. Vulputate dignissim suspendisse in est ante in. Nunc pulvinar sapien et ligula ullamcorper. Convallis convallis tellus id interdum velit. Proin libero nunc consequat interdum. Amet porttitor eget dolor morbi non arcu risus quis. Mattis nunc sed blandit libero. Adipiscing enim eu turpis egestas pretium aenean pharetra. Mi proin sed libero enim sed faucibus turpis. Hac habitasse platea dictumst quisque sagittis purus sit. Commodo sed egestas egestas fringilla phasellus faucibus scelerisque. Commodo nulla facilisi nullam vehicula ipsum a arcu cursus. Sed odio morbi quis commodo odio. Consectetur libero id faucibus nisl tincidunt eget. Lectus urna duis convallis convallis tellus id interdum. Nulla posuere sollicitudin aliquam ultrices sagittis orci a scelerisque purus. Potenti nullam ac tortor vitae purus faucibus. Semper viverra nam libero justo. Malesuada pellentesque elit eget gravida cum sociis natoque penatibus. Cras semper auctor neque vitae tempus quam pellentesque nec. Egestas erat imperdiet sed euismod nisi porta lorem. Mattis vulputate enim nulla aliquet porttitor lacus luctus accumsan tortor. Convallis aenean et tortor at risus viverra adipiscing at. Morbi tristique senectus et netus et malesuada fames ac turpis. Donec massa sapien faucibus et molestie. Feugiat nibh sed pulvinar proin gravida. Commodo odio aenean sed adipiscing diam donec adipiscing tristique risus. Ridiculus mus mauris vitae ultricies leo integer. Neque viverra justo nec ultrices dui sapien eget mi. Suspendisse faucibus interdum posuere lorem ipsum dolor sit amet consectetur. Faucibus et molestie ac feugiat sed. Sit amet venenatis urna cursus eget nunc. Faucibus in ornare quam viverra. Vel eros donec ac odio tempor orci dapibus. Quam id leo in vitae turpis massa sed elementum tempus. Eget mauris pharetra et ultrices neque ornare aenean. Magna fermentum iaculis eu non diam phasellus vestibulum. Sem integer vitae justo eget. '
:: ~&  >  "Message: {<msg>}"
=/  nchunks  12
~&  >  "Input size: {<(met 3 long-msg)>} bytes"

=/  short-msg  'hellohellohell'

=/  encoded  (encode short-msg 12)

=/  letters
  %+  turn
    chunks.encoded
  |=  c=@
  (rip 3 c)
~&  >  "encoded: {<letters>}"
:: can erase up to nchunks - (nchunks/2 - 1) pieces
=.  chunks.encoded
  (snap chunks.encoded 2 0)
=.  missing.encoded
  ~[2]
=/  letters
  %+  turn
    chunks.encoded
  |=  c=@
  (rip 3 c)  
~&  >  "erased: {<letters>}" 
:: =/  corrected
::   (decode encoded)
::  
::  =/  decoded-message
::  %+  turn
::    corrected
::  |=  [data=(list @) symbols=(list @)]
::  (rep 3 data)
::  
::  =/  repairs-combined  `@t`(rep 10 decoded-message)
::  
::  ?:  ?!  =(long-msg repairs-combined)
::    !! :: repaired msg doesn't match!
::  
:-  %noun
"Repaired: "
