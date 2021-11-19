=>  ~%  %erasure-types-lib  ..part  ~
  |%
  +$  field
    $:  size=@ud
        exp=@
        log=@
    ==
  +$  field-list
    $:  size=@ud
        exp=(list @ud)
        log=(list @ud)
    ==
  :: encoded data type
  +$  encoded-chunks
    $:  amount=@ud
        needed=@ud
        padding-bytes=@ud
        nsym=@ud
        field-size=@ud
        :: indices of any missing chunks
        :: for erasing by end users
        missing=(list @ud)
        :: should be a map, maybe?
        chunks=(list @)
    ==
  --
=<
~%  %erasure-lib-main  ..generate-field  ~
|%
::  $encode: perform reed-solomon encoding on an atom
::
::    Encode takes an atom and a number of chunks to produce
::    that can then be erased up to a certain threshold. That
::    threshold is defined as n=(number of chunks)/2 - 1.
::    Returns a type containing amount of chunks, padding bytes
::    if any, size of Galois field used, and the chunks themselves.
::
++  encode
  ~/  %encode
  |=  [input=@ nchunks=@]
  ^-  encoded-chunks
  ::  n, the number of chunks needed to reconstruct
  ::
  =/  n  
    %-  dec 
    %+  div
      nchunks
    2
  =/  padding-bytes
    =/  extra
      %+  mod  (met 3 input)  n
    ?:  =(extra 0)
      0
    %+  sub
      n
    extra
  ::  nsym, the number of extra code symbols encoding will generate
  ::
  =/  nsym
    %+  sub  nchunks  n
  =/  smallest-field-size
    %-  bex  (met 0 nchunks)
  ::  the galois field used for encoding
  ::
  =/  f
    %-  generate-field
    ?:  (gth 256 smallest-field-size)
      256
    smallest-field-size
  ::  irreducible encoder polynomial represented as atom
  ::
  =/  gen
    (~(rs-generator-poly gf-math f) nsym)
  =/  gen-lent
    (met 3 gen)
  ~&  "nchunks: {<nchunks>}"
  ~&  "n: {<n>}"
  ::  the number of bytes in 'slices' input atom will become
  ::
  =/  total
    ?:  =(0 padding-bytes)
      %+  div  (met 3 input)  n
    %-  succ
    %+  div  (met 3 input)  n
  ~&  "total: {<total>}"
  ::  an atom containing the encoded bytes, but rearranged
  ::  such that erasures can be done to large pieces of data
  ::
  =/  encoded-frags
    =+  [remaining=input encoded-frags=*@ count=*@ud]
    |-  ^+  encoded-frags
    ?:  =(remaining 0)
      encoded-frags
    =/  piece
      (end [3 n] remaining)
    ::  pad with 0s if input < n bytes
    ::
    =.  piece
      ?.  (lth (met 3 piece) n)
        piece
      (lsh [3 (sub n (met 3 piece))] piece)
    =/  encoded-piece
      ^-  @
      ::  throw an error if message too long
      ::
      ?:  (gth nchunks (dec size.f))
          !! 
      =/  symbols
        =+  :-  i=(dec nchunks)
            encoded=(lsh [3 (dec gen-lent)] (rev 3 n piece))
        |-  ^+  encoded
        ?:  =(i +(n))  encoded
        =/  coef  (cut 3 [i 1] encoded)
        ::  don't do anything if on an empty byte
        ::
        ?:  =(coef 0)
          %=  $
            i  (dec i)
          ==
        =/  subloop-result
          =+  j=1
          |-  ^+  encoded
          ?:  =(j gen-lent)
            encoded
          =/  new
            %+  mix
              (cut 3 [(sub i j) 1] encoded)
            %+  ~(gf-mul gf-math f)
              (cut 3 [j 1] gen)
            coef
          %=  $
            j  +(j)
            encoded  (sew 3 [(sub i j) 1 new] encoded)
          ==
        %=  $
          i  (dec i)
          encoded  subloop-result
        ==
      %^  cat  3
        piece
      (rev 3 nsym (end [3 nsym] symbols))
    ::  now, assign every nth byte of encoded-piece
    ::  to the matching index in an encoded set of bytes
    ::
    =.  encoded-frags
      =+  i=0
      |-
      ?:  =(encoded-piece 0)
        encoded-frags
      =.  encoded-frags
        %^  sew  3
          [(add (mul i total) count) 1 (end 3 encoded-piece)]
        encoded-frags
      %=  $
        i  +(i)
        encoded-piece  (rsh 3 encoded-piece)
      ==
    %=  $
      count  +(count)
      remaining  (rsh [3 n] remaining)
    ==  
  [nchunks n padding-bytes nsym size.f ~ (rip-with-padding [3 total] encoded-frags)]
::  $decode: take a list of erasure-coded chunks and perform repairs
::
::    Decode needs at least as many symbols as missing chunks to
::    successfully decode the chunks. TODO change to atom/byte
::    manipulation
::    Gives back a cell of the decoded data and the ECC code symbols
::
++  decode
  ~/  %decode
  |=  encoded=encoded-chunks
  ^-  (list [(list @) (list @)])
  ?:  (gth amount.encoded 255)
    !!
  ?:  (gth (lent missing.encoded) nsym.encoded)
    !!
  =/  f  (generate-field field-size.encoded)
  =/  reconstructed-amount  (met 3 (rear chunks.encoded))
  ::  need to reconstruct encoded bytes linearly
  ::  rather than split between chunks
  ::
  =/  linear-stream
    ^-  (list (list @))
    =+  [collected=*(list (list @)) n=*@ud]
    |-  ^+  collected
    ?:  =(n reconstructed-amount)
      ::  finished
      collected
    =/  slice
      ^-  (list @)
      ::  grab the nth byte from each chunk
      ::
      %+  turn
        chunks.encoded
      |=  chunk=@
      (cut 3 [n 1] chunk)
    =.  collected
      %+  snoc
        collected
      slice
    %=  $
        n  +(n)
    ==
  ::  now go through reconstructed chunks and decode one at a time
  ::
  %+  turn
    linear-stream
  |=  chunk=(list @)
  ^-  [(list @) (list @)]
  =/  synd
    (~(calc-syndromes gf-math f) chunk nsym.encoded)
  ::  if max val in synd is 0, no erasures
  ::
  =/  repaired
    (~(correct-errata gf-math f) chunk synd missing.encoded)
  ::  check if max val in synd is NOT 0 and throw an error (couldn't correct)
  ::
  =/  pos  (sub amount.encoded nsym.encoded)
  :-  (scag pos repaired)
  (slag pos repaired)
--
::
~%  %erasure-lib-utils  ..field  ~
|%
::  $generate-field: build a galois field table of size
::  
++  generate-field
  ~/  %generate-field
  |=  size=@
  ^-  field
  =/  exp-and-log
    =+  [i=0 exp=*@ log=*@ x=1]
    |-  ^+  [exp log]
    ?:  =(i (dec size))
      [exp log]
    ?:  =(i 0)
      %=  $
          i  +(i)
          exp  (cat 3 1 exp)
      ==
    =.  x  (lsh 0 x)
    =.  x
      ?.  =((dis x size) 0)
        (mix x (con size 0x1D))
      x
    %=  $
        i  +(i)
        exp  (cat 3 exp x)::insert x at i
        log  (sew 3 [x 1 i] log)
    ==
  =/  exp
    (cat 3 -.exp-and-log -.exp-and-log)
  =/  log
    +.exp-and-log
  [size exp log]
::  $rip-with-padding: $rip, but pad the last item to fit bite size.
:: 
++  rip-with-padding
  |=  [a=bite b=@]
  ^-  (list @)
  ?:  (lte (met 3 b) +.a)
    ~[(lsh [3 (sub +.a (met 3 b))] b)]
  [(end a b) $(b (rsh a b))]
::
::  Galois math
::
++  gf-math
  ~%  %gf-math-functions  ..field  ~
  |_  f=field
  ++  gf-add
    ~/  %gf-add
    |=  [x=@ y=@]
    ^-  @
    %+  mix  x  y
  ::
  ++  gf-sub
    ~/  %gf-sub
    |=  [x=@ y=@]
    ^-  @
    %+  mix  x  y
  ::
  ++  gf-mul
    ~/  %gf-mul
    |=  [x=@ y=@]
    ^-  @
    ?:  ?|  =(x 0)
            =(y 0)
        ==
      0
    %^  cut  3
      :_  1
      %+  add
        (cut 3 [x 1] log.f)
      (cut 3 [y 1] log.f)
    exp.f
  ::
  ++  gf-div
    ~/  %gf-div
    |=  [x=@ y=@]
    ^-  @
    ::  reject attempt to divide by 0
    ?:  =(y 0)
      !!
    ?:  =(x 0)
      0
    %^  cut  3
      :_  1
      %+  mod
        %+  sub
          %+  add
            (cut 3 [x 1] log.f)
          255
        (cut 3 [y 1] log.f)
      255
    exp.f
  ::
  ++  gf-pow
    ~/  %gf-pow
    |=  [x=@ power=@]
    ^-  @
    %^  cut  3
      :_  1
      %+  mod
        %+  mul
          (cut 3 [x 1] log.f)
        power
      255
    exp.f
  ::
  ++  gf-inverse
    ~/  %gf-inverse
    |=  [x=@]
    ^-  @
    %^  cut  3
      :_  1
      %+  sub
        255
      (cut 3 [x 1] log.f)
    exp.f
  ::
  ::  Polynomial math
  ::
  ++  gf-poly-scale
    ~/  %gf-poly-scale
    |=  [p=(list @) x=@]
    ^-  (list @)
    %+  turn
      p
    |=  i=@
    %+  gf-mul
      i
    x
  ::
  ++  gf-poly-add
    ~/  %gf-poly-add
    |=  [p=(list @) q=(list @)]
    ^-  (list @)
    =/  [longer=(list @) shorter=(list @)]
      ?:  (gth (lent p) (lent q))
        [p q]
      [q p]
    =/  diff
      %+  sub
        (lent longer)
      (lent shorter)
    %+  welp
      %+  scag
        diff
      longer
    =<  p
    %^    spin
        %+  slag
          diff
        longer
      shorter
    |=  [i=@ud r=(list @)]
    [(mix i -.r) +.r]
  ::
  ++  gf-poly-mul
    ~/  %gf-poly-mul
    |=  [p=(list @) q=(list @)]
    ^-  (list @)
    =<  q
    %^    spin
        (gulf 0 (sub (lent q) 1))
      (reap (sub (add (lent p) (lent q)) 1) 0)
    |=  [j=@ r=(list @)]
    =<  q
    %^    spin
        (gulf 0 (sub (lent p) 1))
      [j r]
    |=  [i=@ [j=@ r=(list @)]]
    =/  a
      %+  gf-add
        %+  snag
          (add i j)
        r
      %+  gf-mul
        (snag i p)
      (snag j q)
    :-  i
    :-  j
    %^    snap
        r
      (add i j)
    a
    
  ::
  ++  gf-poly-mul-bytes
    ~/  %gf-poly-mul-bytes
    |=  [p=@ q=@]
    ^-  @
    =/  el-p  (met 3 p)
    =/  el-q  (met 3 q)
    =+  [j=0 output=*@]
    |-  ^-  @
    ?:  =(j el-q)
      output
    ::  inner loop
    ::
    =.  output
      =+  i=0
      |-  ^-  @
      ?:  =(i el-p)
        output
      =/  r
        %+  gf-add
          (cut 3 [(add i j) 1] output)
        %+  gf-mul
          (cut 3 [i 1] p)
        (cut 3 [j 1] q) 
      %=  $
          i  +(i)
          output  (sew 3 [(add i j) 1 r] output)
      ==
    %=  $
        j  +(j)
    ==
  ::
  ++  gf-poly-eval
    ~/  %gf-poly-eval
    |=  [p=(list @) x=@]
    ^-  @
    =/  y  -.p
    =<  q
    %^    spin
        `(list @)`+.p
      y
    |=  [i=@ y=@]
    [i (mix (gf-mul y x) i)]
  ::
  :: ++  gf-poly-eval-bytes
  ::   ~/  %gf-poly-eval-bytes
  ::   |=  [p=@ x=@]
  ::   ^-  @
  ::   =+  rest=p
  ::   |-
  ::   =/  y  (end 3 p)
  ::   ?:  =(rest 0)
  ::
  ::  Reed-Solomon encoding utils
  ::
  ++  rs-generator-poly
    ~/  %rs-generator-poly
    |=  nsym=@
    ^-  @
    =+  [i=0 output=1]
    |-
    ?:  =(i nsym)
      output
    =.  output
      %+  gf-poly-mul-bytes
        output
      %^  cat  3
        1
      %+  gf-pow
        2
      i
    %=  $
        i  +(i)
    ==
  ::
  ::  Reed-Solomon decoding utils
  ::  Currently just handling repairing *erasures*, 
  ::  but can supplement to find and repair *errors*
  :: 
  ++  calc-syndromes
    ~/  %calc-syndromes
    |=  [data=(list @) nsym=@]
    ^-  (list @)
    %+  weld
      ~[0]
    %+  turn
      (gulf 0 (sub nsym 1))
    |=  i=@
    %+  gf-poly-eval
      data
    (gf-pow 2 i)
  ::
  :: ++  calc-syndromes-bytes
  ::   ~/  %calc-syndromes
  ::   |=  [data=@ nsym=@]
  ::   ^-  @
  ::   =+  [synd=0 i=0]
  ::   |-
  ::   ?:  =(i nsym)
  ::     synd
  ::   =/  new
  ::     %+  gf-poly-eval
  ::       data
  ::     (gf-pow 2 i)
  ::   =.  synd
  ::     (sew 3 [i 1 new] synd)
  ::   $(i +(i))
  ::
  ++  find-errata-locator
    ~/  %find-errata-locator
    :: takes in a list of erasure positions
    |=  [erasures=(list @)]
    ^-  (list @)
    =<  q
    %^    spin
        erasures
      `(list @)`~[1]
    |=  [i=@ loc=(list @)]
    :-  i
    %+  gf-poly-mul
      loc
    %+  gf-poly-add
      `(list @)`~[1]
    `(list @)`~[(gf-pow 2 i) 0]
  ::
  ++  find-error-evaluator
    ~/  %find-error-evaluator
    |=  [synd=(list @) err-locs=(list @) nsym=@]
    ^-  (list @)
    =/  remainder
      %+  gf-poly-mul
        synd
      err-locs
    :: return truncated remainder, equivalent to dividing
    %+  slag
      %+  sub
        (lent remainder)
      (add nsym 1)
    remainder
  ::
  ++  correct-errata
    ~/  %correct-errata
    |=  [data=(list @) synd=(list @) erasures=(list @)]
    =/  el  (lent data)
    =/  coef-pos
      %+  turn
        erasures
      |=  i=@
      (sub (sub el 1) i)
    =/  err-locs
      (find-errata-locator coef-pos)
    =/  err-eval
      %-  flop 
      %^    find-error-evaluator
          (flop synd)
        err-locs
      (sub (lent err-locs) 1)
    =/  x
      %+  turn
        (gulf 0 (sub (lent coef-pos) 1))
      |=  i=@
      (gf-pow 2 (snag i coef-pos))
    =/  x-lent  (lent x)
    :: Forney algorithm
    =/  e
      =<  q
      %^    spin
          (gulf 0 (sub x-lent 1))
        (reap (lent data) 0)
      |=  [i=@ e=(list @)]
      =/  inverse  (gf-inverse (snag i x))
      =/  err-loc-prime-tmp
        %+  turn
          (oust [i 1] (gulf 0 (sub x-lent 1)))
        |=  j=@
        %+  gf-sub
          1
        %+  gf-mul
          inverse
        (snag j x)
      =/  err-loc-prime
        =<  q
        %^    spin
            err-loc-prime-tmp
          1
        |=  [coef=@ err=@]
        :-  coef
        %+  gf-mul
          err
        coef
        =/  y  (gf-poly-eval (flop err-eval) inverse)
        =/  y  (gf-mul (gf-pow (snag i x) 1) y)
        ?:  =(err-loc-prime ~[0])
          !! :: could not find error magnitude
        =/  magnitude  (gf-div y err-loc-prime)
        [i (snap e (snag i erasures) magnitude)]
    :: apply correction field to input for repaired data
    %+  gf-poly-add
      data
    e
  --
--
