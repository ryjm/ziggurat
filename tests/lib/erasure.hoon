/+  erasure
=,  erasure
::
::  Tests for encoding/decoding arms in erasure.hoon
::  Preparing for jetting of $encode-piece and $decode-piece
::
|%
++  two-kb-t
  ^-  @t
  'This is a long message (~2kB): Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Volutpat est velit egestas dui id ornare arcu odio ut. Sodales ut eu sem integer vitae justo. Elementum facilisis leo vel fringilla est ullamcorper eget nulla. Consectetur purus ut faucibus pulvinar. Sed elementum tempus egestas sed sed risus pretium. Pulvinar etiam non quam lacus suspendisse faucibus interdum posuere lorem. Senectus et netus et malesuada fames ac turpis. Non curabitur gravida arcu ac tortor dignissim. Convallis aenean et tortor at. Tellus in metus vulputate eu scelerisque felis imperdiet proin. A arcu cursus vitae congue mauris rhoncus aenean vel elit. Egestas integer eget aliquet nibh praesent tristique magna. Metus dictum at tempor commodo. At lectus urna duis convallis convallis. Mauris in aliquam sem fringilla ut. Leo a diam sollicitudin tempor id. Lectus nulla at volutpat diam ut. Tristique senectus et netus et malesuada fames. Mi in nulla posuere sollicitudin aliquam ultrices. Purus sit amet luctus venenatis lectus magna fringilla urna. Auctor elit sed vulputate mi sit amet mauris commodo. Sit amet justo donec enim diam vulputate ut. Quam lacus suspendisse faucibus interdum posuere lorem ipsum dolor. Id aliquet lectus proin nibh nisl condimentum id venenatis a. Sed arcu non odio euismod lacinia at quis risus. Bibendum arcu vitae elementum curabituralesuada fames. Mi in nulla posuere sollicitudin aliquam ultrices. Purus sit amet luctus venenatis lectus magna fringilla urna. Auctor elit sed vulputate mi sit amet mauris commodo. Sit amet justo donec enim diam vulputate ut. Quam lacus suspendisse faucibus interdum posuere lorem ipsum dolor. Id aliquet lectus proin nibh nisl condimentum id venenatis a. Sed arcu non odio euismod lacinia at quis risus. Bibendum arcu vitae elementum curabiturmi sit amet mauris commodo. Sit amet justo donec enim diam vulputate ut.ghggggggggggggggggggggggggggggggggggggg'
++  encode-params
  ^-  [f=field nsym=@ud generator=@]
  =/  f  (generate-field 256)
  :*  f
      12 :: selected in a random fashion
      (~(rs-generator-poly gf-math f) 12)
  ==
++  test-encode-piece
  =/  test-data  'here are some bytes to test with'
  =+  encode-params
  =/  encoded
    (encode-piece test-data nsym f generator)
  =/  correct  47.246.218.407.191.961.773.447.119.806.777.089.973.953.489.518.925.618.957.327.589.190.983.402.808.680
  ?>  =(encoded correct)
  ~
++  test-encode-piece-2
  =/  test-data  'some more testing bytes'
  =+  encode-params
  =/  encoded
    (encode-piece test-data nsym f generator)
  =/  correct  11.052.770.513.474.513.468.179.030.653.391.482.885.198.184.786.386.841.459
  ?>  =(encoded correct)
  ~
++  test-encode-piece-3
  =/  test-data  0x3323.7654.1534.0976.1243.3765.2345.7654.2132
  =+  encode-params
  =/  encoded
    (encode-piece test-data nsym f generator)
  =/  correct  7.916.045.529.306.473.941.742.348.148.591.186.489.105.090.084.086.066
  ?>  =(encoded correct)
  ~
++  test-decode-1
  =/  nchunks  35
  ::  very circular, but difficult to create proper testing parameters
  =/  encoded  (encode two-kb-t nchunks)
  ::  try decoding with many combinations of erased chunks
  ::  total # of erasures it can handle == nsym.encoded
  ?>
  %+  levy
    ^-  (list (list @ud))
    :~
      ~[0 1 2 3 4 5]
      ~[0 2 4 6 8 10]
      ~[1 3 5 7 9 11]
      ~[34 33 32 31 30]
      ~[0 34 2 32 4 30]
      (gulf 1 nsym.encoded)
      (gulf 5 (add nsym.encoded 4))
    ==
  |=  to-erase=(list @ud)
  =.  chunks.encoded
    =<  q
    %^    spin
        to-erase
      chunks.encoded
    |=  [i=@ud chunks=(list @)]
    [i (snap chunks i 0)]
  =.  missing.encoded
    to-erase
  .=(two-kb-t `@t`(decode encoded))
  ~
++  test-decode-2
  =/  nchunks  255 ::maximum
  =/  encoded  (encode two-kb-t nchunks)
  ?>
  %+  levy
    ^-  (list (list @ud))
    :~
      ~[0 1 2 3 4 5]
      ~[0 2 4 6 8 10]
      ~[1 3 5 7 9 11]
      ~[34 33 32 31 30]
      ~[0 34 2 32 4 30]
      (gulf 1 nsym.encoded)
      (gulf 5 (add nsym.encoded 4))
    ==
  |=  to-erase=(list @ud)
  =.  chunks.encoded
    =<  q
    %^    spin
        to-erase
      chunks.encoded
    |=  [i=@ud chunks=(list @)]
    [i (snap chunks i 0)]
  =.  missing.encoded
    to-erase
  .=(two-kb-t `@t`(decode encoded))
  ~
--
