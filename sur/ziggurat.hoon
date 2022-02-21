/+  smart=zig-sys-smart
|%
++  epoch-interval    ~s10
::
+$  epoch   [num=@ud =start=time order=(list ship) =slots]
::
+$  epochs  ((mop @ud epoch) gth)
++  poc     ((on @ud epoch) gth)
::
+$  block         (pair signature chunk)
+$  block-header  [num=@ud prev-header-hash=@uvH data-hash=@uvH]
+$  slot          (pair block-header (unit block))
::
+$  slots  ((mop @ud slot) gth)
++  sot    ((on @ud slot) gth)
::
+$  signature  [p=@ux q=ship r=life]
+$  chunk      [=town-id (list [hash=@ux =egg:smart]) town:smart]
::
+$  mempool   (set egg:smart)
::
+$  update
  $%  [%epochs-catchup =epochs]
      [%blocks-catchup epoch-num=@ud =slots]
      [%new-block epoch-num=@ud header=block-header =block]
      :: todo: add data availability data
      ::
      [%saw-block epoch-num=@ud header=block-header]
  ==
::
+$  action
  $%  [%start mode=?(%fisherman %validator) history=epochs validators=(set ship)]
      [%stop ~]
      [%new-epoch ~]
  ==
::
+$  mempool-action
  $%  [%receive tx=egg:smart]
      [%hear tx=egg:smart]
      [%forward-set to=ship txs=(set egg:smart)]
      [%receive-set txs=(set egg:smart)]
  ==
::
+$  chain-action
  $%  [%submit slotnum=@ud =block]
      [%receive-state =grain]
  ==
--
