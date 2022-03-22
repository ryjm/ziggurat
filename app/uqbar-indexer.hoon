::  uqbar-indexer:
::
::  Index blocks
::
::    Receive new blocks, index them,
::    and update subscribers with full blocks
::    or with hashes of interest
::
::
::    ## Scry paths
::
::    /x/block-height:
::      The current block height
::    /x/block:
::      The most recent block
::    /x/block/[@ud]:
::      The block with given block number
::    /x/hash/[@ux]:
::      History of id with the given hash
::    /x/rice/[@ux]:
::      State of rice with given hash
::
::
::    ## Subscription paths (TODO)
::
::    /block:
::
::    /hash/[@ux]:
::
::    ##  Pokes
::
::    %dao-group-create:
::      Create a DAO group. Further documented in /sur/dao-group-store.hoon
::
::    %dao-group-modify:
::      Modify the DAO group. Further documented in /sur/dao-group-store.hoon
::
::
