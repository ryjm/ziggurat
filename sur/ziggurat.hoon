/+  smart=zig-sys-smart
|%
++  epoch-interval  ~s10
++  relay-town-id   0
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
::
+$  chunks  (map town-id=@ud =chunk)
+$  chunk   [(list [@ux egg:smart]) town:smart]
::
+$  basket  (set egg:smart)  ::  mempool
::
::  runs a town
::
+$  hall  [council=(map ship [id:smart signature]) order=(list ship)]
::
+$  update
  $%  [%epochs-catchup =epochs]
      [%blocks-catchup epoch-num=@ud =slots]
      [%new-block epoch-num=@ud header=block-header =block]
      [%saw-block epoch-num=@ud header=block-header]
      [%indexer-block epoch-num=@ud header=block-header blk=(unit block)]
  ==
+$  sequencer-update
  $%  [%next-producer =ship]
      [%new-hall council=(map ship [id:smart signature])]
  ==
+$  chunk-update  [%new-chunk =town:smart]
::
+$  chain-poke
  $%  [%set-addr =id:smart]
      [%start mode=?(%indexer %validator) history=epochs validators=(set ship) starting-state=town:smart]
      [%stop gas=[rate=@ud bud=@ud]]
      [%new-epoch ~]
      [%receive-chunk town-id=@ud =chunk]
  ==
::
+$  weave-poke
  $%  [%forward eggs=(set egg:smart)]
      [%receive eggs=(set egg:smart)]
  ==
::
+$  hall-poke
  $%  ::  will remove starting-state for persistent testnet
      [%init town-id=@ud starting-state=(unit town:smart) gas=[rate=@ud bud=@ud]]
      [%join town-id=@ud gas=[rate=@ud bud=@ud]]
      [%exit gas=[rate=@ud bud=@ud]]
      [%clear-state ~]
  ==
--
