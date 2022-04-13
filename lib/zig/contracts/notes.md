##  State of Uqbar contracts

- Concepts that need to be explained
  - contract architecture (split between data and functions)
    - "a contract is a stateless bundle of functions"
  - chain architecture explainer (hands-on)
  - contract execution explainer
  - glossary of plain-language type explanations

- After context above is shared, can explain contract writing hands-on
  - how to design a data model
  - how to perform chains of calls
  - how to design arguments
  - how to deploy & test contract
    - write a test file
    - use deploy script


We're actively building contracts, both in order to run the testnet and explore the ergonomics of our data/execution model.

For a contract to be 'ready', it must compile and pass tests for every supported call type. Then, we can store a compiled nock version of it in a folder (TODO: do this). From there, we can hardcode it into a town initialization generator and test it on-chain.

We can kelvin-version these compiled contracts (TODO). The kelvin-version can be enforced on-chain, and a version 0 can enforce immutability(?).

Contracts in the repo and their current state (will be keeping this updated):

- `capitol.hoon`: Management contract for validators and sequencers. Keeps track of Urbit IDs involved in running Uqbar chain and towns/shards. Critical for chain to function, and as such is always kept in a working state.

- `zigs.hoon`: The contract for `zigs`, Uqbar's gas token. Requires a unique contract to enforce budget contraints on token sends (need to check account has gte send + budget). Also nice to store this token in its own location for an added layer of 'officialness'. Critical for chain to function (hardcoded to process all transaction gas payments).

- `fungible.hoon`: Uqbar's token standard. Has some tests but needs far more. Well-documented and functional (good example contract). Enables the creation of new tokens without deploying new contracts.

- `publish.hoon`: Contract to deploy and upgrade other contracts. Very important for creating conditions for persistent testnet. Quite simple, but untested.

- `trivial.hoon`: Included for testing purposes. Used to compile versions of our smart-standard-library. Never actually deployed, unlikely to change.

- `multisig.hoon`: Currently out-of-date, needs rewrite and testing. Will manage simple multisig wallets and potentially define the standard for multisig interfaces.

- `dao.hoon`: Currently out-of-date, used to manage DAOs. Will be used for EScape DAO product.

- `nft.hoon`: A contract that should be made soon.

====================

General TODOs for contracts & contract language ("uHoon"):

- Define set of jets used in uHoon and define subset of `hoon.hoon` to include

- Continue identifying areas in contract-writing which need standard helper functions, or possibly custom data types

- Figure out best way to include external libraries in contracts at compile-time

- Try out building external library for use in contract

- Create generator for compiling contract and saving it as a nock-blob (better version of deploy.hoon)

- Add kelvin versions to compiled contracts in head cell, handle this in `mill.hoon`?

- Continue writing tests for contracts and possibly create better contract testing framework which includes mill execution

- Determine kelvin version for `mill.hoon`

- Determine kelvin version for `smart.hoon`
