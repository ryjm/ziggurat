/-  *ziggurat
=,  dejs:format
|_  act=wallet-poke
++  grab
  |%
  ++  noun  wallet-poke
  ++  json
    |=  jon=^json
    %-  wallet-poke
    =<  (process jon)
    |%
    ++  process
      %-  of
      :~  [%populate ~]
          [%import (ot ~[[%seed (se %ux)]])]
          [%create ~]
          [%delete (ot ~[[%address (se %ux)]])]
          [%set-node parse-set]
          [%submit parse-submit]
      ==
    ++  parse-set
      %-  ot
      :~  [%town ni]
          [%ship (se %p)]
      ==
    ++  parse-submit
      %-  ot
      :~  [%from (se %ux)]
          [%sequencer (mu (se %p))]
          [%to (se %ux)]
          [%town ni]
          [%gas (ot ~[[%rate ni] [%bud ni]])]
          [%args parse-args]
      ==
    ++  parse-args
      %-  of
      :~  [%give parse-give]
      ==
    ++  parse-give
      %-  ot
      :~  [%token (se %ux)]
          [%to (se %ux)]
          [%known bo]
          [%amount ni]
      ==
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--
