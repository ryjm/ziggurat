/+  erasure
=,  erasure
::
::  Tests for encoding/decoding arms in erasure.hoon
::  Preparing for jetting of $encode-piece and $decode-piece
::
|%
++  gen-encode-params
  ^-  [f=field nsym=@ud generator=@]
  =/  f  (generate-field 256)
  :*  f
      12 :: selected in a random fashion
      (~(rs-generator-poly gf-math f) 12)
  ==
++  test-encode-piece
  =/  test-data  'here are some bytes to test with'
  =+  gen-params
  =/  encoded
    (encode-piece test-data nsym f generator)
  =/  correct  47.246.218.407.191.961.773.447.119.806.777.089.973.953.489.518.925.618.957.327.589.190.983.402.808.680
  ?>  =(encoded correct)
  ~
++  test-encode-piece-2
  =/  test-data  'some more testing bytes'
  =+  gen-params
  =/  encoded
    (encode-piece test-data nsym f generator)
  =/  correct  11.052.770.513.474.513.468.179.030.653.391.482.885.198.184.786.386.841.459
  ?>  =(encoded correct)
  ~
++  test-encode-piece-3
  =/  test-data  0x3323.7654.1534.0976.1243.3765.2345.7654.2132
  =+  gen-params
  =/  encoded
    (encode-piece test-data nsym f generator)
  ~&  >  encoded
  =/  correct  7.916.045.529.306.473.941.742.348.148.591.186.489.105.090.084.086.066
  ?>  =(encoded correct)
  ~
--
