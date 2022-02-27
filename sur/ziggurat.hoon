/+  smart=zig-sys-smart
|%
++  epoch-interval  ~s10
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
+$  signature  [p=@ux q=ship r=life]
+$  chunks     (set chunk)
+$  chunk      [town-id=@ud (list [hash=@ux =egg:smart]) town:smart]
::
+$  basket   (set egg:smart)  ::  mempool
::
+$  hall  ::  runs a town
  $:  id=@ud
      blocknum=@ud
      council=(set ship)
      order=(list ship)
      chair=@ud  :: position of leader in order
  ==
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
+$  basket-action
  $%  [%receive egg=egg:smart]
      [%hear egg=egg:smart]
      [%forward-set to=ship eggs=(set egg:smart)]
      [%receive-set eggs=(set egg:smart)]
  ==
::
+$  chain-action
  $%  [%submit slotnum=@ud =block]
      [%init-town id=@ud]
      [%leave-town ~]
      [%receive-state =grain:smart]
  ==
+$  chunk-action
  $%  [%receive =chunk]
  ==
--
