/-  *ziggurat, *uqbar-wallet
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
          [%create parse-create]
          [%delete parse-delete]
          [%set-node parse-set]
          [%submit parse-submit]
          [%submit-custom parse-custom]
      ==
    ++  parse-import
      (ot ~[[%mnemonic sa] [%password sa]])
    ++  parse-create
      (ot ~[[%password sa]])
    ++  parse-seed
      (ot ~[[%seed (se %ux)]])
    ++  parse-delete
      (ot ~[[%pubkey (se %ux)]])
    ++  parse-set
      %-  ot
      :~  [%town ni]
          [%ship (se %p)]
      ==
    ++  parse-custom
      %-  ot
      :~  [%from (se %ux)]
          [%to (se %ux)]
          [%town ni]
          [%gas (ot ~[[%rate ni] [%bud ni]])]
          [%args (se %t)]
          [%my-grains (ar (se %ux))]
          [%cont-grains (ar (se %ux))]
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
          [%give-nft parse-nft]
      ==
    ++  parse-give
      %-  ot
      :~  [%salt (se %ud)]
          [%to (se %ux)]
          [%amount ni]
      ==
    ++  parse-nft
      %-  ot
      :~  [%salt (se %ud)]
          [%to (se %ux)]
          [%item-id ni]
      ==
    --
  --
++  grow
  |%
  ++  noun  act
  --
++  grad  %noun
--
