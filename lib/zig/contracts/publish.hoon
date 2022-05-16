::  publish.hoon  [uqbar-dao]
::
::  Smart contract that processes deployment and upgrades
::  for other smart contracts. Automatically (?) inserted
::  on any town that wishes to allow contract production.
::
::  /+  *zig-sys-smart
|_  =cart
++  write
  |=  inp=zygote
  ^-  chick
  |^
  ?~  args.inp  !!
  (process (hole arguments u.args.inp) (pin caller.inp))
  ::
  +$  arguments
    $%  ::  add kelvin versioning to contracts?
        [%deploy mutable=? nok=* owns=(list rice)]
        [%upgrade to-upgrade=id new-nok=*]  ::  not yet real
    ==
  ::
  ++  process
    |=  [args=arguments caller-id=id]
    ?-    -.args
        %deploy
      ::  0x0 denotes immutable contract
      =/  lord=id  ?.(mutable.args 0x0 caller-id)
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
      [%& ~ (~(put by produced) our-id our-grain) ~]
    ::
        %upgrade
      ::  expect wheat of contract-to-upgrade in grains.input
      ::  caller must be lord and holder
      =/  contract  (~(got by grains.inp) to-upgrade.args)
      ?>  ?&  =(lord.contract caller-id)
              =(holder.contract caller-id)
              ?=(%| -.germ.contract)
          ==
      =.  cont.p.germ.contract  `new-nok.args
      [%& (malt ~[[id.contract contract]]) ~ ~]
    ==
  --
::
++  read
  |_  =path
  ++  json
    ~
  ++  noun
    ~
  --
--
