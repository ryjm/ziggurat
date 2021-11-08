/-  galois
/+  *bitcoin-utils
=,  galois
|%
::
:: Galois math
::
++  gf-math
  |_  f=field
  ++  gf-add
    |=  [x=@ y=@]
    (mix x y)
  
  ++  gf-sub
    |=  [x=@ y=@]
    (mix x y)
  
  ++  gf-mul
    |=  [x=@ y=@]
    ?:  ?|  =(x 0)
            =(y 0)
        ==
      0
    %+  add
      (snag x log.f)
    (snag y log.f)
  
  ++  gf-div
    |=  [x=@ y=@]
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
    %+  snag
      %+  mod
        %+  mul
          (snag x log.f)
        power
      255
    exp.f
  
  ++  gf-inverse
    |=  [x=@]
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

  :: def gf_poly_scale(p,x):
  ::     r = [0] * len(p)
  ::     for i in range(0, len(p)):
  ::         r[i] = gf_mul(p[i], x)
  ::     return r
  ++  gf-poly-scale
    |=  [p=(list @) x=@]
    %+  turn
      p
    |=  i=@
    %+  gf-mul
      i
    x
  
  :: def gf_poly_add(p,q):
  ::     r = [0] * max(len(p),len(q))
  ::     for i in range(0,len(p)):
  ::         r[i+len(r)-len(p)] = p[i]
  ::     for i in range(0,len(q)):
  ::         r[i+len(r)-len(q)] ^= q[i]
  ::     return r
  ++  gf-poly-add
    |=  [p=(list @) q=(list @)]
    =/  [longer=(list @) shorter=(list @)]
      ?:  (gth (lent p) (lent q))
        [p q]
      [q p]
    =/  diff
      (sub (lent longer) (lent shorter))
    :: p is longer, XOR q starting at (lent p) - (lent q)
    %+  welp
      %+  scag
        diff
      longer
    %^    spin
        %+  slag
          diff
        longer
      shorter
    |=  [i=@ud r=(list @)]
    [(mix i -.r) +.r]

  :: def gf_poly_mul(p,q):
  ::     '''Multiply two polynomials, inside Galois Field'''
  ::     # Pre-allocate the result array
  ::     r = [0] * (len(p)+len(q)-1)
  ::     # Compute the polynomial multiplication (just like the outer product of two vectors,
  ::     # we multiply each coefficients of p with all coefficients of q)
  ::     for j in range(0, len(q)):
  ::         for i in range(0, len(p)):
  ::             r[i+j] ^= gf_mul(p[i], q[j]) # equivalent to: r[i + j] = gf_add(r[i+j], gf_mul(p[i], q[j]))
  ::                                                          # -- you can see it's your usual polynomial multiplication
  ::     return r
  ++  gf-poly-mul
    |=  [p=(list @) q=(list @)]
    ^-  (list @)
    =/  r
    %^    spin
        (gulf 0 (lent q))
      (reap (sub (add (lent p) (lent q)) 1) 0)
    |=  [j=@ r=(list @)]
      =/  out
      %^    spin
          (gulf 0 (lent p))
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
  
  :: def gf_poly_eval(poly, x):
  ::     '''Evaluates a polynomial in GF(2^p) given the value for x. This is based on Horner's scheme for maximum efficiency.'''
  ::     y = poly[0]
  ::     for i in range(1, len(poly)):
  ::         y = gf_mul(y, x) ^ poly[i]
  ::     return y
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

  :: TODO for decoding
  :: def gf_poly_div(dividend, divisor):
  ::     '''Fast polynomial division by using Extended Synthetic Division and optimized for GF(2^p) computations
  ::     (doesn't work with standard polynomials outside of this galois field, see the Wikipedia article for generic algorithm).'''
  ::     # CAUTION: this function expects polynomials to follow the opposite convention at decoding:
  ::     # the terms must go from the biggest to lowest degree (while most other functions here expect
  ::     # a list from lowest to biggest degree). eg: 1 + 2x + 5x^2 = [5, 2, 1], NOT [1, 2, 5]
  :: 
  ::     msg_out = list(dividend) # Copy the dividend
  ::     #normalizer = divisor[0] # precomputing for performance
  ::     for i in range(0, len(dividend) - (len(divisor)-1)):
  ::         #msg_out[i] /= normalizer # for general polynomial division (when polynomials are non-monic), the usual way of using
  ::                                   # synthetic division is to divide the divisor g(x) with its leading coefficient, but not needed here.
  ::         coef = msg_out[i] # precaching
  ::         if coef != 0: # log(0) is undefined, so we need to avoid that case explicitly (and it's also a good optimization).
  ::             for j in range(1, len(divisor)): # in synthetic division, we always skip the first coefficient of the divisior,
  ::                                               # because it's only used to normalize the dividend coefficient
  ::                 if divisor[j] != 0: # log(0) is undefined
  ::                     msg_out[i + j] ^= gf_mul(divisor[j], coef) # equivalent to the more mathematically correct
  ::                                                                # (but xoring directly is faster): msg_out[i + j] += -divisor[j] * coef
  :: 
  ::     # The resulting msg_out contains both the quotient and the remainder, the remainder being the size of the divisor
  ::     # (the remainder has necessarily the same degree as the divisor -- not length but degree == length-1 -- since it's
  ::     # what we couldn't divide from the dividend), so we compute the index where this separation is, and return the quotient and remainder.
  ::     separator = -(len(divisor)-1)
  ::     return msg_out[:separator], msg_out[separator:] # return quotient, remainder.
--
::
:: Reed-Solomon encoding
::

:: def rs_generator_poly(nsym):
::     '''Generate an irreducible generator polynomial (necessary to encode a message into Reed-Solomon)'''
::     g = [1]
::     for i in range(0, nsym):
::         g = gf_poly_mul(g, [1, gf_pow(2, i)])
::     return g
:: TODO make faster; this is really inefficient
++  rs-generator-poly
  |=  [f=field nsym=@]
  ^-  (list @)
  =/  g  `(list @)`~[1]
  =/  out
  %^    spin
      (gulf 0 nsym)
    g
  |=  [i=@ g=(list @)]
  :-  i 
  %+  ~(gf-poly-mul gf-math f)
    g
  %+  weld
    `(list @)`~[1]
  ~[(~(gf-pow gf-math f) 2 i)]
  q.out

:: def rs_encode_msg(msg_in, nsym):
::     if (len(msg_in) + nsym) > 255: raise ValueError("Message is too long (%i when max is 255)" % (len(msg_in)+nsym))
::     gen = rs_generator_poly(nsym)
::     # Init msg_out with the values inside msg_in and pad with len(gen)-1 bytes (which is the number of ecc symbols).
::     msg_out = [0] * (len(msg_in) + len(gen)-1)
::     # Initializing the Synthetic Division with the dividend (= input message polynomial)
::     msg_out[:len(msg_in)] = msg_in
:: 
::     # Synthetic division main loop
::     for i in range(len(msg_in)):
::         # Note that it's msg_out here, not msg_in. Thus, we reuse the updated value at each iteration
::         # (this is how Synthetic Division works: instead of storing in a temporary register the intermediate values,
::         # we directly commit them to the output).
::         coef = msg_out[i]
:: 
::         # log(0) is undefined, so we need to manually check for this case. There's no need to check
::         # the divisor here because we know it can't be 0 since we generated it.
::         if coef != 0:
::             # in synthetic division, we always skip the first coefficient of the divisior, because it's only used to normalize the dividend coefficient (which is here useless since the divisor, the generator polynomial, is always monic)
::             for j in range(1, len(gen)):
::                 msg_out[i+j] ^= gf_mul(gen[j], coef) # equivalent to msg_out[i+j] += gf_mul(gen[j], coef)
:: 
::     # At this point, the Extended Synthetic Divison is done, msg_out contains the quotient in msg_out[:len(msg_in)]
::     # and the remainder in msg_out[len(msg_in):]. Here for RS encoding, we don't need the quotient but only the remainder
::     # (which represents the RS code), so we can just overwrite the quotient with the input message, so that we get
::     # our complete codeword composed of the message + code.
::     msg_out[:len(msg_in)] = msg_in
:: 
::     return msg_out
++  rs-encode-msg
  |=  [f=field input=@ nsym=@]
  =/  gen  (rs-generator-poly f nsym)
  

::
:: Initialization
::

:: generate a galois field table of size 2^8
++  generate-field
  :: |=  [prim=@]
  ^-  [(list @ud) (list @ud)]
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

  [exp log]
--
