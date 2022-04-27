/-  *ziggurat, *uqbar-wallet
=,  enjs:format
|_  upd=wallet-update
++  grab
  |%
  ++  noun  wallet-update
  --
++  grow
  |%
  ++  noun  upd
  ++  json
    ?-    -.upd
        %new-book
      %-  pairs
      %+  turn  ~(tap by tokens.upd)
      |=  [pub=@ux =book]
      :-  (scot %ux pub)
      %-  pairs
      %+  turn  ~(tap by book)
      |=  [* [=token-type =grain:smart]]
      ?.  ?=(%& -.germ.grain)  !!
      :-  (scot %ux id.grain)
      %-  pairs
      :~  ['id' (tape (scow %ux id.grain))]
        ['lord' (tape (scow %ux lord.grain))]
        ['holder' (tape (scow %ux holder.grain))]
        ['town' (numb town-id.grain)]
        ['token_type' (tape (scow %tas token-type))]
        :-  'data'
        %-  pairs
        ?+    token-type  ~[['unknown_data_structure' (tape "?")]]
            %token
          =+  ;;(token-account data.p.germ.grain)
          :~  ['balance' (numb balance.-)]
              ['metadata' (tape (scow %ux metadata.-))]
              ['salt' (tape (scow %u salt.p.germ.grain))]
          ==
        ::
            %nft
          =+  ;;(nft-account data.p.germ.grain)
          :~  ['metadata' (tape (scow %ux metadata.-))]
              ['salt' (tape (scow %u salt.p.germ.grain))]
              :-  'items'
              %-  pairs
              %+  turn  ~(tap by items.-)
              |=  [id=@ud =item]
              :-  (scot %ud id)
              %-  pairs
              :~  ['desc' (tape desc.item)]
                  ['URI' (tape uri.item)]
              ==
          ==
        ==
    ==
    ::
        %tx-status
      %-  pairs
      :~  ['status' (tape (scow %ud status.upd))]
          ['hash' (tape (scow %ux hash.upd))]
      ==
    ==
  --
++  grad  %noun
--
