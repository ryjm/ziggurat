/-  *uqbar-wallet, uqbar-indexer
/+  *wallet-util
=,  enjs:format
|%
++  parse-asset
  |=  [=token-type =grain:smart]
  ^-  [p=@t q=json]
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
++  parse-transaction
  |=  [hash=@ux t=egg:smart args=(unit supported-args)]
  ^-  [p=@t q=json]
  ?.  ?=(account:smart from.p.t)  !!
  :-  (scot %ux hash)
  %-  pairs
  :~  ['from' (tape (scow %ux id.from.p.t))]
      ['nonce' (numb nonce.from.p.t)]
      ['to' (tape (scow %ux to.p.t))]
      ['rate' (numb rate.p.t)]
      ['budget' (numb budget.p.t)]
      ['town' (numb town-id.p.t)]
      ['status' (numb status.p.t)]
      ?~  args  ['args' (tape "received")]
      :-  'args'
      %-  frond
      :-  (scot %tas -.args)
      %-  pairs
      ?-    -.u.args
          %give
        :~  ['salt' (tape (scow %ux salt.u.args))]
            ['to' (tape (scow %ux to.u.args))]
            ['amount' (numb amount.u.args)]
        ==
          %give-nft
        :~  ['salt' (tape (scow %ux salt.u.args))]
            ['to' (tape (scow %ux to.u.args))]
            ['item-id' (numb item-id.u.args)]
        ==
      ::
          ?(%become-validator %stop-validating)
        ~[['signature' (tape (scow %p q.signature.u.args))]]
      ::
          ?(%init %join %exit)
        ~[['signature' (tape (scow %p q.signature.u.args))] ['town' (numb town.u.args)]]
      ::
          %custom
        ~[['args' (tape (scow %t args.u.args))]]
      ==
  ==
--
