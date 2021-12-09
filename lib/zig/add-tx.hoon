/-  *tx
=,  tx
|%
++  process-tx
  |=  [=tx =state]
  ^+  state
  ::  modify state to include results of this transaction, if valid
  =/  from
    ::  gotta be a better way to get same item
    ?-  -.tx
        %send
      from.tx
        %mint
      from.tx
        %create-multisig
      from.tx
        %update-multisig
      from.tx
        %create-minter
      from.tx
    ==
  =/  account  (~(get by accts.state) account-id.from)
  ?~  account
    !! ::  tx from unrecognized account
  =/  account  u.account
  ?>  =((succ nonce.account) nonce.from)
  =/  feerate
    ?+  -.tx  0
        %send
      feerate.tx
        %mint
      feerate.tx
    ==
  =/  fee
    (mul (compute-gas tx) feerate)
  ::  TODO ensure enough zigs in account to cover fee
  ::  TODO check validity of signatures
  ::  branch on type of transaction and modify
  ::  output state
  ?-  -.tx
      %send
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
  |=  [=tx =state =account =fee]
  ?>
  ::  assert that send is valid for all assets in tx

  ::  keeping a map to check for dupes
  =/  seen  `(map asset ?)`~
  =/  to
    (~(get by accts.state) account-id.from)
  %^    spun
      assets.tx
  |=  to-send=asset
  ::  check if asset has been seen
  ?.  ?~  (~(get by seen) to-send)
    !!  ::  can't send 1 asset twice in tx
  ::  check if enough of asset to send is in wallet
  ::  if so, modify state with that part of the tx
  =.  assets.account
    %+  turn
      assets.account
    |=  mine=asset
    ?-  -.to-send
        %nft
      ?>  ?&  =(minter.to-send minter.mine)
              =(hash.to-send hash.mine)
              can-xfer.mine
          ==
      ::  good to send, modify state
      
      ~
        %fung
      ::  if sending zigs, check that fee is covered
      ::  assuming zigs minted at 0x0
      ?>
      ?:  =(minter.to-send 0x0) 
        ?&  =(minter.to-send minter.mine)
            (gth amount.mine (add fee amount.to-send))
        ==
      ?&  =(minter.to-send minter.mine)
          (gth amount.mine amount.to-send)
      ==
      ::  good to send, modify state

    
::
++  compute-gas
  |=  [=tx]
  ::  determine how much work this tx requires
  ::  these are all single-action transactions,
  ::  can determine set costs for each type of tx
  7  ::  temporary
--
