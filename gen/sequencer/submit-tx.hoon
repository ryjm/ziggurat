/-  *sequencer
/+  smart=zig-sys-smart
:-  %say
|=  [[now=@da eny=@uvJ bek=beak] [town-id=@ud nonce=@ud ~] ~]
:-  %zig-basket-action
^-  basket-action
:-  %receive
:-  [[0xbeef nonce 0x1.beef] 0x0 1 500 town-id] 
:^    [0xbeef nonce 0x1.beef]
    `[%give 0xcafe 10 500]
  (silt ~[0x1.beef])
(silt ~[0x1.cafe])
