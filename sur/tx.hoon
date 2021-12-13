|%
+$  pubkey  @ux 
+$  multisig
  [members=(set pubkey) threshold=@ud]
+$  owner  ?(pubkey multisig)
+$  id  @ud
+$  account-id  @ux
+$  nonce  @ud
+$  amount  @ud
+$  supply  @ud
+$  zigs  amount
::
+$  asset
  $%  [%nft minter=account-id =id uri=@t hash=@ux can-xfer=?]
      [%tok minter=account-id =amount]
  ==
+$  minting-asset
  $%  [%nft uri=@t hash=@ux can-xfer=?]
      [%tok =amount]
  ==
+$  account
  $%
    $:  %blank-account
        ~
    ==
    $:  %minter-account
        =owner
        =nonce
        max=supply
        total=supply
    ==
    $:  %asset-account
        =owner
        =nonce
        assets=(map account-id asset)
    ==
  ==
+$  state  [hash=@ux accts=(map account-id account)]
::  TODO: patricia merkle tree data structure

::  transactions
::
+$  sig-type  ?(%schnorr %ecdsa)
+$  signature
  [r=@ux s=@ux =sig-type]
+$  pubkey-sender
  $:  =account-id 
      =nonce
      =pubkey 
      sig=signature
      feerate=zigs
  ==
+$  multisig-sender
  $:  =account-id 
      =nonce
      pubkeys=(list pubkey) 
      sigs=(list signature)
      feerate=zigs
  ==
+$  sender  ?(pubkey-sender multisig-sender)
::
++  tx
  $%  
    $:  %send
        from=sender
        to=account-id
        assets=(set asset)
    ==
    $:  %mint
        from=sender
        minter=account-id
        to=(list [account-id minting-asset])
    ==
    $:  %lone-mint
        from=sender
        to=(list [account-id minting-asset])
    ==
    ::
    $:  %create-multisig
        from=sender
        owner=multisig
    ==
    $:  %update-multisig
        from=multisig-sender 
        owner=multisig
    ==
    ::
    $:  %create-minter
        from=sender
        max=supply
        =owner
    ==
    $:  %update-minter
        from=sender
        =owner
    ==
  ==
--
