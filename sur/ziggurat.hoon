|%
++  epoch-interval    ~s30
++  blocks-per-epoch  100
::
+$  epoch   [=start=time num=@ud order=(list ship) =blocks]
::
+$  epochs  ((mop time epoch) gth)
++  poc     ((on time epoch) gth)
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
  $%  [%start-validating ~]
      [%stop-validating ~]
  ==
--
