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
      |=  [* =grain:smart]
      ?.  ?=(%& -.germ.grain)  !!
      =/  data  ;;(token-account data.p.germ.grain)
      :-  (scot %ux id.grain)
      %-  pairs
      :~  ['id' (tape (scow %ux id.grain))]
          ['lord' (tape (scow %ux lord.grain))]
          ['holder' (tape (scow %ux holder.grain))]
          ['town' (numb town-id.grain)]
          ::  note: need to use 'token standard' here
          ::  to guarantee properly parsed data
          :-  'data'
          %-  pairs
          :~  ['balance' (numb balance.data)]
              ['metadata' (tape (scow %ux metadata.data))]
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
