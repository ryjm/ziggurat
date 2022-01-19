/+  *bink, tiny
|%
::
+$  args
  $%  [%read num=@ud]
      [%write s=(set @ud)]
  ==
::
++  blue
  |=  [for=hoon tiny-hoon=hoon =args bud=@ud]
  =.  for
    ?:  ?=(%read -.args)
      [%tsgr for [%wing ~[%read]]]
    [%tsgr for [%wing ~[%write]]]
  =/  tiny-nock
    q:(~(mint ut %noun) %noun tiny-hoon)
  =/  gat
    q:(~(mint ut -:!>(tiny)) %noun for)
  =/  sam
    ?:  ?=(%read -.args)
      num.args
    s.args
  (bock [tiny-nock [%9 2 %10 [6 %1 sam] gat]] 1.000.000)
--
