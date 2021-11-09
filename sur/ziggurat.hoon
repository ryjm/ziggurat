|%
++  epoch-interval    ~s30
::
+$  epoch   [num=@ud =start=time order=(list ship) =blocks]
::
+$  epochs  ((mop @ud epoch) gth)
++  poc     ((on @ud epoch) gth)
::
+$  block-header  [num=@ud prev-header-hash=@uvH data-hash=@uvH]
+$  block-data    chunks
+$  block         (pair block-header (unit (pair signature block-data)))
::
+$  blocks  ((mop @ud block) gth)
++  bok     ((on @ud block) gth)
::
+$  signature  [p=@ux q=ship r=life]
+$  chunks     (list chunk)
+$  chunk      ~
::
+$  update
  $%  [%epochs-catchup =epochs]
      [%new-block epoch-num=@ud =block]
      :: todo: add data availability data
      ::
      [%saw-block epoch-num=@ud header=block-header]
  ==
::
+$  action
  $%  [%start mode=?(%fisherman %validator)]
      [%stop ~]
  ==
--
