|%
++  epoch-interval    ~s30
::
+$  epoch   [num=@ud =start=time order=(list ship) =blocks]
::
+$  epochs  ((mop @ud epoch) gth)
++  poc     ((on @ud epoch) gth)
::
+$  block   [num=@ud data=(unit (pair signature chunks))]
::
+$  blocks  ((mop @ud block) gth)
++  bok     ((on @ud block) gth)
::
+$  signature         [p=@ux q=ship r=life]
+$  chunks            (list chunk)
+$  chunk             ~
::
+$  update
  $%  [%epochs-catchup =epochs]
      [%new-block epoch-num=@ud =block]
  ==
::
+$  action
  $%  [%start-epoch ~]
  ==
--
