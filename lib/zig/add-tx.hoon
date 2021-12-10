/-  *tx
=,  tx
|%
::  something hardcoded
++  zigs-id  `@ux`0x0
::  $process-tx: return modified state that includes 
::  results of this transaction, if valid.
++  process-tx
  |=  [=tx =state]
  ^+  state
  ::  tx from unrecognized account is rejected by got
  =/  account  (~(got by accts.state) account-id.from.tx)
  ?>  =((succ nonce.account) nonce.from.tx)
  =/  fee
    %+  mul
      (compute-gas tx)
    ::  fixed feerate or none for creates/updates?
    ?+  -.tx  0  
        ?(%send %mint)
      feerate.tx
    ==
  =/  zigs-in-account
    ?-  -.account
        %minter-account
      ::  no zigs held in here, can't pay any fees?
      !!
        %asset-account
      =/  zigs  (~(got by assets.account) zigs-id)
      ?+  -.zigs  !!
          %fung
        amount.zigs
      ==
    ==
  ::  TODO check validity of signatures
  ::  branch on type of transaction and modify
  ::  output state
  ?-  -.tx
      %send
    =/  to
      (~(get by accts.state) to.tx)
    (process-send tx state account fee)
      %mint
    state
      %create-multisig
    state
      %update-multisig
    state
      %create-minter
    state
  ==
::
++  process-send
  |=  [=tx =state =account fee=zigs]
  ::?>
  ::  assert that send is valid for all assets in tx

  ::  keeping a map to check for dupes
  =/  seen  `(map asset ?)`~
  ::=/  to
  ::  (~(get by accts.state) to.tx)
  ::%^    spun
  ::    assets.tx
  ::|=  to-send=asset
  ::::  check if asset has been seen
  ::?.  ?~  (~(get by seen) to-send)
  ::  !!  ::  can't send 1 asset twice in tx
  ::::  check if enough of asset to send is in wallet
  ::::  if so, modify state with that part of the tx
  ::=.  assets.account
  ::  %+  turn
  ::    assets.account
  ::  |=  mine=asset
  ::  ?-  -.to-send
  ::      %nft
  ::    ?>  ?&  =(minter.to-send minter.mine)
  ::            =(hash.to-send hash.mine)
  ::            can-xfer.mine
  ::        ==
  ::    ::  good to send, modify state
  ::    
  ::    ~
  ::      %fung
  ::    ::  if sending zigs, check that fee is covered
  ::    ::  assuming zigs minted at 0x0
  ::    ?>
  ::    ?:  =(minter.to-send 0x0) 
  ::      ?&  =(minter.to-send minter.mine)
  ::          (gth amount.mine (add fee amount.to-send))
  ::      ==
  ::    ?&  =(minter.to-send minter.mine)
  ::        (gth amount.mine amount.to-send)
  ::    ==
  ::    ::  good to send, modify state
  ::
  ::    ~
  state  
::
++  compute-gas
  |=  [=tx]
  ::  determine how much work this tx requires
  ::  these are all single-action transactions,
  ::  can determine set costs for each type of tx
  7  ::  temporary
--
