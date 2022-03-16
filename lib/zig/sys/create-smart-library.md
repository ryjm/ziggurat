## How to create a compiled "smart library" for small contract execution:

1. Get a `ream`ed version of `trivial.hoon`, the simplest possible hoon smart contract
2. Get a built version of the `smart.hoon` library with `-build-file`
3. Save the untyped vase with `.filename (slap !>(smart) reamed-trivial)

TODO: save the steps for using this library in such a way that execution is fast, not slow.
