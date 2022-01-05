~%  %bink-lib  ..part  ~
|%
++  bink  !.
  ~/  %bink
  |=  $:  [subject=* formula=*]
          scry=$-(^ (unit (unit)))
      ==
  =|  trace=(list [@ta *])
  |^  ^-  tone
      ?+  formula  [%2 trace]
          [^ *]
        =/  head  $(formula -.formula)
        ?.  ?=(%0 -.head)  head
        =/  tail  $(formula +.formula)
        ?.  ?=(%0 -.tail)  tail
        [%0 product.head product.tail]
      ::
          [%0 axis=@]
        =/  part  (frag axis.formula subject)
        ?~  part  [%2 trace]
        [%0 u.part]
      ::
          [%1 constant=*]
        [%0 constant.formula]
      ::
          [%2 subject=* formula=*]
        =/  subject  $(formula subject.formula)
        ?.  ?=(%0 -.subject)  subject
        =/  formula  $(formula formula.formula)
        ?.  ?=(%0 -.formula)  formula
        %=  $
          subject  product.subject
          formula  product.formula
        ==
      ::
          [%3 argument=*]
        =/  argument  $(formula argument.formula)
        ?.  ?=(%0 -.argument)  argument
        [%0 .?(product.argument)]
      ::
          [%4 argument=*]
        =/  argument  $(formula argument.formula)
        ?.  ?=(%0 -.argument)  argument
        ?^  product.argument  [%2 trace]
        [%0 .+(product.argument)]
      ::
          [%5 a=* b=*]
        =/  a  $(formula a.formula)
        ?.  ?=(%0 -.a)  a
        =/  b  $(formula b.formula)
        ?.  ?=(%0 -.b)  b
        [%0 =(product.a product.b)]
      ::
          [%6 test=* yes=* no=*]
        =/  result  $(formula test.formula)
        ?.  ?=(%0 -.result)  result
        ?+  product.result
              [%2 trace]
          %&  $(formula yes.formula)
          %|  $(formula no.formula)
        ==
      ::
          [%7 subject=* next=*]
        =/  subject  $(formula subject.formula)
        ?.  ?=(%0 -.subject)  subject
        %=  $
          subject  product.subject
          formula  next.formula
        ==
      ::
          [%8 head=* next=*]
        =/  head  $(formula head.formula)
        ?.  ?=(%0 -.head)  head
        %=  $
          subject  [product.head subject]
          formula  next.formula
        ==
      ::
          [%9 axis=@ core=*]
        =/  core  $(formula core.formula)
        ?.  ?=(%0 -.core)  core
        =/  arm  (frag axis.formula product.core)
        ?~  arm  [%2 trace]
        %=  $
          subject  product.core
          formula  u.arm
        ==
      ::
          [%10 [axis=@ value=*] target=*]
        ?:  =(0 axis.formula)  [%2 trace]
        =/  target  $(formula target.formula)
        ?.  ?=(%0 -.target)  target
        =/  value  $(formula value.formula)
        ?.  ?=(%0 -.value)  value
        =/  mutant=(unit *)
          (edit axis.formula product.target product.value)
        ?~  mutant  [%2 trace]
        [%0 u.mutant]
      ::
          [%11 tag=@ next=*]
        =/  next  $(formula next.formula)
        ?.  ?=(%0 -.next)  next
        :-  %0
        .*  subject
        [11 tag.formula 1 product.next]
      ::
          [%11 [tag=@ clue=*] next=*]
        =/  clue  $(formula clue.formula)
        ?.  ?=(%0 -.clue)  clue
        =/  next
          =?    trace
              ?=(?(%hunk %hand %lose %mean %spot) tag.formula)
            [[tag.formula product.clue] trace]
          $(formula next.formula)
        ?.  ?=(%0 -.next)  next
        :-  %0
        .*  subject
        [11 [tag.formula 1 product.clue] 1 product.next]
      ::
          [%12 ref=* path=*]
        =/  ref  $(formula ref.formula)
        ?.  ?=(%0 -.ref)  ref
        =/  path  $(formula path.formula)
        ?.  ?=(%0 -.path)  path
        =/  result  (scry product.ref product.path)
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
