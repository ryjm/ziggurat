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
+$  chunk      [helix-id=@ux [(list [hash=@ux =tx:tx]) state:tx]]
::
+$  mempools  (map @ux mempool) :: keyed by helix ID
+$  mempool   (set tx:tx)
::
+$  helices  (map @ux helix) :: keyed by helix ID
+$  helix
  $:  id=@ux
      =state:tx
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
      ::  who gets to form a new helix? vote/sigs from the existing relay set?
      ::  what helices are hard-coded into the relay chain?
      ::  [%new-helix validators=(set ship)]
  ==
::
+$  mempool-action
  $%  [%receive helix-id=@ux =tx:tx]
      [%hear helix-id=@ux =tx:tx]
      [%forward-set helix-id=@ux to=ship txs=(set tx:tx)]
      [%receive-set helix-id=@ux txs=(set tx:tx)]
  ==
::
+$  chunk-action
  $%  [%hear =chunk]
      [%signed helix-id=@ux =signature hash=@ux]
      [%submit sigs=(list signature) =chunk]
  ==
--
