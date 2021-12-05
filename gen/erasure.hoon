/+  erasure
=,  erasure
:-  %say
|=  [[now=@da eny=@uv *] *]
=/  long-msg  'This is a long message (~2kB): Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Volutpat est velit egestas dui id ornare arcu odio ut. Sodales ut eu sem integer vitae justo. Elementum facilisis leo vel fringilla est ullamcorper eget nulla. Consectetur purus ut faucibus pulvinar. Sed elementum tempus egestas sed sed risus pretium. Pulvinar etiam non quam lacus suspendisse faucibus interdum posuere lorem. Senectus et netus et malesuada fames ac turpis. Non curabitur gravida arcu ac tortor dignissim. Convallis aenean et tortor at. Tellus in metus vulputate eu scelerisque felis imperdiet proin. A arcu cursus vitae congue mauris rhoncus aenean vel elit. Egestas integer eget aliquet nibh praesent tristique magna. Metus dictum at tempor commodo. At lectus urna duis convallis convallis. Mauris in aliquam sem fringilla ut. Leo a diam sollicitudin tempor id. Lectus nulla at volutpat diam ut. Tristique senectus et netus et malesuada fames. Mi in nulla posuere sollicitudin aliquam ultrices. Purus sit amet luctus venenatis lectus magna fringilla urna. Auctor elit sed vulputate mi sit amet mauris commodo. Sit amet justo donec enim diam vulputate ut. Quam lacus suspendisse faucibus interdum posuere lorem ipsum dolor. Id aliquet lectus proin nibh nisl condimentum id venenatis a. Sed arcu non odio euismod lacinia at quis risus. Bibendum arcu vitae elementum curabituralesuada fames. Mi in nulla posuere sollicitudin aliquam ultrices. Purus sit amet luctus venenatis lectus magna fringilla urna. Auctor elit sed vulputate mi sit amet mauris commodo. Sit amet justo donec enim diam vulputate ut. Quam lacus suspendisse faucibus interdum posuere lorem ipsum dolor. Id aliquet lectus proin nibh nisl condimentum id venenatis a. Sed arcu non odio euismod lacinia at quis risus. Bibendum arcu vitae elementum curabiturmi sit amet mauris commodo. Sit amet justo donec enim diam vulputate ut.ghggggggggggggggggggggggggggggggggggggg'
=/  short-msg  'abcdefg'
=/  msg-256  'this is an exactly 256 byte atom. this atom is 256 bytes long. jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj256'
=/  msg-125  'this is an exactly 125 byte atom. this atom is 125 bytes long. jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj125'
::
::  single piece testing
::
:: =/  f  (generate-field 256)
:: =/  n  125
:: =/  nsym  127
:: =/  nchunks  252
:: =/  generator
::   (~(rs-generator-poly gf-math f) nsym)
:: =/  encoded
::   (encode-piece msg-125 nsym f generator)
:: ~&  >  (met 3 encoded)
:: =/  decoded
::   (decode-piece (snap (rip 3 encoded) 2 0) f nsym ~[2] nchunks)
:: ~&  >>  `tape`-.decoded
::
::  full chunk dispersion testing
::  GF(256) can only handle up to 255 validators!
::
=/  nchunks  12
=/  data  long-msg
~&  >  "Input size: {<(met 3 data)>} bytes"
=/  encoded  (encode data nchunks)
=/  letters
  %+  turn
    chunks.encoded
  |=  c=@
  (rip 3 c)
:: can erase up to nchunks - (nchunks/2 - 1) pieces
=.  chunks.encoded
  (snap chunks.encoded 1 0)
=.  missing.encoded
  ~[1]
:: ~&  encoded
=/  corrected
  (decode encoded)
::  
=/  decoded-message
  %+  turn
    corrected
  |=  [data=(list @) symbols=(list @)]
  data
::  remove padding bytes from last
=/  unpadded-rear
  (slag padding-bytes.encoded (rear decoded-message))
=.  decoded-message
  %+  snoc
    %-  snip  decoded-message
  unpadded-rear
=/  repairs-combined
  `@t`(rep 3 (zing decoded-message))
:: ~&  >  repairs-combined
?:  ?!  =(data repairs-combined)
  :-  %noun
  "Repairs were NOT successful."
:-  %noun
"Repairs were successful."
