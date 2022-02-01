/+  *zig-mill
|_  now=time
++  our-granary
  ^-  granary
  =/  contracts=(list (pair id grain:tiny))
    :~  [0x1 %| 0x1 0x2 `q:(slap !>(tiny) (ream .^(@t %cx /(scot %p ~zod)/zig/(scot %da now)/lib/zig/contracts/one/hoon)))]
        [0x2 %| 0x2 0x2 `q:(slap !>(tiny) (ream .^(@t %cx /(scot %p ~zod)/zig/(scot %da now)/lib/zig/contracts/publish/hoon)))]
        [0x3 %| 0x3 0x2 `q:(slap !>(tiny) (ream .^(@t %cx /(scot %p ~zod)/zig/(scot %da now)/lib/zig/contracts/two/hoon)))]
    ==
  (~(gas by *(map id grain:tiny)) contracts)^~
--
