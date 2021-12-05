=>  ~%  %erasure-types  ..part  ~
  |%
  +$  field
    $:  size=@ud
        exp=@
        log=@
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
::    threshold is defined as n=(number of chunks - 1)/2.
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
    (div (dec nchunks) 2)
  =/  padding-bytes
    =/  extra
      (mod (met 3 input) n)
    ?:  =(extra 0)
      0
    (sub n extra)
  ::  nsym, the number of extra code symbols encoding will generate
  ::
  =/  nsym  (sub nchunks n)
  ::  the galois field used for encoding
  ::
  =/  f  (generate-field 256)
  ::  irreducible encoder polynomial represented as atom
  ::
  =/  gen
    (~(rs-generator-poly gf-math f) nsym)
  =/  gen-lent
   (met 3 gen)
  ::  the number of bytes in 'slices' input atom will become
  ::
  =/  total
    ?:  =(0 padding-bytes)
      (div (met 3 input) n)
    (succ (div (met 3 input) n))
  ::  an atom containing the encoded bytes, but rearranged
  ::  such that erasures can be done to large pieces of data
  ::
  =/  encoded-frags
    %:  encode-frags
        input
        n
        f
        nsym
        nchunks
        gen
        gen-lent
        total
    ==
  :*  nchunks
      n
      padding-bytes
      nsym
      size.f
      ~
      %+  rip-with-padding  
        [3 total]
      encoded-frags
  ==
++  encode-frags
  ~/  %encode-frags
  |=  [remaining=@ n=@ud f=field nsym=@ nchunks=@ generator=@ gen-lent=@ud total=@ud]
  ^-  @
  =+  [encoded-frags=*@ count=*@ud]
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
    %+  lsh
      [3 (sub n (met 3 piece))]
    piece
  =/  encoded-piece
    %:  encode-piece
        piece
        nsym
        f
        generator
    ==
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
        :+  (add (mul i total) count)
            1 
            (end 3 encoded-piece)
      encoded-frags
    %=  $
      i  +(i)
      encoded-piece  (rsh 3 encoded-piece)
    ==
  %=  $
    count  +(count)
    remaining  (rsh [3 n] remaining)
  ==  
++  encode-piece
  ~/  %encode-piece
  |=  [piece=@ nsym=@ud f=field generator=@]
  ^-  @
  =/  n  (met 3 piece)
  =/  nchunks  (add n nsym)
  =/  stopping-point
    ?:  =((mod nchunks 2) 0)
      +(n)
    n
  ::  throw an error if piece is too long
  ::
  ?:  (gth nchunks (dec size.f))
      !!
  =/  gen-lent  (met 3 generator)
  =+  :-  i=nchunks
      encoded=(lsh [3 (dec gen-lent)] (rev 3 n piece))
  |-  ^+  encoded
  ::  return result if we've generated the full set of symbols
  ::
  ?:  =(i stopping-point)
    %^  cat  3
      piece
    (rev 3 nsym (end [3 nsym] encoded))
  =/  coef  (cut 3 [i 1] encoded)
  ?:  =(coef 0)
    ::  don't do anything if on an empty byte
    ::
    $(i (dec i))
  %=    $
    i  (dec i)
  ::
      encoded
    =+  j=1
    |-  ^+  encoded
    ?:  =(j gen-lent)
      encoded
    %=    $
      j  +(j)
    ::
        encoded
      ::  multiply by bex to edit bytearray instead of sewing
      ::  ~33% time improvement
      %+  mix
        encoded
      %+  mul
        (bex (mul (sub i j) 8))
      %+  ~(gf-mul gf-math f)
        (cut 3 [j 1] generator)
      coef
    ==
  ==
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
      |=(chunk=@ (cut 3 [n 1] chunk))
    =.  collected
      (snoc collected slice)
    $(n +(n))
  ::  now go through reconstructed chunks and decode one at a time
  ::
  %+  turn
    linear-stream
  |=  chunk=(list @)
  (decode-piece chunk f nsym.encoded missing.encoded amount.encoded)
++  decode-piece
  |=  [chunk=(list @) f=field nsym=@ud missing=(list @ud) amount=@ud]
  ^-  [(list @) (list @)]
  =/  synd
    (~(calc-syndromes gf-math f) chunk nsym)
  ::  if max val in synd is 0, no erasures
  ::
  =/  repaired
    (~(correct-errata gf-math f) chunk synd missing)
  ::  check if max val in synd is NOT 0 and throw an error (couldn't correct)
  ::
  =/  pos  (sub amount nsym)
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
  =+  [i=0 exp=*@ log=*@ x=1]
  |-  ^+  [size exp log]
  ?:  =(i (dec size))
    [size (cat 3 exp exp) log]
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
::  $rip-with-padding: $rip, but pad the last item to fit bite size.
:: 
++  rip-with-padding
  ~/  %rip-with-padding
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
  :: ++  gf-sub
  ::   ~/  %gf-sub
  ::   |=  [x=@ y=@]
  ::   ^-  @
  ::   %+  mix  x  y
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
          (add (cut 3 [x 1] log.f) 255)
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
        (mul (cut 3 [x 1] log.f) power)
      255
    exp.f
  ::
  ++  gf-inverse
    ~/  %gf-inverse
    |=  [x=@]
    ^-  @
    %^  cut  3
      :_  1
      (sub 255 (cut 3 [x 1] log.f))
    exp.f
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
      (cat 3 1 (gf-pow 2 i))
    $(i +(i))
  ::
  ::  Reed-Solomon decoding utils
  ::  Currently just handling repairing *erasures*, 
  ::  but can supplement to find and repair *errors*
  ::
  ++  gf-poly-add
    ~/  %gf-poly-add
    |=  [p=(list @) q=(list @)]
    ^-  (list @)
    =/  [longer=(list @) shorter=(list @)]
      ?:  %+  gth  (lent p)  (lent q)
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
  ++  gf-poly-add-bytes
    |=  [p=@ q=@]
    ^-  @
    (mix p q)
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
    :+  i
      j
    (snap r (add i j) a)
  ::
  ++  gf-poly-mul-bytes
    |=  [p=@ q=@]
    ^-  @
    =/  el-p  (met 3 p)
    =/  el-q  (met 3 q)
    =+  [j=0 i=0 result=*@]
    |-  ^-  @
    ?:  =(j el-q)
      result
    =.  result
      |-  ^-  @
      ?:  =(i el-p)
        result
      =.  result
        %+  mix
          result
        %+  mul
          (bex (mul (add i j) 8))
        %+  gf-mul
          (cut 3 [i 1] p)
        (cut 3 [j 1] q)
      $(i +(i))
    $(j +(j))
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
  ++  gf-poly-eval-bytes
    |=  [p=@ x=@]
    ^-  @
    =+  [i=1 y=(end [3 1] p)]
    |-  ^-  @
    ?:  =(i (met 3 p))
      y
    %=    $
      i  +(i)
    ::
        y
      %+  mix
        (gf-mul y x)
      (cut 3 [i 1] p)
    ==
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
  ++  calc-syndromes-bytes
    |=  [data=@ nsym=@]
    ^-  @
    =+  [synd=*@ i=0]
    |-  ^+  synd
    ?:  =(i nsym)
      synd
    %=    $
      i  +(i)
    ::
        synd
      %^  sew  3
        [i 1 (gf-poly-eval-bytes data (gf-pow 2 i))]
      synd
    ==
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
        %+  gf-add
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
