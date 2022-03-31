/-  *ziggurat
=,  dejs:format
|_  act=wallet-poke
++  grab
  |%
  ++  noun  wallet-poke
  ++  json
    |=  jon=^json
    ~&  >>  jon
    ^-  wallet-poke
    %-  wallet-poke
    |^
    (process jon)
    ++  process
      %-  of
      :~  [%populate bo]
          [%import parse-import]
          [%create bo]
          [%delete parse-delete]
          [%set-node parse-set]
          [%submit parse-submit]
      ==
    ++  parse-import
      (ot ~[[%seed so]])
    ++  parse-delete
      (ot ~[[%pubkey (se %ux)]])
    ++  parse-set
      %-  ot
      :~  [%town ni]
          [%ship (se %p)]
      ==
    ++  parse-submit
      %-  ot
      :~  [%from (se %ux)]
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
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--
