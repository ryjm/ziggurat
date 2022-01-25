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
/+  *test, *zig-mill, *tiny, *zig-contracts-zigs
|%
++  user-balances
  :~  [0xaa 1.000]
      [0xbb 1.000]
      [0xcc 500]
      [0xdd 500]
      [0xee 490]
      [0xff 10]
  ==
++  user-allowances
  :~  [[0xaa 0xbb] 100]
      [[0xee 0xff] 100]
  ==
++  zigs-rice-data
  :*  total=3.500
      balances=(~(gas by *(map id @ud)) user-balances)
      allowances=(~(gas by *(map [owner=id sender=id] @ud)) user-allowances)
      coinbase-rate=50  ::  # of tokens granted in +coinbase
  ==
++  zigs-rice
  ^-  rice
  :*  zigs-rice-id  ::  id/holder/lord
      zigs-rice-id
      zigs-wheat-id
      0             ::  helix 0
      zigs-rice-data
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
  :-  (~(gas by *(map id grain)) grains)
  (malt ~[[0xaa 0] [0xbb 0] [0xcc 0]])
++  test-mill-basic-give
  =/  write
     [%write [0xaa 1] (silt ~[zigs-rice-id]) [~ [%give 0xbb 200 500]]]
  =/  call
    [[0xaa 1] zigs-wheat-id rate=1 budget=500 town-id=0 write]
  =/  res=granary
    (mill 0 fake-granary call)
  ::  what's the best way to create a correct updated granary to check against?
  ::  also need to calculate exact fee to get proper outcome
  (expect-eq !>(~) !>(res))
++  test-mill-failed-give
  =/  write
     [%write [0xaa 1] (silt ~[zigs-rice-id]) [~ [%give 0xbb 2.000 500]]]
  =/  call
    [[0xaa 1] zigs-wheat-id rate=1 budget=500 town-id=0 write]
  =/  res=granary
    (mill 0 fake-granary call)
  ::  updated granary should be same but minus 0xaa's fee
  (expect-eq !>(~) !>(res))
--