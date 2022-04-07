## How to create a compiled "smart library" for smart contract execution:
*used to generate new versions of uHoon*

`=trivial .^(@t %cx /=zig=/lib/zig/contracts/trivial/hoon)`

`=smart-txt .^(@t %cx /=zig=/lib/zig/sys/smart/hoon)`

`=hoon-txt .^(@t %cx %/sys/hoon/hoon)`

`=hoe (slap !>(~) (ream hoon-txt))`

`=hoed (slap hoe (ream smart-txt))`

`=compiled (slap hoed (ream trivial))`

`.smart-lib-new q:compiled`

