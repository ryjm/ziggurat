::  multisig.hoon  [uqbar-dao]
::
::  Smart contract to manage a simple multisig wallet.
::  New multisigs can be generated through the %create
::  argument, and are stored in account-controlled rice.
::
::/+  *zig-sys-smart
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
    (~(has in members.state) id)
  ++  is-me
    |=  =id
    ^-  ?
    =(me.cart id)
  ++  shamspin
    |=  ids=(list id)
    ^-  @uvH
    =<  q
    %^  spin  ids
      0v0
    |=  [=id hash=@uvH]
    :_  (sham (cat 3 (sham id) hash))
    ~
  ++  process
    |=  [args=arguments caller-id=id]
    ^-  chick
    ?:  ?=(%create-multisig -.args)
      ::  issue a new multisig rice
      =/  new-sig-germ  [%& ~ [members.args init-thresh.args ~]]
      =/  salt=@  
        =-  (sham (cat 3 caller-id -))
        (shamspin ~(tap in members.args))
      =/  new-sig-id=id  (fry-rice caller-id me.cart town-id.cart salt)
      =-  [%& ~ (malt ~[[new-sig-id -]]) ~]
      [new-sig-id me.cart me.cart town-id.cart new-sig-germ]
    =/  my-grain=grain  -:~(val by owns.cart)
    ?>  =(lord.my-grain me.cart)
    ?>  ?=(%& -.germ.my-grain)
    =/  state  (hole multisig-state data.p.germ.my-grain)
    ::  N.B. because no type assert has been made, 
    ::  data.p.germ.my-grain is basically * and thus has no type checking done
    ?-    -.args
        %vote
      ::  should emit event triggering actual call
      ::  if this sig pushes it over thresh
      ::  validate member in multisig
      ?.  (is-member caller-id state)  !!
      ?~  prop=(~(get by pending.state) tx-hash.args)  !!
      =/  prop  u.prop(votes (~(put in votes.u.prop) caller-id))
      =.  pending.state  (~(put by pending.state) tx-hash.args prop)
      ::  check if proposal is at threshold, execute if so
      ::  otherwise simply update rice
      ::  TODO this doesn't seem right. (also there is no event arm (?))
      ?:  (gth threshold.state ~(wyt in votes.prop))
        ::  TODO:
        ::  exec tx.
        ::  if the pending egg is a multisig action, just
        ::  recurse with $
        ::  otherwise issue a hen chick with the call.
        :: [~ next=[to=me.cart town-id args=[me.cart ]] roost=rooster]
        =.  data.p.germ.my-grain  state(pending (~(del by pending.state) tx-hash.args))
        [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
      =.  data.p.germ.my-grain  state
      [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
    ::
        %submit-tx
      ::  validate member in multisig
      ?.  (is-member caller-id state)  !!
      ::  TODO is mug appropriate here?
      =.  data.p.germ.my-grain
        state(pending (~(put by pending.state) (mug egg.args) [egg.args (silt ~[caller-id])]))
      [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
    ::
        %add-member
      ::  this must be sent by contract
      ?.  (is-me caller-id)  !!
      =.  data.p.germ.my-grain  state(members (~(put in members.state) id.args))
      [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
    ::
        %remove-member
      ::  this must be sent by contract
      ?.  (is-me caller-id)  !!
      =.  data.p.germ.my-grain  state(members (~(del in members.state) id))
      [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
    ::
        %set-threshold
      ::  this must be sent by contract
      ?.  (is-me caller-id)  !!
      =.  data.p.germ.my-grain  state(threshold new-thresh.args)
      [%& (malt ~[[id.my-grain my-grain]]) ~ ~]
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
