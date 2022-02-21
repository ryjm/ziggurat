/+  *zig-sys-smart
|_  =cart
++  write
  |=  inp=zygote
  ^-  chick
  ?~  args.inp  !!
  =*  args  +.u.args.inp
  ?.  ?=(%publish -.u.args.inp)
    !!
  ::  expected args: lord=id, contract=*, (list rice)
  ::  need to determine good way to submit list of something..
  ::  i mean, the contract can just fail if given bad inputs
  =*  lord  ;;(id -.args)
  =/  cont  ;;(contract -.+.args)
  =*  rices  +.args
  =/  contract-id
    (fry lord town-id.cart [%| `cont ~])
  =/  owns-map
    %-  ~(gas by *(map id grain))
    ^-  (list [id grain])
    |-
    ?~  rices  ~
    =/  me  [contract-id contract-id town-id.cart [%& ;;(rice -.rices)]]
    =/  my-id  (fry contract-id town-id.cart [%& ;;(rice -.rices)])
    :-  i=[my-id [my-id me]]
    t=$(rices +.rices)
  =/  contract-grain
    [contract-id lord lord town-id.cart [%| `cont ~(key by owns-map)]]
  :+  %&  ~
  (~(put by owns-map) contract-id contract-grain)
::
++  read
  |=  inp=path
  ^-  *
  "TBD"
::
++  event
  |=  inp=rooster
  ^-  chick
  :: TBD
  !!
--
