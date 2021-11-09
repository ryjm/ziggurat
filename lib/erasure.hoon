/-  galois
/+  *bitcoin-utils
=,  galois
|%
:: Generate a galois field table of size 2^8
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
  
  :: TODO russian peasant multiplication algorithm from erasure.py
  :: def gf_mult_noLUT(x, y, prim, field_charac_full=256, carryless=True):
  ::     '''Galois Field integer multiplication using Russian Peasant Multiplication algorithm (faster than the standard multiplication + modular reduction).
  ::     If prim is 0 and carryless=False, then the function produces the result for a standard integers multiplication (no carry-less arithmetics nor modular reduction).'''
  ::     r = 0
  ::     while y: # while y is above 0
  ::         if y & 1: r = r ^ x if carryless else r + x # y is odd, then add the corresponding x to r (the sum of all x's corresponding to odd y's will give the final product). Note that since we're in GF(2), the addition is in fact an XOR (very important because in GF(2) the multiplication and additions are carry-less, thus it changes the result!).
  ::         y = y >> 1 # equivalent to y // 2
  ::         x = x << 1 # equivalent to x*2
  ::         if prim > 0 and x & field_charac_full: x = x ^ prim # GF modulo: if x >= 256 then apply modular reduction using the primitive polynomial (we just subtract, but since the primitive number can be above 256 then we directly XOR).
  :: 
  ::     return r
  :: ++  gf-mul-faster
  ::   |=  [x=@ud y=@ud prim=@ ]
  
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
    =/  r
    %^    spin
        (gulf 0 (sub (lent q) 1))
      (reap (sub (add (lent p) (lent q)) 1) 0)
    |=  [j=@ r=(list @)]
      =/  out
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
      q.out
    q.r

  ++  gf-poly-eval
    |=  [p=(list @) x=@]
    ^-  @
    =/  y  -.p
    =/  res
    %^    spin
        `(list @)`+.p
      y
    |=  [i=@ y=@]
    [i (mix (gf-mul y x) i)]
    q.res

  ::
  :: Reed-Solomon encoding
  ::
  
  :: TODO make faster; this is really inefficient
  ++  rs-generator-poly
    |=  nsym=@
    ^-  (list @)
    =/  g  `(list @)`~[1]
    =/  out
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
    q.out


  ::
  :: Reed-Solomon decoding
  :: Currently just handling repairing *erasures*, 
  :: but can supplement to find and repair *errors*
  ::
  
  :: def rs_calc_syndromes(msg, nsym):
  ::     '''Given the received codeword msg and the number of error correcting symbols (nsym), computes the syndromes polynomial.
  ::     Mathematically, it's essentially equivalent to a Fourrier Transform (Chien search being the inverse).
  ::     '''
  ::     # Note the "[0] +" : we add a 0 coefficient for the lowest degree (the constant). This effectively shifts the syndrome, and will shift every computations depending on the syndromes (such as the errors locator polynomial, errors evaluator polynomial, etc. but not the errors positions).
  ::     # This is not necessary, you can adapt subsequent computations to start from 0 instead of skipping the first iteration (ie, the often seen range(1, n-k+1)),
  ::     synd = [0] * nsym
  ::     for i in range(0, nsym):
  ::         synd[i] = gf_poly_eval(msg, gf_pow(2,i))
  ::     return [0] + synd # pad with one 0 for mathematical precision (else we can end up with weird calculations sometimes)
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
  
  
  :: def rs_find_errata_locator(e_pos):
  ::     '''Compute the erasures/errors/errata locator polynomial from the erasures/errors/errata positions
  ::        (the positions must be relative to the x coefficient, eg: "hello worldxxxxxxxxx" is tampered to "h_ll_ worldxxxxxxxxx"
  ::        with xxxxxxxxx being the ecc of length n-k=9, here the string positions are [1, 4], but the coefficients are reversed
  ::        since the ecc characters are placed as the first coefficients of the polynomial, thus the coefficients of the
  ::        erased characters are n-1 - [1, 4] = [18, 15] = erasures_loc to be specified as an argument.'''
  :: 
  ::     e_loc = [1] # just to init because we will multiply, so it must be 1 so that the multiplication starts correctly without nulling any term
  ::     # erasures_loc = product(1 - x*alpha**i) for i in erasures_pos and where alpha is the alpha chosen to evaluate polynomials.
  ::     for i in e_pos:
  ::         e_loc = gf_poly_mul( e_loc, gf_poly_add([1], [gf_pow(2, i), 0]) )
  ::     return e_loc
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

  
  :: def rs_find_error_evaluator(synd, err_loc, nsym):
  ::     remainder = gf_poly_mul(synd, err_loc) # first multiply the syndromes with the errata locator polynomial
  ::     remainder = remainder[len(remainder)-(nsym+1):] # then slice the list to truncate it (which represents the polynomial), which
  ::     return remainder
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
    :: TODO be very sure this shortcut works
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


++  encode-data
  ::  input is a list of atoms to get encoded
  ::  for a tape this is just chars casted to @
  ::  should just generate the field in here for usability?
  |=  [f=field input=(list @) nsym=@]
  ^-  (list @)
  ~&  >  "Message: {<input>}"
  ?:  (gth (add (lent input) nsym) 255)
    !! :: message too long 
       :: (TODO: break long messages into manageable chunks)
  =/  gen
  (~(rs-generator-poly gf-math f) nsym)
  =/  msg-out
  %+  weld
    input
  (reap (sub (lent gen) 1) 0)
  =/  r
    %^    spin
        (gulf 0 (sub (lent input) 1))
      msg-out
    |=  [i=@ out=(list @)]
    =/  coef
    (snag i out)
    ?:  =(coef 0)
      :: do nothing
      [i out]
    =/  res
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
    q.res
  %+  weld
    input
  %+  slag
    (lent input)
  q.r

:: def rs_correct_msg(msg_in, nsym, erase_pos=None):
::     if len(msg_in) > 255: # can't decode, message is too big
::         raise ValueError("Message is too long (%i when max is 255)" % len(msg_in))
::     msg_out = list(msg_in)     # copy of message
::     if len(erase_pos) > nsym: raise ReedSolomonError("Too many erasures to correct")
::     synd = rs_calc_syndromes(msg_out, nsym)
::     msg_out = rs_correct_errata(msg_out, synd, erase_pos) # note that we here use the original syndrome, not the forney syndrome                                                                                                                         # (because we will correct both errors and erasures, so we need the full syndrome)
::     # check if the final message is fully repaired
::     synd = rs_calc_syndromes(msg_out, nsym)
::     if max(synd) > 0:
::         raise ReedSolomonError("Could not correct message")     # message could not be repaired
::     # return the successfully decoded message
::     return msg_out[:-nsym], msg_out[-nsym:] # also return the corrected ecc block so that the user can check()
++  correct-data
  :: takes in rs-encoded data with missing elements
  :: number of ECC code symbols as second argument
  :: list of indexes of missing elements as third argument
  |=  [f=field data=(list @) nsym=@ missing=(list @)]
  :: gives back a cell of the decoded data and the ECC code symbols
  ^-  [(list @) (list @)]
  ?:  (gth (lent data) 255)
    !! :: more chunks than galois field 256 can handle
  ?:  (gth (lent missing) nsym)
    !! :: too many missing chunks to repair
  =/  repaired  data
  =/  synd  (~(calc-syndromes gf-math f) data nsym)
  ::  if max val in synd is 0, no erasures, why would we need to correct
  =/  repaired  (~(correct-errata gf-math f) data synd missing)
  ::  check if max val in synd is NOT 0 and throw an error (couldn't correct)
  =/  n  (sub (lent data) nsym)
  :-  (scag n repaired)
  (slag n repaired)
--
