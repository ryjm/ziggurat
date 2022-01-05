~%  %bink-lib  ..part  ~
|%
::                                                        ::
+$  bone                                                  ::  bounded tone
  $:  $@(~ tone)
      rem=@
  ==
::                                                        ::
++  gas-cost-atom
  |=  a=@
  (met 8 a)
::                                                        ::
++  gas-cost-cell
  |=  [a=* b=*]
  :(add 1 (gas-cost-noun a) (gas-cost-noun b))
::                                                        ::
++  gas-cost-noun
  |=  a=*
  ?@  a
    (gas-cost-atom a)
  (gas-cost-cell a)
::                                                        ::
++  bink
  ~/  %bink
  |=  $:  [subject=* formula=*]
          bud=@ud
          scry=$-(^ (unit (unit)))
      ==
  =|  trace=(list [@ta *])
  |^
  =/  cos  (gas-cost-noun [subject formula])
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
    =/  part  (frag axis.formula subject)
    ?~  part  [%2 trace]^bud
    [%0 u.part]^bud
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
    ::  XX change cos if atom size changes?
    =.  cos  1
    ?:  (lth bud cos)  [~ bud]
    =.  bud  (sub bud cos)
    =^  argument  bud
      $(formula argument.formula)
    :_  bud
    ?~  argument  ~
    ?.  ?=(%0 -.argument)  argument
    ?^  product.argument  [%2 trace]
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
    =/  arm  (frag axis.formula product.core)
    ?~  arm  [%2 trace]^bud
    %=  $
      subject  product.core
      formula  u.arm
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
    =/  mutant=(unit *)
      (edit axis.formula product.target product.value)
    :_  bud
    ?~  mutant  [%2 trace]
    [%0 u.mutant]
  ::
      [%11 tag=@ next=*]
    =.  cos  1
    ?:  (lth bud cos)  [~ bud]
    =.  bud  (sub bud cos)
    =^  next  bud
      $(formula next.formula)
    :_  bud
    ?~  next  ~
    ?.  ?=(%0 -.next)  next
    :-  %0
    .*  subject   ::  XX run through bink?
    [11 tag.formula 1 product.next]
  ::
      [%11 [tag=@ clue=*] next=*]
    =.  cos  1
    ?:  (lth bud cos)  [~ bud]
    =.  bud  (sub bud cos)
    =^  clue  bud
      $(formula clue.formula)
    ?~  clue  [~ bud]
    ?.  ?=(%0 -.clue)  clue^bud
    =^  next  bud
      =?    trace
          ?=(?(%hunk %hand %lose %mean %spot) tag.formula)
        [[tag.formula product.clue] trace]
      $(formula next.formula)
    :_  bud
    ?~  next  ~
    ?.  ?=(%0 -.next)  next
    :-  %0
    .*  subject
    [11 [tag.formula 1 product.clue] 1 product.next]
  ::
      [%12 ref=* path=*]
    =.  cos  1
    ?:  (lth bud cos)  [~ bud]
    =.  bud  (sub bud cos)
    =^  ref  bud
      $(formula ref.formula)
    ?~  ref  [~ bud]
    ?.  ?=(%0 -.ref)  ref^bud
    =^  path  bud
      $(formula path.formula)
    ?~  path  [~ bud]
    ?.  ?=(%0 -.path)  path^bud
    =/  result  (scry product.ref product.path)
    :_  bud
    ?~  result
      [%1 product.path]
    ?~  u.result
      [%2 [%hunk product.ref product.path] trace]
    [%0 u.u.result]
  ==
  ::
  ++  frag
    |=  [axis=@ noun=*]
    ^-  (unit)
    ?:  =(0 axis)  ~
    |-  ^-  (unit)
    ?:  =(1 axis)  `noun
    ?@  noun  ~
    =/  pick  (cap axis)
    %=  $
      axis  (mas axis)
      noun  ?-(pick %2 -.noun, %3 +.noun)
    ==
  ::
  ++  edit
    |=  [axis=@ target=* value=*]
    ^-  (unit)
    ?:  =(1 axis)  `value
    ?@  target  ~
    =/  pick  (cap axis)
    =/  mutant
      %=  $
        axis    (mas axis)
        target  ?-(pick %2 -.target, %3 +.target)
      ==
    ?~  mutant  ~
    ?-  pick
      %2  `[u.mutant +.target]
      %3  `[-.target u.mutant]
    ==
  --
--
