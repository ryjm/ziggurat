/-  spider,
    d=dao,
    zig=ziggurat
/+  strandio,
    smart=zig-sys-smart
::
=*  strand     strand:spider
=*  poke       poke:strandio
=*  scry       scry:strandio
=*  take-fact  take-fact:strandio
=*  watch      watch:strandio
=>
  |%
  +$  arguments
    $%  [%add-dao salt=@ =dao:d]
        [%vote dao-id=id:smart proposal-id=id:smart]
        [%propose dao-id=id:smart =on-chain-update:d]
        [%execute dao-id=id:smart =on-chain-update:d]  ::  called only by this contract
    ==
  ::
  --
::
=>
  |_  [=account:smart contract-args=arguments]
  ::
  ++  dao-contract-id  ::  HARDCODE to work with gen/sequencer/init.hoon
    `@ux`'dao'
  ::
  ++  rate  ::  HARDCODE to work with gen/sequencer/init.hoon
    1
  ::
  ++  budget  ::  HARDCODE to work with gen/sequencer/init.hoon
    200.000
  ::
  ++  town-id  ::  HARDCODE to work with gen/sequencer/init.hoon
    1
  ++  private-key
    107.379.313.537.631.041.329.005.050.813.496.923.836.597.816.390.555.428.520.502.222.583.401.090.828.793
  ::
  ++  make-proposal-egg
    ^-  egg:smart
    =/  =yolk:smart  make-proposal-yolk
    =/  signature  (make-signature yolk)
    :_  yolk
    (make-proposal-shell signature)
  ::
  ++  make-proposal-shell
    |=  signature=[@ @ @]
    ^-  shell:smart
    :*  from=account
        sig=signature
        to=dao-contract-id
        rate=rate
        budget=budget
        town-id=town-id
    ==
  ::
  ++  make-proposal-yolk
    ^-  yolk:smart
    :^    account
        `contract-args
      ~
    ?:  ?=(%add-dao -.contract-args)  ~
    (~(put in *(set id:smart)) dao-id.contract-args)
  ::
  ++  make-signature
    |=  =yolk:smart
    %+  ecdsa-raw-sign:secp256k1:secp:crypto
      (sham (jam yolk))
    private-key
  ::
  ++  caller-to-account
    |=  =caller:smart
    =/  m  (strand ,account:smart)
    ^-  form:m
    ?:  ?=(account:smart caller)
      (pure:m caller)
    ;<  =account:smart  bind:m
      %+  scry  account:smart
      /gx/wallet/account/(scot %ux caller)/(scot %ud town-id)/noun
    (pure:m account(nonce +(nonce.account)))
  ::
  --
::
^-  thread:spider
|=  arg=vase
=/  m  (strand ,vase)
^-  form:m
=/  arg-mold
  $:  sequencer=ship
      =caller:smart
      contract-args=arguments
  ==
=/  args  !<((unit arg-mold) arg)
?~  args  (pure:m !>(~))
=*  sequencer  sequencer.u.args
=*  caller     caller.u.args
=*  contract-args  contract-args.u.args
;<  =account:smart  bind:m  (caller-to-account caller)
~&  >  "poking sequencer..."
;<  ~  bind:m
  %^  poke  [sequencer %sequencer]  %zig-weave-poke
  !>  ^-  weave-poke:zig
  :-  %forward
  %-  %~  put  in  *(set egg:smart) 
  %=  make-proposal-egg
      account        account
      contract-args  contract-args
  ==
~&  >  "done"
(pure:m !>(~))
