|%
+$  pubkey  @ux 
+$  multisig
  $:  members=(set pubkey)
      threshold=@ud
  ==
+$  owner  ?(pubkey multisig)
+$  id  @ux
+$  account-id  id
+$  asset-id  id
+$  nonce  @ud
+$  amount  @ud
+$  supply  @ud
+$  zigs  amount
::
+$  asset
  $%  ::  nft asset-id = minter+hash?
      [%nft id=asset-id minter=account-id uri=@t hash=@ux can-xfer=?]
      ::  asset-id = account-id for fungibles
      [%fung id=asset-id minter=account-id =amount]
  ==
::  +$  minter-account
::    $:  =owner  :: this line creates a fish-loop on line 28
::        =nonce
::        max=supply
::        total=supply
::    ==
::  +$  asset-account
::    $:  =owner
::        =nonce
::        assets=(list asset)
::    ==
::  double-nesting (set pubkey) caused fish-loop
::  error when defining account. bizarre.
+$  account  :: ?(minter-account asset-account)
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
        assets=(map asset-id asset) ::  make this a map?
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
