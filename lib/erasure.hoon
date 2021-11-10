/-  galois
/+  *bitcoin-utils
=,  galois
|%
:: Generate a galois field table of size 2^8
:: store this somewhere for speed?
++  generate-field
  :: |=  [prim=@]
  ^-  field
  =/  size  256
  =/  exp-and-log
  %^  spin  (gulf 0 254)
    [(reap size 0) 1]
  |=  [i=@ud [log=(list @ud) x=@ud]]
  ?:  =(0 i)
    [1 [log x]]
  =/  x  (lsh 0 x)
  =/  x
    ?.  =((dis x size) 0)
      (mix x (con size 0x1D))
    x
  [x [(snap log x i) x]]
  =/  exp
  (weld p.exp-and-log p.exp-and-log)
  =/  log
  -.q.exp-and-log

  [256 exp log]
::
:: Galois math
::
++  gf-math
  |_  f=field
  ++  gf-add
    |=  [x=@ y=@]
    ^-  @
    (mix x y)
  
  ++  gf-sub
    |=  [x=@ y=@]
    ^-  @
    (mix x y)
  
  ++  gf-mul
    |=  [x=@ y=@]
    ^-  @
    ?:  ?|  =(x 0)
            =(y 0)
        ==
      0
    %+  snag
      %+  add
        (snag x log.f)
      (snag y log.f)
    exp.f
  
  ++  gf-div
    |=  [x=@ y=@]
    ^-  @
    ?:  =(y 0)
      !! :: attempt to divide by 0
    ?:  =(x 0)
      0
    %+  snag
      %+  sub
        %+  add
          (snag x log.f)
        255
      (snag y log.f)
    exp.f
  
  ++  gf-pow
    |=  [x=@ power=@]
    ^-  @
    %+  snag
      %+  mod
        %+  mul
          (snag x log.f)
        power
      255
    exp.f
  
  ++  gf-inverse
    |=  [x=@]
    ^-  @
    %+  snag
      %+  sub
        255
      (snag x log.f)
    exp.f
  
  ::
  ::  Polynomial math
  ::
  ++  gf-poly-scale
    |=  [p=(list @) x=@]
    ^-  (list @)
    %+  turn
      p
    |=  i=@
    %+  gf-mul
      i
    x
  
  ++  gf-poly-add
    |=  [p=(list @) q=(list @)]
    ^-  (list @)
    =/  [longer=(list @) shorter=(list @)]
      ?:  (gth (lent p) (lent q))
        [p q]
      [q p]
    =/  diff
      (sub (lent longer) (lent shorter))
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

  ++  gf-poly-mul
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
        =/  r
        %^    snap
            r
          (add i j)
        %+  gf-add
          %+  snag
            (add i j)
          r
        %+  gf-mul
          (snag i p)
        (snag j q)
        [i [j r]]

  ++  gf-poly-eval
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
  :: Reed-Solomon encoding utils
  ::
  
  :: TODO make faster; this is really inefficient
  ++  rs-generator-poly
    |=  nsym=@
    ^-  (list @)
    =/  g  `(list @)`~[1]
    =<  q
    %^    spin
        (gulf 0 (sub nsym 1))
      g
    |=  [i=@ g=(list @)]
    :-  i
    %+  gf-poly-mul
      g
    %+  weld
      `(list @)`~[1]
    ~[(gf-pow 2 i)]

  ::
  :: Reed-Solomon decoding utils
  :: Currently just handling repairing *erasures*, 
  :: but can supplement to find and repair *errors*
  ::
  
  ++  calc-syndromes
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

  ++  find-errata-locator
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

  ++  find-error-evaluator
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

  ++  correct-errata
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
    :: End Forney algorithm

    :: apply correction field to input for repaired data
    %+  gf-poly-add
      data
    e
--

::  input is a list of atoms to get encoded
::  for a tape this is just chars casted to @
::  should just generate the field in here for usability?
::  returns a cell of number of code symbols and the encoded data
:: TODO: use 'transparent chunking' to break large inputs
:: into streams of <256 bytes
++  encode-data
  |=  [input=@ n=@]
  ^-  [@ (list @)]
  =/  f  generate-field

  :: We should take an input, and break it into smaller pieces
  :: which each contain 

  :: get a list of bytes to encode individually
  =/  input-bytes  (rip 3 input)
  ?:  (gth (lent input-bytes) n)
    !!  :: not enough symbols for size of input
  =/  nsym  (sub n (lent input-bytes))
  :: ~&  >  "Input: {<input>}"
  ?:  (gth (add (lent input-bytes) nsym) 255)
    !! :: message too long
       :: (TODO: break long messages into manageable chunks)
  =/  gen
  (~(rs-generator-poly gf-math f) nsym)
  =/  msg-out
  %+  weld
    input-bytes
  (reap (sub (lent gen) 1) 0)
  =/  res
    %^    spin
        (gulf 0 (sub (lent input-bytes) 1))
      msg-out
    |=  [i=@ out=(list @)]
    =/  coef
    (snag i out)
    ?:  =(coef 0)
      :: do nothing
      [i out]
    =<  q
    %^    spin
        (gulf 1 (sub (lent gen) 1))
      [i out]
    |=  [j=@ [i=@ out=(list @)]]
    =/  new
    %+  mix
      (snag (add i j) out)
    %+  ~(gf-mul gf-math f)
      (snag j gen)
    coef
    [j [i (snap out (add i j) new)]]
  :-  nsym
  %+  weld
    input-bytes
  %+  slag
    (lent input-bytes)
  q.res

:: takes in rs-encoded data with missing elements
:: number of ECC code symbols as second argument
:: list of indexes of missing elements as third argument
++  correct-data
  |=  [data=(list @) nsym=@ missing=(list @)]
  :: gives back a cell of the decoded data and the ECC code symbols
  ^-  [(list @) (list @)]
  ?:  (gth (lent data) 255)
    !! :: more chunks than galois field 256 can handle
  ?:  (gth (lent missing) nsym)
    !! :: too many missing chunks to repair
  =/  f  generate-field
  =/  repaired  data
  =/  synd  (~(calc-syndromes gf-math f) data nsym)
  ::  if max val in synd is 0, no erasures, why would we need to correct
  =/  repaired  (~(correct-errata gf-math f) data synd missing)
  ::  check if max val in synd is NOT 0 and throw an error (couldn't correct)
  =/  pos  (sub (lent data) nsym)
  :-  (scag pos repaired)
  (slag pos repaired)
--
