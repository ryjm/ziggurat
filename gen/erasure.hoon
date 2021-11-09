/-  galois
/+  erasure
=,  erasure
:-  %say
|=  [[* eny=@uv *] *]
=/  n  45

=/  msg  "Tlon, Uqbar, Orbis Tertius"
~&  >  "Message: {<msg>}"
=/  msg  `(list @)`msg

=/  nsym  (sub n (lent msg))
=/  encoded  (encode-data generate-field msg nsym)
=/  erased-indices  `(list @)`~[1 3 5 7 9 11]
=/  erased
=<  q
%^    spin
    erased-indices
  encoded
|=  [i=@ msg=(list @)]
[i (snap msg i 0)]
=/  corrected  (correct-data generate-field erased nsym erased-indices)
=/  decoded-message
%+  turn
  -.corrected
|=  i=@
`@tD`i
~&  >>  `tape`decoded-message
:-  %noun
"Original: {<encoded>}"^"Damaged: {<erased>}"^"Repaired: {<corrected>}"
