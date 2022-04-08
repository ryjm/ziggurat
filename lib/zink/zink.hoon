/-  *zink
/+  *zock-pedersen, *zink-json
|_  cax=(map * phash)
::
++  zink
  |_  hit=hints
  ++  update
    |=  [s=* f=* bud=@]
    ^-  [[(unit *) @] hints (map * phash)]
    =/  evaluated
      (eval s f bud)
    [evaluated hit cax]
  ::
  ++  eval
    |=  [s=* f=* bud=@]
    ^-  [(unit *) @]  ::  TODO: must return trace on crash
    =^  sroot  cax  (hash s)
    =^  froot  cax  (hash f)
    =|  trace=(list [@ta *])
    |^
    ?~  formula-cost=(cost f bud)
      [~ 0]
    =/  cos=@ud  u.formula-cost
    ?:  (lth bud cos)  [~ bud]
    =.  bud  (sub bud cos)
    |-
    ?+    f  !!
    ::  formula is a cell; do distribution
    ::
        [^ *]
      =*  f1  -.f
      =*  f2  +.f
      =.  cos  1
      ?:  (lth bud cos)  [~ bud]
      =.  bud  (sub bud cos)
      =^  hed  bud
        (eval s f1 bud)
      =^  tal  bud
        (eval s f2 bud)
      =^  hf1  cax  (hash f1)
      =^  hf2  cax  (hash f2)
      =.  hit  (put-hint [%cons hf1 hf2])
      [~ hed^tal]^bud
    ::
        [%0 axis=@]
      =/  res  .*(s f)  ::  TODO: is this safe?
      =^  hres  cax  (hash res)
      =^  sibs  cax  (merk-sibs s axis.f)
      =.  hit  (put-hint [%0 axis.f hres sibs])
      [~ res]^bud
    ::
        [%1 const=*]
      =^  hres  cax  (hash const.f)
      =.  hit  (put-hint [%1 hres])
      [~ const.f]^bud
    ::
        [%2 sub=* for=*]
      =^  hsub  cax  (hash sub.f)
      =^  hfor  cax  (hash for.f)
      =^  subject=(unit *)  bud
        $(f sub.f)
      ?~  subject  [~ bud]
      ::  TODO: need to add a check to ensure no crash
      =^  formula=(unit *)  bud
        $(f for.f)
      ?~  formula  [~ bud]
      ::  TODO: need to add a check to ensure no crash
      =.  hit  (put-hint [%2 hsub hfor])
      $(s u.subject, f u.formula)
    ::
        [%3 arg=*]
      =^  argument=(unit *)  bud
        $(f arg.f)
      =^  harg  cax  (hash arg.f)
      ?~  argument  [~ bud]
      ?@  u.argument
        =.  hit  (put-hint [%3 harg %atom u.argument])
        [~ %.n]^bud
      =^  hhash  cax  (hash -.u.argument)
      =^  thash  cax  (hash +.u.argument)
      =.  hit  (put-hint [%3 harg %cell hhash thash])
      [~ %.y]^bud
    ::
        [%4 arg=*]
      =^  argument=(unit *)  bud
        $(f arg.f)
      =^  harg  cax  (hash arg.f)
      ?~  argument  [~ bud]
      ?>  ?=(@ u.argument)  ::  TODO: safely return trace
      =.  hit  (put-hint [%4 harg u.argument])
      [~ .+(u.argument)]^bud
    ::
        [%5 a=* b=*]
      =^  ha  cax  (hash a.f)
      =^  hb  cax  (hash b.f)
      =^  a=(unit *)  bud
        $(f a.f)
      ?~  a  [~ bud]
      =^  b=(unit *)  bud
        $(f b.f)
      ?~  b  [~ bud]
      =.  hit  (put-hint [%5 ha hb])
      [~ =(u.a u.b)]^bud
    ::
        [%6 test=* yes=* no=*]
      =^  htest  cax  (hash test.f)
      =^  hyes  cax  (hash yes.f)
      =^  hno  cax  (hash no.f)
      =^  test=(unit *)  bud
        $(f test.f)
      ?~  test  [~ bud]
      =.  hit  (put-hint [%6 htest hyes hno])
      ?+  u.test  !!  ::  TODO: safely do trace
        %&  $(f yes.f)
        %|  $(f no.f)
      ==
    ::
        [%7 subj=* next=*]
      =^  hsubj  cax  (hash subj.f)
      =^  hnext  cax  (hash next.f)
      =^  subject=(unit *)  bud
        $(s subj.f)
      ?~  subject  [~ bud]
      ::  TODO: check if crash here and do trace
      =.  hit  (put-hint [%7 hsubj hnext])
      $(s u.subject, f next.f)
    ::
        [%8 head=* next=*]
      =^  hhead  cax  (hash head.f)
      =^  hnext  cax  (hash next.f)
      =^  head=(unit *)  bud
        $(f head.f)
      ?~  head  [~ bud]
      ::  TODO: check if head crashes
      =.  hit  (put-hint [%8 hhead hnext])
      $(s [u.head s], f next.f)
    ::
        [%9 axis=@ core=*]
      =^  hcore  cax  (hash core.f)
      =^  core=(unit *)  bud
        $(f core.f)
      ?~  core  [~ bud]
      ::  TODO: check if core crashed
      =^  arm=(unit *)  bud
        $(s u.core, f [0 axis.f])
      ?~  arm  [~ bud]
      ::  TODO: check if arm crashed
      =^  harm  cax  (hash u.arm)
      =^  sibs  cax  (merk-sibs u.core axis.f)
      =.  hit   (put-hint [%9 axis.f hcore harm sibs])
      $(s u.core, f u.arm)
    ::
        [%10 [axis=@ value=*] target=*]
      =^  hval  cax  (hash value.f)
      =^  htar  cax  (hash target.f)
      =^  newleaf=(unit *)  bud  ::  TODO: not even used wtf?
        $(f value.f)
      ?~  newleaf  [~ bud]
      =^  oldtree=(unit *)  bud
        $(f target.f)
      ?~  oldtree  [~ bud]
      =/  res  .*(s f)  ::  TODO: not safe wtf?
      =^  oldleaf=(unit *)  bud
        $(s u.oldtree, f [%0 axis])
      ?~  oldleaf  [~ bud]
      =^  holdleaf  cax  (hash u.oldleaf)
      =^  sibs  cax  (merk-sibs u.oldtree axis.f)
      =.  hit  (put-hint [%10 axis.f hval htar holdleaf sibs])
      [~ res]^bud
    ::
        [%11 *]
      ::  todo: needs a redo
      (eval s +>.f bud)
    ==
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
    ::
    ++  put-hint
      |=  hin=cairo-hint
      ^-  hints
      =/  inner=(map phash cairo-hint)
        (~(gut by hit) sroot ~)
      %+  ~(put by hit)
        sroot
      (~(put by inner) froot hin)
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
  ::  hash:
  ::  if x is an atom then hash(x)=h(x, 0)
  ::  else hash([x y])=h(h(x), h(y))
  ::  where h = pedersen hash
  ++  hash
    |=  n=*
    ^-  [phash (map * phash)]
    =/  mh  (~(get by cax) n)
    ?.  ?=(~ mh)
      [u.mh cax]
    ?@  n
      =/  h  (hash:pedersen n 0)
      [h (~(put by cax) n h)]
    =^  hh  cax  $(n -.n)
    =^  ht  cax  $(n +.n)
    =/  h  (hash:pedersen hh ht)
    [h (~(put by cax) n h)]
  --
 ::  build-hoon: compile a hoon file and print out the nock.
 ::
 ++  build-hoon
   |=  [file=path]
   ^-  [@ @ (map * phash)]
   =/  src  .^(@t %cx file)
   =/  nock  (slap !>(~) (ream src))
   ~&  >  nock
   [0 0 cax]
::  hash-noun:  pederson hash noun
::
 ++  hash-noun
   |=  n=*
   ^-  [phash (map * phash)]
   (~(hash zink ~) n)
::  eval-noun: evaluate nock with zink
::
++  eval-noun
  |=  [n=(pair) bud=@]
  ^-  [* @t (map * phash)]
  =/  [[res=(unit *) bud=@] h=hints c=(map * phash)]
    (~(update zink ~) p.n q.n bud)
  =-  [res (crip (en-json:html js)) cache]
  (create-hints n h)
::  eval-hoon: compile a hoon file and evaluate it with zink
::
++  eval-hoon
  |=  [lib=path file=path arm=@tas sample=@t bud=@]
  ^-  [* @t (map * phash)]
  =/  clib
    ?~  lib  !>(~)
    =/  libsrc  .^(@t %cx lib)
    (slap !>(~) (ream libsrc))
  =/  src  .^(@t %cx file)
  =/  cs  (slap clib (ream src))
  =/  nock  [q.cs q:(~(mint ut p.cs) %noun (make-hoon arm sample))]
  (eval-noun nock bud)
::  make-hoon: create hoon AST to call core
::
++  make-hoon
  |=  [arm=@tas sample=@t]
  ^-  hoon
  [%cncl [%wing ~[arm]] ~[(ream sample)]]
::  create-hints: create full hint json
::
++  create-hints
  |=  [n=^ h=hints]
  ^-  [js=json cache=(map * phash)]
  =^  hs  cax  (~(hash zink h) -.n)
  =^  hf  cax  (~(hash zink h) +.n)
  :_  cax
  %-  pairs:enjs:format
  :~  ['subject' s+(num:enjs hs)]
      ['formula' s+(num:enjs hf)]
      ['hints' (all:enjs h)]
  ==
--
