/-  *ziggurat
=,  dejs:format
|_  act=wallet-poke
++  grab
  |%
  ++  noun  wallet-poke
  ++  json
    |=  jon=^json
    ^-  wallet-poke
    %-  wallet-poke
    |^
    (process jon)
    ++  process
      %-  of
      :~  [%populate parse-seed]
          [%import parse-import]
          [%create bo]
          [%delete parse-delete]
          [%set-node parse-set]
          [%submit parse-submit]
      ==
    ++  parse-import
      (ot ~[[%mnemonic sa] [%password sa]])
    ++  parse-seed
      (ot ~[[%seed (se %ux)]])
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
