A token rice (data) contains:

* total: total supply of token
* balances: map of id->number (balances)
* allowances: map of (owner id, sender id)->number (allowances, or how much token an owner has given a sender permission to spend)

A token grain (contract) has methods:

WRITE:
* +transfer: send X tokens to Y id
* +set-allow: make an entry in allowances letting Y id spend X tokens
* +take: use an allowance to spend X tokens from Y id (not that of caller)

READ:
* +get-bal: return balance of Y id
* +get-allow: return how many tokens Y id is allowed to spend from Z id
* +get-total: return total supply of token

ZIGS contract has the following additional methods:

* +coinbase: mint X tokens to Y validator id
* +take-fee: take X tokens from Y id to pay gas fee
* +set-inflation: alter amount of tokens minted in coinbase?

ZIGS rice has following additional data:

* inflation-rate: number of tokens granted by coinbase
* ??