/-  *zink
/+  *zink-pedersen, *zink-json, *mip
|%
::
+$  good  (unit *)
+$  fail  (list [@ta *])
::
+$  body  (each good fail)
+$  cache  (map * phash)
+$  appendix  [cax=cache hit=hints bud=@]
+$  book  (pair body appendix)
::
++  zink
  =|  appendix
  =*  app  -
  =|  trace=fail
  |=  [s=* f=*]
  ^-  book
  |^
  ?~  formula-cost=(cost f bud)
    [%&^~ [cax hit 0]]
  ?:  (lth bud u.formula-cost)  [%&^~ [cax hit 0]]
  =.  bud  (sub bud u.formula-cost)
  |-
  ?+    f
    ~&  f
    [%|^trace app]
  ::  formula is a cell; do distribution
  ::
      [^ *]
    ?:  (lth bud 1)  [%&^~ app]
    =.  bud  (sub bud 1)
    =^  hed=body  app
      $(f -.f)
    ?:  ?=(%| -.hed)  [%|^trace app]
    ?~  p.hed  [%&^~ app]
    =^  tal=body  app
      $(f +.f)
    ?:  ?=(%| -.tal)  [%|^trace app]
    ?~  p.tal  [%&^~ app]
    =^  hhed  cax  (hash -.f)
    =^  htal  cax  (hash +.f)
    =.  app  (put-hint [%cons hhed htal])
    [%& ~ u.p.hed^u.p.tal]^app
  ::
      [%0 axis=@]
    ?:  (lth bud 1)  [%&^~ app]
    =.  bud  (sub bud 1)
    =^  part  bud
      (frag axis.f s bud)
    ?~  part  [%&^~ app]
    ?~  u.part  [%|^trace app]
    =^  hpart  cax  (hash u.u.part)
    =^  hsibs  cax  (merk-sibs s axis.f)
    =.  app  (put-hint [%0 axis.f hpart hsibs])
    [%& ~ u.u.part]^app
  ::
      [%1 const=*]
    ?:  (lth bud 1)  [%&^~ app]
    =.  bud  (sub bud 1)
    =^  hres  cax  (hash const.f)
    =.  app  (put-hint [%1 hres])
    [%& ~ const.f]^app
  ::
      [%2 sub=* for=*]
    ?:  (lth bud 1)  [%&^~ app]
    =.  bud  (sub bud 1)
    =^  hsub  cax  (hash sub.f)
    =^  hfor  cax  (hash for.f)
    =^  subject=body  app
      $(f sub.f)
    ?:  ?=(%| -.subject)  [%|^trace app]
    ?~  p.subject  [%&^~ app]
    =^  formula=body  app
      $(f for.f)
    ?:  ?=(%| -.formula)  [%|^trace app]
    ?~  p.formula  [%&^~ app]
    =.  app  (put-hint [%2 hsub hfor])
    $(s u.p.subject, f u.p.formula)
  ::
      [%3 arg=*]
    ?:  (lth bud 1)  [%&^~ app]
    =.  bud  (sub bud 1)
    =^  argument=body  app
      $(f arg.f)
    ?:  ?=(%| -.argument)  [%|^trace app]
    ?~  p.argument  [%&^~ app]
    =^  harg  cax  (hash arg.f)
    ?@  u.p.argument
      =.  app  (put-hint [%3 harg %atom u.p.argument])
      [%& ~ %.n]^app
    =^  hhash  cax  (hash -.u.p.argument)
    =^  thash  cax  (hash +.u.p.argument)
    =.  app  (put-hint [%3 harg %cell hhash thash])
    [%& ~ %.y]^app
  ::
      [%4 arg=*]

    ?:  (lth bud 1)  [%&^~ app]
    =.  bud  (sub bud 1)
    =^  argument=body  app
      $(f arg.f)
    ?:  ?=(%| -.argument)  [%|^trace app]
    =^  harg  cax  (hash arg.f)
    ?~  p.argument  [%&^~ app]
    ?^  u.p.argument  [%|^trace app]
    =.  app  (put-hint [%4 harg u.p.argument])
    [%& ~ .+(u.p.argument)]^app
  ::
      [%5 a=* b=*]
    ?:  (lth bud 1)  [%&^~ app]
    =.  bud  (sub bud 1)
    =^  ha  cax  (hash a.f)
    =^  hb  cax  (hash b.f)
    =^  a=body  app
      $(f a.f)
    ?:  ?=(%| -.a)  [%|^trace app]
    ?~  p.a  [%&^~ app]
    =^  b=body  app
      $(f b.f)
    ?:  ?=(%| -.b)  [%|^trace app]
    ?~  p.b  [%&^~ app]
    =.  app  (put-hint [%5 ha hb])
    [%& ~ =(u.p.a u.p.b)]^app
  ::
      [%6 test=* yes=* no=*]
    ?:  (lth bud 1)  [%&^~ app]
    =.  bud  (sub bud 1)
    =^  htest  cax  (hash test.f)
    =^  hyes   cax  (hash yes.f)
    =^  hno    cax  (hash no.f)
    =^  result=body  app
      $(f test.f)
    ?:  ?=(%| -.result)  [%|^trace app]
    ?~  p.result  [%&^~ app]
    =.  app  (put-hint [%6 htest hyes hno])
    ?+  u.p.result  [%|^trace app]
      %&  $(f yes.f)
      %|  $(f no.f)
    ==
  ::
      [%7 subj=* next=*]
    ?:  (lth bud 1)  [%&^~ app]
    =.  bud  (sub bud 1)
    =^  hsubj  cax  (hash subj.f)
    =^  hnext  cax  (hash next.f)
    =^  subject=body  app
      $(f subj.f)
    ?:  ?=(%| -.subject)  [%|^trace app]
    ?~  p.subject  [%&^~ app]
    =.  app  (put-hint [%7 hsubj hnext])
    %=  $
      s  u.p.subject
      f  next.f
    ==
  ::
      [%8 head=* next=*]
    ?:  (lth bud 1)  [%&^~ app]
    =.  bud  (sub bud 1)
    =^  jax=body  app
      (jet head.f next.f)
    ?:  ?=(%| -.jax)  [%|^trace app]
    ?^  p.jax  [%& p.jax]^app
    =^  hhead  cax  (hash head.f)
    =^  hnext  cax  (hash next.f)
    =^  head=body  app
      $(f head.f)
    ?:  ?=(%| -.head)  [%|^trace app]
    ?~  p.head  [%&^~ app]
    =.  app  (put-hint [%8 hhead hnext])
    %=  $
      s  [u.p.head s]
      f  next.f
    ==
  ::
      [%9 axis=@ core=*]
    ?:  (lth bud 1)  [%&^~ app]
    =.  bud  (sub bud 1)
    =^  hcore  cax  (hash core.f)
    =^  core=body  app
      $(f core.f)
    ?:  ?=(%| -.core)  [%|^trace app]
    ?~  p.core  [%&^~ app]
    =^  arm  bud
      (frag axis.f u.p.core bud)
    ?~  arm  [%&^~ app]
    ?~  u.arm  [%|^trace app]
    =^  harm  cax  (hash u.u.arm)
    =^  sibs  cax  (merk-sibs u.p.core axis.f)
    =.  app  (put-hint [%9 axis.f hcore harm sibs])
    %=  $
      s  u.p.core
      f  u.u.arm
    ==
  ::
      [%10 [axis=@ value=*] target=*]
    ?:  (lth bud 1)  [%&^~ app]
    =.  bud  (sub bud 1)
    =^  hval  cax  (hash value.f)
    =^  htar  cax  (hash target.f)
    ?:  =(0 axis.f)  [%|^trace app]
    =^  target=body  app
      $(f target.f)
    ?:  ?=(%| -.target)  [%|^trace app]
    ?~  p.target  [%&^~ app]
    =^  value=body  app
      $(f value.f)
    ?:  ?=(%| -.value)  [%|^trace app]
    ?~  p.value  [%&^~ app]
    =^  mutant=(unit (unit *))  bud
      (edit axis.f u.p.target u.p.value bud)
    ?~  mutant  [%&^~ app]
    ?~  u.mutant  [%|^trace app]
    =^  oldleaf  bud
      (frag axis.f u.p.target bud)
    ?~  oldleaf  [%&^~ app]
    ?~  u.oldleaf  [%|^trace app]
    =^  holdleaf  cax  (hash u.u.oldleaf)
    =^  sibs  cax  (merk-sibs u.p.target axis.f)
    =.  app  (put-hint [%10 axis.f hval htar holdleaf sibs])
    [%& ~ u.u.mutant]^app
  ==
  :: Check if we are calling an arm in a core and if so lookup the axis
  :: in the jet map
  :: Calling convention is
  :: [8 [9 JET-AXIS 0 CORE-AXIS] 9 2 10 [6 MAKE-SAMPLE] 0 2]
  :: If we match this then look up JET-AXIS in the jet map to see if we're
  :: calling a jetted arm.
  ::
  :: Note that this arm should only be called on an 8
  :: TODO Figure out what CORE-AXIS should be
  ++  jet
    |=  [head=* next=*]
    ^-  book
    =^  mj  app  (match-jet head next)
    ?~  mj  [%&^~ app]
    (run-jet u.mj)^app
  ::
  ++  match-jet
    |=  [head=* next=*]
    ^-  [(unit [@tas *]) appendix]
    ?:  (lth bud 1)  `app
    =.  bud  (sub bud 1)
    ?.  ?=([%9 arm-axis=@ %0 core-axis=@] head)  `app
    ?.  ?=([%9 %2 %10 [%6 sam=*] %0 %2] next)  `app
    ?~  mjet=(~(get by jets) arm-axis.head)  `app
    =^  sub=body  app
      ^$(f head)
    ?:  ?=(%| -.sub)  `app
    ?~  p.sub  `app
    =^  arg=body  app
      ^$(s sub^s, f sam.next)
    ?:  ?=(%| -.arg)  `app
    ?~  p.arg  `app
    [~ u.mjet u.p.arg]^app
  ::
  ++  run-jet
    |=  [arm=@tas sam=*]
    ^-  body
    ?+  arm  %|^trace
    ::
        %dec
      ?:  (lth bud 1)  %&^~
      =.  bud  (sub bud 1)
      ?.  ?=(@ sam)  %|^trace
      ::  TODO: probably unsustainable to need to include assertions to
      ::  make all jets crash safe
      ?.  (gth sam 0)  %|^trace
      %&^(some (dec sam))
    ::
        %add
      ?:  (lth bud 1)  %&^~
      =.  bud  (sub bud 1)
      ?.  ?=([x=@ud y=@ud] sam)  %|^trace
      %&^(some (add x.sam y.sam))
    ::
        %mul
      ?:  (lth bud 1)  %&^~
      =.  bud  (sub bud 1)
      ?.  ?=([x=@ud y=@ud] sam)  %|^trace
      %&^(some (mul x.sam y.sam))
    ::
        %double
      ?:  (lth bud 1)  %&^~
      =.  bud  (sub bud 1)
      ?.  ?=(@ sam)  %|^trace
      %&^(some (mul 2 sam))
    ==
  ::
  ++  put-hint
    |=  hin=cairo-hint
    ^-  appendix
    =^  sroot  cax  (hash s)
    =^  froot  cax  (hash f)
    =.  hit  (~(put bi hit) sroot froot hin)
    app
  ::
  ++  frag
    |=  [axis=@ noun=* bud=@ud]
    ^-  [(unit (unit)) @ud]
    ?:  =(0 axis)  [`~ bud]
    |-  ^-  [(unit (unit)) @ud]
    ?:  =(0 bud)  [~ bud]
    ?:  =(1 axis)  [``noun (dec bud)]
    ?@  noun  [`~ (dec bud)]
    =/  pick  (cap axis)
    %=  $
      axis  (mas axis)
      noun  ?-(pick %2 -.noun, %3 +.noun)
      bud   (dec bud)
    ==
  ::
  ++  edit
    |=  [axis=@ target=* value=* bud=@ud]
    ^-  [(unit (unit)) @ud]
    ?:  =(1 axis)  [``value bud]
    ?@  target  [`~ bud]
    ?:  =(0 bud)  [~ bud]
    =/  pick  (cap axis)
    =^  mutant  bud
      %=  $
        axis    (mas axis)
        target  ?-(pick %2 -.target, %3 +.target)
        bud     (dec bud)
      ==
    ?~  mutant  [~ bud]
    ?~  u.mutant  [`~ bud]
    ?-  pick
      %2  [``[u.u.mutant +.target] bud]
      %3  [``[-.target u.u.mutant] bud]
    ==
  ::  hash:
  ::  if x is an atom then hash(x)=h(x, 0)
  ::  else hash([x y])=h(hash(x), hash(y))
  ::  where h = pedersen hash
  ++  hash
    |=  n=*
    ^-  [phash cache]
    =/  mh  (~(get by cax) n)
    ?^  mh  [u.mh cax]
    ?@  n
      =/  h  (hash:pedersen n 0)
      [h (~(put by cax) n h)]
    =^  hh  cax  $(n -.n)
    =^  ht  cax  $(n +.n)
    =/  h  (hash:pedersen hh ht)
    [h (~(put by cax) n h)]
  ::
  ++  cost                                              ::  gas cost of noun
    |^
    |=  [a=* bud=@ud]
    ^-  (unit @ud)
    ?@(a `(pat a) (ket a bud))
    ++  pat  |=(a=@ (max 1 (met 5 a)))
    ++  ket
      |=  [a=^ bud=@ud]
      ?:  (lth bud 1)  ~
      =.  bud  (dec bud)
      ?~  lef=(^$ -.a bud)  ~
      ?:  (lth bud u.lef)  ~
      =.  bud  (sub bud u.lef)
      ?~  rig=(^$ +.a bud)  ~
      `+((add u.lef u.rig))
    --
  ::  +merk-sibs from bottom to top
  ::
  ++  merk-sibs
    |=  [s=* axis=@]
    =|  path=(list phash)
    |-  ^-  [(list phash) (map * phash)]
    ?:  =(1 axis)
      [path cax]
    ?~  axis  !!
    ?@  s  !!
    =/  pick  (cap axis)
    =^  sibling=phash  cax
      %-  hash
      ?-(pick %2 +.s, %3 -.s)
    =/  child  ?-(pick %2 -.s, %3 +.s)
    %=  $
      s     child
      axis  (mas axis)
      path  [sibling path]
    ==
  --
::
::  eval-noun: evaluate nock with zink
::
++  eval-noun
  |=  [n=(pair) bud=@]
  ^-  book
  %.  n
  %*  .  zink
    app  [~ ~ bud]
  ==
::
::  eval-noun: evaluate nock with zink
::
++  eval-noun-with-cache
  |=  [n=(pair) bud=@ cax=cache]
  ^-  book
  %.  n
  %*  .  zink
    app  [cax ~ bud]
  ==
::
::  eval-hoon-with-hints: eval hoon and return result w/hints as json
::
++  eval-hoon-with-hints
  |=  [file=path gen=hoon bud=@]
  ^-  [body json]
  =/  src  .^(@t %cx file)
  =/  gun  (slap !>(~) (ream src))
  =/  han  (~(mint ut p.gun) %noun gen)
  =-  [p (create-hints [q.gun q.han] hit.q)]
  (eval-noun [q.gun q.han] bud)
::
::  eval-hoon: compile a hoon file and evaluate it with zink
::
++  eval-hoon
  |=  [file=path lib=(unit path) gen=hoon bud=@]
  ^-  book
  =/  clib
    ?~  lib  !>(~)
    =/  libsrc  .^(@t %cx u.lib)
    (slap !>(~) (ream libsrc))
  =/  src  .^(@t %cx file)
  =/  gun  (slap clib (ream src))
  =/  han  (~(mint ut p.gun) %noun gen)
  (eval-noun [q.gun q.han] bud)
::
::  eval-hoon-with-cache: compile a hoon file and evaluate it with zink
::
++  eval-hoon-with-cache
  |=  [file=path lib=(unit path) gen=hoon bud=@ cax=cache]
  ^-  book
  =/  clib
    ?~  lib  !>(~)
    =/  libsrc  .^(@t %cx u.lib)
    (slap !>(~) (ream libsrc))
  =/  src  .^(@t %cx file)
  =/  gun  (slap clib (ream src))
  =/  han  (~(mint ut p.gun) %noun gen)
  (eval-noun-with-cache [q.gun q.han] bud cax)
::
::  create-hints: create full hint json
::
++  create-hints
  |=  [n=^ h=hints]
  ^-  js=json
  =/  hs  (hash -.n)
  =/  hf  (hash +.n)
  %-  pairs:enjs:format
  :~  ['subject' s+(num:enjs hs)]
      ['formula' s+(num:enjs hf)]
      ['hints' (all:enjs h)]
  ==
::
++  hash
  |=  n=*
  ^-  phash
  ?@  n
    (hash:pedersen n 0)
  =/  hh  $(n -.n)
  =/  ht  $(n +.n)
  (hash:pedersen hh ht)
--
