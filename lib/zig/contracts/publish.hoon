::  publish.hoon  [uqbar-dao]
::
::  Smart contract that processes deployment and upgrades
::  for other smart contracts. Automatically (?) inserted
::  on any town that wishes to allow contract production.
::  TODO totally untested
/+  *zig-sys-smart
|_  =cart
++  write
  |=  inp=zygote
  ^-  chick
  |^
  ?~  args.inp  !!
  (process (hole arguments u.args.inp) (pin caller.inp))
  ::
  +$  arguments
    $%  ::  TODO add kelvin versioning to contracts
        [%deploy mutable=? nok=* owns=(list rice)]
        [%upgrade to-upgrade=id new-nok=*]  ::  not yet real
    ==
  ::
  ++  process
    |=  [args=arguments caller-id=id]
    ?-    -.args
        %deploy
      ::  0x0 denotes immutable contract
      =/  lord=id  ?~(mutable.args 0x0 caller-id)
      =+  our-id=(fry-contract lord town-id.cart nok.args)
      ::  generate grains out of new rice we spawn
      =/  produced=(map id grain)
        %-  ~(gas by *(map id grain))
        %+  turn  owns.args
        |=  =rice
        ^-  [id grain]
        =+  (fry-rice our-id our-id town-id.cart salt.rice)
        [- [- our-id our-id town-id.cart [%& rice]]]
      ::
      =/  our-grain
        [our-id lord lord town-id.cart [%| `nok.args ~(key by produced)]]
      [%& ~ (~(put by produced) our-id our-grain)]
    ::
        %upgrade
      !!
    ==
  --
::
::  not currently used
::
++  read
  |=  inp=path
  ^-  *
  ~
::
++  event
  |=  inp=rooster
  ^-  chick
  *chick
--
