/+  *bink
:-  %say
|=  [^ [[subject=* formula=* bud=@ud ~] ~]]
:-  %noun
=/  read
  |.
  %i-was-read
=/  scry=(brie *)
  |=  [[ref=* path=*] @ud]
  ^-  [(unit (unit (unit *))) @ud]
  ?:  =(0 bud)
    [~ bud]
  =.  bud  (dec bud)
  =^  res=(unit (each @tas (list tank)))  bud
    (bull read ..$ bud)
  ?~  res  [~ bud]
  :_  bud
  ?-  -.u.res
    %&  ```p.u.res
    %|  ``~  ::  XX ??
  ==
(bink [subject formula] scry bud)
