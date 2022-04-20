::  Tests for nft.hoon (non-fungible token contract)
::  to test, make sure to add library import at top of contract
::  (remove again before compiling for deployment)
::
/+  *test, cont=zig-contracts-publish, *zig-sys-smart
=>  ::  test data
    |%
    ++  owner-1  ^-  account
      [0xbeef 0 0x1234.5678]
    ++  trivial-nok  ^-  *
      [[8 [1 0] [1 1 0] 0 1] 8 [1 0 0 0] [1 8 [8 [9 2.398 0 4.095] 9 2 10 [6 7 [0 3] 1 100] 0 2] 1 0 0 0] 0 1]
    ++  trivial-nok-upgrade  ^-  *
      [[8 [1 0] [1 1 0] 0 1] 8 [1 0 0 0] [1 8 [8 [9 2.398 0 4.095] 9 2 10 [6 7 [0 3] 1 1.000] 0 2] 1 0 0 0] 0 1]
    --
::  testing arms
|%
++  test-matches-type  ^-  tang
  =/  valid  (mule |.(;;(contract cont)))
  (expect-eq !>(%.y) !>(-.valid))
::
::  tests for %deploy
::
++  test-trivial-deploy  ^-  tang
  =/  =zygote
    [owner-1 `[%deploy %.y trivial-nok ~] ~]
  =/  =cart
    [~ `@ux`'publish' 0 1 ~]
  =/  new-id  (fry-contract 0xbeef 1 trivial-nok)
  =/  new-grain  ^-  grain
    :*  new-id
        0xbeef
        0xbeef
        1
        [%| `trivial-nok ~]
    ==
  =/  res=chick
    (~(write cont cart) zygote)
  =/  correct=chick
    [%& ~ (malt ~[[id.new-grain new-grain]])]
  (expect-eq !>(correct) !>(res))
::
::  tests for %upgrade
::

--