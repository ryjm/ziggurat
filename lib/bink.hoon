~%  %bink-lib  ..part  ~
|%
+$  bone  [$@(~ tone) rem=@ud]                            ::  bounded $tone
::                                                        ::
+$  brie  $-([^ @ud] [(unit (unit (unit))) @ud])          ::  bounded scry
::                                                        ::
++  bink                                                  ::  bounded +mink
  ~/  %bink
  |=  $:  [subject=* formula=*]
          scry=brie
          bud=@ud                                         ::  gas budget
      ==
  ::  ~>  %bout                                           ::  XX remove: timing
  =|  trace=(list [@ta *])
  |^
  ?~  formula-cost=(cost formula bud)
    [~ 0]
  =/  cos=@ud  u.formula-cost
  ?:  (lth bud cos)  [~ bud]
  =.  bud  (sub bud cos)
  |-
  ^-  bone
  ?+  formula  [%2 trace]^bud
      [^ *]
    =.  cos  1
    ?:  (lth bud cos)  [~ bud]
    =.  bud  (sub bud cos)
    =^  head  bud
      $(formula -.formula)
    ?~  head  [~ bud]
    ?.  ?=(%0 -.head)  head^bud
    =^  tail  bud
      $(formula +.formula)
    ?~  tail  [~ bud]
    ?.  ?=(%0 -.tail)  tail^bud
    [%0 product.head product.tail]^bud
  ::
      [%0 axis=@]
    =.  cos  1
    ?:  (lth bud cos)  [~ bud]
    =.  bud  (sub bud cos)
    =^  part  bud
      (frag axis.formula subject bud)
    ?~  part  [~ bud]
    ?~  u.part  [%2 trace]^bud
    [%0 u.u.part]^bud
  ::
      [%1 constant=*]
    =.  cos  1
    ?:  (lth bud cos)  [~ bud]
    =.  bud  (sub bud cos)
    [%0 constant.formula]^bud
  ::
      [%2 subject=* formula=*]
    =.  cos  1
    ?:  (lth bud cos)  [~ bud]
    =.  bud  (sub bud cos)
    =^  subject  bud
      $(formula subject.formula)
    ?~  subject  [~ bud]
    ?.  ?=(%0 -.subject)  subject^bud
    =^  formula  bud
      $(formula formula.formula)
    ?~  formula  [~ bud]
    ?.  ?=(%0 -.formula)  formula^bud
    %=  $
      subject  product.subject
      formula  product.formula
    ==
  ::
      [%3 argument=*]
    =.  cos  1
    ?:  (lth bud cos)  [~ bud]
    =.  bud  (sub bud cos)
    =^  argument  bud
      $(formula argument.formula)
    :_  bud
    ?~  argument  ~
    ?.  ?=(%0 -.argument)  argument
    [%0 .?(product.argument)]
  ::
      [%4 argument=*]
    =.  cos  1
    ?:  (lth bud cos)  [~ bud]
    =.  bud  (sub bud cos)
    =^  argument  bud
      $(formula argument.formula)
    ?~  argument  [~ bud]
    ?.  ?=(%0 -.argument)  argument^bud
    ?^  product.argument  [%2 trace]^bud
    ::  XX maybe we need a cache of computed gas costs
    =.  cos  %+  sub  (pat:cost +(product.argument))
                      (pat:cost product.argument)
    ?:  (lth bud cos)  [~ bud]
    :_  (sub bud cos)
    [%0 .+(product.argument)]
  ::
      [%5 a=* b=*]
    =.  cos  1
    ?:  (lth bud cos)  [~ bud]
    =.  bud  (sub bud cos)
    =^  a  bud
      $(formula a.formula)
    ?~  a  [~ bud]
    ?.  ?=(%0 -.a)  a^bud
    =^  b  bud
      $(formula b.formula)
    :_  bud
    ?~  b  ~
    ?.  ?=(%0 -.b)  b
    [%0 =(product.a product.b)]
  ::
      [%6 test=* yes=* no=*]
    =.  cos  1
    ?:  (lth bud cos)  [~ bud]
    =.  bud  (sub bud cos)
    =^  result  bud
      $(formula test.formula)
    ?~  result  [~ bud]
    ?.  ?=(%0 -.result)  result^bud
    ?+  product.result  [%2 trace]^bud
      %&  $(formula yes.formula)
      %|  $(formula no.formula)
    ==
  ::
      [%7 subject=* next=*]
    =.  cos  1
    ?:  (lth bud cos)  [~ bud]
    =.  bud  (sub bud cos)
    =^  subject  bud
      $(formula subject.formula)
    ?~  subject  [~ bud]
    ?.  ?=(%0 -.subject)  subject^bud
    %=  $
      subject  product.subject
      formula  next.formula
    ==
  ::
      [%8 head=* next=*]
    =.  cos  1
    ?:  (lth bud cos)  [~ bud]
    =.  bud  (sub bud cos)
    =^  head  bud
      $(formula head.formula)
    ?~  head  [~ bud]
    ?.  ?=(%0 -.head)  head^bud
    %=  $
      subject  [product.head subject]
      formula  next.formula
    ==
  ::
      [%9 axis=@ core=*]
    =.  cos  1
    ?:  (lth bud cos)  [~ bud]
    =.  bud  (sub bud cos)
    =^  core  bud
      $(formula core.formula)
    ?~  core  [~ bud]
    ?.  ?=(%0 -.core)  core^bud
    =^  arm  bud
      (frag axis.formula product.core bud)
    ?~  arm  [~ bud]
    ?~  u.arm  [%2 trace]^bud
    %=  $
      subject  product.core
      formula  u.u.arm
    ==
  ::
      [%10 [axis=@ value=*] target=*]
    =.  cos  1
    ?:  (lth bud cos)  [~ bud]
    =.  bud  (sub bud cos)
    ?:  =(0 axis.formula)  [%2 trace]^bud
    =^  target  bud
      $(formula target.formula)
    ?~  target  [~ bud]
    ?.  ?=(%0 -.target)  target^bud
    =^  value  bud
      $(formula value.formula)
    ?~  value  [~ bud]
    ?.  ?=(%0 -.value)  value^bud
    =^  mutant=(unit (unit *))  bud
      (edit axis.formula product.target product.value bud)
    :_  bud
    ?~  mutant  ~
    ?~  u.mutant  [%2 trace]
    [%0 u.u.mutant]
  ::
      [%11 [tag=@ clue=*] next=*]
    ::  XX change gas cost if jet changes atom size
    =.  cos  1
    ?:  (lth bud cos)  [~ bud]
    =.  bud  (sub bud cos)
    ::?.  (~(has in tags) tag.formula)
      ::  TODO: put something in the trace
    ::  [%2 trace]^bud
    =^  clue  bud
      $(formula clue.formula)
    ?~  clue  [~ bud]
    ?.  ?=(%0 -.clue)  clue^bud
    =?    trace
        ?=(?(%hunk %hand %lose %mean %spot) tag.formula)
      [[tag.formula product.clue] trace]
    =^  next  bud
      $(formula next.formula)
    :_  bud
    ?~  next  ~
    ?.  ?=(%0 -.next)  next
::    ?.  ?|  !=(%fast tag.formula)
::            ?&  ?=([@ *] product.clue)
::                (~(has in wits) -.product.clue)
::        ==  ==
::      [%2 trace]
    :-  %0
    .*  subject
    [11 [tag.formula 1 product.clue] 1 product.next]
  ::
  ::  [%11 tag=@ next=*]
  ::
      [%12 ref=* path=*]
    =^  ref  bud
      $(formula ref.formula)
    ?~  ref  [~ bud]
    ?.  ?=(%0 -.ref)  ref^bud
    =^  path  bud
      $(formula path.formula)
    ?~  path  [~ bud]
    ?.  ?=(%0 -.path)  path^bud
    =^  result  bud
      (scry [product.ref product.path] bud)
    ?~  result  [~ bud]
    ?~  u.result
      [%1 product.path]^bud
    ?~  u.u.result
      [%2 [%hunk product.ref product.path] trace]^bud
    [%0 u.u.u.result]^bud
  ::
  ==
  ::
  ++  cost                                                ::  gas cost of noun
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
  ::
  ++  wits
    ^-  (set @tas)
    %-  ~(gas in *(set @tas))
    :~  %'a.50'                                           ::  XX tiny top-level
        %add    %apt    %bex  %by     %cad
        %can    %cat    %con  %cut    %dec
        %del    %dis    %div  %dor    %dvr
        %end    %flop   %get  %gor    %gte
        %gth    %has    %in   %lent   %lsh
        %lte    %lth    %met  %mix    %mod
        %mor    %mug    %mul  %on     %por
        %put    %reap   %rep  %rip    %rsh
        %slag   %snag   %sub  %swp    %welp
    ==
  ::
  ++  tags
    ^-  (set @tas)
    (~(gas in *(set @tas)) ~[%fast %mean %spot])
  --
::                                                        ::
++  bock                                                  ::  bounded +mock
  |=  [[sub=* fol=*] gul=brie bud=@ud]
  ^-  [(unit toon) @ud]
  =/  =bone  (bink [sub fol] gul bud)
  :_  rem.bone
  ?~  -.bone  ~
  `(mook -.bone)
::                                                        ::
++  brute                                                 ::  bounded +mute
  |=  [tap=(trap) scry=brie bud=@ud]
  ^-  [(unit (each * (list tank))) @ud]
  =+  [ton rem]=(bock [tap %9 2 %0 1] scry bud)
  :_  rem
  ?~  ton  ~
  :-  ~
  ?-  -.u.ton
    %0  [%& p.u.ton]
  ::
    %1  =/  sof=(unit path)  ((soft path) p.u.ton)
        [%| ?~(sof leaf+"brute.hunk" (smyt u.sof)) ~]
  ::
    %2  [%| p.u.ton]
  ==
::                                                        ::
++  bull                                                  ::  bounded +mule
  |*  [tap=(trap) bud=@ud]
  =+  [mud rem]=(brute tap bud)
  :_  rem
  ?~  mud  ~
  ?:  =(%| -.u.mud)
    ?>  ?=(%| -.u.mud)
    `[%| p=p.u.mud]
  =/  res  $:tap
  ^-  (unit (each _res (list tank)))
  ?>  ?=(%& -.u.mud)
  `[%& res]
--
