## How to create a compiled "smart library" for small contract execution:

`=trivial .^(@t %cx /=zig=/lib/zig/contracts/trivial/hoon)`

`=smart -build-file /=zig=/lib/zig/sys/smart/hoon`

`=compiled (slap !>(smart) (ream trivial))`

`.smart-lib-new q:(slap compiled (ream '+>'))`

