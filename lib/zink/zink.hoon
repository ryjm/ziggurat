/-  *zink
/+  *zink-pedersen, *zink-json
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
  =.  hit  *hints
  ?+    f
    ~&  f
    [%|^trace app]
  ::  formula is a cell; do distribution
  ::
      [^ *]
    =^  hed=body  app
      $(f -.f)
    ?:  ?=(%| -.hed)  [%|^trace app]
    ?~  p.hed  [%&^~ app]
    =^  tal=body  app
      $(f +.f)
    ?:  ?=(%| -.tal)  [%|^trace app]
    ?~  p.tal  [%&^~ app]
    =^  hhed=(unit phash)  app  (hash -.f)
    ?~  hhed  [%&^~ app]
    =^  htal=(unit phash)  app  (hash +.f)
    ?~  htal  [%&^~ app]
    :-  [%& ~ u.p.hed^u.p.tal]
    app(hit [%cons u.hhed u.htal]^hit)
  ::
      [%0 axis=@]
    =^  part  bud
      (frag axis.f s bud)
    ?~  part  [%&^~ app]
    ?~  u.part  [%|^trace app]
    =^  hpart=(unit phash)         app  (hash u.u.part)
    ?~  hpart  [%&^~ app]
    =^  hsibs=(unit (list phash))  app  (merk-sibs s axis.f)
    ?~  hsibs  [%&^~ app]
    :-  [%& ~ u.u.part]
    app(hit [%0 axis.f u.hpart u.hsibs]^hit)
  ::
      [%1 const=*]
    =^  hres=(unit phash)  app  (hash const.f)
    ?~  hres  [%&^~ app]
    :-  [%& ~ const.f]
    app(hit [%1 u.hres]^hit)
  ::
      [%2 sub=* for=*]
    =^  hsub=(unit phash)  app  (hash sub.f)
    ?~  hsub  [%&^~ app]
    =^  hfor=(unit phash)  app  (hash for.f)
    ?~  hfor  [%&^~ app]
    =^  subject=body  app
      $(f sub.f)
    ?:  ?=(%| -.subject)  [%|^trace app]
    ?~  p.subject  [%&^~ app]
    =^  formula=body  app
      $(f for.f)
    ?:  ?=(%| -.formula)  [%|^trace app]
    ?~  p.formula  [%&^~ app]
    %_  $
      s    u.p.subject
      f    u.p.formula
      hit  [%2 u.hsub u.hfor]^hit
    ==
  ::
      [%3 arg=*]
    =^  argument=body  app
      $(f arg.f)
    ?:  ?=(%| -.argument)  [%|^trace app]
    ?~  p.argument  [%&^~ app]
    =^  harg=(unit phash)  app  (hash arg.f)
    ?~  harg  [%&^~ app]
    ?@  u.p.argument
      :-  [%& ~ %.n]
      app(hit [%3 u.harg %atom u.p.argument]^hit)
    =^  hhash=(unit phash)  app  (hash -.u.p.argument)
    ?~  hhash  [%&^~ app]
    =^  thash=(unit phash)  app  (hash +.u.p.argument)
    ?~  thash  [%&^~ app]
    :-  [%& ~ %.y]
    app(hit [%3 u.harg %cell u.hhash u.thash]^hit)
  ::
      [%4 arg=*]
    =^  argument=body  app
      $(f arg.f)
    ?:  ?=(%| -.argument)  [%|^trace app]
    =^  harg=(unit phash)  app  (hash arg.f)
    ?~  harg  [%&^~ app]
    ?~  p.argument  [%&^~ app]
    ?^  u.p.argument  [%|^trace app]
    :-  [%& ~ .+(u.p.argument)]
    app(hit [%4 u.harg u.p.argument]^hit)
  ::
      [%5 a=* b=*]
    =^  ha=(unit phash)  app  (hash a.f)
    ?~  ha  [%&^~ app]
    =^  hb=(unit phash)  app  (hash b.f)
    ?~  hb  [%&^~ app]
    =^  a=body  app
      $(f a.f)
    ?:  ?=(%| -.a)  [%|^trace app]
    ?~  p.a  [%&^~ app]
    =^  b=body  app
      $(f b.f)
    ?:  ?=(%| -.b)  [%|^trace app]
    ?~  p.b  [%&^~ app]
    :-  [%& ~ =(u.p.a u.p.b)]
    app(hit [%5 u.ha u.hb]^hit)
  ::
      [%6 test=* yes=* no=*]
    =^  htest=(unit phash)  app  (hash test.f)
    ?~  htest  [%&^~ app]
    =^  hyes=(unit phash)   app  (hash yes.f)
    ?~  hyes  [%&^~ app]
    =^  hno=(unit phash)    app  (hash no.f)
    ?~  hno  [%&^~ app]
    =^  result=body  app
      $(f test.f)
    ?:  ?=(%| -.result)  [%|^trace app]
    ?~  p.result  [%&^~ app]
    =.  hit  [%6 u.htest u.hyes u.hno]^hit
    ?+  u.p.result  [%|^trace app]
      %&  $(f yes.f)
      %|  $(f no.f)
    ==
  ::
      [%7 subj=* next=*]
    =^  hsubj=(unit phash)  app  (hash subj.f)
    ?~  hsubj  [%&^~ app]
    =^  hnext=(unit phash)  app  (hash next.f)
    ?~  hnext  [%&^~ app]
    =^  subject=body  app
      $(f subj.f)
    ?:  ?=(%| -.subject)  [%|^trace app]
    ?~  p.subject  [%&^~ app]
    %_  $
      s    u.p.subject
      f    next.f
      hit  [%7 u.hsubj u.hnext]^hit
    ==
  ::
      [%8 head=* next=*]
    =^  jax=body  app
      (jet head.f next.f)
    ?:  ?=(%| -.jax)  [%|^trace app]
    ?^  p.jax  [%& p.jax]^app
    =^  hhead=(unit phash)  app  (hash head.f)
    ?~  hhead  [%&^~ app]
    =^  hnext=(unit phash)  app  (hash next.f)
    ?~  hnext  [%&^~ app]
    =^  head=body  app
      $(f head.f)
    ?:  ?=(%| -.head)  [%|^trace app]
    ?~  p.head  [%&^~ app]
    %_  $
      s    [u.p.head s]
      f    next.f
      hit  [%8 u.hhead u.hnext]^hit
    ==
  ::
      [%9 axis=@ core=*]
    =^  hcore=(unit phash)  app  (hash core.f)
    ?~  hcore  [%&^~ app]
    =^  core=body  app
      $(f core.f)
    ?:  ?=(%| -.core)  [%|^trace app]
    ?~  p.core  [%&^~ app]
    =^  arm  bud
      (frag axis.f u.p.core bud)
    ?~  arm  [%&^~ app]
    ?~  u.arm  [%|^trace app]
    =^  harm=(unit phash)  app  (hash u.u.arm)
    ?~  harm  [%&^~ app]
    =^  hsibs=(unit (list phash))  app  (merk-sibs u.p.core axis.f)
    ?~  hsibs  [%&^~ app]
    %_  $
      s    u.p.core
      f    u.u.arm
      hit  [%9 axis.f u.hcore u.harm u.hsibs]^hit
    ==
  ::
      [%10 [axis=@ value=*] target=*]
    =^  hval=(unit phash)  app  (hash value.f)
    ?~  hval  [%&^~ app]
    =^  htar=(unit phash)  app  (hash target.f)
    ?~  htar  [%&^~ app]
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
    =^  holdleaf=(unit phash)  app  (hash u.u.oldleaf)
    ?~  holdleaf  [%&^~ app]
    =^  hsibs=(unit (list phash))  app  (merk-sibs u.p.target axis.f)
    ?~  hsibs  [%&^~ app]
    :-  [%& ~ u.u.mutant]
    app(hit [%10 axis.f u.hval u.htar u.holdleaf u.hsibs]^hit)
  ::
       [%11 tag=@ next=*]
    =^  next=body  app
      $(f next.f)
    :_  app
    ?:  ?=(%| -.next)  %|^trace
    ?~  p.next  %&^~
    :+  %&  ~
    .*  s
    [11 tag.f 1 u.p.next]
  ::
      [%11 [tag=@ clue=*] next=*]
    =^  clue=body  app
      $(f clue.f)
    ?:  ?=(%| -.clue)  [%|^trace app]
    ?~  p.clue  [%&^~ app]
    =^  next=body  app
      =?    trace
          ?=(?(%hunk %hand %lose %mean %spot) tag.f)
        [[tag.f u.p.clue] trace]
      $(f next.f)
    :_  app
    ?:  ?=(%| -.next)  %|^trace
    ?~  p.next  %&^~
    :+  %&  ~
    .*  s
    [11 [tag.f 1 u.p.clue] 1 u.p.next]
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
        %cain
      ?:  (lth bud 1)  %&^~
      =.  bud  (sub bud 1)
      =/  vax=(unit vase)
        ((soft vase) sam)
      ?~  vax  %|^trace
      %&^(some (sell u.vax))
    ==
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
    ^-  [(unit phash) appendix]
    =/  mh  (~(get by cax) n)
    ?^  mh  [mh app]
    ?@  n
      =/  h  (hash:pedersen n 0)
      ?:  (lth bud 1)  [~ app]
      =.  bud  (sub bud 1)
      [`h app(cax (~(put by cax) n h))]
    =^  hh=(unit phash)  app  $(n -.n)
    ?~  hh  [~ app]
    =^  ht=(unit phash)  app  $(n +.n)
    ?~  ht  [~ app]
    =/  h  (hash:pedersen u.hh u.ht)
    ?:  (lth bud 1)  [~ app]
    =.  bud  (sub bud 1)
    [`h app(cax (~(put by cax) n h))]
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
    |-  ^-  [(unit (list phash)) appendix]
    ?:  =(1 axis)
      [`path app]
    ?~  axis  !!
    ?@  s  !!
    =/  pick  (cap axis)
    =^  sibling=(unit phash)  app
      %-  hash
      ?-(pick %2 +.s, %3 -.s)
    ?~  sibling  [~ app]
    =/  child  ?-(pick %2 -.s, %3 +.s)
    %=  $
      s     child
      axis  (mas axis)
      path  [u.sibling path]
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
  ~&  %compiled
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
  =/  hs  (hash -.n ~)
  =/  hf  (hash +.n ~)
  %-  pairs:enjs:format
  :~  hints+(hints:enjs h)
      subject+s+(num:enjs hs)
      formula+s+(num:enjs hf)
  ==
::
++  hash
  |=  [n=* cax=(map * phash)]
  ^-  phash
  ?@  n
    ?:  (lte n 12)
      =/  ch  (~(get by cax) n)
      ?^  ch  u.ch
      (hash:pedersen n 0)
    (hash:pedersen n 0)
  ?^  ch=(~(get by cax) n)
    ~&  %cache-hit
    u.ch
  =/  hh  $(n -.n)
  =/  ht  $(n +.n)
  (hash:pedersen hh ht)
::
++  conq
  |%
  ::
  ::  To use this, pass in a vase of lib/zig/sys/hoon.hoon generated via:
  ::  (slap !>(~) (ream text-of-hoon))
  ::
  ++  layers
    ^-  (list @t)
    :~  '..add'
        '..biff'
        '..egcd'
        '..po'
    ==
  ::
  ++  all-arms-to-axes
    |=  vax=vase
    %-  ~(gas by *(map term @))
    %+  turn  (list-arms vax)
    |=  t=term
    [t (arm-axis vax t)]
  ::
  ++  list-arms
    |=  vax=vase
    ^-  (list term)
    (sloe p.vax)
  ::
  ++  arm-axis
    |=  [vax=vase arm=term]
    ^-  @
    =/  r  (~(find ut p.vax) %read ~[arm])
    ?>  ?=(%& -.r)
    ?>  ?=(%| -.q.p.r)
    p.q.p.r
  ::
  ++  hash-all-arms
    |=  [vax=vase cax=(map * phash)]
    ^-  (map * phash)
    =/  lis=(list term)  (list-arms vax)
    |-
    ?~  lis  cax
    =*  t  i.lis
    =/  a=@  (arm-axis vax t)
    ~&  [t a]
    =/  n  q:(slot a vax)
    $(lis t.lis, cax (~(put by cax) n (hash n cax)))
  ::
  ++  hash-arms-per-layer
    |=  [vax=vase layer=@t cax=(map * phash)]
    ^-  (map * phash)
    =/  cor  (slap vax (ream layer))
    (hash-all-arms cor cax)
  ::
  ++  main
    |=  hoonlib-txt=@t
    =/  hoonlib  (slap !>(~) (ream hoonlib-txt))
    =/  cax
      %-  ~(gas by *(map * phash))
      %+  turn  (gulf 0 12)
      |=  n=@
      ^-  [* phash]
      [n (hash n ~)]
    =/  l  layers
    |-
    ?~  l
      cax
    $(l t.l, cax (hash-arms-per-layer hoonlib i.l cax))
  --
--
