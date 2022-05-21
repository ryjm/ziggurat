::  multisig.hoon  [uqbar-dao]
::
::  Smart contract to manage a simple multisig wallet.
::  New multisigs can be generated through the %create
::  argument, and are stored in account-controlled rice.
::
|_  =cart
++  write
  |=  inp=zygote
  ^-  chick
  |^
  ?~  args.inp  !!
  (process (hole arguments u.args.inp) (pin caller.inp))
  ::
  +$  arguments
    $%
      [%create-multisig init-thresh=@ud members=(set id)]  :: any id can call
      [%vote tx-hash=@ux]              :: can be called by anyone in members
      [%submit-tx =egg]                :: can be called by anyone in members
      [%add-member =id]                :: must be sent by contract
      [%remove-member =id]             :: must be sent by contract
      [%set-threshold new-thresh=@ud]  :: must be sent by contract
    ==
  ::
  +$  multisig-state
      $:  members=(set id)
          threshold=@ud
          pending=(map @ux [=egg votes=(set id)])
      ==
  ::
  ++  is-member
    |=  [=id state=multisig-state]
    ^-  ?
    (~(has in members.state) caller-id)
  ++  is-me
    |=  =id
    ^-  ?
    =(me.cart id)
  ++  process
    |=  [args=arguments caller-id=id]
    ?:  ?=(%create-multisig -.args)
      ::  issue a new multisig rice
      =/  new-sig-germ  [%& ~ [members.args init-thresh.args ~]]
      =/  new-sig-id  (fry caller-id 0 new-sig-germ) 
      =-  [%& ~ (malt ~[[new-sig-id -]]) ~]
      [new-sig-id me.cart me.cart town-id.cart new-sig-germ]
    =/  my-grain=grain  -:~(val by owns.cart)
    ?>  =(lord.my-grain me.cart)
    ?>  ?=(%& -.germ.my-grain)
    =/  state  (hole multisig-state data.p.germ.my-grain)
    ?:  ?=(%vote -.args)
      ::  should emit event triggering actual call
      ::  if this sig pushes it over thresh
      ::  validate member in multisig
      ?.  (is-member caller-id state)  !!
      ?~  prop=(~(get by pending.state) tx-hash.args)  !!
      =/  prop  u.prop(votes (~(put in votes.u.prop) caller-id))
      =.  pending.state  (~(put by pending.state) tx-hash.args prop)
      ::  check if proposal is at threshold, execute if so
      ::  otherwise simply update rice
      ::  TODO this doesn't seem exactly right anymore, since there is no event arm
      ?:  (gth threshold.state ~(wyt in votes.prop))
        =.  data.p.germ.my-grain  state
        [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
      =.  data.p.germ.my-grain
        state(pending (~(del by pending.state) tx-hash.args))
      ::  TODO:
      ::  if the pending egg is a multisig action, just
      ::  recurse with $
      ::  otherwise issue a hen chick with the call.
      :: [~ next=[to=me.cart town-id args=[me.cart ]] roost=rooster]
    =.  data.p.germ.my-grain
      ?+    -.args  !!
          %submit-tx
        ::  validate member in multisig
        ?.  (is-member caller-id state)  !!
        state(pending (~(put by pending.state) (mug egg.args) [egg.args (silt ~[caller-id])]))
      ::
          %add-member
        ::  this must be sent by contract
        ?.  (is-me caller-id)  !!
        state(members (~(put in members.state) id.args))
      ::
          %remove-member
        ::  this must be sent by contract
        ?.  (is-me caller-id)  !!
        state(members (~(del in members.state) id))
      ::
          %set-threshold
        ::  this must be sent by contract
        ?.  (is-me caller-id)  !!
        state(threshold new-thresh.args)
      ==
    [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
::
++  read
  |_  =path
    ++  json
      ~
    ++  noun
      ~
    --
--
