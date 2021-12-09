|%
+$  pubkey  @ux 
+$  multisig
  [members=(set pubkey) threshold=@ud]
+$  owner  ?(pubkey multisig)
+$  id  @ux
+$  account-id  id
+$  nonce  @ud
+$  amount  @ud
+$  supply  @ud
+$  zigs  amount
::
+$  asset
  $%  [%nft minter=account-id uri=@t hash=@ux can-xfer=?]
      [%fung minter=account-id =amount]
  ==
:: +$  minter-account
::   $:  ::=owner  :: this line creates a fish-loop on line 28 for some bizarre reason
::       =nonce
::       max=supply
::       total=supply
::   ==
:: +$  asset-account
::   $:  =owner
::       =nonce
::       assets=(list asset)
::   ==
+$  account  ::  ?(minter-account asset-account)
  $%
    $:  %minter-account
        =owner
        =nonce
        max=supply
        total=supply
    ==
    $:  %asset-account
        =owner
        =nonce
        assets=(list asset)
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
  ==
+$  multisig-sender
  $:  =account-id 
      =nonce
      pubkeys=(list pubkey) 
      sigs=(list signature)
  ==
+$  sender  ?(pubkey-sender multisig-sender)
::
+$  tx
  $%  
    $:  %send
        from=sender
        feerate=zigs
        to=account-id
        assets=(list asset)
    ==
    $:  %mint
        from=sender
        feerate=zigs
        to=(list [account-id asset])
    ==
    ::
    $:  %create-multisig
        from=sender
        salt=@ud
        owner=multisig
    ==
    $:  %update-multisig
        from=multisig-sender 
        owner=multisig
    ==
    ::
    $:  %create-minter
        from=sender
        salt=@ud
        =max=supply
        =owner
    ==
  ==
--
