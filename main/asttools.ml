(* camlp5r *)
(* asttools.ml,v *)
(* Copyright (c) INRIA 2007-2017 *)

#load "q_MLast.cmo";

value longid_concat li1 li2 =
  let rec crec = fun [
    <:extended_longident:< $longid:a$ . $_uid:b$ >> ->
      <:extended_longident< $longid:(crec a)$ . $_uid:b$ >>
  | <:extended_longident:< $longid:a$ ( $longid:b$ ) >> ->
      <:extended_longident< $longid:(crec a)$ ( $longid:b$ ) >>
  | <:extended_longident:< $_uid:b$ >> ->
      <:extended_longident< $longid:li1$ . $_uid:b$ >>
  ] in
  crec li2
;

value rec longid_last = fun [
  <:extended_longident< $uid:_$ >> as z -> z
| <:extended_longident:< $longid:_$ . $uid:uid$ >> -> <:extended_longident< $uid:uid$ >>
| _ -> failwith "longid_last"
]
;
