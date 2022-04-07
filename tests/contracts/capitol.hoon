::  Tests for capitol.hoon (chain management contract)
::  to test, make sure to add library import at top of contract
::  (remove again before compiling for deployment)
::
/+  *test, contract=zig-contracts-capitol, smart=zig-sys-smart

=>  ::  test data
    |%
    ++  world-grain  ^-  grain:smart
      :*  `@ux`'world'            ::  id
          `@ux`'capitol'          ::  lord
          `@ux`'capitol'          ::  holder
          0                       ::  town-id
          [%& `@`'world' data=*(map @ud @ux)]
      ==
    ::
    ++  ziggurat-grain  ^-  grain:smart
      :*  `@ux`'ziggurat'
          `@ux`'capitol'
          `@ux`'capitol'
          0
          [%& `@`'ziggurat' data=*(map ship [@ux ship @ud])]
      ==
    ++  world-cart  ^-  cart:smart
      :*  ~
          `@ux`'capitol'
          0
          0
          (malt ~[[`@ux`'world' world-grain]])
      ==
    ++  ziggurat-cart  ^-  cart:smart
      :*  ~
          `@ux`'capitol'
          0
          0
          (malt ~[[`@ux`'ziggurat' ziggurat-grain]])
      ==
    --
::  testing arms
|%
++  test-functional-contract  ^-  tang
  ::  TODO get this into the expect-eq
  =/  valid=contract:smart  ;;(contract:smart contract)
  (expect-eq !>(%.y) !>(%.y))
::
::  Tests for %become-validator calls
::
++  test-become-validator  ^-  tang
  =/  inp=zygote:smart
    :+  [0xbeef 0 0x1.beef]
      `[%become-validator [0x1111 ~zod 1]]
    ~
  =/  updated-ziggurat
    :*  `@ux`'ziggurat'
        `@ux`'capitol'
        `@ux`'capitol'
        0
        [%& `@`'ziggurat' (malt ~[[~zod [0x1111 ~zod 1]]])]
    ==
  =/  res=chick:smart
    (~(write contract ziggurat-cart) inp)
  =/  correct=chick:smart
    [%& (malt ~[[`@ux`'ziggurat' updated-ziggurat]]) ~]
  (expect-eq !>(res) !>(correct))
::
++  test-become-validator-already-one  ^-  tang
  =/  inp=zygote:smart
    :+  [0xbeef 0 0x1.beef]
      `[%become-validator [0x1111 ~zod 1]]
    ~
  =/  initial
    :*  `@ux`'ziggurat'
        `@ux`'capitol'
        `@ux`'capitol'
        0
        [%& `@`'ziggurat' (malt ~[[~zod [0x1111 ~zod 1]]])]
    ==
  =/  cart
    [~ `@ux`'capitol' 0 0 (malt ~[[`@ux`'ziggurat' initial]])]
  =/  res=(each * (list tank))
    (mule |.((~(write contract cart) inp)))
  (expect-eq !>(%.n) !>(-.res))
::
::  Tests for %stop-validating calls
::
++  test-stop-validating  ^-  tang
  =/  inp=zygote:smart
    :+  [0xbeef 0 0x1.beef]
      `[%stop-validating [0x1111 ~zod 1]]
    ~
  =/  initial
    :*  `@ux`'ziggurat'
        `@ux`'capitol'
        `@ux`'capitol'
        0
        [%& `@`'ziggurat' (malt ~[[~zod [0x1111 ~zod 1]]])]
    ==
  =/  updated-ziggurat
    :*  `@ux`'ziggurat'
        `@ux`'capitol'
        `@ux`'capitol'
        0
        [%& `@`'ziggurat' ~]
    ==
  =/  cart
    [~ `@ux`'capitol' 0 0 (malt ~[[`@ux`'ziggurat' initial]])]
  =/  res=chick:smart
    (~(write contract cart) inp)
  =/  correct=chick:smart
    [%& (malt ~[[`@ux`'ziggurat' updated-ziggurat]]) ~]
  (expect-eq !>(res) !>(correct))
::
++  test-stop-validating-wasnt-one  ^-  tang
  =/  inp=zygote:smart
    :+  [0xbeef 0 0x1.beef]
      `[%stop-validating [0x1111 ~zod 1]]
    ~
  =/  res=(each * (list tank))
    (mule |.((~(write contract ziggurat-cart) inp)))
  (expect-eq !>(%.n) !>(-.res))
::
::  Tests for %init calls
::
++  test-init-1
  =/  inp=zygote:smart
    :+  [0xbeef 0 0x1.beef]
      `[%init [0x1111 ~zod 1] 1]
    ~
  =/  updated-world
    :*  `@ux`'world'
        `@ux`'capitol'
        `@ux`'capitol'
        0
        [%& `@`'world' (malt ~[[1 (malt ~[[~zod [0xbeef [0x1111 ~zod 1]]]])]])]
    ==
  =/  res=chick:smart
    (~(write contract world-cart) inp)
  =/  correct=chick:smart
    [%& (malt ~[[`@ux`'world' updated-world]]) ~]
  (expect-eq !>(res) !>(correct))
::
::  Tests for %join calls
::
++  test-join-1
  =/  inp=zygote:smart
    :+  [0xdead 0 0x1.dead]
      `[%join [0x2222 ~bus 1] 1]
    ~
  =/  initial
    :*  `@ux`'world'
        `@ux`'capitol'
        `@ux`'capitol'
        0
        [%& `@`'world' (malt ~[[1 (malt ~[[~zod [0xbeef [0x1111 ~zod 1]]]])]])]
    ==
  =/  updated-world
    :*  `@ux`'world'
        `@ux`'capitol'
        `@ux`'capitol'
        0
        [%& `@`'world' (malt ~[[1 (malt ~[[~zod [0xbeef [0x1111 ~zod 1]]] [~bus [0xdead [0x2222 ~bus 1]]]])]])]
    ==
  =/  cart
    [~ `@ux`'capitol' 0 0 (malt ~[[`@ux`'world' initial]])]
  =/  res=chick:smart
    (~(write contract cart) inp)
  =/  correct=chick:smart
    [%& (malt ~[[`@ux`'world' updated-world]]) ~]
  (expect-eq !>(res) !>(correct))
::
::  Tests for %exit calls
::
++  test-exit-1
  =/  inp=zygote:smart
    :+  [0xdead 0 0x1.dead]
      `[%exit [0x2222 ~bus 1] 1]
    ~
  =/  initial
    :*  `@ux`'world'
        `@ux`'capitol'
        `@ux`'capitol'
        0
        [%& `@`'world' (malt ~[[1 (malt ~[[~zod [0xbeef [0x1111 ~zod 1]]] [~bus [0xdead [0x2222 ~bus 1]]]])]])]
    ==
  =/  updated-world
    :*  `@ux`'world'
        `@ux`'capitol'
        `@ux`'capitol'
        0
        [%& `@`'world' (malt ~[[1 (malt ~[[~zod [0xbeef [0x1111 ~zod 1]]]])]])]
    ==
  =/  cart
    [~ `@ux`'capitol' 0 0 (malt ~[[`@ux`'world' initial]])]
  =/  res=chick:smart
    (~(write contract cart) inp)
  =/  correct=chick:smart
    [%& (malt ~[[`@ux`'world' updated-world]]) ~]
  (expect-eq !>(res) !>(correct))
--