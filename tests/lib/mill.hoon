::
::  Tests for lib/zig/mill.hoon
::  Basic goal: construct a simple granary / helix state
::  and manipulate it with some calls to our zigs contract.
::  Mill should handle clearing a mempool populated by
::  calls and return an updated granary. The zigs contract
::  should manage transactions properly so this is testing
::  the arms of that contract as well.
::
/-  *mill
/+  *test, *zig-mill, *zig-contracts-zigs
|%
++  zigs-rice
  ^-  rice
  :*  zigs-rice-id  ::  id/holder/lord
      zigs-rice-id
      zigs-wheat-id
      0             ::  helix 0
      :*  total=*@ud
          balances=*(map id @ud)
          allowances=*(map [owner=id sender=id] @ud)
          coinbase-rate=50  ::  # of tokens granted in +coinbase
      ==
      ~  ::  doesn't hold any other rice
  ==
++  zigs-wheat
  ^-  wheat
  :-  zigs-wheat-id
  `(ream .^(@t %cx /(scot %p ~zod)/zig/(scot %da now)/lib/zig/contracts/zigs/hoon))
++  fake-town
  (~(gas by *(map @ud granary)) ~[[0 fake-granary]])
++  fake-granary
  ^-  granary
  =/  grains=(list (pair id grain))
    :~  [zigs-wheat-id %| zigs-wheat]
        [zigs-rice-id %& zigs-rice]
    ==
  :_  (malt ~[[0xaa 0] [0xbb 0] [0xcc 0]])
  (~(gas by *(map id grain)) grains)
++  test-mill-basic
  =/  basic-call
    [[0xaa 1] zigs-wheat-id 1 1.000.000 0 [%read [0xaa 1] (silt ~[zigs-rice-id]) ~]]
  =/  res=granary
    (mill 0 fake-granary basic-call)
  (expect-eq !>(~) !>(res))
--