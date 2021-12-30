/-  tx
|%
++  epoch-interval    ~s10
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
+$  chunks     (list @)
+$  chunk      [(list [hash=@ux =tx:tx]) state:tx]
+$  mempool    (set tx:tx)
::
+$  helix
  $:  =state:tx
      order=(list ship)
      leader=ship
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
::  can fold these into action possibly
+$  mempool-action
  $%  [%receive =tx:tx]
      [%hear =tx:tx]
      [%forward-set to=ship txs=(set tx:tx)]
      [%receive-set txs=(set tx:tx)]
  ==
::
+$  chunk-action
  $%  [%hear =chunk]
      [%signed =signature hash=@ux]
      [%submit sigs=(list signature) =chunk]
  ==
--
