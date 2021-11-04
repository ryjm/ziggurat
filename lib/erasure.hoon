/-  galois
/+  *bitcoin-utils
=,  galois
|%
++  encode
  |=  [data=@ frags=@ud allowed-missing=@ud]
  ^-  [(list @ud) (list @ud)]
  :: generate a galois field
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

  :: [exp log]
  :: now create fragments and do stuff
  =/  n  (add frags (mul allowed-missing 2))
  =/  encode-size  (mul (con (div size n) 0) n)
  =/  input-size  (div (mul encode-size frags) n)
  =/  nec  (sub encode-size input-size)
  =/  symbol-size  (div input-size frags)
  ?.  =((mul symbol-size frags) input-size)
    !! :: bad alignment of bytes in chunking
  :: go thru data and take pieces, put into list
  :: then use polynomial to encode
  [exp log]
++  field-math
  |_  f=field
  ++  mask
    (sub size.f 1)
  ++  get-exp
    |=  y=@ud
    %+  snag 
      y 
    exp.f
  ++  mul
    |=  [x=@ud y=@ud]
    ?:  ?|  =(x 0)  
            =(y 0) 
        ==
      0
    %+  snag
      %+  add
        %+  snag
          x
        log.f
        %+  snag
          y
        log.f
    exp.f
  ++  div
    |=  [x=@ud y=@ud]
    ?:  =(y 0)
      :: can't divide by 0
      !!
    ?:  =(x 0)
      0
    %+  snag
      %+  sub
        %+  add
          %+  snag
            x
          log.f
        255
        %+  snag
          y
        log.f
    exp.f
  --
--