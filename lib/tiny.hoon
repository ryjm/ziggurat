!.
=>  %u50
~%  %u.50  ~  ~
|%
::
::  tiny types
::
+$  noun  *
+$  axis  @
+$  atom  @
+$  aura  @ta
+$  ship  @p
+$  term  @tas
+$  char  @t
+$  cord  @t
+$  tape  (list @tD)
+$  knot  @ta
+$  life  @ud
+$  rift  @ud
+$  pass  @
+$  bloq  @
+$  step  _`@u`1
+$  bite  $@(bloq [=bloq =step])
+$  octs  [p=@ud q=@]
+$  mold  $~(* $-(* *))
++  unit  |$  [item]  $@(~ [~ u=item])
++  each
  |$  [this that]
  $%  [%| p=that]
      [%& p=this]
  ==
++  list  |$  [item]  $@(~ [i=item t=(list item)])
++  lest  |$  [item]  [i=item t=(list item)]
++  tree  |$  [node]  $@(~ [n=node l=(tree node) r=(tree node)])
++  pair  |$  [head tail]  [p=head q=tail]
++  map
  |$  [key value]
  $|  (tree (pair key value))
  |=(a=(tree (pair)) ?:(=(~ a) & ~(apt by a)))
::
++  set
  |$  [item]
  $|  (tree item)
  |=(a=(tree) ?:(=(~ a) & ~(apt in a)))
::
++  jug   |$  [key value]  (map key (set value))
::
::  Bits
::
++  dec                                                 ::  decrement
  ~/  %dec
  |=  a=@
  ~_  leaf+"decrement-underflow"
  ?<  =(0 a)
  =+  b=0
  |-  ^-  @
  ?:  =(a +(b))  b
  $(b +(b))
::
++  add                                                 ::  plus
  ~/  %add
  |=  [a=@ b=@]
  ^-  @
  ?:  =(0 a)  b
  $(a (dec a), b +(b))
::
++  sub                                                 ::  subtract
  ~/  %sub
  |=  [a=@ b=@]
  ~_  leaf+"subtract-underflow"
  ::  difference
  ^-  @
  ?:  =(0 b)  a
  $(a (dec a), b (dec b))
::
++  mul                                                 ::  multiply
  ~/  %mul
  |:  [a=`@`1 b=`@`1]
  ^-  @
  =+  c=0
  |-
  ?:  =(0 a)  c
  $(a (dec a), c (add b c))
::
++  div                                                 ::  divide
  ~/  %div
  |:  [a=`@`1 b=`@`1]
  ^-  @
  ~_  leaf+"divide-by-zero"
  ?<  =(0 b)
  =+  c=0
  |-
  ?:  (lth a b)  c
  $(a (sub a b), c +(c))
::
++  dvr                                                 ::  divide w/remainder
  ~/  %dvr
  |:  [a=`@`1 b=`@`1]
  ^-  [p=@ q=@]
  [(div a b) (mod a b)]
::
++  mod                                                 ::  modulus
  ~/  %mod
  |:  [a=`@`1 b=`@`1]
  ^-  @
  ?<  =(0 b)
  (sub a (mul b (div a b)))
::
++  bex                                                 ::  binary exponent
  ~/  %bex
  |=  a=bloq
  ^-  @
  ?:  =(0 a)  1
  (mul 2 $(a (dec a)))
::
++  lsh                                                 ::  left-shift
  ~/  %lsh
  |=  [a=bite b=@]
  =/  [=bloq =step]  ?^(a a [a *step])
  (mul b (bex (mul (bex bloq) step)))
::
++  rsh                                                 ::  right-shift
  ~/  %rsh
  |=  [a=bite b=@]
  =/  [=bloq =step]  ?^(a a [a *step])
  (div b (bex (mul (bex bloq) step)))
::
++  con                                                 ::  binary or
  ~/  %con
  |=  [a=@ b=@]
  =+  [c=0 d=0]
  |-  ^-  @
  ?:  ?&(=(0 a) =(0 b))  d
  %=  $
    a   (rsh 0 a)
    b   (rsh 0 b)
    c   +(c)
    d   %+  add  d
          %+  lsh  [0 c]
          ?&  =(0 (end 0 a))
              =(0 (end 0 b))
          ==
  ==
::
++  dis                                                 ::  binary and
  ~/  %dis
  |=  [a=@ b=@]
  =|  [c=@ d=@]
  |-  ^-  @
  ?:  ?|(=(0 a) =(0 b))  d
  %=  $
    a   (rsh 0 a)
    b   (rsh 0 b)
    c   +(c)
    d   %+  add  d
          %+  lsh  [0 c]
          ?|  =(0 (end 0 a))
              =(0 (end 0 b))
          ==
  ==
::
++  mix                                                 ::  binary xor
  ~/  %mix
  |=  [a=@ b=@]
  ^-  @
  =+  [c=0 d=0]
  |-
  ?:  ?&(=(0 a) =(0 b))  d
  %=  $
    a   (rsh 0 a)
    b   (rsh 0 b)
    c   +(c)
    d   (add d (lsh [0 c] =((end 0 a) (end 0 b))))
  ==
::
++  lth                                                 ::  less
  ~/  %lth
  |=  [a=@ b=@]
  ^-  ?
  ?&  !=(a b)
      |-
      ?|  =(0 a)
          ?&  !=(0 b)
              $(a (dec a), b (dec b))
  ==  ==  ==
::
++  lte                                                 ::  less or equal
  ~/  %lte
  |=  [a=@ b=@]
  |(=(a b) (lth a b))
::
++  gte                                                 ::  greater or equal
  ~/  %gte
  |=  [a=@ b=@]
  ^-  ?
  !(lth a b)
::
++  gth                                                 ::  greater
  ~/  %gth
  |=  [a=@ b=@]
  ^-  ?
  !(lte a b)
::
++  swp                                                 ::  naive rev bloq order
  ~/  %swp
  |=  [a=bloq b=@]
  (rep a (flop (rip a b)))
::
++  met                                                 ::  measure
  ~/  %met
  |=  [a=bloq b=@]
  ^-  @
  =+  c=0
  |-
  ?:  =(0 b)  c
  $(b (rsh a b), c +(c))
::
++  end                                                 ::  tail
  ~/  %end
  |=  [a=bite b=@]
  =/  [=bloq =step]  ?^(a a [a *step])
  (mod b (bex (mul (bex bloq) step)))
::
++  cat                                                 ::  concatenate
  ~/  %cat
  |=  [a=bloq b=@ c=@]
  (add (lsh [a (met a b)] c) b)
::
++  cut                                                 ::  slice
  ~/  %cut
  |=  [a=bloq [b=step c=step] d=@]
  (end [a c] (rsh [a b] d))
::
++  can                                                 ::  assemble
  ~/  %can
  |=  [a=bloq b=(list [p=step q=@])]
  ^-  @
  ?~  b  0
  (add (end [a p.i.b] q.i.b) (lsh [a p.i.b] $(b t.b)))
::
++  cad                                                 ::  assemble specific
  ~/  %cad
  |=  [a=bloq b=(list [p=step q=@])]
  ^-  [=step @]
  :_  (can a b)
  |-
  ?~  b
    0
  (add p.i.b $(b t.b))
::
++  rep                                                 ::  assemble fixed
  ~/  %rep
  |=  [a=bite b=(list @)]
  =/  [=bloq =step]  ?^(a a [a *step])
  =|  i=@ud
  |-  ^-  @
  ?~  b   0
  %+  add  $(i +(i), b t.b)
  (lsh [bloq (mul step i)] (end [bloq step] i.b))
::
++  rip                                                 ::  disassemble
  ~/  %rip
  |=  [a=bite b=@]
  ^-  (list @)
  ?:  =(0 b)  ~
  [(end a b) $(b (rsh a b))]
::
::
::  Lists
::
++  lent                                                ::  length
  ~/  %lent
  |=  a=(list)
  ^-  @
  =+  b=0
  |-
  ?~  a  b
  $(a t.a, b +(b))
::
++  slag                                                ::  suffix
  ~/  %slag
  |*  [a=@ b=(list)]
  |-  ^+  b
  ?:  =(0 a)  b
  ?~  b  ~
  $(b t.b, a (dec a))
::
++  snag                                                ::  index
  ~/  %snag
  |*  [a=@ b=(list)]
  |-  ^+  ?>(?=(^ b) i.b)
  ?~  b
    ~_  leaf+"snag-fail"
    !!
  ?:  =(0 a)  i.b
  $(b t.b, a (dec a))
::
++  homo                                                ::  homogenize
  |*  a=(list)
  ^+  =<  $
    |@  ++  $  ?:(*? ~ [i=(snag 0 a) t=$])
    --
  a
::
++  flop                                                ::  reverse
  ~/  %flop
  |*  a=(list)
  =>  .(a (homo a))
  ^+  a
  =+  b=`_a`~
  |-
  ?~  a  b
  $(a t.a, b [i.a b])
::
++  welp                                                ::  concatenate
  ~/  %welp
  =|  [* *]
  |@
  ++  $
    ?~  +<-
      +<-(. +<+)
    +<-(+ $(+<- +<->))
  --
::
++  reap                                                ::  replicate
  ~/  %reap
  |*  [a=@ b=*]
  |-  ^-  (list _b)
  ?~  a  ~
  [b $(a (dec a))]
::
::  Modular arithmetic
::
++  fe                                                  ::  modulo bloq
  |_  a=bloq
  ++  rol  |=  [b=bloq c=@ d=@]  ^-  @                  ::  roll left
           =+  e=(sit d)
           =+  f=(bex (sub a b))
           =+  g=(mod c f)
           (sit (con (lsh [b g] e) (rsh [b (sub f g)] e)))
  ++  sum  |=([b=@ c=@] (sit (add b c)))                ::  wrapping add
  ++  sit  |=(b=@ (end a b))                            ::  enforce modulo
  --
::
::  Hashes
::
++  muk                                                 ::  standard murmur3
  ~%  %muk  ..muk  ~
  =+  ~(. fe 5)
  |=  [syd=@ len=@ key=@]
  =.  syd      (end 5 syd)
  =/  pad      (sub len (met 3 key))
  =/  data     (welp (rip 3 key) (reap pad 0))
  =/  nblocks  (div len 4)  ::  intentionally off-by-one
  =/  h1  syd
  =+  [c1=0xcc9e.2d51 c2=0x1b87.3593]
  =/  blocks  (rip 5 key)
  =/  i  nblocks
  =.  h1  =/  hi  h1  |-
    ?:  =(0 i)  hi
    =/  k1  (snag (sub nblocks i) blocks)  ::  negative array index
    =.  k1  (sit (mul k1 c1))
    =.  k1  (rol 0 15 k1)
    =.  k1  (sit (mul k1 c2))
    =.  hi  (mix hi k1)
    =.  hi  (rol 0 13 hi)
    =.  hi  (sum (sit (mul hi 5)) 0xe654.6b64)
    $(i (dec i))
  =/  tail  (slag (mul 4 nblocks) data)
  =/  k1    0
  =/  tlen  (dis len 3)
  =.  h1
    ?+  tlen  h1  ::  fallthrough switch
      %3  =.  k1  (mix k1 (lsh [0 16] (snag 2 tail)))
          =.  k1  (mix k1 (lsh [0 8] (snag 1 tail)))
          =.  k1  (mix k1 (snag 0 tail))
          =.  k1  (sit (mul k1 c1))
          =.  k1  (rol 0 15 k1)
          =.  k1  (sit (mul k1 c2))
          (mix h1 k1)
      %2  =.  k1  (mix k1 (lsh [0 8] (snag 1 tail)))
          =.  k1  (mix k1 (snag 0 tail))
          =.  k1  (sit (mul k1 c1))
          =.  k1  (rol 0 15 k1)
          =.  k1  (sit (mul k1 c2))
          (mix h1 k1)
      %1  =.  k1  (mix k1 (snag 0 tail))
          =.  k1  (sit (mul k1 c1))
          =.  k1  (rol 0 15 k1)
          =.  k1  (sit (mul k1 c2))
          (mix h1 k1)
    ==
  =.  h1  (mix h1 len)
  |^  (fmix32 h1)
  ++  fmix32
    |=  h=@
    =.  h  (mix h (rsh [0 16] h))
    =.  h  (sit (mul h 0x85eb.ca6b))
    =.  h  (mix h (rsh [0 13] h))
    =.  h  (sit (mul h 0xc2b2.ae35))
    =.  h  (mix h (rsh [0 16] h))
    h
  --
::
++  mug                                                 ::  mug with murmur3
  ~/  %mug
  |=  a=*
  |^  ?@  a  (mum 0xcafe.babe 0x7fff a)
      =/  b  (cat 5 $(a -.a) $(a +.a))
      (mum 0xdead.beef 0xfffe b)
  ::
  ++  mum
    |=  [syd=@uxF fal=@F key=@]
    =/  wyd  (met 3 key)
    =|  i=@ud
    |-  ^-  @F
    ?:  =(8 i)  fal
    =/  haz=@F  (muk syd wyd key)
    =/  ham=@F  (mix (rsh [0 31] haz) (end [0 31] haz))
    ?.(=(0 ham) ham $(i +(i), syd +(syd)))
  --
::
++  gor                                                 ::  mug order
  ~/  %gor
  |=  [a=* b=*]
  ^-  ?
  =+  [c=(mug a) d=(mug b)]
  ?:  =(c d)
    (dor a b)
  (lth c d)
::
++  mor                                                 ::  more mug order
  ~/  %mor
  |=  [a=* b=*]
  ^-  ?
  =+  [c=(mug (mug a)) d=(mug (mug b))]
  ?:  =(c d)
    (dor a b)
  (lth c d)
::
++  dor                                                 ::  tree order
  ~/  %dor
  |=  [a=* b=*]
  ^-  ?
  ?:  =(a b)  &
  ?.  ?=(@ a)
    ?:  ?=(@ b)  |
    ?:  =(-.a -.b)
      $(a +.a, b +.b)
    $(a -.a, b -.b)
  ?.  ?=(@ b)  &
  (lth a b)
::
++  por                                                 ::  parent order
  ~/  %por
  |=  [a=@p b=@p]
  ^-  ?
  ?:  =(a b)  &
  =|  i=@
  |-
  ?:  =(i 2)
    ::  second two bytes
    (lte a b)
  ::  first two bytes
  =+  [c=(end 3 a) d=(end 3 b)]
  ?:  =(c d)
    $(a (rsh 3 a), b (rsh 3 b), i +(i))
  (lth c d)
::
::  Maps
::
++  by
  ~/  %by
  =|  a=(tree (pair))  ::  (map)
  =*  node  ?>(?=(^ a) n.a)
  |@
  ++  get
    ~/  %get
    |*  b=*
    =>  .(b `_?>(?=(^ a) p.n.a)`b)
    |-  ^-  (unit _?>(?=(^ a) q.n.a))
    ?~  a
      ~
    ?:  =(b p.n.a)
      `q.n.a
    ?:  (gor b p.n.a)
      $(a l.a)
    $(a r.a)
  ::
  ++  put
    ~/  %put
    |*  [b=* c=*]
    |-  ^+  a
    ?~  a
      [[b c] ~ ~]
    ?:  =(b p.n.a)
      ?:  =(c q.n.a)
        a
      a(n [b c])
    ?:  (gor b p.n.a)
      =+  d=$(a l.a)
      ?>  ?=(^ d)
      ?:  (mor p.n.a p.n.d)
        a(l d)
      d(r a(l r.d))
    =+  d=$(a r.a)
    ?>  ?=(^ d)
    ?:  (mor p.n.a p.n.d)
      a(r d)
    d(l a(r l.d))
  ::
  ++  del
    ~/  %del
    |*  b=*
    |-  ^+  a
    ?~  a
      ~
    ?.  =(b p.n.a)
      ?:  (gor b p.n.a)
        a(l $(a l.a))
      a(r $(a r.a))
    |-  ^-  [$?(~ _a)]
    ?~  l.a  r.a
    ?~  r.a  l.a
    ?:  (mor p.n.l.a p.n.r.a)
      l.a(r $(l.a r.l.a))
    r.a(l $(r.a l.r.a))
  ::
  ++  apt
    =<  $
    ~/  %apt
    =|  [l=(unit) r=(unit)]
    |.  ^-  ?
    ?~  a   &
    ?&  ?~(l & &((gor p.n.a u.l) !=(p.n.a u.l)))
        ?~(r & &((gor u.r p.n.a) !=(u.r p.n.a)))
        ?~  l.a   &
        &((mor p.n.a p.n.l.a) !=(p.n.a p.n.l.a) $(a l.a, l `p.n.a))
        ?~  r.a   &
        &((mor p.n.a p.n.r.a) !=(p.n.a p.n.r.a) $(a r.a, r `p.n.a))
    ==
  ::
  ++  has                                               ::  key existence check
    ~/  %has
    |*  b=*
    !=(~ (get b))
  ::
  ++  jab
    ~/  %jab
    |*  [key=_?>(?=(^ a) p.n.a) fun=$-(_?>(?=(^ a) q.n.a) _?>(?=(^ a) q.n.a))]
    ^+  a
    ::
    ?~  a  !!
    ::
    ?:  =(key p.n.a)
      a(q.n (fun q.n.a))
    ::
    ?:  (gor key p.n.a)
      a(l $(a l.a))
    ::
    a(r $(a r.a))
  ::
  ++  gas                                               ::  concatenate
    ~/  %gas
    |*  b=(list [p=* q=*])
    =>  .(b `(list _?>(?=(^ a) n.a))`b)
    |-  ^+  a
    ?~  b
      a
    $(b t.b, a (put p.i.b q.i.b))
  ::
  ++  val                                               ::  list of vals
    =+  b=`(list _?>(?=(^ a) q.n.a))`~
    |-  ^+  b
    ?~  a   b
    $(a r.a, b [q.n.a $(a l.a)])
  --
::
++  on                                                  ::  ordered map
  ~/  %on
  |*  [key=mold val=mold]
  =>  |%
      +$  item  [key=key val=val]
      --
  ::
  ~%  %comp  +>+  ~
  |=  compare=$-([key key] ?)
  ~%  %core    +  ~
  |%
  ::
  ++  apt
    ~/  %apt
    |=  a=(tree item)
    =|  [l=(unit key) r=(unit key)]
    |-  ^-  ?
    ?~  a  %.y
    ?&  ?~(l %.y (compare key.n.a u.l))
        ?~(r %.y (compare u.r key.n.a))
        ?~(l.a %.y &((mor key.n.a key.n.l.a) $(a l.a, l `key.n.a)))
        ?~(r.a %.y &((mor key.n.a key.n.r.a) $(a r.a, r `key.n.a)))
    ==
  ::
  ++  get
    ~/  %get
    |=  [a=(tree item) b=key]
    ^-  (unit val)
    ?~  a  ~
    ?:  =(b key.n.a)
      `val.n.a
    ?:  (compare b key.n.a)
      $(a l.a)
    $(a r.a)
  ::
  ++  has
    ~/  %has
    |=  [a=(tree item) b=key]
    ^-  ?
    !=(~ (get a b))
  ::
  ++  put
    ~/  %put
    |=  [a=(tree item) =key =val]
    ^-  (tree item)
    ?~  a  [n=[key val] l=~ r=~]
    ?:  =(key.n.a key)  a(val.n val)
    ?:  (compare key key.n.a)
      =/  l  $(a l.a)
      ?>  ?=(^ l)
      ?:  (mor key.n.a key.n.l)
        a(l l)
      l(r a(l r.l))
    =/  r  $(a r.a)
    ?>  ?=(^ r)
    ?:  (mor key.n.a key.n.r)
      a(r r)
    r(l a(r l.r))
  --
::
::  Sets
::
++  in
  ~/  %in
  =|  a=(tree)  :: (set)
  |@
  ++  put
    ~/  %put
    |*  b=*
    |-  ^+  a
    ?~  a
      [b ~ ~]
    ?:  =(b n.a)
      a
    ?:  (gor b n.a)
      =+  c=$(a l.a)
      ?>  ?=(^ c)
      ?:  (mor n.a n.c)
        a(l c)
      c(r a(l r.c))
    =+  c=$(a r.a)
    ?>  ?=(^ c)
    ?:  (mor n.a n.c)
      a(r c)
    c(l a(r l.c))
  ::
  ++  del
    ~/  %del
    |*  b=*
    |-  ^+  a
    ?~  a
      ~
    ?.  =(b n.a)
      ?:  (gor b n.a)
        a(l $(a l.a))
      a(r $(a r.a))
    |-  ^-  [$?(~ _a)]
    ?~  l.a  r.a
    ?~  r.a  l.a
    ?:  (mor n.l.a n.r.a)
      l.a(r $(l.a r.l.a))
    r.a(l $(r.a l.r.a))
  ::
  ++  tap                                               ::  convert to list
    =<  $
    ~/  %tap
    =+  b=`(list _?>(?=(^ a) n.a))`~
    |.  ^+  b
    ?~  a
      b
    $(a r.a, b [n.a $(a l.a)])
  ::
  ++  apt
    =<  $
    ~/  %apt
    =|  [l=(unit) r=(unit)]
    |.  ^-  ?
    ?~  a   &
    ?&  ?~(l & (gor n.a u.l))
        ?~(r & (gor u.r n.a))
        ?~(l.a & ?&((mor n.a n.l.a) $(a l.a, l `n.a)))
        ?~(r.a & ?&((mor n.a n.r.a) $(a r.a, r `n.a)))
    ==
  ::
  ++  has
    ~/  %has
    |*  b=*
    ^-  ?
    ::  wrap extracted item type in a unit because bunting fails
    ::
    ::    If we used the real item type of _?^(a n.a !!) as the sample type,
    ::    then hoon would bunt it to create the default sample for the gate.
    ::
    ::    However, bunting that expression fails if :a is ~. If we wrap it
    ::    in a unit, the bunted unit doesn't include the bunted item type.
    ::
    ::    This way we can ensure type safety of :b without needing to perform
    ::    this failing bunt. It's a hack.
    ::
    %.  [~ b]
    |=  b=(unit _?>(?=(^ a) n.a))
    =>  .(b ?>(?=(^ b) u.b))
    |-  ^-  ?
    ?~  a
      |
    ?:  =(b n.a)
      &
    ?:  (gor b n.a)
      $(a l.a)
    $(a r.a)
  ::
  ++  wyt                                               ::  size of set
    =<  $
    ~%  %wyt  +  ~
    |.  ^-  @
    ?~(a 0 +((add $(a l.a) $(a r.a))))
  --
::
::  Jugs
::
++  ju
  =|  a=(tree (pair * (tree)))  ::  (jug)
  |@
  ++  get
    |*  b=*
    =+  c=(~(get by a) b)
    ?~(c ~ u.c)
  ::
  ++  del
    |*  [b=* c=*]
    ^+  a
    =+  d=(get b)
    =+  e=(~(del in d) c)
    ?~  e
      (~(del by a) b)
    (~(put by a) b e)
  ::
  ++  put
    |*  [b=* c=*]
    ^+  a
    =+  d=(get b)
    (~(put by a) b (~(put in d) c))
  --
::  types from hoon.hoon
::  brought in to contract stdlib for vase access
::
+$  vase  [p=type q=*]
+$  type  $~  %noun                                     ::
          $@  $?  %noun                                 ::  any nouns
                  %void                                 ::  no noun
              ==                                        ::
          $%  [%atom p=term q=(unit @)]                 ::  atom / constant
              [%cell p=type q=type]                     ::  ordered pair
              [%core p=type q=coil]                     ::  object
              [%face p=$@(term tune) q=type]            ::  namespace
              [%fork p=(set type)]                      ::  union
              [%hint p=(pair type note) q=type]         ::  annotation
              [%hold p=type q=hoon]                     ::  lazy evaluation
          ==
+$  note                                                ::  type annotation
          $%  [%help p=help]                            ::  documentation
              [%know p=stud]                            ::  global standard
              [%made p=term q=(unit (list wing))]       ::  structure
          ==
+$  coil  $:  p=garb                                    ::  name, wet=dry, vary
              q=type                                    ::  context
              r=(pair seminoun (map term tome))         ::  chapters
          ==
+$  tune                                                ::  complex
          $~  [~ ~]                                     ::
          $:  p=(map term (unit hoon))                  ::  aliases
              q=(list hoon)                             ::  bridges
          ==
+$  hoon                                                ::
  $~  [%zpzp ~]
  $^  [p=hoon q=hoon]                                   ::
  $%                                                    ::
    [%$ p=axis]                                         ::  simple leg
  ::                                                    ::
    [%base p=base]                                      ::  base spec
    [%bust p=base]                                      ::  bunt base
    [%dbug p=spot q=hoon]                               ::  debug info in trace
    [%eror p=tape]                                      ::  assembly error
    [%hand p=type q=nock]                               ::  premade result
    [%note p=note q=hoon]                               ::  annotate
    [%fits p=hoon q=wing]                               ::  underlying ?=
    [%knit p=(list woof)]                               ::  assemble string
    [%leaf p=(pair term @)]                             ::  symbol spec
    [%limb p=term]                                      ::  take limb
    [%lost p=hoon]                                      ::  not to be taken
    [%rock p=term q=*]                                  ::  fixed constant
    [%sand p=term q=*]                                  ::  unfixed constant
    [%tell p=(list hoon)]                               ::  render as tape
    [%tune p=$@(term tune)]                             ::  minimal face
    [%wing p=wing]                                      ::  take wing
    [%yell p=(list hoon)]                               ::  render as tank
    [%xray p=manx:hoot]                                 ::  ;foo; templating
  ::                                            ::::::  cores
    [%brbc sample=(lest term) body=spec]                ::  |$
    [%brcb p=spec q=alas r=(map term tome)]             ::  |_
    [%brcl p=hoon q=hoon]                               ::  |:
    [%brcn p=(unit term) q=(map term tome)]             ::  |%
    [%brdt p=hoon]                                      ::  |.
    [%brkt p=hoon q=(map term tome)]                    ::  |^
    [%brhp p=hoon]                                      ::  |-
    [%brsg p=spec q=hoon]                               ::  |~
    [%brtr p=spec q=hoon]                               ::  |*
    [%brts p=spec q=hoon]                               ::  |=
    [%brpt p=(unit term) q=(map term tome)]             ::  |@
    [%brwt p=hoon]                                      ::  |?
  ::                                            ::::::  tuples
    [%clcb p=hoon q=hoon]                               ::  :_ [q p]
    [%clkt p=hoon q=hoon r=hoon s=hoon]                 ::  :^ [p q r s]
    [%clhp p=hoon q=hoon]                               ::  :- [p q]
    [%clls p=hoon q=hoon r=hoon]                        ::  :+ [p q r]
    [%clsg p=(list hoon)]                               ::  :~ [p ~]
    [%cltr p=(list hoon)]                               ::  :* p as a tuple
  ::                                            ::::::  invocations
    [%cncb p=wing q=(list (pair wing hoon))]            ::  %_
    [%cndt p=hoon q=hoon]                               ::  %.
    [%cnhp p=hoon q=hoon]                               ::  %-
    [%cncl p=hoon q=(list hoon)]                        ::  %:
    [%cntr p=wing q=hoon r=(list (pair wing hoon))]     ::  %*
    [%cnkt p=hoon q=hoon r=hoon s=hoon]                 ::  %^
    [%cnls p=hoon q=hoon r=hoon]                        ::  %+
    [%cnsg p=wing q=hoon r=(list hoon)]                 ::  %~
    [%cnts p=wing q=(list (pair wing hoon))]            ::  %=
  ::                                            ::::::  nock
    [%dtkt p=spec q=hoon]                               ::  .^  nock 11
    [%dtls p=hoon]                                      ::  .+  nock 4
    [%dttr p=hoon q=hoon]                               ::  .*  nock 2
    [%dtts p=hoon q=hoon]                               ::  .=  nock 5
    [%dtwt p=hoon]                                      ::  .?  nock 3
  ::                                            ::::::  type conversion
    [%ktbr p=hoon]                                      ::  ^|  contravariant
    [%ktdt p=hoon q=hoon]                               ::  ^.  self-cast
    [%ktls p=hoon q=hoon]                               ::  ^+  expression cast
    [%kthp p=spec q=hoon]                               ::  ^-  structure cast
    [%ktpm p=hoon]                                      ::  ^&  covariant
    [%ktsg p=hoon]                                      ::  ^~  constant
    [%ktts p=skin q=hoon]                               ::  ^=  label
    [%ktwt p=hoon]                                      ::  ^?  bivariant
    [%kttr p=spec]                                      ::  ^*  example
    [%ktcl p=spec]                                      ::  ^:  filter
  ::                                            ::::::  hints
    [%sgbr p=hoon q=hoon]                               ::  ~|  sell on trace
    [%sgcb p=hoon q=hoon]                               ::  ~_  tank on trace
    [%sgcn p=chum q=hoon r=tyre s=hoon]                 ::  ~%  general jet hint
    [%sgfs p=chum q=hoon]                               ::  ~/  function j-hint
    [%sggl p=$@(term [p=term q=hoon]) q=hoon]           ::  ~<  backward hint
    [%sggr p=$@(term [p=term q=hoon]) q=hoon]           ::  ~>  forward hint
    [%sgbc p=term q=hoon]                               ::  ~$  profiler hit
    [%sgls p=@ q=hoon]                                  ::  ~+  cache=memoize
    [%sgpm p=@ud q=hoon r=hoon]                         ::  ~&  printf=priority
    [%sgts p=hoon q=hoon]                               ::  ~=  don't duplicate
    [%sgwt p=@ud q=hoon r=hoon s=hoon]                  ::  ~?  tested printf
    [%sgzp p=hoon q=hoon]                               ::  ~!  type on trace
  ::                                            ::::::  miscellaneous
    [%mcts p=marl:hoot]                                 ::  ;=  list templating
    [%mccl p=hoon q=(list hoon)]                        ::  ;:  binary to nary
    [%mcfs p=hoon]                                      ::  ;/  [%$ [%$ p ~] ~]
    [%mcgl p=spec q=hoon r=hoon s=hoon]                 ::  ;<  bind
    [%mcsg p=hoon q=(list hoon)]                        ::  ;~  kleisli arrow
    [%mcmc p=spec q=hoon]                               ::  ;;  normalize
  ::                                            ::::::  compositions
    [%tsbr p=spec q=hoon]                               ::  =|  push bunt
    [%tscl p=(list (pair wing hoon)) q=hoon]            ::  =:  q w= p changes
    [%tsfs p=skin q=hoon r=hoon]                        ::  =/  typed variable
    [%tsmc p=skin q=hoon r=hoon]                        ::  =;  =/(q p r)
    [%tsdt p=wing q=hoon r=hoon]                        ::  =.  r with p as q
    [%tswt p=wing q=hoon r=hoon s=hoon]                 ::  =?  conditional =.
    [%tsgl p=hoon q=hoon]                               ::  =<  =>(q p)
    [%tshp p=hoon q=hoon]                               ::  =-  =+(q p)
    [%tsgr p=hoon q=hoon]                               ::  =>  q w=subject p
    [%tskt p=skin q=wing r=hoon s=hoon]                 ::  =^  state machine
    [%tsls p=hoon q=hoon]                               ::  =+  q w=[p subject]
    [%tssg p=(list hoon)]                               ::  =~  hoon stack
    [%tstr p=(pair term (unit spec)) q=hoon r=hoon]     ::  =*  new style
    [%tscm p=hoon q=hoon]                               ::  =,  overload p in q
  ::                                            ::::::  conditionals
    [%wtbr p=(list hoon)]                               ::  ?|  loobean or
    [%wthp p=wing q=(list (pair spec hoon))]            ::  ?-  pick case in q
    [%wtcl p=hoon q=hoon r=hoon]                        ::  ?:  if=then=else
    [%wtdt p=hoon q=hoon r=hoon]                        ::  ?.  ?:(p r q)
    [%wtkt p=wing q=hoon r=hoon]                        ::  ?^  if p is a cell
    [%wtgl p=hoon q=hoon]                               ::  ?<  ?:(p !! q)
    [%wtgr p=hoon q=hoon]                               ::  ?>  ?:(p q !!)
    [%wtls p=wing q=hoon r=(list (pair spec hoon))]     ::  ?+  ?-  w=default
    [%wtpm p=(list hoon)]                               ::  ?&  loobean and
    [%wtpt p=wing q=hoon r=hoon]                        ::  ?@  if p is atom
    [%wtsg p=wing q=hoon r=hoon]                        ::  ?~  if p is null
    [%wthx p=skin q=wing]                               ::  ?#  if q matches p
    [%wtts p=spec q=wing]                               ::  ?=  if q matches p
    [%wtzp p=hoon]                                      ::  ?!  loobean not
  ::                                            ::::::  special
    [%zpcm p=hoon q=hoon]                               ::  !,
    [%zpgr p=hoon]                                      ::  !>
    [%zpgl p=spec q=hoon]                               ::  !<
    [%zpmc p=hoon q=hoon]                               ::  !;
    [%zpts p=hoon]                                      ::  !=
    [%zppt p=(list wing) q=hoon r=hoon]                 ::  !@
    [%zpwt p=$@(p=@ [p=@ q=@]) q=hoon]                  ::  !?
    [%zpzp ~]                                           ::  !!
  ==
+$  tyre  (list [p=term q=hoon])
+$  chum  $?  lef=term                                  ::  jet name
              [std=term kel=@]                          ::  kelvin version
              [ven=term pro=term kel=@]                 ::  vendor and product
              [ven=term pro=term ver=@ kel=@]           ::  all of the above
          ==
+$  skin                                                ::  texture
          $@  =term                                     ::  name/~[term %none]
          $%  [%base =base]                             ::  base match
              [%cell =skin =skin]                       ::  pair
              [%dbug =spot =skin]                       ::  trace
              [%leaf =aura =atom]                       ::  atomic constant
              [%help =help =skin]                       ::  describe
              [%name =term =skin]                       ::  apply label
              [%over =wing =skin]                       ::  relative to
              [%spec =spec =skin]                       ::  cast to
              [%wash depth=@ud]                         ::  strip faces
          ==
+$  alas  (list (pair term hoon))
+$  spec                                                ::  structure definition
          $~  [%base %null]                             ::
          $%  [%base p=base]                            ::  base type
              [%dbug p=spot q=spec]                     ::  set debug
              [%leaf p=term q=@]                        ::  constant atom
              [%like p=wing q=(list wing)]              ::  reference
              [%loop p=term]                            ::  hygienic reference
              [%made p=(pair term (list term)) q=spec]  ::  annotate synthetic
              [%make p=hoon q=(list spec)]              ::  composed spec
              [%name p=term q=spec]                     ::  annotate simple
              [%over p=wing q=spec]                     ::  relative to subject
          ::                                            ::
              [%bcgr p=spec q=spec]                     ::  $>, filter: require
              [%bcbc p=spec q=(map term spec)]          ::  $$, recursion
              [%bcbr p=spec q=hoon]                     ::  $|, verify
              [%bccb p=hoon]                            ::  $_, example
              [%bccl p=[i=spec t=(list spec)]]          ::  $:, tuple
              [%bccn p=[i=spec t=(list spec)]]          ::  $%, head pick
              [%bcdt p=spec q=(map term spec)]          ::  $., read-write core
              [%bcgl p=spec q=spec]                     ::  $<, filter: exclude
              [%bchp p=spec q=spec]                     ::  $-, function core
              [%bckt p=spec q=spec]                     ::  $^, cons pick
              [%bcls p=stud q=spec]                     ::  $+, standard
              [%bcfs p=spec q=(map term spec)]          ::  $/, write-only core
              [%bcmc p=hoon]                            ::  $;, manual
              [%bcpm p=spec q=hoon]                     ::  $&, repair
              [%bcsg p=hoon q=spec]                     ::  $~, default
              [%bctc p=spec q=(map term spec)]          ::  $`, read-only core
              [%bcts p=skin q=spec]                     ::  $=, name
              [%bcpt p=spec q=spec]                     ::  $@, atom pick
              [%bcwt p=[i=spec t=(list spec)]]          ::  $?, full pick
              [%bczp p=spec q=(map term spec)]          ::  $!, opaque core
          ==
++  hoot                                                ::  hoon tools
  |%
  +$  beer  $@(char [~ p=hoon])                    ::  simple embed
  +$  mane  $@(@tas [@tas @tas])                    ::  XML name+space
  +$  manx  $~([[%$ ~] ~] [g=marx c=marl])          ::  dynamic XML node
  +$  marl  (list tuna)                             ::  dynamic XML nodes
  +$  mart  (list [n=mane v=(list beer)])           ::  dynamic XML attrs
  +$  marx  $~([%$ ~] [n=mane a=mart])              ::  dynamic XML tag
  +$  mare  (each manx marl)                        ::  node or nodes
  +$  maru  (each tuna marl)                        ::  interp or nodes
  +$  tuna                                          ::  maybe interpolation
      $~  [[%$ ~] ~]
      $^  manx
      $:  ?(%tape %manx %marl %call)
          p=hoon
      ==
  --
+$  woof  $@(@ [~ p=hoon])
+$  link                                                ::  lexical segment
          $%  [%chat p=term]                            ::  |chapter
              [%cone p=aura q=atom]                     ::  %constant
              [%frag p=term]                            ::  .leg
              [%funk p=term]                            ::  +arm
          ==                                            ::
+$  crib  [summary=cord details=(list sect)]
+$  sect  (list pica)
+$  pica  (pair ? cord)            ::
+$  help  [links=(list link) =crib]
+$  path  (list knot)                                   ::  like unix path
+$  stud                                                ::  standard name
          $@  mark=@tas                                 ::  auth=urbit
          $:  auth=@tas                                 ::  standards authority
              type=path                                 ::  standard label
          ==
+$  wing  (list limb)
+$  limb  $@  term                                      ::  wing element
          $%  [%& p=axis]                               ::  by geometry
              [%| p=@ud q=(unit term)]                  ::  by name
          ==
+$  garb  [p=(unit term) q=poly r=vair]
+$  vair  ?(%gold %iron %lead %zinc)                  ::  core
+$  poly  ?(%wet %dry)
::
::  +block: abstract identity of resource awaited
::
+$  block
  path
::
::  +result: internal interpreter result
::
+$  result
  $@(~ seminoun)
::
::  +thunk: fragment constructor
::
+$  thunk
  $-(@ud (unit noun))
::
::  +seminoun:
::
+$  seminoun
  ::  partial noun; blocked subtrees are ~
  ::
  $~  [[%full / ~ ~] ~]
  [mask=stencil data=noun]
::
::  +stencil: noun knowledge map
::
+$  stencil
  $%  ::
      ::  %half: noun has partial block substructure
      ::
      [%half left=stencil rite=stencil]
      ::
      ::  %full: noun is either fully complete, or fully blocked
      ::
      [%full blocks=(set block)]
      ::
      ::  %lazy: noun can be generated from virtual subtree
      ::
      [%lazy fragment=axis resolve=thunk]
  ==
+$  tome  (pair what (map term hoon))
+$  what  (unit (pair cord (list sect)))
+$  base                                                ::  base mold
  $@  $?  %noun                                         ::  any noun
          %cell                                         ::  any cell
          %flag                                         ::  loobean
          %null                                         ::  ~ == 0
          %void                                         ::  empty set
      ==                                                ::
  [%atom p=aura]
+$  pint  [p=[p=@ q=@] q=[p=@ q=@]]                     ::  line+column range                         ::  parsing rule
+$  spot  [p=path q=pint]
+$  nock  $^  [p=nock q=nock]                           ::  autocons
          $%  [%1 p=*]                                  ::  constant
              [%2 p=nock q=nock]                        ::  compose
              [%3 p=nock]                               ::  cell test
              [%4 p=nock]                               ::  increment
              [%5 p=nock q=nock]                        ::  equality test
              [%6 p=nock q=nock r=nock]                 ::  if, then, else
              [%7 p=nock q=nock]                        ::  serial compose
              [%8 p=nock q=nock]                        ::  push onto subject
              [%9 p=@ q=nock]                           ::  select arm and fire
              [%10 p=[p=@ q=nock] q=nock]               ::  edit
              [%11 p=$@(@ [p=@ q=nock]) q=nock]         ::  hint
              [%12 p=nock q=nock]                       ::  grab data from sky
              [%0 p=@]                                  ::  axis select
          ==
::  our types
::
+$  id  @ux                   ::  pubkey
++  zigs-wheat-id  0x0
++  zigs-rice-id  0x1
::
+$  user  [=id nonce=@ud]
+$  caller  $@(id user)
+$  signature  [r=@ux s=@ux type=?(%schnorr %ecdsa)]
::
+$  rice
  $:  holder=id
      holds=(set id)
      data=*
  ==
::
+$  wheat  (unit *)
::
+$  grain
  $:  =id
      lord=id
      town-id=@ud
      germ=(each rice wheat)
  ==
::
+$  granary   (map id grain)    ::  replace with +merk
+$  populace  (map id @ud)
+$  town      (pair granary populace)
+$  land      (map @ud town)
::
+$  contract
  $_  ^|
  |_  mem=(unit vase)
  ++  write
    |~  contract-input
    *contract-output
  ::
  ++  read
    |~  contract-input
    *contract-output
  ::
  ++  event
    |~  contract-result
    *contract-output
  --
::
+$  call
  $:  from=caller
      to=id
      rate=@ud
      budget=@ud
      town-id=@ud
      args=call-args
  ==
::
+$  call-args
  [?(%read %write) call-input]
+$  call-input
  $:  =caller
      rice=(set id)
      args=(unit noun)
  ==
::
+$  contract-args
  $%  [?(%read %write) contract-input]
      [%event contract-result]
  ==
::
+$  contract-input
  $:  =caller
      args=(unit noun)
      rice=contract-input-rice
  ==
::
+$  contract-input-rice
  %+  map  id
  $:  =id
      lord=id
      town-id=@ud
      germ=[%& rice]
  ==
::
+$  contract-output
  $%  [%result p=contract-result]
      [%callback p=continuation]
  ==
::
+$  contract-result
  $%  [%read =noun]
      [%write changed=(map id grain) issued=(map id grain)]
  ==
::
+$  continuation  [mem=(unit vase) next=[to=id town-id=@ud args=call-args]]
--
