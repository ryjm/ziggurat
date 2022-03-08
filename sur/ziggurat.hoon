/+  smart=zig-sys-smart
|%
++  epoch-interval    ~s40
::
+$  epoch   [num=@ud =start=time order=(list ship) =slots]
::
+$  epochs  ((mop @ud epoch) gth)
++  poc     ((on @ud epoch) gth)
::
+$  block         (pair signature chunks)
+$  block-header  [num=@ud prev-header-hash=@uvH data-hash=@uvH]
+$  slot          (pair block-header (unit block))
::
+$  slots  ((mop @ud slot) gth)
++  sot    ((on @ud slot) gth)
::
+$  signature   [p=@ux q=ship r=life]
+$  chunks      (list chunk)
+$  chunk       [txs=(list [@ux egg:smart]) =town:smart]
+$  chain-hall  [council=(set ship) is-open=?]
::
+$  update
  $%  [%epochs-catchup =epochs]
      [%blocks-catchup epoch-num=@ud =slots]
      [%new-block epoch-num=@ud header=block-header =block]
      [%hall-update id=@ud =chain-hall]
      :: todo: add data availability data
      ::
      [%saw-block epoch-num=@ud header=block-header]
  ==
::
+$  action
  $%  [%start mode=?(%fisherman %validator) history=epochs validators=(set ship)]
      [%stop ~]
      [%new-epoch ~]
      [%receive-chunk =chunk]
      ::  [%new-hall id=@ud =chain-hall]
      ::  [%add-to-hall id=@ud]
      ::  [%remove-from-hall id=@ud]
  ==
--
