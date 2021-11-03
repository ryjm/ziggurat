# ziggurat roadmap v0 - ~rul

## Basic Architecture:
  Singular gall agent, %ziggurat that keeps track of relay chain
  state and is able to opt-in to run particular helixes. Have an
  official implementation that is signed and contains all helix
  source code in library files at the path /lib/ziggurat/helix/.

## Core Implemention Phases:
  Phase 0: Begin by creating a simplified block definition
  and a simple mechanism for for advancing the relay chain forward
  with blocks made up of empty chunks that are produced by a
  hardcoded validator set. This portion should have a basic epoch
  protocol such that every block producer knows when to produce
  their block, and makes it available to the other producers.

  Phase 1: Build out a minimal mempool system for allowing txs to
  be submitted and a singular Helix for registering and
  deregistering validators. Create a trivial chunk production
  system with no gas, CSEs, *erasure coding*, or *data availability
  (red/blue)* checks. Build out the necessary Helix runner for
  importing in and running this Helix from a library.

  Phase 2: Flesh out the block and chunk validation system such
  that all state transitions are actually performed properly and
  validated, at least by the producer. Integrate the erasure coding
  system for ensuring chunk data was available to all validators.

  Phase 3:
  - *Implement the tx fees, post-hoc gas fees, production of Zigs per
    block, and chunk/block rewards*
  - *Fully implement native asset / pubkey account system*

  Phase 4: A few lines of work that can be done in parallel:
  - Implement the CSE system.
  - *Implement a version of +mink that passes the control flow
    back to the program that ran it every so often as a means
    of limiting time spent executing any particular program*
  - *Fork Naive's std.hoon library and add cryptographic
    functions (Schnorr sigs, Keccak, etc) for smart contracts*
  - *Implement a second Helix that is meant for more "normal" usage
    as opposed to the initial specialized Helix for validator
    registration.*
  - *Utilize the existing +azimuth-tracker and +roller code to build
    a snapshot of existing Urbit ID PKI*
  - Build out "fisherman" mode to just watch chain state and validate it.
    Perhaps build a corresponding Helix for this?

  Phase 5: Clean up loose ends, such as initial sync for new
  validators, and all the other issues that pop up. Write unit tests.

    Phase 6: Performance optimization and security audit

    Phase 7: Begin running testnets, doing load tests, and preparing to
    transition Zig tokens off of Ethereum.

    * All asterisks denote work that is easily parallelized.

  Some thoughts on defining a helix, and defining a contract account:

```|%
+$  config  %0
+$  tx      @
+$  effect  @
+$  chunk   (list (pair tx (list effect)))
::
++  contract
  $_  ^|
  |_  [p=(map @ux holdings) q=vase]
  ++  take-input
    |~  vase
    *vase
  --
::
+$  accounts
  $%  [%pubkey p=(map @ux holdings)]
      [%contract p=(map @ux holdings) q=vase r=contract]
  ==
+$  token
  $~  [%$ p=@ud]
  $%  [%generic p=vase]
  ==
::
+$  holdings  (map @tas token)
::
++  helix
  |*  =config
  $_  ^|
  |_  p=accounts
  ++  produce-chunk
    |~  mempool
    *chunk
  ::
  ++  validate-chunk
    |~  chunk
    *?
  ::
  ++  consume-chunk
    |~  chunk
    *accounts
  --
--```
