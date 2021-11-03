|%
++  epoch-interval    ~s30
++  blocks-per-epoch  100
::
+$  epoch   [=start=time num=@ud order=(list ship) =blocks]
+$  blocks  (list block)
+$  block   [num=@ud sig=signature data=(unit validated-chunks)]
::
+$  validated-chunks  [sig=signature chu=chunks]
+$  signature         [p=@ux q=ship r=life]
+$  chunks            (list chunk)
+$  chunk             ~
--
