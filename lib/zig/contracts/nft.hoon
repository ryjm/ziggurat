::  fungible.hoon [uqbar-dao]
::
::  NFT standard. Provides abilities similar to ERC-721 tokens, also ability
::  to deploy and mint new sets of tokens.
::
/+  *zig-sys-smart
|_  =cart
++  write
  |=  inp=zygote
  ^-  chick
  |^
  ?~  args.inp  !!
  (process (hole arguments u.args.inp) (pin caller.inp))
  ::
  +$  collection-metadata
    $:  name=@t
        symbol=@t
        item-mold=mold  ::  provide the shape of each NFT, traits, etc
        supply=@ud
        cap=(unit @ud)  ::  no cap here means minting is unlimited
        mintable=?      ::  automatically set to %.n if supply == cap
        minters=(set id)
        deployer=id
        salt=@
    ==
  ::
  +$  account  ::  holds your items from a given collection
    $:  metadata=id
        items=(map @ud item)     :: maps to item ids
        allowances=(map id @ud)  :: maps to item ids
    ==
  ::
  ::  probably need to add an allowances map here too
  +$  item
    $:  id=@ud  ::  item id in collection
        data=*  ::  must fit item-mold in metadata
        desc=tape  ::  is this needed?
        uri=tape   ::  path?
        transferrable=?
    ==
  ::
  +$  mint
    $:  to=id
        account=(unit id)
        data=*
        desc=tape
        uri=tape
        transferrable=?
    ==
  +$  arguments
    $%  [%give to=id account=(unit id) item=@ud]
        [%take to=id account=(unit id) from-rice=id item=@ud]
        [%mint token=id mints=(set mint)]
        $:  %deploy
            distribution=(set mint)
            minters=(set id)
            name=@t
            symbol=@t
            item-mold=mold
            cap=@ud
            finite=?
            mintable=?
    ==  ==
  ::
  ++  process
    |=  [args=arguments caller-id=id]
    ?-    -.args
        %give
      !!
    ::
        %take
      !!
    ::
        %mint
      !!
    ::
        %deploy
      !!
    ==
  --
::
::  not yet using these
::
++  read
  |=  inp=path
  ^-  *
  ~
--
