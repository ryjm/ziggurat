::  adaptive radix trie: [uqbar dao]
::
::
=<
|%
::
++  art
  |*  val=mold
  |=  =bloq
  |=  tre=*
  =/  b  ;;((radix-tree val) tre)
  ::?>  (apt:((on key val) ord) b)
  b
::
++  ra
  ~/  %ra
  |*  val=mold
  =>  |%
      +$  child  (pair @ (radix-tree val))
      ++  orm    ((on @ (radix-tree val)) lth)
      --
  |%
  ++  get
    =/  i  1
    |=  [a=(radix-tree val) b=@]
    ^-  (unit val)
    ?~  a  ~
    ?:  =(key.item.a b)
      `val.item.a
    ?-    -.a
        %8
      |-
      ?~  children.a  ~
      ?:  =((end [3 i] b) p.i.children.a)
        ^$(a q.i.children.a, i +(i))
      $(children.a t.children.a)
    ::
        %64
      =/  result=(unit (radix-tree val))  (get:orm children.a (end [3 i] b))
      ?~  result  ~
      $(a u.result, i +(i))
    ::
        %256
      ::  raw axis lookup using .* and nock %0
      ~
    ==
  ::
  ++  put
    |=  [a=(radix-tree val) b=@]
    ^-  val
    *(radix-tree val)
  ::
  ++  del
    |=  [a=(radix-tree val) b=@]
    ^-  (radix-tree val)
    *(radix-tree val)
  --
--
::
|%
++  radix-tree
  =>  |%
      ++  child  |$  [val]  (pair @ (radix-tree val))
      --
  |$  [val]
  $@  ~
  $%  [%8 item=[key=@ val=val] children=(list (child val))]
      [%64 item=[key=@ val=val] children=((mop @ (radix-tree val)) lth)]
      $:  %256  item=[key=@ val=val]
          $=  children
          $:  (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
            ::
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
            ::
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
            ::
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
            ::
            ::
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
            ::
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
            ::
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
            ::
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
            ::
            ::
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
            ::
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
            ::
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
            ::
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
            ::
            ::
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
            ::
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
            ::
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
            ::
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
              (unit (child val))  (unit (child val))  (unit (child val))  (unit (child val))
  ==  ==  ==
--
