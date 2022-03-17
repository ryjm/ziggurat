## How to create a compiled "smart library" for small contract execution:

1. Get a `ream`ed version of `trivial.hoon`, the simplest possible hoon smart contract
2. Get a built version of the `smart.hoon` library with `-build-file`
3. Get the untyped vase with `=compiled (slap !>(smart) reamed-trivial)`
4. Save the end product sans trivial contract with `.filename (slap !>(compiled) '+>')`
^^ this is WRONG in some way.. need to recall real answer

TODO: save the steps for using this library in such a way that execution is fast, not slow.
