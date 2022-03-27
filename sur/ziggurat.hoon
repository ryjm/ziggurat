/+  smart=zig-sys-smart
|%
++  epoch-interval  ~s30
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
      ::  todo: add data availability data
      ::
      [%saw-block epoch-num=@ud header=block-header]
  ==
+$  sequencer-update
  $%  [%next-producer =ship]
      [%new-hall council=(map ship [id:smart signature])]
  ==
+$  chunk-update  [%new-chunk =town:smart]
::
+$  chain-poke
  $%  [%key =account:smart]
      [%start mode=?(%fisherman %validator) history=epochs validators=(set ship) starting-state=town:smart]
      [%stop ~]
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
::
+$  wallet-poke
  $%  [%set-keys seed=@]
      [%set-zigs town=@ud addr=id:smart]
      $:  %submit  sequencer=ship
          to=id:smart  town=@ud
          gas=[rate=@ud bud=@ud]  args=(unit *) 
          my-grains=(set @ux)  cont-grains=(set @ux)
      ==
  ==
--
