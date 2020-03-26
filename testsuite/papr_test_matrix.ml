(* camlp5r *)
(* papr_patrix_test.ml *)

open Testutil;
open Testutil2;

open OUnit2;
open OUnitTest;

value smart_exn_eq e1 e2 =
  let rec eqrec e1 e2 =
  match (e1, e2) with [
    (Ploc.Exc _ e1, Ploc.Exc _ e2) -> eqrec e1 e2
  | (Stream.Error msg1, Stream.Error msg2) -> msg1 = msg2
  | (Failure msg1, Failure msg2) -> msg1 = msg2
  | (Syntaxerr.Error (Other _), Syntaxerr.Error (Other _)) -> True
  | _ -> e1 = e2
  ]
  in eqrec e1 e2
;

type step_desc_t = [
  OK of string
| EXN of string and exn
| SKIP of string and string
| TODO of string
]
;

type instance_t = {
  name : string ;
  exclude : list string ;
  implem : bool ;
  r_input : step_desc_t;
  o_input : step_desc_t ;
  official_input : step_desc_t ;
  r_output : step_desc_t ;
  o_output : step_desc_t ;
  official_output : step_desc_t
}
;

value skip =
  {name="test-prototype"; implem = True ;
   exclude=[];
   o_input = SKIP "" "" ;
   official_input = SKIP "" "" ;
   r_input = SKIP "" "" ;
   o_output = SKIP "" "";
   official_output = SKIP "" "" ;
   r_output = SKIP "" ""
  } ;

value test_matrix = [
    {name="test-prototype"; implem = True ;
     exclude=[];
     o_input = OK {foo||foo} ;
     official_input = OK {foo||foo} ;
     r_input = OK {foo||foo} ;
     o_output = OK {foo||foo};
     official_output = OK {foo||foo} ;
     r_output = OK {foo||foo}
    };
    {name="simplest"; implem = True ;
     exclude=[];
     o_input = OK "(1; 2);; 3 ;; let x = 1 ;;" ;
     official_input = OK "(1; 2);; 3 ;; let x = 1 ;;" ;
     r_input = OK "do { 1; 2}; 3 ; value x = 1 ;" ;
     o_output = OK {foo|let _ = 1; 2;;
let _ = 3;;
let x = 1;;
|foo} ;
     official_output = OK {foo|;;1; 2
;;3
let x = 1|foo};
     r_output = OK {foo|do { 1; 2 };
3;
value x = 1;
|foo}
    };
    {name="infix1"; implem = True ;
     exclude=[];
     o_input = OK"(a + b) c;;" ;
     official_input = OK"(+) a b c;;" ;
     r_input = OK"(a + b) c;" ;
     o_output = OK {foo|let _ = (a + b) c;;
|foo} ;
     official_output = OK {foo|;;(+) a b c|foo} ;
     r_output = OK{foo|(a + b) c;
|foo}
    };
    {name="infix2"; implem = True ;
     exclude=[];
     o_input = OK "(a --> b) c;;" ;
     official_input = OK "(-->) a b c;;" ;
     r_input = OK"(a --> b) c;" ;
     o_output = OK {foo|let _ = (a --> b) c;;
|foo} ;
     official_output = OK {foo|;;(-->) a b c|foo} ;
     r_output = OK {foo|(a --> b) c;
|foo}
    };
    {name="prefix1"; implem = True ;
     exclude=[];
     o_input = OK"(!!!a) c;;" ;
     official_input = OK"(!!!) a c;;" ;
     r_input = OK"(!!!a) c;" ;
     o_output = OK {foo|let _ = !!!a c;;
|foo} ;
     official_output = OK {foo|;;(!!!) a c|foo} ;
     r_output = OK {foo|!!!a c;
|foo}
    };
    (* original syntax accepts "$" as an infix symbol; revised syntax DOES NOT *)
    {name="dollar"; implem = True ;
     exclude=[];
     o_input = OK"a $ c;;" ;
     official_input = OK"a $ c;;" ;
     r_input = EXN "a $ c;" (Ploc.Exc Ploc.dummy (Stream.Error "';' expected after [str_item] (in [str_item_semi])")) ;
     o_output = OK {foo|let _ = a $ c;;
|foo} ;
     official_output = OK {foo|;;a $ c|foo} ;
     r_output = OK {foo|\$  a c;
|foo}
    };
    {name="alg_attribute1"; implem = True ;
     exclude=[];
     o_input = OK"a[@foo];;" ;
     official_input = OK"a[@foo];;" ;
     r_input = OK"a [@foo];" ;
     o_output = OK {foo|let _ = a[@foo];;
|foo} ;
     official_output = OK {foo|;;((a)[@foo ])|foo} ;
     r_output = OK {foo|a[@foo];
|foo}
    };
    {name="alg_attribute2"; implem = True ;
     exclude=[];
     o_input = OK"a + b[@foo];;" ;
     official_input = OK"a + b[@foo];;" ;
     r_input = OK"a + b [@foo];" ;
     o_output = OK {foo|let _ = a + b[@foo];;
|foo} ;
     official_output = OK {foo|;;((a + b)[@foo ])|foo} ;
     r_output = OK {foo|a + b[@foo];
|foo}
    };
    {name="alg_attribute3"; implem = True ;
     exclude=[];
     o_input = OK"(a [@foo])[@bar];;" ;
     official_input = OK"(a [@foo])[@bar];;" ;
     r_input = OK"a[@foo][@bar];" ;
     o_output = OK {foo|let _ = a[@foo][@bar];;
|foo} ;
     official_output = OK {foo|;;((a)[@foo ][@bar ])|foo} ;
     r_output = OK {foo|a[@foo][@bar];
|foo}
    };
    {name="alg_attribute4"; implem = True ;
     exclude=[];
     o_input = OK"a [@foo :type t = int];;" ;
     official_input = OK"a [@foo :type t = int];;" ;
     r_input = OK"a[@foo :type t = int;];" ;
     o_output = OK {foo|let _ = a[@foo: type t = int;;];;
|foo} ;
     official_output = OK {foo|;;((a)[@foo :type t = int])|foo} ;
     r_output = OK{foo|a[@foo: type t = int;];
|foo}
    };
    {name="alg_attribute5"; implem = True ;
     exclude=[];
     o_input = OK"a [@foo :int];;" ;
     official_input = OK"a [@foo :int];;" ;
     r_input = OK"a[@foo :int];" ;
     o_output = OK {foo|let _ = a[@foo: int];;
|foo} ;
     official_output = OK {foo|;;((a)[@foo :int])|foo} ;
     r_output = OK {foo|a[@foo: int];
|foo}
    };
    {name="alg_attribute6"; implem = True ;
     exclude=[];
     o_input = OK"a [@foo ? (_,_)];;" ;
     official_input = OK"a [@foo ? (_,_)];;" ;
     r_input = OK"a[@foo ? (_,_)];" ;
     o_output = OK {foo|let _ = a[@foo? _, _];;
|foo} ;
     official_output = OK {foo|;;((a)[@foo ?(_, _)])|foo} ;
     r_output = OK {foo|a[@foo? (_, _)];
|foo}
    };
    {name="alg_attribute7"; implem = True ;
     exclude=[];
     o_input = OK"a [@foo ? (_,_) when true];;" ;
     official_input = OK"a [@foo ? (_,_) when true];;" ;
     r_input = OK"a[@foo ? (_,_) when True];" ;
     o_output = OK {foo|let _ = a[@foo? _, _ when true];;
|foo} ;
     official_output = OK {foo|;;((a)[@foo ?(_, _) when true])|foo} ;
     r_output = OK {foo|a[@foo? (_, _) when True];
|foo}
    };
    {name="alg_attribute8"; implem = True ;
     exclude=[];
     o_input = OK"a [@foo ? _,_ when true];;" ;
     official_input = OK"a [@foo ? _,_ when true];;" ;
     r_input = OK"a[@foo ? (_,_) when True];" ;
     o_output = OK {foo|let _ = a[@foo? _, _ when true];;
|foo} ;
     official_output = OK {foo|;;((a)[@foo ?(_, _) when true])|foo} ;
     r_output = OK "a[@foo? (_, _) when True];
"
    };
    {name="alg_attribute9"; implem = True ;
     exclude=[];
     o_input = OK"type t = int [@foo]" ;
     official_input = OK"type t = int [@foo]" ;
     r_input = OK"type t = int [@foo];" ;
     o_output = OK {foo|type t = int[@foo];;
|foo} ;
     official_output = OK {foo|type t = ((int)[@foo ])|foo} ;
     r_output = OK {foo|type t = int[@foo];
|foo}
    };
    {name="alg_attribute10"; implem = True ;
     exclude=[];
     o_input = OK"type t = int [@foo][@bar]" ;
     official_input = OK"type t = int [@foo][@bar]" ;
     r_input = OK"type t = int [@foo][@bar];" ;
     o_output = OK {foo|type t = int[@foo][@bar];;
|foo} ;
     official_output = OK {foo|type t = ((int)[@foo ][@bar ])|foo} ;
     r_output = OK {foo|type t = int[@foo][@bar];
|foo}
    };
    {name="alg_attribute11"; implem = True ;
     exclude=[];
     o_input = OK"function x|y[@foo] -> 1" ;
     official_input = SKIP "function x|y[@foo] -> 1" "this test is problematic but probably not an error" ;
     r_input = OK"fun [ (x|y[@foo]) -> 1 ];" ;
     o_output = OK {foo|let _ =
  function
    x | y[@foo] -> 1;;
|foo} ;
     official_output = OK {foo|;;fun (x|((y)[@foo ])) -> 1|foo} ;
     r_output = OK {foo|fun
[ x | y[@foo] → 1 ];
|foo}
    };
    {name="alg_attribute12"; implem = True ;
     exclude=[];
     o_input = OK"module M = struct end [@foo]" ;
     official_input = OK"module M = struct end [@foo]" ;
     r_input = OK"module M = struct end [@foo];" ;
     o_output = OK {foo|module M = struct  end[@foo];;
|foo} ;
     official_output = OK {foo|module M = ((struct  end)[@foo ])|foo} ;
     r_output = OK {foo|module M = struct  end[@foo];
|foo}
    };
    {name="alg_attribute13"; implem = True ;
     exclude=[];
     o_input = OK"class t = object end [@foo]" ;
     official_input = OK"class t = object end [@foo]" ;
     r_input = OK"class t = object end [@foo];" ;
     o_output = OK {foo|class t = object  end[@foo];;
|foo} ;
     official_output = OK {foo|class t = ((object  end)[@foo ])|foo} ;
     r_output = OK {foo|class t = object  end[@foo];
|foo}
    };
    {name="alg_attribute13"; implem = True ;
     exclude=[];
     o_input = OK"class type ['a ] t = object end [@foo]" ;
     official_input = OK"class type ['a ] t = object end [@foo]" ;
     r_input = OK"class type t ['a] = object end [@foo];" ;
     o_output = OK {foo|class type ['a] t = object  end[@foo];;
|foo} ;
     official_output = OK {foo|class type ['a] t = object  end[@foo ]|foo} ;
     r_output = OK {foo|class type t ['a] = object  end[@foo];
|foo}
    };
    {name="alg_attribute14"; implem = True ;
     exclude=[];
     o_input = OK"type t = { a : int [@foo] }" ;
     official_input = OK"type t = { a : int [@foo] }" ;
     r_input = OK"type t = { a : int [@foo] };" ;
     o_output = OK {foo|type t = { a : int[@foo] };;
|foo} ;
     official_output = OK {foo|type t = {
  a: int [@foo ]}|foo} ;
     r_output = OK {foo|type t = { a : int[@foo] };
|foo}
    };
    {name="alg_attribute15"; implem = True ;
     exclude=[];
     o_input = OK"type t = { a : (int [@bar]) [@foo] }" ;
     official_input = OK"type t = { a : (int [@bar]) [@foo] }" ;
     r_input = OK"type t = { a : (int [@bar]) [@foo] };" ;
     o_output = OK {foo|type t = { a : (int[@bar])[@foo] };;
|foo} ;
     official_output = OK {foo|type t = {
  a: ((int)[@bar ]) [@foo ]}|foo} ;
     r_output = OK {foo|type t = { a : (int[@bar])[@foo] };
|foo}
    };
    {name="alg_attribute16"; implem = True ;
     exclude=[];
     o_input = OK"type t = a * (b[@bar])" ;
     official_input = OK"type t = a * (b[@bar])" ;
     r_input = OK"type t = (a * b[@bar]);" ;
     o_output = OK {foo|type t = a * (b[@bar]);;
|foo} ;
     official_output = OK {foo|type t = (a * ((b)[@bar ]))|foo} ;
     r_output = OK {foo|type t = (a * b[@bar]);
|foo}
    };
    {name="alg_attribute17"; implem = True ;
     exclude=[];
     o_input = OK"type t = a * b[@bar]" ;
     official_input = OK"type t = a * b[@bar]" ;
     r_input = OK"type t = (a * b)[@bar];" ;
     o_output = OK {foo|type t = a * b[@bar];;
|foo} ;
     official_output = OK {foo|type t = (((a * b))[@bar ])|foo} ;
     r_output = OK {foo|type t = (a * b)[@bar];
|foo}
    };
    {name="alg_attribute19"; implem = True ;
     exclude=[];
     o_input = OK"type t = { a : ((int * bool)[@bar]) [@foo] }" ;
     official_input = OK"type t = { a : ((int * bool)[@bar]) [@foo] }" ;
     r_input = OK"type t = { a : ((int * bool)[@bar]) [@foo] };" ;
     o_output = OK {foo|type t = { a : (int * bool[@bar])[@foo] };;
|foo} ;
     official_output = OK {foo|type t = {
  a: (((int * bool))[@bar ]) [@foo ]}|foo} ;
     r_output = OK {foo|type t = { a : ((int * bool)[@bar])[@foo] };
|foo}
    };
    {name="poly-variant-alg-attribute1"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = [ `Foo [@alg_foo] ]|foo} ;
     official_input = OK {foo|type t = [ `Foo [@alg_foo] ]|foo} ;
     r_input = OK {foo|type t = [= `Foo [@alg_foo] ];|foo} ;
     o_output = OK {foo|type t = [ `Foo[@alg_foo] ];;
|foo} ;
     official_output = OK {foo|type t = [ `Foo [@alg_foo ]]|foo} ;
     r_output = OK {foo|type t = [ = `Foo[@alg_foo] ];
|foo}
    };
    {name="poly-variant-alg-attribute2"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = [ `Foo of (int [@alg_bar]) [@alg_foo] ]|foo} ;
     official_input = OK {foo|type t = [ `Foo of (int [@alg_bar]) [@alg_foo] ]|foo} ;
     r_input = OK {foo|type t = [= `Foo of (int [@alg_bar])[@alg_foo] ];|foo} ;
     o_output = OK {foo|type t = [ `Foo of int[@alg_bar][@alg_foo] ];;
|foo} ;
     official_output = OK {foo|type t = [ `Foo of ((int)[@alg_bar ]) [@alg_foo ]]|foo} ;
     r_output = OK {foo|type t = [ = `Foo of int[@alg_bar][@alg_foo] ];
|foo}
    };

    {name="simple-interf"; implem = False ;
     exclude=[];
     o_input = OK"val x : int" ;
     official_input = OK"val x : int" ;
     r_input = OK"value x : int;" ;
     o_output = OK {foo|val x : int;;
|foo} ;
     official_output = OK {foo|val x : int|foo} ;
     r_output = OK {foo|value x : int;
|foo}
    };
    {name="item_attribute1"; implem = False ;
     exclude=[];
     o_input = OK"val x : int [@@foo]" ;
     official_input = OK"val x : int [@@foo]" ;
     r_input = OK"value x : int[@@foo];" ;
     o_output = OK {foo|val x : int[@@foo];;
|foo} ;
     official_output = OK {foo|val x : int[@@foo ]|foo} ;
     r_output = OK {foo|value x : int[@@foo];
|foo}
    };
    {name="item_attribute2"; implem = True ;
     exclude=[];
     o_input = OK"1 [@@foo]" ;
     official_input = OK"1 [@@foo]" ;
     r_input = OK"do { 1 } [@@foo];" ;
     o_output = OK {foo|let _ = 1[@@foo];;
|foo} ;
     official_output = OK {foo|;;1[@@foo ]|foo} ;
     r_output = OK {foo|1[@@foo];
|foo}
    };
    {name="item_attribute3"; implem = True ;
     exclude=[];
     o_input = OK"type nonrec t1 = int [@@bar] and t2 = bool [@@foo]" ;
     official_input = OK"type nonrec t1 = int [@@bar] and t2 = bool [@@foo]" ;
     r_input = OK"type nonrec t1 = int [@@bar] and t2 = bool [@@foo];" ;
     o_output = OK {foo|type nonrec t1 = int[@@bar]
and t2 = bool[@@foo];;
|foo} ;
     official_output = OK {foo|type nonrec t1 = int[@@bar ]
and t2 = bool[@@foo ]|foo} ;
     r_output = OK {foo|type nonrec t1 = int[@@bar]
and t2 = bool[@@foo];
|foo}
    };
    {name="item_attribute4"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t [@@a]|foo} ;
     official_input = OK {foo|type t [@@a]|foo} ;
     r_input = OK {foo|type t = 'a [@@a];|foo} ;
     o_output = OK {foo|type t[@@a];;
|foo};
     official_output = OK {foo|type t[@@a ]|foo} ;
     r_output = OK {foo|type t = α[@@a];
|foo}
    };
    {name="exception-decl-attributes1"; implem = True ;
     exclude=[];
     o_input = OK"exception Foo of int [@@foo]" ;
     official_input = OK"exception Foo of int [@@foo]" ;
     r_input = OK"exception Foo of int [@@foo];" ;
     o_output = OK {foo|exception Foo of int[@@foo];;
|foo} ;
     official_output = OK {foo|exception Foo of int [@@foo ]|foo} ;
     r_output = OK {foo|exception Foo of int[@@foo];
|foo}
    };
    {name="exception-decl-attributes2"; implem = True ;
     exclude=[];
     o_input = OK"exception T of (int [@alg_foo]) [@alg_bar] [@@item_bar]" ;
     official_input = OK"exception T of (int [@alg_foo]) [@alg_bar] [@@item_bar]" ;
     r_input = OK"exception T of (int [@alg_foo]) [@alg_bar] [@@item_bar] ;" ;
     o_output = OK {foo|exception T of (int[@alg_foo])[@alg_bar][@@item_bar];;
|foo} ;
     official_output = OK {foo|exception T of ((int)[@alg_foo ]) [@alg_bar ][@@item_bar ]|foo} ;
     r_output = OK {foo|exception T of (int[@alg_foo])[@alg_bar][@@item_bar];
|foo}
    };
    {name="exception-decl-attributes3"; implem = True ;
     exclude=[];
     o_input = OK"exception Foo [@foo]" ;
     official_input = OK"exception Foo [@foo]" ;
     r_input = OK"exception Foo [@foo];" ;
     o_output = OK {foo|exception Foo[@foo];;
|foo} ;
     official_output = OK {foo|exception Foo [@foo ]|foo} ;
     r_output = OK {foo|exception Foo[@foo];
|foo}
    };
    {name="exception-decl-attributes3b"; implem = False ;
     exclude=[];
     o_input = OK"exception Foo [@foo]" ;
     official_input = OK"exception Foo [@foo]" ;
     r_input = OK"exception Foo [@foo];" ;
     o_output = OK {foo|exception Foo[@foo];;
|foo} ;
     official_output = OK {foo|exception Foo [@foo ]|foo} ;
     r_output = OK {foo|exception Foo[@foo];
|foo}
    };
    {name="constructor-decl-attributes1"; implem = True ;
     exclude=[];
     o_input = OK"type t = A of int * bool [@alg_foo] | B of bool * string [@alg_bar] [@@item_bar]" ;
     official_input = OK"type t = A of int * bool [@alg_foo] | B of bool * string [@alg_bar] [@@item_bar]" ;
     r_input = OK"type t = [ A of int and bool [@alg_foo] | B of bool and string [@alg_bar] ] [@@item_bar];" ;
     o_output = OK {foo|type t =
    A of int * bool[@alg_foo]
  | B of bool * string[@alg_bar][@@item_bar];;
|foo} ;
     official_output = OK {foo|type t =
  | A of int * bool [@alg_foo ]
  | B of bool * string [@alg_bar ][@@item_bar ]|foo} ;
     r_output = OK {foo|type t =
  [ A of int and bool[@alg_foo]
  | B of bool and string[@alg_bar] ][@@item_bar];
|foo}
    };
    {name="constructor-decl-attributes2a"; implem = True ;
     exclude=[];
     o_input = OK{foo|type t = A of int [@alg_bar] [@@item_bar]|foo} ;
     official_input = OK {foo|type t = A of int [@alg_bar] [@@item_bar]|foo} ;
     r_input = OK {foo|type t =
  [ A of int[@alg_bar] ][@@item_bar];|foo} ;
     o_output = OK {foo|type t =
    A of int[@alg_bar][@@item_bar];;
|foo} ;
     official_output = OK {foo|type t =
  | A of int [@alg_bar ][@@item_bar ]|foo} ;
     r_output = OK {foo|type t =
  [ A of int[@alg_bar] ][@@item_bar];
|foo}
    };
    {name="constructor-decl-attributes2b"; implem = True ;
     exclude=[];
     o_input = OK{foo|type t = A of (int [@alg_foo]) [@@item_bar]|foo} ;
     official_input = OK {foo|type t = A of (int [@alg_foo]) [@@item_bar]|foo} ;
     r_input = OK {foo|type t =
  [ A of (int[@alg_foo]) ][@@item_bar];|foo} ;
     o_output = OK {foo|type t =
    A of (int[@alg_foo])[@@item_bar];;
|foo} ;
     official_output = OK {foo|type t =
  | A of ((int)[@alg_foo ]) [@@item_bar ]|foo} ;
     r_output = OK {foo|type t =
  [ A of (int[@alg_foo]) ][@@item_bar];
|foo}
    };
    {name="constructor-decl-attributes2c"; implem = True ;
     exclude=[];
     o_input = OK{foo|type t = A of (int [@alg_foo]) [@alg_bar] [@@item_bar]|foo} ;
     official_input = OK {foo|type t = A of (int [@alg_foo]) [@alg_bar] [@@item_bar]|foo} ;
     r_input = OK {foo|type t =
  [ A of (int[@alg_foo])[@alg_bar] ][@@item_bar];|foo} ;
     o_output = OK {foo|type t =
    A of (int[@alg_foo])[@alg_bar][@@item_bar];;
|foo} ;
     official_output = OK {foo|type t =
  | A of ((int)[@alg_foo ]) [@alg_bar ][@@item_bar ]|foo} ;
     r_output = OK {foo|type t =
  [ A of (int[@alg_foo])[@alg_bar] ][@@item_bar];
|foo}
    };
    {name="module-expr-item-attributes1"; implem = True ;
     exclude=[];
     o_input = OK{foo|module M = struct end [@alg_foo] [@@item_bar]|foo} ;
     official_input = OK{foo|module M = struct end [@alg_foo] [@@item_bar]|foo} ;
     r_input = OK{foo|module M = struct end [@alg_foo] [@@item_bar];|foo} ;
     o_output = OK {foo|module M = struct  end[@alg_foo][@@item_bar];;
|foo} ;
     official_output = OK {foo|module M = ((struct  end)[@alg_foo ])[@@item_bar ]|foo} ;
     r_output = OK {foo|module M = struct  end[@alg_foo][@@item_bar];
|foo}
    };
    {name="module-expr-item-attributes2"; implem = True ;
     exclude=[];
     o_input = OK{foo|module M = N [@alg_foo] [@@item_bar]|foo} ;
     official_input = OK{foo|module M = N [@alg_foo] [@@item_bar]|foo} ;
     r_input = OK{foo|module M = N [@alg_foo] [@@item_bar];|foo} ;
     o_output = OK {foo|module M = N[@alg_foo][@@item_bar];;
|foo} ;
     official_output = OK {foo|module M = ((N)[@alg_foo ])[@@item_bar ]|foo} ;
     r_output = OK {foo|module M = N[@alg_foo][@@item_bar];
|foo}
    };
    {name="method-class-sig-item-attributes1"; implem = True ;
     exclude=[];
     o_input = OK {foo|class type ct = object method m : int [@@argle] end |foo} ;
     official_input = OK {foo|class type ct = object method m : int [@@argle] end |foo} ;
     r_input = OK {foo|class type ct = object method m : int  [@@argle] ; end;|foo} ;
     o_output = OK {foo|class type ct = object method m : int[@@argle] end;;
|foo} ;
     official_output = OK {foo|class type ct = object method  m : int[@@argle ] end|foo} ;
     r_output = OK {foo|class type ct = object method m : int[@@argle]; end;
|foo}
    };
    {name="method-class-struct-item-attributes1"; implem = True ;
     exclude=[];
     o_input = OK {foo|class c = object method foo = 1 [@@argle] end |foo} ;
     official_input = OK {foo|class c = object method foo = 1 [@@argle] end |foo} ;
     r_input = OK {foo|class c = object method foo = 1[@@argle]; end; |foo} ;
     o_output = OK {foo|class c = object method foo = 1[@@argle] end;;
|foo} ;
     official_output = OK {foo|class c = object method foo = 1[@@argle ] end|foo} ;
     r_output = OK {foo|class c = object method foo = 1[@@argle]; end;
|foo}
    };
    {name="class-decl-item-attributes1"; implem = True ;
     exclude=[];
     o_input = OK {foo|class c = object end [@@argle] |foo} ;
     official_input = OK {foo|class c = object end [@@argle] |foo} ;
     r_input = OK {foo|class c = object end [@@argle] ;|foo} ;
     o_output = OK {foo|class c = object  end[@@argle];;
|foo} ;
     official_output = OK {foo|class c = object  end[@@argle ]|foo} ;
     r_output = OK {foo|class c = object  end[@@argle];
|foo}
    };
    {name="let-binding-item-attributes1"; implem = True ;
     exclude=[];
     o_input = OK {foo|let x = 1 [@@argle] in 2|foo} ;
     official_input = OK {foo|let x = 1 [@@argle] in 2|foo} ;
     r_input = OK {foo|let x = 1 [@@argle] in 2;|foo} ;
     o_output = OK {foo|let _ = let x = 1[@@argle] in 2;;
|foo};
     official_output = OK {foo|;;let x = 1[@@argle ] in 2|foo};
     r_output = OK {foo|let x = 1[@@argle] in
2;
|foo}
    };
    {name="let-binding-item-attributes2"; implem = True ;
     exclude=[];
     o_input = OK {foo|let [@argle] x = 1 in 2|foo} ;
     official_input = OK {foo|let [@argle] x = 1 in 2|foo} ;
     r_input = SKIP {foo|let [@argle] x = 1 in 2;|foo} "this isn't allowed in revised syntax (and won't be)";
     o_output = OK {foo|let _ = let x = 1[@@argle] in 2;;
|foo};
     official_output = OK {foo|;;let x = 1[@@argle ] in 2|foo};
     r_output = OK {foo|let x = 1[@@argle] in
2;
|foo}
    };
    {name="letop-binding-item-attributes1-FAILS"; implem = True ;
     exclude=[];
     o_input = EXN {foo|let|| x = 1 [@@argle] in 2|foo}
                   (Ploc.Exc Ploc.dummy (Stdlib.Stream.Error
                    "[andop_binding] expected after [letop_binding] (in [expr])")) ;
     official_input = EXN {foo|let|| x = 1 [@@argle] in 2|foo}
                   (Syntaxerr.Error (Syntaxerr.Other Location.none)) ;
     r_input = EXN {foo|let|| x = 1 [@@argle] in 2;|foo}
                   (Ploc.Exc Ploc.dummy (Stdlib.Stream.Error
                    "[andop_binding] expected after [letop_binding] (in [expr])")) ;
     o_output = OK "should never get here";
     official_output = OK "should never get here";
     r_output = OK "should never get here"
    };
    {name="open-item-attributes1"; implem = True ;
     exclude=[];
     o_input = OK {foo|open Foo [@@argle]|foo} ;
     official_input = OK {foo|open Foo [@@argle]|foo} ;
     r_input = OK {foo|open Foo [@@argle];|foo} ;
     o_output = OK {foo|open Foo[@@argle];;
|foo};
     official_output = OK {foo|open Foo[@@argle ]|foo};
     r_output = OK {foo|open Foo[@@argle];
|foo}
    };
    {name="floating-attributes1"; implem = True ;
     exclude=[];
     o_input = OK {foo|[@@@argle]|foo} ;
     official_input = OK {foo|[@@@argle]|foo} ;
     r_input = OK {foo|[@@@argle];|foo} ;
     o_output = OK {foo|[@@@argle];;
|foo};
     official_output = OK {foo|[@@@argle ]|foo};
     r_output = OK {foo|[@@@argle];
|foo}
    };
    {name="floating-attributes2"; implem = False ;
     exclude=[];
     o_input = OK {foo|[@@@argle]|foo} ;
     official_input = OK {foo|[@@@argle]|foo} ;
     r_input = OK {foo|[@@@argle];|foo} ;
     o_output = OK {foo|[@@@argle];;
|foo};
     official_output = OK {foo|[@@@argle ]|foo};
     r_output = OK {foo|[@@@argle];
|foo}
    };
    {name="let-exception1"; implem = True ;
     exclude=[];
     o_input = OK {foo|let exception E [@algattr] in 1 [@@itemattr]|foo} ;
     official_input = OK {foo|let exception E[@algattr] in 1 [@@itemattr]|foo} ;
     r_input = OK {foo|let exception E[@algattr] in 1 [@@itemattr];|foo} ;
     o_output = OK {foo|let _ = let exception E[@algattr] in 1[@@itemattr];;
|foo};
     official_output = OK {foo|;;let exception E [@algattr ] in 1[@@itemattr ]|foo};
     r_output = OK {foo|let exception E[@algattr] in 1[@@itemattr];
|foo}
    };
    {name="let-exception2"; implem = True ;
     exclude=[];
     o_input = OK {foo|let exception E of (int [@algattr2])[@algattr] in 1 [@@itemattr]|foo} ;
     official_input = OK {foo|let exception E of (int [@algattr2])[@algattr] in 1 [@@itemattr]|foo} ;
     r_input = OK {foo|let exception E of (int [@algattr2])[@algattr] in 1 [@@itemattr];|foo} ;
     o_output = OK {foo|let _ = let exception E of (int[@algattr2])[@algattr] in 1[@@itemattr];;
|foo};
     official_output = OK {foo|;;let exception E of ((int)[@algattr2 ]) [@algattr ] in 1[@@itemattr ]|foo};
     r_output = OK {foo|let exception E of (int[@algattr2])[@algattr] in 1[@@itemattr];
|foo}
    };
    {name="pat-exception1"; implem = True ;
     exclude=[];
     o_input = OK {foo|match x with exception E -> 1|foo} ;
     official_input = OK {foo|match x with exception E -> 1|foo} ;
     r_input = OK {foo|match x with [ exception E -> 1 ];|foo} ;
     o_output = OK {foo|let _ = match x with exception E -> 1;;
|foo};
     official_output = OK {foo|;;match x with | exception E -> 1|foo};
     r_output = OK {foo|match x with [ exception E → 1 ];
|foo}
    };
    {name="pat-exception1"; implem = True ;
     exclude=[];
     o_input = OK {foo|match x with exception E.F -> 1|foo} ;
     official_input = OK {foo|match x with exception E.F -> 1|foo} ;
     r_input = OK {foo|match x with [ exception E.F -> 1 ];|foo} ;
     o_output = OK {foo|let _ = match x with exception E.F -> 1;;
|foo};
     official_output = OK {foo|;;match x with | exception E.F -> 1|foo};
     r_output = OK {foo|match x with [ exception E.F → 1 ];
|foo}
    };
    {name="pat-exception2"; implem = True ;
     exclude=["r2official"];
     o_input = OK {foo|match x with exception E.F _ -> 1|foo} ;
     official_input = OK {foo|match x with exception E.F _ -> 1|foo} ;
     r_input = OK {foo|match x with [ exception E.F _ -> 1 ];|foo} ;
     o_output = OK {foo|let _ = match x with exception E.F _ -> 1;;
|foo};
     official_output = OK {foo|;;match x with | exception E.F _ -> 1|foo};
     r_output = OK {foo|match x with [ exception E.F _ → 1 ];
|foo}
    };
    {name="unary-plus1"; implem = True ;
     exclude=[];
     o_input = OK {foo|+ 1|foo} ;
     official_input = OK {foo|+ 1|foo} ;
     r_input = OK {foo|+ 1;|foo} ;
     o_output = OK {foo|let _ = 1;;
|foo};
     official_output = OK {foo|;;1|foo} ;
     r_output = OK {foo|1;
|foo}
    };
    {name="unary-plus2"; implem = True ;
     exclude=[];
     o_input = OK {foo|+. 1.|foo} ;
     official_input = OK {foo|+. 1.|foo} ;
     r_input = OK {foo|+. 1.;|foo} ;
     o_output = OK {foo|let _ = 1.;;
|foo};
     official_output = OK {foo|;;1.|foo} ;
     r_output = OK {foo|1.;
|foo}
    };
    {name="unary-plus3"; implem = True ;
     exclude=[];
     o_input = OK {foo|+ x|foo} ;
     official_input = OK {foo|+ x|foo} ;
     r_input = OK {foo|+ x;|foo} ;
     o_output = OK {foo|let _ = +x;;
|foo};
     official_output = OK {foo|;;+ x|foo} ;
     r_output = OK {foo|+x;
|foo}
    };
    {name="unary-plus4"; implem = True ;
     exclude=[];
     o_input = OK {foo|+ + x|foo} ;
     official_input = OK {foo|+ + x|foo} ;
     r_input = OK {foo|+ +x;|foo} ;
     o_output = OK {foo|let _ = +(+x);;
|foo};
     official_output = OK {foo|;;+ (+ x)|foo} ;
     r_output = OK {foo|+(+x);
|foo}
    };
    {name="module-record1"; implem = True ;
     exclude=[];
     o_input = OK {foo|M.{a = b}|foo} ;
     official_input = OK {foo|M.{a = b}|foo} ;
     r_input = OK {foo|M.{a = b};|foo} ;
     o_output = OK {foo|let _ = M.{a = b};;
|foo};
     official_output = OK {foo|;;let open M in { a = b }|foo} ;
     r_output = OK {foo|M.{a = b};
|foo}
    };
    {name="module-begin1"; implem = True ;
     exclude=[];
     o_input = OK {foo|M.(a; b; c)|foo} ;
     official_input = OK {foo|M.(a; b; c)|foo} ;
     r_input = OK {foo|M.(do { a; b; c });|foo} ;
     o_output = OK {foo|let _ = M.( a; b; c );;
|foo};
     official_output = OK {foo|;;let open M in a; b; c|foo} ;
     r_output = OK {foo|M.(do { a; b; c });
|foo}
    };
    {name="module-record2a"; implem = True ;
     exclude=[];
     o_input = OK {foo|M.N.a|foo} ;
     official_input = OK {foo|M.N.a|foo} ;
     r_input = OK {foo|M.N.a;|foo} ;
     o_output = OK {foo|let _ = M.N.a;;
|foo};
     official_output = OK {foo|;;M.N.a|foo} ;
     r_output = OK {foo|M.N.a;
|foo}
    };
    {name="module-record2b"; implem = True ;
     exclude=[];
     o_input = OK {foo|M.N.(::)|foo} ;
     official_input = OK {foo|M.N.(::)|foo} ;
     r_input = OK {foo|M.N.(::);|foo} ;
     o_output = OK {foo|let _ = M.N.( :: );;
|foo};
     official_output = OK {foo|;;M.N.(::)|foo} ;
     r_output = OK {foo|M.N.( :: );
|foo}
    };
    {name="module-record2"; implem = True ;
     exclude=[];
     o_input = OK {foo|M.N.{a = b}|foo} ;
     official_input = OK {foo|M.N.{a = b}|foo} ;
     r_input = OK {foo|M.N.{a = b};|foo} ;
     o_output = OK {foo|let _ = M.N.{a = b};;
|foo};
     official_output = OK {foo|;;let open M.N in { a = b }|foo} ;
     r_output = OK {foo|M.N.{a = b};
|foo}
    };
    {name="dot-parens-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|M.N.(::)|foo} ;
     official_input = OK {foo|M.N.(::)|foo} ;
     r_input = OK {foo|M.N.( :: );|foo} ;
     o_output = OK {foo|let _ = M.N.( :: );;
|foo};
     official_output = OK {foo|;;M.N.(::)|foo} ;
     r_output = OK {foo|M.N.( :: );
|foo}
    };
    {name="dot-parens-2"; implem = True ;
     exclude=["r2official";"o2official"];
     o_input = OK {foo|M.N.(x)|foo} ;
     official_input = OK {foo|M.N.(x)|foo} ;
     r_input = OK {foo|M.N.(x);|foo} ;
     o_output = OK {foo|let _ = M.N.x;;
|foo};
     official_output = OK {foo|;;let open M.N in x|foo} ;
     r_output = OK {foo|M.N.x;
|foo}
    };
    {(skip) with
     name="dot-parens-2-[ro]2official"; implem = True ;
     exclude=[];
     o_input = OK {foo|M.N.(x)|foo} ;
     r_input = OK {foo|M.N.(x);|foo} ;
     official_output = OK {foo|;;M.N.x|foo}
    };
    {name="dot-parens-4"; implem = True ;
     exclude=[];
     o_input = OK {foo|M.N.(a + b)|foo} ;
     official_input = OK {foo|M.N.(a + b)|foo} ;
     r_input = OK {foo|M.N.(a + b);|foo} ;
     o_output = OK {foo|let _ = M.N.(a + b);;
|foo};
     official_output = OK {foo|;;let open M.N in a + b|foo} ;
     r_output = OK {foo|M.N.(a + b);
|foo}
    };
    {name="dot-curly-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|M.N.{a=b}|foo} ;
     official_input = OK {foo|M.N.{a=b}|foo} ;
     r_input = OK {foo|M.N.{a=b};|foo} ;
     o_output = OK {foo|let _ = M.N.{a = b};;
|foo};
     official_output = OK {foo|;;let open M.N in { a = b }|foo} ;
     r_output = OK {foo|M.N.{a = b};
|foo}
    };
    {name="dot-curly-2"; implem = True ;
     exclude=[];
     o_input = OK {foo|M.N.({a=b})|foo} ;
     official_input = OK {foo|M.N.({a=b})|foo} ;
     r_input = OK {foo|M.N.({a = b});|foo} ;
     o_output = OK {foo|let _ = M.N.{a = b};;
|foo};
     official_output = OK {foo|;;let open M.N in { a = b }|foo} ;
     r_output = OK {foo|M.N.{a = b};
|foo}
    };
    {name="dot-curly-3"; implem = True ;
     exclude=[];
     o_input = OK {foo|M.N.{e with a = b}|foo} ;
     official_input = OK {foo|M.N.{e with a = b}|foo} ;
     r_input = OK {foo|M.N.{(e) with a = b};|foo} ;
     o_output = OK {foo|let _ = M.N.{e with a = b};;
|foo};
     official_output = OK {foo|;;let open M.N in { e with a = b }|foo} ;
     r_output = OK {foo|M.N.{(e) with a = b};
|foo}
    };
    {name="dot-curly-4"; implem = True ;
     exclude=[];
     o_input = OK {foo|M.N.({e with a = b})|foo} ;
     official_input = OK {foo|M.N.({e with a = b})|foo} ;
     r_input = OK {foo|M.N.({(e) with a = b});|foo} ;
     o_output = OK {foo|let _ = M.N.{e with a = b};;
|foo};
     official_output = OK {foo|;;let open M.N in { e with a = b }|foo} ;
     r_output = OK {foo|M.N.{(e) with a = b};
|foo}
    };
    {name="dot-curly-5"; implem = True ;
     exclude=[];
     o_input = OK {foo|n.{a}|foo} ;
     official_input = OK {foo|n.{a}|foo} ;
     r_input = OK {foo|n.{a};|foo} ;
     o_output = OK {foo|let _ = n.{a};;
|foo};
     official_output = OK {foo|;;n.{a}|foo} ;
     r_output = OK {foo|n.{a};
|foo}
    };
    {name="dot-curly-6"; implem = True ;
     exclude=[];
     o_input = OK {foo|n.{M.a}|foo} ;
     official_input = OK {foo|n.{M.a}|foo} ;
     r_input = OK {foo|n.{M.a};|foo} ;
     o_output = OK {foo|let _ = n.{M.a};;
|foo};
     official_output = OK {foo|;;n.{M.a}|foo} ;
     r_output = OK {foo|n.{M.a};
|foo}
    };
    {name="constructors-1"; implem = True ;
     exclude=["r2official"];
     o_input = OK {foo|A(b,c)|foo} ;
     official_input = OK {foo|A(b,c)|foo} ;
     r_input = OK {foo|A b c;|foo} ;
     o_output = OK {foo|let _ = A (b, c);;
|foo};
     official_output = OK {foo|;;A (b, c)|foo} ;
     r_output = OK {foo|A b c;
|foo}
    };
    {(skip) with
     name="constructors-1-r2official";
     r_input = OK {foo|A b c;|foo} ;
     official_output = OK {foo|;;((A (b, c))[@ocaml.explicit_arity ])|foo}
    };
    {name="dot-lbracket-0"; implem = True ;
     exclude=["r2official"];
     o_input = OK {foo|[a;b]|foo} ;
     official_input = OK {foo|[a;b]|foo} ;
     r_input = OK {foo|[a;b];|foo} ;
     o_output = OK {foo|let _ = [a; b];;
|foo};
     official_output = OK {foo|;;[a; b]|foo} ;
     r_output = OK {foo|[a; b];
|foo}
    };
    {(skip) with
     name="dot-lbracket-0-r2official";
     r_input = OK {foo|[a;b];|foo} ;
     official_output = OK {foo|;;((a :: (([b])[@ocaml.explicit_arity ]))[@ocaml.explicit_arity ])|foo}
    };
    {name="dot-lbracket-1"; implem = True ;
     exclude=["r2official"];
     o_input = OK {foo|M.[a;b]|foo} ;
     official_input = OK {foo|M.[a;b]|foo} ;
     r_input = OK {foo|M.[a;b];|foo} ;
     o_output = OK {foo|let _ = M.[a; b];;
|foo};
     official_output = OK {foo|;;let open M in [a; b]|foo} ;
     r_output = OK {foo|M.[a; b];
|foo}
    };
    {(skip) with
     name="dot-lbracket-1-r2official";
     r_input = OK {foo|M.[a;b];|foo} ;
     official_output = OK {foo|;;let open M in ((a :: (([b])[@ocaml.explicit_arity ]))
    [@ocaml.explicit_arity ])|foo}
    };
    {name="dot-lbracket-2"; implem = True ;
     exclude=["o2official"; "r2official"];
     o_input = OK {foo|M.[]|foo} ;
     official_input = OK {foo|M.[]|foo} ;
     r_input = OK {foo|M.[];|foo} ;
     o_output = OK {foo|let _ = M.[];;
|foo};
     official_output = OK {foo|;;let open M in []|foo} ;
     r_output = OK {foo|M.[];
|foo}
    };
    {(skip) with
     name="dot-lbracket-2-[or]2official";
     o_input = OK {foo|M.[]|foo} ;
     r_input = OK {foo|M.[];|foo} ;
     official_output = OK {foo|;;M.[]|foo}
    };
    {name="module-record3"; implem = True ;
     exclude=[];
     o_input = OK {foo|M.N.{e with a = b}|foo} ;
     official_input = OK {foo|M.N.{e with a = b}|foo} ;
     r_input = OK {foo|M.N.{(e) with a = b};|foo} ;
     o_output = OK {foo|let _ = M.N.{e with a = b};;
|foo};
     official_output = OK {foo|;;let open M.N in { e with a = b }|foo} ;
     r_output = OK {foo|M.N.{(e) with a = b};
|foo}
    };
    {name="module-alias1"; implem = False ;
     exclude=[];
     o_input = OK {foo|module T = A.B.C|foo} ;
     official_input = OK {foo|module T = A.B.C|foo} ;
     r_input = OK {foo|module alias T = A.B.C;|foo} ;
     o_output = OK {foo|module T = A.B.C;;
|foo};
     official_output = OK {foo|module T = A.B.C|foo} ;
     r_output = OK {foo|module alias T = A.B.C;
|foo}
    };
    {name="labeled-field-alg-attribute1"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = { a : int [@attr] ; }|foo} ;
     official_input = OK {foo|type t = { a : int [@attr] ; }|foo} ;
     r_input = OK {foo|type t = { a : int[@attr] };|foo} ;
     o_output = OK {foo|type t = { a : int[@attr] };;
|foo};
     official_output = OK {foo|type t = {
  a: int [@attr ]}|foo} ;
     r_output = OK {foo|type t = { a : int[@attr] };
|foo}
    };
    {name="labeled-field-alg-attribute2"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = { a : int [@attr] ; [@attr2] }|foo} ;
     official_input = OK {foo|type t = { a : int [@attr] ;  [@attr2]}|foo} ;
     r_input = OK {foo|type t = { a : int[@attr] [@attr2] };|foo} ;
     o_output = OK {foo|type t = { a : int[@attr] [@attr2] };;
|foo};
     official_output = OK {foo|type t = {
  a: int [@attr ][@attr2 ]}|foo} ;
     r_output = OK {foo|type t = { a : int[@attr] [@attr2] };
|foo}
    };
    {name="val-attributes1"; implem = False ;
     exclude=[];
     o_input = OK {foo|val x : int [@@attr2]|foo} ;
     official_input = OK {foo|val x : int [@@attr2]|foo} ;
     r_input = OK {foo|value x : int [@@attr2];|foo} ;
     o_output = OK {foo|val x : int[@@attr2];;
|foo};
     official_output = OK {foo|val x : int[@@attr2 ]|foo} ;
     r_output = OK {foo|value x : int[@@attr2];
|foo}
    };
    {name="val-attributes2"; implem = False ;
     exclude=[];
     o_input = OK {foo|val[@attr1] x : int [@@attr2]|foo} ;
     official_input = OK {foo|val[@attr1] x : int [@@attr2]|foo} ;
     r_input = OK {foo|value x : int [@@attr1][@@attr2];|foo} ;
     o_output = OK {foo|val x : int[@@attr1] [@@attr2];;
|foo};
     official_output = OK {foo|val x : int[@@attr1 ][@@attr2 ]|foo} ;
     r_output = OK {foo|value x : int[@@attr1] [@@attr2];
|foo}
    };
    {name="external-operator-sig-item"; implem = False ;
     exclude=[];
     o_input = OK {foo|external ( & ) : bool -> bool -> bool = "%sequand"
  [@@a "msg"]|foo} ;
     official_input = OK {foo|external ( & ) : bool -> bool -> bool = "%sequand"
  [@@a "msg"]|foo} ;
     r_input = OK {foo|external ( & ) : bool -> bool -> bool = "%sequand"
  [@@a "msg";];|foo} ;
     o_output = OK {foo|external (&) : bool -> bool -> bool = "%sequand"[@@a "msg"];;
|foo};
     official_output = OK {foo|external (&) : bool -> bool -> bool = "%sequand"[@@a "msg"]|foo} ;
     r_output = OK {foo|external ( & ) : bool → bool → bool = "%sequand"[@@a "msg";];
|foo}
    };
    {name="external-operator-str-item"; implem = True ;
     exclude=[];
     o_input = OK {foo|external ( & ) : bool -> bool -> bool = "%sequand"
  [@@a "msg"]|foo} ;
     official_input = OK {foo|external ( & ) : bool -> bool -> bool = "%sequand"
  [@@a "msg"]|foo} ;
     r_input = OK {foo|external ( & ) : bool -> bool -> bool = "%sequand"
  [@@a "msg";];|foo} ;
     o_output = OK {foo|external (&) : bool -> bool -> bool = "%sequand"[@@a "msg"];;
|foo};
     official_output = OK {foo|external (&) : bool -> bool -> bool = "%sequand"[@@a "msg"]|foo} ;
     r_output = OK {foo|external ( & ) : bool → bool → bool = "%sequand"[@@a "msg";];
|foo}
    };
    {name="expr-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|let () = (f [@inlined never]) ()|foo} ;
     official_input = OK {foo|let () = (f [@inlined never]) ()|foo} ;
     r_input = OK {foo|value () = (f[@inlined never;]) ();|foo} ;
     o_output = OK {foo|let () = (f[@inlined never]) ();;
|foo};
     official_output = OK {foo|let () = ((f)[@inlined never]) ()|foo} ;
     r_output = OK {foo|value () = (f[@inlined never;]) ();
|foo}
    };
    {name="anon-module-argumet"; implem = True ;
     exclude=[];
     o_input = OK {foo|let f (module _ : S) = ()|foo} ;
     official_input = OK {foo|let f (module _ : S) = ()|foo} ;
     r_input = OK {foo|value f (module _ : S) = ();|foo} ;
     o_output = OK {foo|let f (module _ : S) = ();;
|foo};
     official_output = OK {foo|let f ((module _)  : (module S)) = ()|foo} ;
     r_output = OK {foo|value f (module _ : S) = ();
|foo}
    };
    {name="named-module-argumet"; implem = True ;
     exclude=[];
     o_input = OK {foo|let f (module M : S) = ()|foo} ;
     official_input = OK {foo|let f (module M : S) = ()|foo} ;
     r_input = OK {foo|value f (module M : S) = ();|foo} ;
     o_output = OK {foo|let f (module M : S) = ();;
|foo};
     official_output = OK {foo|let f ((module M)  : (module S)) = ()|foo} ;
     r_output = OK {foo|value f (module M : S) = ();
|foo}
    };
    {name="abstract-module-type-str-item"; implem = True ;
     exclude=[];
     o_input = OK {foo|module type S|foo} ;
     official_input = OK {foo|module type S|foo} ;
     r_input = OK {foo|module type S;|foo} ;
     o_output = OK {foo|module type S;;
|foo};
     official_output = OK {foo|module type S|foo} ;
     r_output = OK {foo|module type S;
|foo}
    };
    {name="alg-extension-ctyp"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = int * [%a]|foo} ;
     official_input = OK {foo|type t = int * [%a]|foo} ;
     r_input = OK {foo|type t = (int * [%a]);|foo} ;
     o_output = OK {foo|type t = int * [%a];;
|foo};
     official_output = OK {foo|type t = (int * [%a ])|foo} ;
     r_output = OK {foo|type t = (int * [%a]);
|foo}
    };
    {name="alg-extension-patt"; implem = True ;
     exclude=[];
     o_input = OK {foo|match x with (x, [%a]) -> 1|foo} ;
     official_input = OK {foo|match x with (x, [%a]) -> 1|foo} ;
     r_input = OK {foo|match x with [ (x, [%a]) -> 1 ];|foo} ;
     o_output = OK {foo|let _ = match x with x, [%a] -> 1;;
|foo};
     official_output = OK {foo|;;match x with | (x, [%a ]) -> 1|foo} ;
     r_output = OK {foo|match x with (x, [%a]) → 1;
|foo}
    };
    {name="alg-extension-expr"; implem = True ;
     exclude=[];
     o_input = OK {foo|let x = 1 + [%a]|foo} ;
     official_input = OK {foo|let x = 1 + [%a]|foo} ;
     r_input = OK {foo|value x = 1 + [%a];|foo} ;
     o_output = OK {foo|let x = 1 + [%a];;
|foo};
     official_output = OK {foo|let x = 1 + ([%a ])|foo} ;
     r_output = OK {foo|value x = 1 + [%a];
|foo}
    };
    {name="alg-extension-module-type"; implem = True ;
     exclude=[];
     o_input = OK {foo|module type S = sig module M : [%a] end|foo} ;
     official_input = OK {foo|module type S = sig module M : [%a] end|foo} ;
     r_input = OK {foo|module type S = sig module M : [%a]; end;|foo} ;
     o_output = OK {foo|module type S = sig module M : [%a] end;;
|foo};
     official_output = OK {foo|module type S  = sig module M : [%a ] end|foo} ;
     r_output = OK {foo|module type S = sig module M : [%a]; end;
|foo}
    };
    {name="alg-extension-sig-item"; implem = True ;
     exclude=[];
     o_input = OK {foo|module type S = sig [%%a] type t end|foo} ;
     official_input = OK {foo|module type S = sig [%%a] type t end|foo} ;
     r_input = OK {foo|module type S = sig [%%a]; type t = 'a; end;|foo} ;
     o_output = OK {foo|module type S = sig [%%a] type t end;;
|foo};
     official_output = OK {foo|module type S  = sig [%%a ] type t end|foo} ;
     r_output = OK {foo|module type S = sig [%%a]; type t = α; end;
|foo}
    };
    {name="alg-extension-module-expr"; implem = True ;
     exclude=[];
     o_input = OK {foo|module M = F([%a])|foo} ;
     official_input = OK {foo|module M = F([%a])|foo} ;
     r_input = OK {foo|module M = F([%a]);|foo} ;
     o_output = OK {foo|module M = F ([%a]);;
|foo};
     official_output = OK {foo|module M = (F)([%a ])|foo} ;
     r_output = OK {foo|module M = F [%a];
|foo}
    };
    {name="alg-extension-str-item"; implem = True ;
     exclude=[];
     o_input = OK {foo|module S = struct [%%a] type t end|foo} ;
     official_input = OK {foo|module S = struct [%%a] type t end|foo} ;
     r_input = OK {foo|module S = struct [%%a]; type t = 'a; end;|foo} ;
     o_output = OK {foo|module S = struct [%%a] type t end;;
|foo};
     official_output = OK {foo|module S = struct [%%a ]
                  type t end|foo} ;
     r_output = OK {foo|module S = struct [%%a]; type t = α; end;
|foo}
    };
    {name="alg-extension-class-sig-item"; implem = True ;
     exclude=[];
     o_input = OK {foo|class type ct = object val x : int [%%a] end|foo} ;
     official_input = OK {foo|class type ct = object val x : int [%%a] end|foo} ;
     r_input = OK {foo|class type ct = object value x : int; [%%a]; end;|foo} ;
     o_output = OK {foo|class type ct = object val x : int [%%a] end;;
|foo};
     official_output = OK {foo|class type ct = object val  x : int [%%a ] end|foo} ;
     r_output = OK {foo|class type ct = object value x : int; [%%a]; end;
|foo}
    };
    {name="alg-extension-class-str-item"; implem = True ;
     exclude=[];
     o_input = OK {foo|class ct = object val x = 1 [%%a] end|foo} ;
     official_input = OK {foo|class ct = object val x = 1 [%%a] end|foo} ;
     r_input = OK {foo|class ct = object value x = 1; [%%a]; end;|foo} ;
     o_output = OK {foo|class ct = object val x = 1 [%%a] end;;
|foo};
     official_output = OK {foo|class ct = object val x = 1 [%%a ] end|foo} ;
     r_output = OK {foo|class ct = object value x = 1; [%%a]; end;
|foo}
    };
    {name="alg-extension-class-expr"; implem = True ;
     exclude=[];
     o_input = OK {foo|class c = ([%a]) 1 |foo} ;
     official_input = OK {foo|class c = ([%a]) 1 |foo} ;
     r_input = OK {foo|class c = ([%a]) 1 ;|foo} ;
     o_output = OK {foo|class c = ([%a]) 1;;
|foo};
     official_output = OK {foo|class c = (([%a ]) 1)|foo} ;
     r_output = OK {foo|class c = ([%a]) 1;
|foo}
    };
    {name="alg-extension-class-str-item"; implem = True ;
     exclude=[];
     o_input = OK {foo|class type ct = object val x : int [%%a] end|foo} ;
     official_input = OK {foo|class type ct = object val x : int [%%a] end|foo} ;
     r_input = OK {foo|class type ct = object value x : int; [%%a]; end;|foo} ;
     o_output = OK {foo|class type ct = object val x : int [%%a] end;;
|foo};
     official_output = OK {foo|class type ct = object val  x : int [%%a ] end|foo} ;
     r_output = OK {foo|class type ct = object value x : int; [%%a]; end;
|foo}
    };
    {name="for-loop-index-var1"; implem = True ;
     exclude=[];
     o_input = OK {foo|for i = 1 to 10 do () done|foo} ;
     official_input = OK {foo|for i = 1 to 10 do () done|foo} ;
     r_input = OK {foo|for i = 1 to 10 do { () };|foo} ;
     o_output = OK {foo|let _ = for i = 1 to 10 do () done;;
|foo};
     official_output = OK {foo|;;for i = 1 to 10 do () done|foo} ;
     r_output = OK {foo|for i = 1 to 10 do { () };
|foo}
    };
    {name="for-loop-index-var2"; implem = True ;
     exclude=[];
     o_input = OK {foo|for (+) = 1 to 10 do () done|foo} ;
     official_input = OK {foo|for (+) = 1 to 10 do () done|foo} ;
     r_input = OK {foo|for (+) = 1 to 10 do { () };|foo} ;
     o_output = OK {foo|let _ = for (+) = 1 to 10 do () done;;
|foo};
     official_output = OK {foo|;;for (+) = 1 to 10 do () done|foo} ;
     r_output = OK {foo|for ( + ) = 1 to 10 do { () };
|foo}
    };
    {name="for-loop-index-var3"; implem = True ;
     exclude=[];
     o_input = OK {foo|for _ = 1 to 10 do () done|foo} ;
     official_input = OK {foo|for _ = 1 to 10 do () done|foo} ;
     r_input = OK {foo|for _ = 1 to 10 do { () };|foo} ;
     o_output = OK {foo|let _ = for _ = 1 to 10 do () done;;
|foo};
     official_output = OK {foo|;;for _ = 1 to 10 do () done|foo} ;
     r_output = OK {foo|for _ = 1 to 10 do { () };
|foo}
    };
    {name="record-label-patterns1"; implem = True ;
     exclude=[];
     o_input = OK {foo|let get_int { contents : int } = contents|foo} ;
     official_input = OK {foo|let get_int { contents : int } = contents|foo} ;
     r_input = OK {foo|value get_int { contents = (contents : int) } = contents;|foo} ;
     o_output = OK {foo|let get_int {contents = (contents : int)} = contents;;
|foo};
     official_output = OK {foo|let get_int { contents = (contents : int) } = contents|foo} ;
     r_output = OK {foo|value get_int {contents = (contents : int)} = contents;
|foo}
    };
    {name="record-label-patterns2"; implem = True ;
     exclude=[];
     o_input = OK {foo|let get_int { M.N.contents : int } = contents|foo} ;
     official_input = OK {foo|let get_int { M.N.contents : int } = contents|foo} ;
     r_input = OK {foo|value get_int { M.N.contents = (contents : int) } = contents;|foo} ;
     o_output = OK {foo|let get_int {M.N.contents = (contents : int)} = contents;;
|foo};
     official_output = OK {foo|let get_int { M.N.contents = (contents : int) } = contents|foo} ;
     r_output = OK {foo|value get_int {M.N.contents = (contents : int)} = contents;
|foo}
    };
    {name="record-label-patterns3"; implem = True ;
     exclude=[];
     o_input = OK {foo|let get_int { M.N.contents : int = c } = c|foo} ;
     official_input = OK {foo|let get_int { M.N.contents : int = c } = c|foo} ;
     r_input = OK {foo|value get_int { M.N.contents = (c : int) } = c;|foo} ;
     o_output = OK {foo|let get_int {M.N.contents = (c : int)} = c;;
|foo};
     official_output = OK {foo|let get_int { M.N.contents = (c : int) } = c|foo} ;
     r_output = OK {foo|value get_int {M.N.contents = (c : int)} = c;
|foo}
    };
    {name="record-label-expression1"; implem = True ;
     exclude=[];
     o_input = OK {foo|let set_int contents = { contents : int }|foo} ;
     official_input = OK {foo|let set_int contents = { contents : int }|foo} ;
     r_input = OK {foo|value set_int contents = { contents = (contents : int) };|foo} ;
     o_output = OK {foo|let set_int contents = {contents = (contents : int)};;
|foo};
     official_output = OK {foo|let set_int contents = { contents = (contents : int) }|foo} ;
     r_output = OK {foo|value set_int contents = {contents = (contents : int)};
|foo}
    };
    {name="record-label-expression2"; implem = True ;
     exclude=[];
     o_input = OK {foo|let set_int2 c = { contents : int = c }|foo} ;
     official_input = OK {foo|let set_int2 c = { contents : int = c }|foo} ;
     r_input = OK {foo|value set_int2 c = { contents = (c : int) };|foo} ;
     o_output = OK {foo|let set_int2 c = {contents = (c : int)};;
|foo};
     official_output = OK {foo|let set_int2 c = { contents = (c : int) }|foo} ;
     r_output = OK {foo|value set_int2 c = {contents = (c : int)};
|foo}
    };
    {name="module-expr-unpack-module1"; implem = True ;
     exclude=[];
     o_input = OK {foo|module M = F(val string)|foo} ;
     official_input = OK {foo|module M = F(val string)|foo} ;
     r_input = OK {foo|module M = F(value string);|foo} ;
     o_output = OK {foo|module M = F ((val string));;
|foo};
     official_output = OK {foo|module M = (F)((val string))|foo} ;
     r_output = OK {foo|module M = F (value string);
|foo}
    };
    {name="module-expr-unpack-module2"; implem = True ;
     exclude=[];
     o_input = OK {foo|module M = F(val string : MT)|foo} ;
     official_input = OK {foo|module M = F(val string : MT)|foo} ;
     r_input = OK {foo|module M = F(value string : MT);|foo} ;
     o_output = OK {foo|module M = F ((val string : MT));;
|foo};
     official_output = OK {foo|module M = (F)((val (string : (module MT))))|foo} ;
     r_output = OK {foo|module M = F (value string : MT);
|foo}
    };
    {name="module-expr-unpack-module3"; implem = True ;
     exclude=[];
     o_input = OK {foo|module M = F(val string : MT :> MT2)|foo} ;
     official_input = OK {foo|module M = F(val string : MT :> MT2)|foo} ;
     r_input = OK {foo|module M = F(value string : MT :> MT2);|foo} ;
     o_output = OK {foo|module M = F ((val string : MT :> MT2));;
|foo};
     official_output = OK {foo|module M = (F)((val (string : (module MT)  :> (module MT2))))|foo} ;
     r_output = OK {foo|module M = F (value string : MT :> MT2);
|foo}
    };
    {name="simplest-raw-strings-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|{|argle|}|foo} ;
     official_input = OK {foo|{|argle|}|foo} ;
     r_input = EXN {foo|{|argle|}|foo}
                   (Ploc.Exc Ploc.dummy
                              (Stdlib.Stream.Error "'(' or [label_expr] expected after '{' (in [expr])"));
     o_output = OK {foo|let _ = "argle";;
|foo};
     official_output = SKIP "meh" "meh" ;
     r_output = OK {foo|"argle";
|foo}
    };
    {name="simplest-raw-strings-2"; implem = True ;
     exclude=[];
     o_input = OK {foo|{|argle|}|foo} ;
     official_input = SKIP "meh" "meh";
     r_input = SKIP "meh" "meh" ;
     o_output = SKIP "meh" "meh" ;
     official_output = OK {foo|;;"argle"|foo} ;
     r_output = SKIP "meh" "meh" 
    };
    {name="simplest-raw-strings-3"; implem = True ;
     exclude=[];
     o_input = SKIP "meh" "meh";
     official_input = OK {foo|{|argle|}|foo} ;
     r_input = SKIP "meh" "meh" ;
     o_output = SKIP "meh" "meh" ;
     official_output = OK {foo|;;{|argle|}|foo} ;
     r_output = SKIP "meh" "meh" 
    };
    {name="poly-type-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|type tlist = { x: 'a. 'a list }|foo} ;
     official_input = OK {foo|type tlist = { x: 'a. 'a list }|foo} ;
     r_input = OK {foo|type tlist = { x : ! 'a . list 'a };|foo} ;
     o_output = OK {foo|type tlist = { x : 'a . 'a list };;
|foo};
     official_output = OK {foo|type tlist = {
  x: 'a . 'a list }|foo} ;
     r_output = OK {foo|type tlist = { x : ! α . list α };
|foo}
    };
    {name="unreachable-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|match x with pat -> .|foo} ;
     official_input = OK {foo|match x with pat -> .|foo} ;
     r_input = OK {foo|match x with [ pat -> . ];|foo} ;
     o_output = OK {foo|let _ = match x with pat -> .;;
|foo};
     official_output = OK {foo|;;match x with | pat -> .|foo} ;
     r_output = OK {foo|match x with pat → .;
|foo}
    };
    {name="unreachable-2"; implem = True ;
     exclude=[];
     o_input = EXN {foo|.|foo} (Ploc.Exc Ploc.dummy (Stdlib.Stream.Error "illegal begin of implem")) ;
     official_input = EXN {foo|.|foo} (Syntaxerr.Error (Syntaxerr.Other Location.none)) ;
     r_input = OK {foo| . ;|foo} ;
     o_output = EXN "" (Ploc.Exc Ploc.dummy
                        (Failure "pr_expr of (PaUnr _) not allowed except at rhs of match-case"));
     official_output = EXN ""
       (Ploc.Exc Ploc.dummy
          (Failure "bad ast ExUnr (parses as '.'; cannot have an ExUnr except at the rhs of match-case)")) ;
     r_output = OK {foo|.;
|foo}
    };
    {name="inline-record-types1"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = A of { a : int }|foo} ;
     official_input = OK {foo|type t = A of { a : int }|foo} ;
     r_input = OK {foo|type t = [ A of { a : int } ];|foo} ;
     o_output = OK {foo|type t =
    A of { a : int };;
|foo};
     official_output = OK {foo|type t =
  | A of {
  a: int } |foo} ;
     r_output = OK {foo|type t =
  [ A of { a : int } ];
|foo}
    };
    {name="inline-record-types2"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = A of int * string | B of { a : int } | C of bool|foo} ;
     official_input = OK {foo|type t = A of int * string | B of { a : int } | C of bool|foo} ;
     r_input = OK {foo|type t = [ A of int and string | B of { a : int } | C of bool ];|foo} ;
     o_output = OK {foo|type t =
    A of int * string
  | B of { a : int }
  | C of bool;;
|foo};
     official_output = OK {foo|type t =
  | A of int * string 
  | B of {
  a: int } 
  | C of bool |foo} ;
     r_output = OK {foo|type t =
  [ A of int and string
  | B of { a : int }
  | C of bool ];
|foo}
    };
    {name="exception-record-type"; implem = True ;
     exclude=[];
     o_input = OK {foo|exception E of { a : int }|foo} ;
     official_input = OK {foo|exception E of { a : int }|foo} ;
     r_input = OK {foo|exception E of { a : int };|foo} ;
     o_output = OK {foo|exception E of { a : int };;
|foo};
     official_output = OK {foo|exception E of {
  a: int } |foo} ;
     r_output = OK {foo|exception E of { a : int };
|foo}
    };
    {name="exception-rebind1"; implem = True ;
     exclude=[];
     o_input = OK {foo|exception E = A.B|foo} ;
     official_input = OK {foo|exception E = A.B|foo} ;
     r_input = OK {foo|exception E = A.B;|foo} ;
     o_output = OK {foo|exception E = A.B;;
|foo};
     official_output = OK {foo|exception E = A.B|foo} ;
     r_output = OK {foo|exception E = A.B;
|foo}
    };
    {name="type-extension-str-item1"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t += A of int | B of { a : int }|foo} ;
     official_input = OK {foo|type t += A of int | B of { a : int }|foo} ;
     r_input = OK {foo|type t += [ A of int | B of { a : int } ];|foo} ;
     o_output = OK {foo|type t += A of int | B of { a : int };;
|foo};
     official_output = OK {foo|type t +=  
  | A of int 
  | B of {
  a: int } |foo} ;
     r_output = OK {foo|type t += [ A of int | B of { a : int } ];
|foo}
    };
    {name="type-extension-str-item2"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = exn = ..|foo} ;
     official_input = OK {foo|type t = exn = ..|foo} ;
     r_input = OK {foo|type t = exn == ..;|foo} ;
     o_output = OK {foo|type t = exn = ..;;
|foo};
     official_output = OK {foo|type t = exn = ..|foo} ;
     r_output = OK {foo|type t = exn == ..;
|foo}
    };
    {name="type-extension-str-item3"; implem = True ;
     exclude=[];
     o_input = OK {foo|type M.t += A of int | B of { a : int }|foo} ;
     official_input = OK {foo|type M.t += A of int | B of { a : int }|foo} ;
     r_input = OK {foo|type M.t += [ A of int | B of { a : int } ];|foo} ;
     o_output = OK {foo|type M.t += A of int | B of { a : int };;
|foo};
     official_output = OK {foo|type M.t +=  
  | A of int 
  | B of {
  a: int } |foo} ;
     r_output = OK {foo|type M.t += [ A of int | B of { a : int } ];
|foo}
    };
    {name="type-extension-str-item4"; implem = True ;
     exclude=[];
     o_input = OK {foo|type 'a t += A of int |foo} ;
     official_input = OK {foo|type 'a t += A of int|foo} ;
     r_input = OK {foo|type t 'a += [ A of int ];|foo} ;
     o_output = OK {foo|type 'a t += A of int;;
|foo} ;
     official_output = OK {foo|type 'a t +=  
  | A of int |foo} ;
     r_output = OK {foo|type t α += [ A of int ];
|foo}
    };
    {name="type-extension-sig-item1"; implem = False ;
     exclude=[];
     o_input = OK {foo|type t += A of int | B of { a : int }|foo} ;
     official_input = OK {foo|type t += A of int | B of { a : int }|foo} ;
     r_input = OK {foo|type t += [ A of int | B of { a : int } ];|foo} ;
     o_output = OK {foo|type t += A of int | B of { a : int };;
|foo};
     official_output = OK {foo|type t +=  
  | A of int 
  | B of {
  a: int } |foo} ;
     r_output = OK {foo|type t += [ A of int | B of { a : int } ];
|foo}
    };
    {name="list-type-def1"; implem = True ;
     exclude=[];
     o_input = OK {foo|type 'a t = 'a list = [] | (::) of 'a * 'a list|foo} ;
     official_input = OK {foo|type 'a t = 'a list = [] | (::) of 'a * 'a list|foo} ;
     r_input = OK {foo|type t 'a = list 'a == [ [] | (::) of 'a and list 'a ];|foo} ;
     o_output = OK {foo|type 'a t =
  'a list =
      []
    | ( :: ) of 'a * 'a list;;
|foo};
     official_output = OK {foo|type 'a t = 'a list =
  | [] 
  | (::) of 'a * 'a list |foo} ;
     r_output = OK {foo|type t α =
  list α ==
    [ []
    | ( :: ) of α and list α ];
|foo}
    };
    {name="extend-types-with-reference1"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t += A = A.A | B = A.B|foo} ;
     official_input = OK {foo|type t += A = A.A | B = A.B|foo} ;
     r_input = OK {foo|type t += [ A = A.A | B = A.B ];|foo} ;
     o_output = OK {foo|type t += A = A.A | B = A.B;;
|foo};
     official_output = OK {foo|type t +=  
  | A = A.A
  | B = A.B|foo} ;
     r_output = OK {foo|type t += [ A = A.A | B = A.B ];
|foo}
    };
    {name="lowercase-module-type1"; implem = True ;
     exclude=[];
     o_input = OK {foo|module type S = sig module type t module M: t end|foo} ;
     official_input = OK {foo|module type S = sig module type t module M: t end|foo} ;
     r_input = OK {foo|module type S = sig module type t; module M: t; end;|foo} ;
     o_output = OK {foo|module type S = sig module type t module M : t end;;
|foo};
     official_output = OK {foo|module type S  = sig module type t module M : t end|foo} ;
     r_output = OK {foo|module type S = sig module type t; module M : t; end;
|foo}
    };
    {name="extended-module-path1"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = A.B.D.t|foo} ;
     official_input = OK {foo|type t = A.B.D.t|foo} ;
     r_input = OK {foo|type t = A.B.D.t ;|foo} ;
     o_output = OK {foo|type t = A.B.D.t;;
|foo};
     official_output = OK {foo|type t = A.B.D.t|foo} ;
     r_output = OK {foo|type t = A.B.D.t;
|foo}
    };
    {name="extended-module-path2"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = A.B(C).D.t|foo} ;
     official_input = OK {foo|type t = A.B(C).D.t|foo} ;
     r_input = OK {foo|type t = A.B(C).D.t ;|foo} ;
     o_output = OK {foo|type t = A.B(C).D.t;;
|foo};
     official_output = OK {foo|type t = A.B(C).D.t|foo} ;
     r_output = OK {foo|type t = A.B(C).D.t;
|foo}
    };
    {name="module-type-longident1"; implem = True ;
     exclude=[];
     o_input = OK {foo|module type S = M.N.S|foo} ;
     official_input = OK {foo|module type S = M.N.S|foo} ;
     r_input = OK {foo|module type S = M.N.S;|foo} ;
     o_output = OK {foo|module type S = M.N.S;;
|foo};
     official_output = OK {foo|module type S  = M.N.S|foo} ;
     r_output = OK {foo|module type S = M.N.S;
|foo}
    };
    {name="module-type-longident2"; implem = True ;
     exclude=[];
     o_input = OK {foo|module type s = M.N.s|foo} ;
     official_input = OK {foo|module type s = M.N.s|foo} ;
     r_input = OK {foo|module type s = M.N.s;|foo} ;
     o_output = OK {foo|module type s = M.N.s;;
|foo};
     official_output = OK {foo|module type s  = M.N.s|foo} ;
     r_output = OK {foo|module type s = M.N.s;
|foo}
    };
    {name="module-type-longident3"; implem = True ;
     exclude=[];
     o_input = OK {foo|module type s = s|foo} ;
     official_input = OK {foo|module type s = s|foo} ;
     r_input = OK {foo|module type s = s;|foo} ;
     o_output = OK {foo|module type s = s;;
|foo};
     official_output = OK {foo|module type s  = s|foo} ;
     r_output = OK {foo|module type s = s;
|foo}
    };
    {name="module-type-longident4"; implem = True ;
     exclude=[];
     o_input = OK {foo|module type S = M.N(P).S|foo} ;
     official_input = OK {foo|module type S = M.N(P).S|foo} ;
     r_input = OK {foo|module type S = M.N(P).S;|foo} ;
     o_output = OK {foo|module type S = M.N(P).S;;
|foo};
     official_output = OK {foo|module type S  = M.N(P).S|foo} ;
     r_output = OK {foo|module type S = M.N(P).S;
|foo}
    };
    {name="-type-constr-longident1"; implem = True ;
     exclude=[];
     o_input = OK {foo|type ('a, 'b) s = ('b, 'a) M.N(P).t|foo} ;
     official_input = OK {foo|type ('a, 'b) s = ('b, 'a) M.N(P).t|foo} ;
     r_input = OK {foo|type s 'a 'b = M.N(P).t 'b 'a;|foo} ;
     o_output = OK {foo|type ('a, 'b) s = ('b, 'a) M.N(P).t;;
|foo};
     official_output = OK {foo|type ('a, 'b) s = ('b, 'a) M.N(P).t|foo} ;
     r_output = OK {foo|type s α β = M.N(P).t β α;
|foo}
    };
    {name="sig-open1"; implem = False ;
     exclude=[];
     o_input = OK {foo|open A.B(C)|foo} ;
     official_input = OK {foo|open A.B(C)|foo} ;
     r_input = OK {foo|open A.B(C);|foo} ;
     o_output = OK {foo|open A.B(C);;
|foo};
     official_output = OK {foo|open A.B(C)|foo} ;
     r_output = OK {foo|open A.B(C);
|foo}
    };
    {name="sig-item-type-nonrec"; implem = False ;
     exclude=[];
     o_input = OK {foo|module type S = sig type nonrec t = t end|foo} ;
     official_input = OK {foo|module type S = sig type nonrec t = t end|foo} ;
     r_input = OK {foo|module type S = sig type nonrec t = t ; end;|foo} ;
     o_output = OK {foo|module type S = sig type nonrec t = t end;;
|foo};
     official_output = OK {foo|module type S  = sig type nonrec t = t end|foo} ;
     r_output = OK {foo|module type S = sig type nonrec t = t; end;
|foo}
    };
    {name="sig-item-type-rec"; implem = False ;
     exclude=[];
     o_input = OK {foo|module type S = sig type t = t end|foo} ;
     official_input = OK {foo|module type S = sig type t = t end|foo} ;
     r_input = OK {foo|module type S = sig type t = t ; end;|foo} ;
     o_output = OK {foo|module type S = sig type t = t end;;
|foo};
     official_output = OK {foo|module type S  = sig type t = t end|foo} ;
     r_output = OK {foo|module type S = sig type t = t; end;
|foo}
    };
    {name="printing-letop1"; implem = True ;
     exclude=[];
     o_input = OK {foo|let (let+) = 1|foo} ;
     official_input = OK {foo|let (let+) = 1|foo} ;
     r_input = OK {foo|value (let+) = 1;|foo} ;
     o_output = OK {foo|let (let+) = 1;;
|foo};
     official_output = OK {foo|let (let+) = 1|foo} ;
     r_output = OK {foo|value ( let+ ) = 1;
|foo}
    };
    {name="printing-letop2"; implem = True ;
     exclude=[];
     o_input = OK {foo|let (let+) f x = 1|foo} ;
     official_input = OK {foo|let (let+) f x = 1|foo} ;
     r_input = OK {foo|value (let+) f x = 1;|foo} ;
     o_output = OK {foo|let (let+) f x = 1;;
|foo};
     official_output = OK {foo|let (let+) f x = 1|foo} ;
     r_output = OK {foo|value ( let+ ) f x = 1;
|foo}
    };
    {name="printing-letop3"; implem = True ;
     exclude=[];
     o_input = OK {foo|let x = let (let+) f x = 1 in ()|foo} ;
     official_input = OK {foo|let x = let (let+) f x = 1 in ()|foo} ;
     r_input = OK {foo|value x = let (let+) f x = 1 in ();|foo} ;
     o_output = OK {foo|let x = let (let+) f x = 1 in ();;
|foo};
     official_output = OK {foo|let x = let (let+) f x = 1 in ()|foo} ;
     r_output = OK {foo|value x =
  let ( let+ ) f x = 1 in
  ();
|foo}
    };
    {name="attributes-in-odd-locations1"; implem = True ;
     exclude=["official2official"];
     o_input = OK {foo|let (x[@foo1]) : unit [@foo2] = ()[@foo3]  [@@foo4]|foo} ;
     official_input = SKIP "meh" "meh" ;
     r_input = OK {foo|value x[@foo1] : unit [@foo2] = ()[@foo3]  [@@foo4];|foo} ;
     o_output = OK {foo|let (x[@foo1]) = (()[@foo3] : unit[@foo2])[@@foo4];;
|foo};
     official_output = OK {foo|let ((x)[@foo1 ]) = (((())[@foo3 ]) : ((unit)[@foo2 ]))[@@foo4 ]|foo} ;
     r_output = OK {foo|value x[@foo1] : unit[@foo2] = ()[@foo3][@@foo4];
|foo}
    };
    {name="attributes-in-odd-locations1-official2official"; implem = True ;
     exclude=[];
     o_input = SKIP "meh" "meh" ;
     official_input = OK {foo|let (x[@foo]) : unit [@foo] = ()[@foo]  [@@foo]|foo} ;
     r_input = SKIP "meh" "meh" ;
     o_output = SKIP "meh" "meh" ;
     official_output = OK {foo|let (((x)[@foo ]) : ((unit)[@foo ])) = ((())[@foo ])[@@foo ]|foo} ;
     r_output = SKIP "meh" "meh"
    };
    {name="attributes-in-odd-locations3-stripped"; implem = False ;
     exclude=[];
     o_input = OK {foo|include (module type of M) with type t := M.t|foo} ;
     official_input = OK {foo|include (module type of M) with type t := M.t|foo} ;
     r_input = OK {foo|include (module type of M) with type t := M.t;|foo} ;
     o_output = OK {foo|include module type of M with type t := M.t;;
|foo};
     official_output = OK {foo|include module type of M with type  t :=  M.t|foo} ;
     r_output = OK {foo|include module type of M with type t := M.t;
|foo}
    };
    {name="attributes-in-odd-locations3"; implem = False ;
     exclude=[];
     o_input = OK {foo|include (module type of (M[@foo]))[@foo] with type t := M.t[@foo]
    [@@foo]|foo} ;
     official_input = OK {foo|include (module type of (M[@foo]))[@foo] with type t := M.t[@foo]
    [@@foo]|foo} ;
     r_input = OK {foo|include (module type of (M[@foo]))[@foo] with type t := M.t[@foo]
    [@@foo];|foo} ;
     o_output = OK {foo|include (module type of M[@foo])[@foo] with type t := M.t[@foo][@@foo];;
|foo};
     official_output = OK {foo|include
  ((((module type of ((M)[@foo ]))[@foo ]) with type  t :=  M.t)[@foo ])
[@@foo ]|foo} ;
     r_output = OK {foo|include (module type of M[@foo])[@foo] with type t := M.t[@foo][@@foo];
|foo}
    };
    {name="attributes-in-odd-locations3test"; implem = False ;
     exclude=[];
     o_input = OK {foo|include (module type of M) with type t := M.t[@foo]|foo} ;
     official_input = OK {foo|include (module type of M) with type t := M.t[@foo]|foo} ;
     r_input = SKIP "" "" ;
     o_output = SKIP "" "";
     official_output = OK {foo|include ((module type of M with type  t :=  M.t)[@foo ])|foo} ;
     r_output = SKIP "" ""
    };
    {name="inline-extensions1"; implem = True ;
     exclude=[];
     o_input = OK {foo|let%foo x = 42|foo} ;
     official_input = OK {foo|let%foo x = 42|foo} ;
     r_input = OK {foo|value%foo x = 42;|foo} ;
     o_output = OK {foo|[%%foo let x = 42;;];;
|foo};
     official_output = OK {foo|[%%foo let x = 42]|foo} ;
     r_output = OK {foo|[%%foo value x = 42;];
|foo}
    };
    {name="inline-extensions2"; implem = True ;
     exclude=[];
     o_input = OK {foo|let%foo x = 42 in ()|foo} ;
     official_input = OK {foo|let%foo x = 42 in ()|foo} ;
     r_input = OK {foo|let%foo x = 42 in ();|foo} ;
     o_output = OK {foo|let _ = [%foo let x = 42 in ()];;
|foo};
     official_output = OK {foo|;;[%foo let x = 42 in ()]|foo} ;
     r_output = OK {foo|[%foo let x = 42 in
();];
|foo}
    };
    {name="inline-extensions3"; implem = True ;
     exclude=[];
     o_input = OK {foo|let module%foo [@foo] M = M in ()|foo} ;
     official_input = OK {foo|let module%foo [@foo] M = M in ()|foo} ;
     r_input = OK {foo|let module%foo [@foo] M = M in ();|foo} ;
     o_output = OK {foo|let _ = [%foo (let module M = M in ())[@foo]];;
|foo};
     official_output = OK {foo|;;[%foo ((let module M = M in ())[@foo ])]|foo} ;
     r_output = OK {foo|[%foo (let module M = M in ())[@foo];];
|foo}
    };
    {name="inline-attributes-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|let module [@foo] M = M in ()|foo} ;
     official_input = OK {foo|let module [@foo] M = M in ()|foo} ;
     r_input = OK {foo|let module [@foo] M = M in ();|foo} ;
     o_output = OK {foo|let _ = (let module M = M in ())[@foo];;
|foo};
     official_output = OK {foo|;;((let module M = M in ())[@foo ])|foo} ;
     r_output = OK {foo|(let module M = M in ())[@foo];
|foo}
    };
    {name="inline-extensions4"; implem = True ;
     exclude=[];
     o_input = OK {foo|let open%foo [@foo] M in ()|foo} ;
     official_input = OK {foo|let open%foo [@foo] M in ()|foo} ;
     r_input = OK {foo|let open%foo [@foo] M in ();|foo} ;
     o_output = OK {foo|let _ = [%foo (let open M in ())[@foo]];;
|foo};
     official_output = OK {foo|;;[%foo ((let open M in ())[@foo ])]|foo} ;
     r_output = OK {foo|[%foo (let open M in ())[@foo];];
|foo}
    };
    {name="inline-extensions5"; implem = True ;
     exclude=[];
     o_input = OK {foo|(fun%foo[@foo] x -> ())|foo} ;
     official_input = OK {foo|(fun%foo[@foo] x -> ())|foo} ;
     r_input = OK {foo|(fun%foo[@foo] x -> ());|foo} ;
     o_output = OK {foo|let _ = [%foo (fun x -> ())[@foo]];;
|foo};
     official_output = OK {foo|;;[%foo ((fun x -> ())[@foo ])]|foo} ;
     r_output = OK {foo|[%foo (fun x → ())[@foo];];
|foo}
    };
    {name="inline-extensions6"; implem = True ;
     exclude=["official2official"];
     o_input = OK {foo|(function%foo[@foo] x -> ())|foo} ;
     official_input = SKIP "" "" ;
     r_input = OK {foo|(fun%foo[@foo] x -> ());|foo} ;
     o_output = OK {foo|let _ = [%foo (fun x -> ())[@foo]];;
|foo};
     official_output = OK {foo|;;[%foo ((fun x -> ())[@foo ])]|foo} ;
     r_output = OK {foo|[%foo (fun x → ())[@foo];];
|foo}
    };
    {name="inline-extensions6-official2official"; implem = True ;
     exclude=[];
     o_input = SKIP "" "" ;
     official_input = OK {foo|(function%foo[@foo] x -> ())|foo} ;
     r_input = SKIP "" "" ;
     o_output = SKIP "" "" ;
     official_output = OK {foo|;;[%foo ((function | x -> ())[@foo ])]|foo} ;
     r_output = SKIP "" ""
    };
    {name="inline-extensions7"; implem = True ;
     exclude=[];
     o_input = OK {foo|(try%foo[@foo] () with _ -> ())|foo} ;
     official_input = OK {foo|(try%foo[@foo] () with _ -> ())|foo} ;
     r_input = OK {foo|(try%foo[@foo] () with _ -> ());|foo} ;
     o_output = OK {foo|let _ = [%foo (try () with _ -> ())[@foo]];;
|foo};
     official_output = OK {foo|;;[%foo ((try () with | _ -> ())[@foo ])]|foo} ;
     r_output = OK {foo|[%foo (try () with _ → ())[@foo];];
|foo}
    };
    {name="inline-extensions8"; implem = True ;
     exclude=["official2official"];
     o_input = OK {foo|(if%foo[@foo] () then () else ())|foo} ;
     official_input = SKIP "" "" ;
     r_input = OK {foo|(if%foo[@foo] () then () else ());|foo} ;
     o_output = OK {foo|let _ = [%foo (if () then ())[@foo]];;
|foo};
     official_output = OK {foo|;;[%foo ((if () then ())[@foo ])]|foo} ;
     r_output = OK {foo|[%foo (if () then () else ())[@foo];];
|foo}
    };
    {name="inline-extensions8-official2official"; implem = True ;
     exclude=[];
     o_input = SKIP "" "" ;
     official_input = OK {foo|(if%foo[@foo] () then () else ())|foo} ;
     r_input = SKIP "" "" ;
     o_output = SKIP "" "" ;
     official_output = OK {foo|;;[%foo ((if () then () else ())[@foo ])]|foo} ;
     r_output = SKIP "" ""
    };
    {name="inline-extensions9"; implem = True ;
     exclude=[];
     o_input = OK {foo|while%foo[@foo] () do () done|foo} ;
     official_input = OK {foo|while%foo[@foo] () do () done|foo} ;
     r_input = OK {foo|while%foo[@foo] () do { () };|foo} ;
     o_output = OK {foo|let _ = [%foo (while () do () done)[@foo]];;
|foo};
     official_output = OK {foo|;;[%foo ((while () do () done)[@foo ])]|foo} ;
     r_output = OK {foo|[%foo (while () do { () })[@foo];];
|foo}
    };
    {name="inline-extensions10"; implem = True ;
     exclude=[];
     o_input = OK {foo|for%foo[@foo] x = () to () do () done|foo} ;
     official_input = OK {foo|for%foo[@foo] x = () to () do () done|foo} ;
     r_input = OK {foo|for%foo[@foo] x = () to () do { () };|foo} ;
     o_output = OK {foo|let _ = [%foo (for x = () to () do () done)[@foo]];;
|foo};
     official_output = OK {foo|;;[%foo ((for x = () to () do () done)[@foo ])]|foo} ;
     r_output = OK {foo|[%foo (for x = () to () do { () })[@foo];];
|foo}
    };
    {name="inline-extensions11"; implem = True ;
     exclude=[];
     o_input = OK {foo|assert%foo[@foo] true|foo} ;
     official_input = OK {foo|assert%foo[@foo] true|foo} ;
     r_input = OK {foo|assert%foo[@foo] True;|foo} ;
     o_output = OK {foo|let _ = [%foo assert true[@foo]];;
|foo};
     official_output = OK {foo|;;[%foo ((assert true)[@foo ])]|foo} ;
     r_output = OK {foo|[%foo assert True[@foo];];
|foo}
    };
    {name="inline-extensions12"; implem = True ;
     exclude=[];
     o_input = OK {foo|lazy%foo[@foo] x|foo} ;
     official_input = OK {foo|lazy%foo[@foo] x|foo} ;
     r_input = OK {foo|lazy%foo[@foo] x;|foo} ;
     o_output = OK {foo|let _ = [%foo lazy x[@foo]];;
|foo};
     official_output = OK {foo|;;[%foo ((lazy x)[@foo ])]|foo} ;
     r_output = OK {foo|[%foo lazy x[@foo];];
|foo}
    };
    {name="inline-extensions13"; implem = True ;
     exclude=[];
     o_input = OK {foo|object%foo[@foo] end|foo} ;
     official_input = OK {foo|object%foo[@foo] end|foo} ;
     r_input = OK {foo|object%foo[@foo] end;|foo} ;
     o_output = OK {foo|let _ = [%foo object  end[@foo]];;
|foo};
     official_output = OK {foo|;;[%foo ((object  end)[@foo ])]|foo} ;
     r_output = OK {foo|[%foo object  end[@foo];];
|foo}
    };
    {name="inline-extensions14"; implem = True ;
     exclude=[];
     o_input = OK {foo|begin%foo[@foo] 3; 4 end|foo} ;
     official_input = OK {foo|begin%foo[@foo] 3; 4 end;|foo} ;
     r_input = OK {foo|do%foo[@foo] { 3; 4 };|foo} ;
     o_output = OK {foo|let _ = [%foo begin 3; 4 end[@foo]];;
|foo};
     official_output = OK {foo|;;[%foo ((3; 4)[@foo ])]|foo} ;
     r_output = OK {foo|[%foo (do { 3; 4 })[@foo];];
|foo}
    };
    {name="inline-extensions15"; implem = True ;
     exclude=[];
     o_input = OK {foo|new%foo[@foo] x|foo} ;
     official_input = OK {foo|new%foo[@foo] x|foo} ;
     r_input = OK {foo|new%foo[@foo] x;|foo} ;
     o_output = OK {foo|let _ = [%foo new x[@foo]];;
|foo};
     official_output = OK {foo|;;[%foo ((new x)[@foo ])]|foo} ;
     r_output = OK {foo|[%foo new x[@foo];];
|foo}
    };
    {name="inline-extensions16"; implem = True ;
     exclude=[];
     o_input = OK {foo|match%foo[@foo] () with x -> x|foo} ;
     official_input = OK {foo|match%foo[@foo] () with x -> x|foo} ;
     r_input = OK {foo|match%foo[@foo] () with x -> x;|foo} ;
     o_output = OK {foo|let _ = [%foo (match () with x -> x)[@foo]];;
|foo};
     official_output = OK {foo|;;[%foo ((match () with | x -> x)[@foo ])]|foo} ;
     r_output = OK {foo|[%foo (match () with x → x)[@foo];];
|foo}
    };
    {name="inline-extensions17"; implem = True ;
     exclude=[];
     o_input = OK {foo|match x with lazy%foo[@foo] x -> ()|foo} ;
     official_input = OK {foo|match x with lazy%foo[@foo] x -> ()|foo} ;
     r_input = OK {foo|match x with [ lazy%foo[@foo] x -> () ];|foo} ;
     o_output = OK {foo|let _ = match x with [%foo? lazy x[@foo]] -> ();;
|foo};
     official_output = OK {foo|;;match x with | [%foo ?(((lazy x))[@foo ])] -> ()|foo} ;
     r_output = OK {foo|match x with [%foo? lazy x[@foo]] → ();
|foo}
    };
    {name="inline-extensions18"; implem = True ;
     exclude=[];
     o_input = OK {foo|match x with exception%foo[@foo] x -> ()|foo} ;
     official_input = OK {foo|match x with exception%foo[@foo] x -> ()|foo} ;
     r_input = OK {foo|match x with [ exception%foo[@foo] x -> () ];|foo} ;
     o_output = OK {foo|let _ = match x with [%foo? exception x[@foo]] -> ();;
|foo};
     official_output = OK {foo|;;match x with | [%foo ?((exception x)[@foo ])] -> ()|foo} ;
     r_output = OK {foo|match x with [%foo? exception x[@foo]] → ();
|foo}
    };
    {name="inline-extensions18b"; implem = True ;
     exclude=[];
     o_input = OK {foo|match x with exception%foo[@foo] x -> ()| Y -> ()|foo} ;
     official_input = OK {foo|match x with exception%foo[@foo] x -> ()| Y -> ()|foo} ;
     r_input = OK {foo|match x with [ exception%foo[@foo] x -> () | Y -> ()];|foo} ;
     o_output = OK {foo|let _ =
  match x with
    [%foo? exception x[@foo]] -> ()
  | Y -> ();;
|foo};
     official_output = OK {foo|;;match x with | [%foo ?((exception x)[@foo ])] -> () | Y -> ()|foo} ;
     r_output = OK {foo|match x with
[ [%foo? exception x[@foo]] → ()
| Y → () ];
|foo}
    };
    {name="inline-extensions19"; implem = True ;
     exclude=[];
     o_input = OK {foo|class x =
  fun[@foo] x ->
  object
  end
|foo} ;
     official_input = OK {foo|class x =
  fun[@foo] x ->
  object
  end
|foo} ;
     r_input = OK {foo|class x =
  fun[@foo] x ->
  object
  end;
|foo} ;
     o_output = OK {foo|class x = (fun x -> object  end)[@foo];;
|foo};
     official_output = OK {foo|class x = ((fun x  -> object  end)[@foo ])|foo} ;
     r_output = OK {foo|class x = (fun x -> object  end)[@foo];
|foo}
    };
    {name="inline-attributes-2a"; implem = True ;
     exclude=[];
     o_input = OK {foo|class type t =
  object[@foo1]
    val[@foo4] mutable x : t
  end
|foo} ;
     official_input = OK {foo|class type t =
  object[@foo1]
    val[@foo4] mutable x : t
  end
|foo} ;
     r_input = OK {foo|class type t =
  object
    value mutable x : t[@@foo4];
  end[@foo1];|foo} ;
     o_output = OK {foo|class type t = object val mutable x : t[@@foo4] end[@foo1];;
|foo};
     official_output = OK {foo|class type t = object val  mutable x : t[@@foo4 ] end[@foo1 ]|foo} ;
     r_output = OK {foo|class type t = object value mutable x : t[@@foo4]; end[@foo1];
|foo}
    };
    {name="inline-attributes-2"; implem = True ;
     exclude=[];
     o_input = OK {foo|class type t =
  object[@foo1]
    inherit[@foo2] t
    val[@foo3] x : t
    val[@foo4] mutable x : t
    method[@foo5] x : t
    method[@foo6] private x : t
    constraint[@foo7] t = t'
    [@@@abc]
    [%%id]
    [@@@aaa]
  end
|foo} ;
     official_input = OK {foo|class type t =
  object[@foo1]
    inherit[@foo2] t
    val[@foo3] x : t
    val[@foo4] mutable x : t
    method[@foo5] x : t
    method[@foo6] private x : t
    constraint[@foo7] t = t'
    [@@@abc]
    [%%id]
    [@@@aaa]
  end
|foo} ;
     r_input = OK {foo|class type t =
  object
    inherit t[@@foo2];
    value x : t[@@foo3];
    value mutable x : t[@@foo4];
    method x : t[@@foo5];
    method private x : t[@@foo6];
    type t = t'[@@foo7];
    [@@@abc];
    [%%id];
    [@@@aaa];
  end[@foo1];|foo} ;
     o_output = OK {foo|class type t =
  object
    inherit t[@@foo2]
    val x : t[@@foo3]
    val mutable x : t[@@foo4]
    method x : t[@@foo5]
    method private x : t[@@foo6]
    constraint t = t'[@@foo7]
    [@@@abc]
    [%%id]
    [@@@aaa]
  end[@foo1];;
|foo};
     official_output = OK {foo|class type t =
  object
    inherit t[@@foo2 ]
    val  x : t[@@foo3 ]
    val  mutable x : t[@@foo4 ]
    method  x : t[@@foo5 ]
    method private  x : t[@@foo6 ]
    constraint t = t'[@@foo7 ]
    [@@@abc ]
    [%%id ]
    [@@@aaa ]
  end[@foo1 ]|foo} ;
     r_output = OK {foo|class type t =
  object
    inherit t[@@foo2];
    value x : t[@@foo3];
    value mutable x : t[@@foo4];
    method x : t[@@foo5];
    method private x : t[@@foo6];
    type t = t'[@@foo7];
    [@@@abc];
    [%%id];
    [@@@aaa];
  end[@foo1];
|foo}
    };
    {name="inline-attributes-3"; implem = True ;
     exclude=[];
     o_input = OK {foo|class x =
  fun[@foo] x ->
  let[@foo] x = 3 in
  object[@foo]
    inherit[@foo] x
    val[@foo] x = 3
    val[@foo] virtual x : t
    val![@foo] mutable x = 3
    method[@foo] x = 3
    method[@foo] virtual x : t
    method![@foo] private x = 3
    initializer[@foo] x
  end
|foo} ;
     official_input = OK {foo|class x =
  fun[@foo] x ->
  let[@foo] x = 3 in
  object[@foo]
    inherit[@foo] x
    val[@foo] x = 3
    val[@foo] virtual x : t
    val![@foo] mutable x = 3
    method[@foo] x = 3
    method[@foo] virtual x : t
    method![@foo] private x = 3
    initializer[@foo] x
  end
|foo} ;
     r_input = OK {foo|class x =
  (fun x ->
     let x = 3[@@foo] in
     object
       inherit x[@@foo];
       value x = 3[@@foo];
       value virtual x : t[@@foo];
       value! mutable x = 3[@@foo];
       method x = 3[@@foo];
       method virtual x : t[@@foo];
       method! private x = 3[@@foo];
       initializer x[@@foo];
     end[@foo])[@foo];|foo} ;
     o_output = OK {foo|class x =
  (fun x ->
     let x = 3[@@foo] in
     object
       inherit x[@@foo]
       val x = 3[@@foo]
       val virtual x : t[@@foo]
       val! mutable x = 3[@@foo]
       method x = 3[@@foo]
       method virtual x : t[@@foo]
       method! private x = 3[@@foo]
       initializer x[@@foo]
     end[@foo])[@foo];;
|foo};
     official_output = OK {foo|class x = ((fun x  -> let x = 3[@@foo ] in
  ((object
      inherit  x[@@foo ]
      val x = 3[@@foo ]
      val virtual x : t[@@foo ]
      val! mutable x = 3[@@foo ]
      method x = 3[@@foo ]
      method virtual  x : t[@@foo ]
      method! private x = 3[@@foo ]
      initializer x[@@foo ]
    end)[@foo ]))[@foo ])|foo} ;
     r_output = OK {foo|class x =
  (fun x ->
     let x = 3[@@foo] in
     object
       inherit x[@@foo];
       value x = 3[@@foo];
       value virtual x : t[@@foo];
       value! mutable x = 3[@@foo];
       method x = 3[@@foo];
       method virtual x : t[@@foo];
       method! private x = 3[@@foo];
       initializer x[@@foo];
     end[@foo])[@foo];
|foo}
    };
    {name="firstclass-modules1"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = (module M)|foo} ;
     official_input = OK {foo|type t = (module M)|foo} ;
     r_input = OK {foo|type t = (module M);|foo} ;
     o_output = OK {foo|type t = (module M);;
|foo};
     official_output = OK {foo|type t = (module M)|foo} ;
     r_output = OK {foo|type t = (module M);
|foo}
    };
    {name="firstclass-modules2"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = (module[@foo] M)|foo} ;
     official_input = OK {foo|type t = (module[@foo] M)|foo} ;
     r_input = OK {foo|type t = (module M[@foo]);|foo} ;
     o_output = OK {foo|type t = (module M[@foo]);;
|foo};
     official_output = OK {foo|type t = (((module M))[@foo ])|foo} ;
     r_output = OK {foo|type t = (module M[@foo]);
|foo}
    };
    {name="inline-extensions20"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = (module%foo[@foo] M)|foo} ;
     official_input = OK {foo|type t = (module%foo[@foo] M)|foo} ;
     r_input = OK {foo|type t = [%foo: (module M[@foo])];
|foo} ;
     o_output = OK {foo|type t = [%foo: (module M[@foo])];;
|foo};
     official_output = OK {foo|type t = [%foo :(((module M))[@foo ])]|foo} ;
     r_output = OK {foo|type t = [%foo: (module M[@foo])];
|foo}
    };
    {name="inline-attributes-4a"; implem = True ;
     exclude=[];
     o_input = OK {foo|module M =
  functor (M : S) ->
    (val x)
    (struct end)
|foo} ;
     official_input = OK {foo|module M =
  functor (M : S) ->
    (val x)
    (struct end)
|foo} ;
     r_input = OK {foo|module M (M : S) = (value x) (struct  end);|foo} ;
     o_output = OK {foo|module M (M : S) = (val x) (struct  end);;
|foo};
     official_output = OK {foo|module M(M:S) = ((val x))(struct  end)|foo} ;
     r_output = OK {foo|module M (M : S) = (value x) (struct  end);
|foo}
    };
    {name="inline-attributes-4"; implem = True ;
     exclude=[];
     o_input = OK {foo|module M =
  functor[@foo1] (M : S) ->
    (val[@foo2] x)
    (struct[@foo3] end)
|foo} ;
     official_input = OK {foo|module M =
  functor[@foo1] (M : S) ->
    (val[@foo2] x)
    (struct[@foo3] end)
|foo} ;
     r_input = OK {foo|module M = (functor (M : S) -> ((value x)[@foo2]) (struct  end[@foo3]))[@foo1];|foo} ;
     o_output = OK {foo|module M = (functor (M : S) -> ((val x)[@foo2]) (struct  end[@foo3]))[@foo1];;
|foo};
     official_output = OK {foo|module M = ((functor (M : S) -> ((((val
  x))[@foo2 ]))(((struct  end)[@foo3 ])))[@foo1 ])|foo} ;
     r_output = OK {foo|module M = (functor (M : S) → ((value x)[@foo2]) (struct  end[@foo3]))[@foo1];
|foo}
    };
    {name="inline-attributes-5a"; implem = True ;
     exclude=[];
     o_input = OK {foo|module type S = (module type of[@foo2] M)|foo} ;
     official_input = OK {foo|module type S = (module type of[@foo2] M)|foo} ;
     r_input = OK {foo|module type S = (module type of M)[@foo2];|foo} ;
     o_output = OK {foo|module type S = ((module type of M)[@foo2]);;
|foo};
     official_output = OK {foo|module type S  = ((module type of M)[@foo2 ])|foo} ;
     r_output = OK {foo|module type S = ((module type of M)[@foo2]);
|foo}
    };
    {name="inline-attributes-5"; implem = True ;
     exclude=[];
     o_input = OK {foo|module type S =
  functor[@foo1] (M:S) ->
    (module type of[@foo2] M) ->
    (sig[@foo3] end)|foo} ;
     official_input = OK {foo|module type S =
  functor[@foo1] (M:S) ->
    (module type of[@foo2] M) ->
    (sig[@foo3] end)|foo} ;
     r_input = OK {foo|module type S =
  (functor (M : S) →
    ((module type of M)[@foo2]) -> sig  end[@foo3])[@foo1];
|foo} ;
     o_output = OK {foo|module type S =
  ((functor (M : S) ->
    functor (_ : (module type of M)[@foo2]) -> sig  end[@foo3])[@foo1]);;
|foo};
     official_output = OK {foo|module type S  =
  ((functor (M : S) -> ((module type of M)[@foo2 ]) -> ((sig  end)[@foo3 ]))
  [@foo1 ])|foo} ;
     r_output = OK {foo|module type S =
  ((functor (M : S) →
    functor (_ : (module type of M)[@foo2]) → sig  end[@foo3])[@foo1]);
|foo}
    };
    {name="inline-attributes-6"; implem = True ;
     exclude=[];
     o_input = OK {foo|let [@foo] rec g x = 1 [@@foo2] and[@bar] h y = 2 [@@bar2]|foo} ;
     official_input = OK {foo|let [@foo] rec g x = 1 [@@foo2] and[@bar] h y = 2 [@@bar2]|foo} ;
     r_input = OK {foo|value  rec g x = 1 [@@foo][@@foo2] and h y = 2 [@@bar][@@bar2];|foo} ;
     o_output = OK {foo|let rec g x = 1[@@foo] [@@foo2] and h y = 2[@@bar] [@@bar2];;
|foo};
     official_output = OK {foo|let rec g x = 1[@@foo ][@@foo2 ]
and h y = 2[@@bar ][@@bar2 ]|foo} ;
     r_output = OK {foo|value rec g x = 1[@@foo] [@@foo2] and h y = 2[@@bar] [@@bar2];
|foo}
    };
    {name="inline-attributes-7"; implem = True ;
     exclude=[];
     o_input = OK {foo|let x = let [@foo] rec g x = 1 [@@foo2] and[@bar] h y = 2 [@@bar2] in ()|foo} ;
     official_input = OK {foo|let x = let [@foo] rec g x = 1 [@@foo2] and[@bar] h y = 2 [@@bar2] in ()|foo} ;
     r_input = OK {foo|value x = let rec g x = 1 [@@foo][@@foo2] and h y = 2 [@@bar][@@bar2] in ();|foo} ;
     o_output = OK {foo|let x = let rec g x = 1[@@foo] [@@foo2] and h y = 2[@@bar] [@@bar2] in ();;
|foo};
     official_output = OK {foo|let x = let rec g x = 1[@@foo ][@@foo2 ]
        and h y = 2[@@bar ][@@bar2 ] in ()|foo} ;
     r_output = OK {foo|value x =
  let rec g x = 1[@@foo] [@@foo2]
  and h y = 2[@@bar] [@@bar2] in
  ();
|foo}
    };
    {name="inline-extensions21"; implem = True ;
     exclude=[];
     o_input = OK {foo|type%foo[@foo] t = int
and[@foo] t = int
|foo} ;
     official_input = OK {foo|type%foo[@foo] t = int
and[@foo] t = int
|foo} ;
     r_input = OK {foo|[%%foo type t = int[@@foo]
and t = int[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo type t = int[@@foo]
and t = int[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo type t = int[@@foo ]
       and t = int[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo type t = int[@@foo]
and t = int[@@foo];];
|foo}
    };
    {name="inline-extensions21nonrec"; implem = True ;
     exclude=[];
     o_input = OK {foo|type%foo[@foo] nonrec t = int
and[@foo] t = int
|foo} ;
     official_input = OK {foo|type%foo[@foo] nonrec t = int
and[@foo] t = int
|foo} ;
     r_input = OK {foo|[%%foo type nonrec t = int[@@foo]
and t = int[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo type nonrec t = int[@@foo]
and t = int[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo type nonrec t = int[@@foo ]
       and t = int[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo type nonrec t = int[@@foo]
and t = int[@@foo];];
|foo}
    };
    {name="inline-extensions22"; implem = True ;
     exclude=[];
     o_input = OK {foo|class%foo[@foo] x = x and[@bar] y = y|foo} ;
     official_input = OK {foo|class%foo[@foo] x = x and[@bar] y = y|foo} ;
     r_input = OK {foo|[%%foo class x = x[@@foo] and y = y[@@bar];];|foo} ;
     o_output = OK {foo|[%%foo class x = x[@@foo] and y = y[@@bar];;];;
|foo};
     official_output = OK {foo|[%%foo class x = x[@@foo ]
       and y = y[@@bar ]]|foo} ;
     r_output = OK {foo|[%%foo class x = x[@@foo] and y = y[@@bar];];
|foo}
    };
    {name="inline-extensions23"; implem = True ;
     exclude=[];
     o_input = OK {foo|class type%foo[@foo] x = x|foo} ;
     official_input = OK {foo|class type%foo[@foo] x = x|foo} ;
     r_input = OK {foo|[%%foo class type x = x[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo class type x = x[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo class type x = x[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo class type x = x[@@foo];];
|foo}
    };
    {name="inline-extensions24"; implem = True ;
     exclude=[];
     o_input = OK {foo|external%foo[@foo] x : _  = ""|foo} ;
     official_input = OK {foo|external%foo[@foo] x : _  = ""|foo} ;
     r_input = OK {foo|[%%foo external x : _ = ""[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo external x : _ = ""[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo external x : _ = ""[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo external x : _ = ""[@@foo];];
|foo}
    };
    {name="inline-extensions25"; implem = True ;
     exclude=[];
     o_input = OK {foo|exception%foo[@foo] X|foo} ;
     official_input = OK {foo|exception%foo[@foo] X|foo} ;
     r_input = OK {foo|[%%foo exception X [@foo ];];|foo} ;
     o_output = OK {foo|[%%foo exception X[@foo];;];;
|foo};
     official_output = OK {foo|[%%foo exception X [@foo ]]|foo} ;
     r_output = OK {foo|[%%foo exception X[@foo];];
|foo}
    };
    {name="inline-extensions26"; implem = True ;
     exclude=[];
     o_input = OK {foo|module%foo[@foo] M = M|foo} ;
     official_input = OK {foo|module%foo[@foo] M = M|foo} ;
     r_input = OK {foo|[%%foo module M = M[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo module M = M[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo module M = M[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo module M = M[@@foo];];
|foo}
    };
    {name="inline-extensions27"; implem = True ;
     exclude=[];
     o_input = OK {foo|module%foo[@foo] rec M : S = M
and[@foo] M : S = M|foo} ;
     official_input = OK {foo|module%foo[@foo] rec M : S = M
and[@foo] M : S = M|foo} ;
     r_input = OK {foo|[%%foo module rec M : S = M[@@foo]
and M : S = M[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo module rec M : S = M[@@foo]
and M : S = M[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo module rec M:S = M[@@foo ]  and M:S = M[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo module rec M : S = M[@@foo]
and M : S = M[@@foo];];
|foo}
    };
    {name="inline-extensions28"; implem = True ;
     exclude=[];
     o_input = OK {foo|module type%foo[@foo] S = S|foo} ;
     official_input = OK {foo|module type%foo[@foo] S = S|foo} ;
     r_input = OK {foo|[%%foo module type S = S[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo module type S = S[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo module type S  = S[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo module type S = S[@@foo];];
|foo}
    };
    {name="inline-extensions29"; implem = True ;
     exclude=[];
     o_input = OK {foo|include%foo[@foo] M|foo} ;
     official_input = OK {foo|include%foo[@foo] M|foo} ;
     r_input = OK {foo|[%%foo include M[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo include M[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo include M[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo include M[@@foo];];
|foo}
    };
    {name="inline-extensions30"; implem = True ;
     exclude=[];
     o_input = OK {foo|open%foo[@foo] M|foo} ;
     official_input = OK {foo|open%foo[@foo] M|foo} ;
     r_input = OK {foo|[%%foo open M[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo open M[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo open M[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo open M[@@foo];];
|foo}
    };

    {name="inline-extensions31"; implem = False ;
     exclude=[];
     o_input = OK {foo|val%foo[@foo] x : t|foo} ;
     official_input = OK {foo|val%foo[@foo] x : t|foo} ;
     r_input = OK {foo|[%%foo: value x : t[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo: val x : t[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo :val x : t[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo: value x : t[@@foo];];
|foo}
    };
    {name="inline-extensions32"; implem = False ;
     exclude=[];
     o_input = OK {foo|external%foo[@foo] x : t = ""|foo} ;
     official_input = OK {foo|external%foo[@foo] x : t = ""|foo} ;
     r_input = OK {foo|[%%foo: external x : t = ""[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo: external x : t = ""[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo :external x : t = ""[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo: external x : t = ""[@@foo];];
|foo}
    };
    {name="inline-extensions33"; implem = False ;
     exclude=[];
     o_input = OK {foo|type%foo[@foo] t = int
  and[@foo] t' = int|foo} ;
     official_input = OK {foo|type%foo[@foo] t = int
  and[@foo] t' = int|foo} ;
     r_input = OK {foo|[%%foo: type t = int[@@foo]
and t' = int[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo: type t = int[@@foo]
and t' = int[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo :type t = int[@@foo ]
        and t' = int[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo: type t = int[@@foo]
and t' = int[@@foo];];
|foo}
    };
    {name="inline-extensions34"; implem = False ;
     exclude=[];
     o_input = OK {foo|type%foo[@foo] t += T|foo} ;
     official_input = OK {foo|type%foo[@foo] t += T|foo} ;
     r_input = OK {foo|[%%foo: type t += [ T ][@@foo];];|foo} ;
     o_output = OK {foo|[%%foo: type t += T[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo :type t +=  
          | T [@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo: type t += [ T ][@@foo];];
|foo}
    };
    {name="inline-extensions35"; implem = False ;
     exclude=[];
     o_input = OK {foo|exception%foo[@foo] X|foo} ;
     official_input = OK {foo|exception%foo[@foo] X|foo} ;
     r_input = OK {foo|[%%foo: exception X[@foo];];|foo} ;
     o_output = OK {foo|[%%foo: exception X[@foo];;];;
|foo};
     official_output = OK {foo|[%%foo :exception X [@foo ]]|foo} ;
     r_output = OK {foo|[%%foo: exception X[@foo];];
|foo}
    };
    {name="inline-extensions36"; implem = False ;
     exclude=[];
     o_input = OK {foo|module%foo[@foo] M : S|foo} ;
     official_input = OK {foo|module%foo[@foo] M : S|foo} ;
     r_input = OK {foo|[%%foo: module M : S[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo: module M : S[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo :module M : S[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo: module M : S[@@foo];];
|foo}
    };
    {name="inline-extensions37"; implem = False ;
     exclude=[];
     o_input = OK {foo|module%foo[@foo] rec M : S
  and[@foo] M : S|foo} ;
     official_input = OK {foo|module%foo[@foo] rec M : S
  and[@foo] M : S|foo} ;
     r_input = OK {foo|[%%foo: module rec M : S[@@foo]
and M : S[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo: module rec M : S[@@foo]
and M : S[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo :module rec M: S[@@foo ] and M: S[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo: module rec M : S[@@foo]
and M : S[@@foo];];
|foo}
    };
    {name="inline-extensions38"; implem = False ;
     exclude=[];
     o_input = OK {foo|module%foo[@foo] M = M|foo} ;
     official_input = OK {foo|module%foo[@foo] M = M|foo} ;
     r_input = OK {foo|[%%foo: module alias M = M[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo: module M = M[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo :module M = M[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo: module alias M = M[@@foo];];
|foo}
    };
    {name="inline-extensions39"; implem = False ;
     exclude=[];
     o_input = OK {foo|module type%foo[@foo] S = S|foo} ;
     official_input = OK {foo|module type%foo[@foo] S = S|foo} ;
     r_input = OK {foo|[%%foo: module type S = S[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo: module type S = S[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo :module type S  = S[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo: module type S = S[@@foo];];
|foo}
    };
    {name="inline-extensions40"; implem = False ;
     exclude=[];
     o_input = OK {foo|include%foo[@foo] M|foo} ;
     official_input = OK {foo|include%foo[@foo] M|foo} ;
     r_input = OK {foo|[%%foo: include M[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo: include M[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo :include M[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo: include M[@@foo];];
|foo}
    };
    {name="inline-extensions41"; implem = False ;
     exclude=[];
     o_input = OK {foo|class%foo[@foo] x : t|foo} ;
     official_input = OK {foo|class%foo[@foo] x : t|foo} ;
     r_input = OK {foo|[%%foo: class x : t[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo: class x : t[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo :class x : t[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo: class x : t[@@foo];];
|foo}
    };
    {name="inline-extensions42"; implem = False ;
     exclude=[];
     o_input = OK {foo|class type%foo[@foo] x = x|foo} ;
     official_input = OK {foo|class type%foo[@foo] x = x|foo} ;
     r_input = OK {foo|[%%foo: class type x = x[@@foo];];|foo} ;
     o_output = OK {foo|[%%foo: class type x = x[@@foo];;];;
|foo};
     official_output = OK {foo|[%%foo :class type x = x[@@foo ]]|foo} ;
     r_output = OK {foo|[%%foo: class type x = x[@@foo];];
|foo}
    };
    {name="gadt-nats1"; implem = True ;
     exclude=[];
     o_input = OK {foo|type zero = Zero
	type 'a succ = Succ of 'a
	type _ nat =
	  | NZ : zero nat
	  | NS : 'a nat -> 'a succ nat
|foo} ;
     official_input = OK {foo|type zero = Zero
	type 'a succ = Succ of 'a
	type _ nat =
	  | NZ : zero nat
	  | NS : 'a nat -> 'a succ nat
|foo} ;
     r_input = OK {foo|type zero = [ Zero ];
type succ α =
  [ Succ of α ];
type nat _ =
  [ NZ : nat zero
  | NS : nat α → nat (succ α) ];|foo} ;
     o_output = OK {foo|type zero = Zero;;
type 'a succ =
    Succ of 'a;;
type _ nat =
    NZ : zero nat
  | NS : 'a nat -> 'a succ nat;;
|foo};
     official_output = OK {foo|type zero =
  | Zero 
type 'a succ =
  | Succ of 'a 
type _ nat =
  | NZ: zero nat 
  | NS: 'a nat -> 'a succ nat |foo} ;
     r_output = OK {foo|type zero = [ Zero ];
type succ α =
  [ Succ of α ];
type nat _ =
  [ NZ : nat zero
  | NS : nat α → nat (succ α) ];
|foo}
    };
    {name="gadt-basic-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = Foo : int -> t|foo} ;
     official_input = OK {foo|type t = Foo : int -> t|foo} ;
     r_input = OK {foo|type t =
  [ Foo : int → t ];|foo} ;
     o_output = OK {foo|type t =
    Foo : int -> t;;
|foo};
     official_output = OK {foo|type t =
  | Foo: int -> t |foo} ;
     r_output = OK {foo|type t =
  [ Foo : int → t ];
|foo}
    };
    {name="gadt-basic-2"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t += Foo : int -> t|foo} ;
     official_input = OK {foo|type t += Foo : int -> t|foo} ;
     r_input = OK {foo|type t += [ Foo : int → t ];|foo} ;
     o_output = OK {foo|type t += Foo : int -> t;;
|foo};
     official_output = OK {foo|type t +=  
  | Foo: int -> t |foo} ;
     r_output = OK {foo|type t += [ Foo : int → t ];
|foo}
    };
    {name="gadt-basic-2b"; implem = True ;
     exclude=[];
     o_input = OK {foo|type _ t += Foo : int -> t|foo} ;
     official_input = OK {foo|type _ t += Foo : int -> t|foo} ;
     r_input = OK {foo|type t _ += [ Foo : int → t ];|foo} ;
     o_output = OK {foo|type _ t += Foo : int -> t;;
|foo};
     official_output = OK {foo|type _ t +=  
  | Foo: int -> t |foo} ;
     r_output = OK {foo|type t _ += [ Foo : int → t ];
|foo}
    };
    {name="gadt-basic-3"; implem = True ;
     exclude=[];
     o_input = OK {foo|exception Foo : int -> t|foo} ;
     official_input = OK {foo|exception Foo : int -> t|foo} ;
     r_input = OK {foo|exception Foo : int -> t;|foo} ;
     o_output = OK {foo|exception Foo : int -> t;;
|foo};
     official_output = OK {foo|exception Foo: int -> t |foo} ;
     r_output = OK {foo|exception Foo : int → t;
|foo}
    };
    {name="gadt-basic-4"; implem = False ;
     exclude=[];
     o_input = OK {foo|exception Foo : int -> t|foo} ;
     official_input = OK {foo|exception Foo : int -> t|foo} ;
     r_input = OK {foo|exception Foo : int -> t;|foo} ;
     o_output = OK {foo|exception Foo : int -> t;;
|foo};
     official_output = OK {foo|exception Foo: int -> t |foo} ;
     r_output = OK {foo|exception Foo : int → t;
|foo}
    };
    {name="gadt-basic-4b"; implem = False ;
     exclude=[];
     o_input = OK {foo|exception Foo : {a : int } -> t|foo} ;
     official_input = OK {foo|exception Foo : {a : int } -> t|foo} ;
     r_input = OK {foo|exception Foo : {a : int } -> t;|foo} ;
     o_output = OK {foo|exception Foo : { a : int } -> t;;
|foo};
     official_output = OK {foo|exception Foo: {
  a: int } -> t |foo} ;
     r_output = OK {foo|exception Foo : { a : int } → t;
|foo}
    };
    {name="gadt-basic-4c"; implem = True ;
     exclude=[];
     o_input = OK {foo|exception Foo : {a : int } -> t|foo} ;
     official_input = OK {foo|exception Foo : {a : int } -> t|foo} ;
     r_input = OK {foo|exception Foo : {a : int } -> t;|foo} ;
     o_output = OK {foo|exception Foo : { a : int } -> t;;
|foo};
     official_output = OK {foo|exception Foo: {
  a: int } -> t |foo} ;
     r_output = OK {foo|exception Foo : { a : int } → t;
|foo}
    };
    {name="gadt-basic-5"; implem = True ;
     exclude=[];
     o_input = OK {foo|type _ foo += A : int -> int foo | B : int foo|foo} ;
     official_input = OK {foo|type _ foo += A : int -> int foo | B : int foo|foo} ;
     r_input = OK {foo|type foo _ += [ A : int → foo int | B : foo int ];|foo} ;
     o_output = OK {foo|type _ foo += A : int -> int foo | B : int foo;;
|foo};
     official_output = OK {foo|type _ foo +=  
  | A: int -> int foo 
  | B: int foo |foo} ;
     r_output = OK {foo|type foo _ += [ A : int → foo int | B : foo int ];
|foo}
    };
    {name="gadt-5"; implem = True ;
     exclude=[];
     o_input = OK {foo| fun (type a) (x : a) -> x |foo} ;
     official_input = OK {foo| fun (type a) (x : a) -> x|foo} ;
     r_input = OK {foo|fun (type a) (x : a) -> x;|foo} ;
     o_output = OK {foo|let _ = fun (type a) (x : a) -> x;;
|foo};
     official_output = OK {foo|;;fun (type a) -> fun (x : a) -> x|foo} ;
     r_output = OK {foo|fun (type a) (x : a) → x;
|foo}
    };
    {name="gadt-5b"; implem = True ;
     exclude=[];
     o_input = OK {foo| fun (type a b) (x : a) -> x |foo} ;
     official_input = OK {foo| fun (type a b) (x : a) -> x|foo} ;
     r_input = OK {foo|fun (type a)(type b) (x : a) -> x;|foo} ;
     o_output = OK {foo|let _ = fun (type a) (type b) (x : a) -> x;;
|foo};
     official_output = OK {foo|;;fun (type a) -> fun (type b) -> fun (x : a) -> x|foo} ;
     r_output = OK {foo|fun (type a) (type b) (x : a) → x;
|foo}
    };
    {name="gadt-5c"; implem = True ;
     exclude=[];
     o_input = OK {foo| let f (type a b) (x : a) = x |foo} ;
     official_input = OK {foo| let f (type a b) (x : a) = x|foo} ;
     r_input = OK {foo|value f (type a)(type b) (x : a) = x;|foo} ;
     o_output = OK {foo|let f (type a) (type b) (x : a) = x;;
|foo};
     official_output = OK {foo|let f (type a) (type b) (x : a) = x|foo} ;
     r_output = OK {foo|value f (type a) (type b) (x : a) = x;
|foo}
    };
    {name="gadt-5d"; implem = True ;
     exclude=[];
     o_input = OK {foo| let f (type a b) (x : a) = x in () |foo} ;
     official_input = OK {foo| let f (type a b) (x : a) = x in ()|foo} ;
     r_input = OK {foo|let f (type a)(type b) (x : a) = x in ();|foo} ;
     o_output = OK {foo|let _ = let f (type a) (type b) (x : a) = x in ();;
|foo};
     official_output = OK {foo|;;let f (type a) (type b) (x : a) = x in ()|foo} ;
     r_output = OK {foo|let f (type a) (type b) (x : a) = x in
();
|foo}
    };
    {name="gadt-5e"; implem = True ;
     exclude=[];
     o_input = OK {foo| let x = let f (type a b) (x : a) = x in () |foo} ;
     official_input = OK {foo| let x = let f (type a b) (x : a) = x in ()|foo} ;
     r_input = OK {foo|value x = let f (type a)(type b) (x : a) = x in ();|foo} ;
     o_output = OK {foo|let x = let f (type a) (type b) (x : a) = x in ();;
|foo};
     official_output = OK {foo|let x = let f (type a) (type b) (x : a) = x in ()|foo} ;
     r_output = OK {foo|value x =
  let f (type a) (type b) (x : a) = x in
  ();
|foo}
    };
    {name="gadt-6a"; implem = True ;
     exclude=[];
     o_input = OK {foo|let magic : 'a 'b. 'a -> 'b = ()
|foo} ;
     official_input = OK {foo|let magic : 'a 'b. 'a -> 'b = ()|foo} ;
     r_input = OK {foo|value magic : ! 'a 'b . 'a → 'b = ();|foo} ;
     o_output = OK {foo|let magic : 'a 'b . 'a -> 'b = ();;
|foo} ;
     official_output = OK {foo|let magic : 'a 'b . 'a -> 'b = ()|foo} ;
     r_output = OK {foo|value magic : ! α β . α → β = ();
|foo}
    };
    {name="gadt-6"; implem = True ;
     exclude=[];
     o_input = OK {foo|let magic : 'a 'b. 'a -> 'b =
  fun (type a b) (x : a) ->
    let module M =
      (functor (T : sig type 'a t end) ->
       struct
         let f (Refl : (a T.t, b T.t) eq) = (x :> b)
       end)
        (struct type 'a t = unit end)
    in M.f Refl
|foo} ;
     official_input = OK {foo|let magic : 'a 'b. 'a -> 'b =
  fun (type a b) (x : a) ->
    let module M =
      (functor (T : sig type 'a t end) ->
       struct
         let f (Refl : (a T.t, b T.t) eq) = (x :> b)
       end)
        (struct type 'a t = unit end)
    in M.f Refl
|foo} ;
     r_input = OK {foo|value magic : ! 'a 'b . 'a → 'b =
  fun (type a) (type b) (x : a) →
    let module M =
      (functor (T : sig type t α = β; end) →
         struct
           value f =
             fun
             [ (Refl : eq (T.t a) (T.t b)) → (x :> b) ]
           ;
         end)
        (struct type t α = unit; end)
    in
    M.f Refl;|foo} ;
     o_output = OK {foo|let magic : 'a 'b . 'a -> 'b =
  fun (type a) (type b) (x : a) ->
    let module M =
      (functor (T : sig type 'a t end) ->
         struct
           let f =
             function
               (Refl : (a T.t, b T.t) eq) -> (x :> b)
         end)
        (struct type 'a t = unit end)
    in
    M.f Refl;;
|foo};
     official_output = OK {foo|let magic : 'a 'b . 'a -> 'b =
  fun (type a) ->
    fun (type b) ->
      fun (x : a) ->
        let module M = (functor (T : sig type 'a t end) ->
          struct let f (Refl : (a T.t, b T.t) eq) = (x :> b) end)(struct
                                                                    type 
                                                                    'a t =
                                                                    unit
                                                                  end) in
          M.f Refl|foo} ;
     r_output = OK {foo|value magic : ! α β . α → β =
  fun (type a) (type b) (x : a) →
    let module M =
      (functor (T : sig type t α = β; end) →
         struct
           value f =
             fun
             [ (Refl : eq (T.t a) (T.t b)) → (x :> b) ]
           ;
         end)
        (struct type t α = unit; end)
    in
    M.f Refl;
|foo}
    };
    {name="functor-syntax-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|module Y = functor (X: sig end) (Y:sig end) -> functor (Z: sig end) ->
  struct end|foo} ;
     official_input = OK {foo|module Y = functor (X: sig end) (Y:sig end) -> functor (Z: sig end) ->
  struct end|foo} ;
     r_input = OK {foo|module Y (X : sig  end) (Y : sig  end) (Z : sig  end) = struct  end;|foo} ;
     o_output = OK {foo|module Y (X : sig  end) (Y : sig  end) (Z : sig  end) = struct  end;;
|foo};
     official_output = OK {foo|module Y(X:sig  end)(Y:sig  end)(Z:sig  end) = struct  end|foo} ;
     r_output = OK {foo|module Y (X : sig  end) (Y : sig  end) (Z : sig  end) = struct  end;
|foo}
    };
    {name="module-type-syntax-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|module GZ : functor (X: sig end) () (Z: sig end) -> sig end
          = functor (X: sig end) () (Z: sig end) -> struct end|foo} ;
     official_input = OK {foo|module GZ : functor (X: sig end) () (Z: sig end) -> sig end
          = functor (X: sig end) () (Z: sig end) -> struct end|foo} ;
     r_input = OK {foo|module GZ :
  functor (X : sig  end) → functor () → functor (Z : sig  end) → sig  end =
  functor (X : sig  end) → functor () → functor (Z : sig  end) → struct  end;|foo} ;
     o_output = OK {foo|module GZ :
  functor (X : sig  end) -> functor () -> functor (Z : sig  end) -> sig  end =
  functor (X : sig  end) ->
    functor () -> functor (Z : sig  end) -> struct  end;;
|foo};
     official_output = OK {foo|module GZ =
  (functor (X : sig  end) -> functor () -> functor (Z : sig  end) ->
    struct  end :
    functor (X : sig  end) ->
      functor () -> functor (Z : sig  end) -> sig  end)|foo} ;
     r_output = OK {foo|module GZ :
  functor (X : sig  end) → functor () → functor (Z : sig  end) → sig  end =
  functor (X : sig  end) → functor () → functor (Z : sig  end) → struct  end;
|foo}
    };
    {name="type-decl-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|type _ t = A: {x : 'a; y : 'b} -> 'a t|foo} ;
     official_input = OK {foo|type _ t = A: {x : 'a; y : 'b} -> 'a t|foo} ;
     r_input = OK {foo|type t _ = [ A: {x : 'a; y : 'b} -> t 'a ];|foo} ;
     o_output = OK {foo|type _ t =
    A : { x : 'a; y : 'b } -> 'a t;;
|foo};
     official_output = OK {foo|type _ t =
  | A: {
  x: 'a ;
  y: 'b } -> 'a t |foo} ;
     r_output = OK {foo|type t _ =
  [ A : { x : α; y : β } → t α ];
|foo}
    };
    {name="greek-type-variables-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|let magic : 'a 'b. 'a -> 'b = ()
|foo} ;
     official_input = OK {foo|let magic : 'a 'b. 'a -> 'b = ()|foo} ;
     r_input = OK {foo|value magic : ! α β . α → β = ();|foo} ;
     o_output = OK {foo|let magic : 'a 'b . 'a -> 'b = ();;
|foo} ;
     official_output = OK {foo|let magic : 'a 'b . 'a -> 'b = ()|foo} ;
     r_output = OK {foo|value magic : ! α β . α → β = ();
|foo}
    };
    {name="greek-type-variables-2"; implem = True ;
     exclude=[];
     o_input = OK {foo|type 'a succ = Succ of 'a|foo} ;
     official_input = OK {foo|type 'a succ = Succ of 'a|foo} ;
     r_input = OK {foo|type succ α = [ Succ of α ];|foo} ;
     o_output = OK {foo|type 'a succ =
    Succ of 'a;;
|foo};
     official_output = OK {foo|type 'a succ =
  | Succ of 'a |foo} ;
     r_output = OK {foo|type succ α =
  [ Succ of α ];
|foo}
    };
    {name="type-variable-slots-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|fun b : (_,_,_) format -> if b then "x" else "y"|foo} ;
     official_input = OK {foo|fun b : (_,_,_) format -> if b then "x" else "y"|foo} ;
     r_input = OK {foo|fun b → (if b then "x" else "y" : format _ _ _);|foo} ;
     o_output = OK {foo|let _ = fun b -> (if b then "x" else "y" : (_, _, _) format);;
|foo};
     official_output = OK {foo|;;fun b -> (if b then "x" else "y" : (_, _, _) format)|foo} ;
     r_output = OK {foo|fun b → (if b then "x" else "y" : format _ _ _);
|foo}
    };
    {name="class-type-member-attribute"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = < foo: int [@foo] >|foo} ;
     official_input = OK {foo|type t = < foo: int [@foo] >|foo} ;
     r_input = OK {foo|type t = < foo : int[@foo] >;|foo} ;
     o_output = OK {foo|type t = < foo : int[@foo] > ;;
|foo};
     official_output = OK {foo|type t = < foo: int [@foo ]  > |foo} ;
     r_output = OK {foo|type t = < foo : int[@foo] > ;
|foo}
    };
    {name="hashop-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|let () = foo##.bar := ()|foo} ;
     official_input = OK {foo|let () = foo##.bar := ()|foo} ;
     r_input = OK {foo|value () = foo ##.bar.val := ();|foo} ;
     o_output = OK {foo|let () = foo ##. bar := ();;
|foo};
     official_output = OK {foo|let () = (foo ##. bar) := ()|foo} ;
     r_output = OK {foo|value () = foo ##. bar.val := ();
|foo}
    };
    {name="expr-local-open-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|let x = let open! [@foo] M in ()|foo} ;
     official_input = OK {foo|let x = let open! [@foo] M in ()|foo} ;
     r_input = OK {foo|value x = (let open! M in ()) [@foo];|foo} ;
     o_output = OK {foo|let x = (let open! M in ())[@foo];;
|foo};
     official_output = OK {foo|let x = ((let open! M in ())[@foo ])|foo} ;
     r_output = OK {foo|value x = (let open! M in ())[@foo];
|foo}
    };
    {name="class-expr-local-open-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|class c = let open! [@foo] M in object end|foo} ;
     official_input = OK {foo|class c = let open! [@foo] M in object end|foo} ;
     r_input = OK {foo|class c = (let open! M in object  end)[@foo];|foo} ;
     o_output = OK {foo|class c = (let open! M in object  end)[@foo];;
|foo};
     official_output = OK {foo|class c = ((let open! M in object  end)[@foo ])|foo} ;
     r_output = OK {foo|class c = (let open! M in object  end)[@foo];
|foo}
    };
    {name="class-type-local-open-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|class type ct =
  let open M in
  object
    method f : t
  end|foo} ;
     official_input = OK {foo|class type ct =
  let open M in
  object
    method f : t
  end|foo} ;
     r_input = OK {foo|class type ct = let open M in object method f : t; end;|foo} ;
     o_output = OK {foo|class type ct = let open M in object method f : t end;;
|foo};
     official_output = OK {foo|class type ct = let open M in object method  f : t end|foo} ;
     r_output = OK {foo|class type ct = let open M in object method f : t; end;
|foo}
    };
    {name="exotic-list-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|type ('a,'b) t = [] | (::) of 'a * 'b *  ('a,'b) t|foo} ;
     official_input = OK {foo|type ('a,'b) t = [] | (::) of 'a * 'b *  ('a,'b) t|foo} ;
     r_input = OK {foo|type  t 'a 'b = [ [] | (::) of 'a and 'b and  t 'a 'b ];|foo} ;
     o_output = OK {foo|type ('a, 'b) t =
    []
  | ( :: ) of 'a * 'b * ('a, 'b) t;;
|foo};
     official_output = OK {foo|type ('a, 'b) t =
  | [] 
  | (::) of 'a * 'b * ('a, 'b) t |foo} ;
     r_output = OK {foo|type t α β =
  [ []
  | ( :: ) of α and β and t α β ];
|foo}
    };
    {name="exotic-list-2"; implem = True ;
     exclude=["o2official"];
     o_input = OK {foo|let Inner.(::)(x,y, Inner.[]) = Inner.(::)(1,"one",Inner.[])|foo} ;
     official_input = OK {foo|let Inner.(::)(x,y, Inner.[]) = Inner.(::)(1,"one",Inner.[])|foo} ;
     r_input = SKIP "" "" ;
     o_output = OK {foo|let (Inner.( :: ) (x, y, Inner.[])) = Inner.( :: ) (1, "one", Inner.[]);;
|foo};
     official_output = OK {foo|let Inner.(::) (x, y, Inner.[] ) =
  Inner.(::) (1, "one", (let open Inner in []))|foo} ;
     r_output = OK {foo|value (x, y) =
  match Inner.( :: ) 1 "one" Inner.[] with
  [ Inner.( :: ) x y Inner.[] → (x, y) ];
|foo}
    };
    {(skip) with
     name="exotic-list-2-o2official";
     o_input = OK {foo|let Inner.(::)(x,y, Inner.[]) = Inner.(::)(1,"one",Inner.[])|foo} ;
     official_output = OK {foo|let Inner.(::) (x, y, Inner.[]) = Inner.(::) (1, "one", Inner.[])|foo}
    };
    {(skip) with
     name="exotic-list-2-r2official";
     r_input = OK {foo|value (x, y) =
  match Inner.( :: ) 1 "one" Inner.[] with
  [ Inner.( :: ) x y Inner.[] → (x, y) ];|foo} ;
     official_output = OK {foo|let (x, y) =
  match ((Inner.(::) (1, "one", Inner.[]))[@ocaml.explicit_arity ]) with
  | ((Inner.(::) (x, y, Inner.[]))[@ocaml.explicit_arity ]) -> (x, y)|foo}
    };
    {name="exotic-list-3"; implem = True ;
     exclude=["o2official";"r2official"];
     o_input = OK {foo|let x = M.[ ]|foo} ;
     official_input = OK {foo|let x = M.[ ]|foo} ;
     r_input = OK {foo|value x = M.[];|foo} ;
     o_output = OK {foo|let x = M.[];;
|foo};
     official_output = OK {foo|let x = let open M in []|foo} ;
     r_output = OK {foo|value x = M.[];
|foo}
    };
    {(skip) with
     name="exotic-list-3-[or]2official";
     o_input = OK {foo|let x = M.[ ]|foo} ;
     r_input = OK {foo|value x = M.[];|foo} ;
     official_output = OK {foo|let x = M.[]|foo}
    };
    {name="exotic-list-4"; implem = True ;
     exclude=[];
     o_input = OK {foo|let x = M.N.(::)|foo} ;
     official_input = OK {foo|let x = M.N.(::)|foo} ;
     r_input = SKIP "" "" ;
     o_output = OK {foo|let x = M.N.( :: );;
|foo};
     official_output = OK {foo|let x = M.N.(::)|foo} ;
     r_output = OK {foo|value x = M.N.( :: );
|foo}
    };
    {name="dotop-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|
    let ( .%[] ) = Hashtbl.find
    let ( .%[] <- ) = Hashtbl.add
    let ( .%() ) = Hashtbl.find
    let ( .%() <- ) = Hashtbl.add
    let ( .%{} ) = Hashtbl.find
    let ( .%{} <- ) = Hashtbl.add
    let ( .%[;..] ) = Hashtbl.find
    let ( .%[;..] <- ) = Hashtbl.add
    let ( .%(;..) ) = Hashtbl.find
    let ( .%(;..) <- ) = Hashtbl.add
    let ( .%{;..} ) = Hashtbl.find
    let ( .%{;..} <- ) = Hashtbl.add
|foo} ;
     official_input = OK {foo|
    let ( .%[] ) = Hashtbl.find
    let ( .%[] <- ) = Hashtbl.add
    let ( .%() ) = Hashtbl.find
    let ( .%() <- ) = Hashtbl.add
    let ( .%{} ) = Hashtbl.find
    let ( .%{} <- ) = Hashtbl.add
    let ( .%[;..] ) = Hashtbl.find
    let ( .%[;..] <- ) = Hashtbl.add
    let ( .%(;..) ) = Hashtbl.find
    let ( .%(;..) <- ) = Hashtbl.add
    let ( .%{;..} ) = Hashtbl.find
    let ( .%{;..} <- ) = Hashtbl.add
|foo} ;
     r_input = OK {foo|
value ( .%[] ) = Hashtbl.find;
value ( .%[]<- ) = Hashtbl.add;
value ( .%() ) = Hashtbl.find;
value ( .%()<- ) = Hashtbl.add;
value ( .%{} ) = Hashtbl.find;
value ( .%{}<- ) = Hashtbl.add;
value ( .%[;..] ) = Hashtbl.find;
value ( .%[;..]<- ) = Hashtbl.add;
value ( .%(;..) ) = Hashtbl.find;
value ( .%(;..)<- ) = Hashtbl.add;
value ( .%{;..} ) = Hashtbl.find;
value ( .%{;..}<- ) = Hashtbl.add;|foo} ;
     o_output = OK {foo|let (.%[]) = Hashtbl.find;;
let (.%[]<-) = Hashtbl.add;;
let (.%()) = Hashtbl.find;;
let (.%()<-) = Hashtbl.add;;
let (.%{}) = Hashtbl.find;;
let (.%{}<-) = Hashtbl.add;;
let (.%[;..]) = Hashtbl.find;;
let (.%[;..]<-) = Hashtbl.add;;
let (.%(;..)) = Hashtbl.find;;
let (.%(;..)<-) = Hashtbl.add;;
let (.%{;..}) = Hashtbl.find;;
let (.%{;..}<-) = Hashtbl.add;;
|foo};
     official_output = OK {foo|let (.%[]) = Hashtbl.find
let (.%[]<-) = Hashtbl.add
let (.%()) = Hashtbl.find
let (.%()<-) = Hashtbl.add
let (.%{}) = Hashtbl.find
let (.%{}<-) = Hashtbl.add
let (.%[;..]) = Hashtbl.find
let (.%[;..]<-) = Hashtbl.add
let (.%(;..)) = Hashtbl.find
let (.%(;..)<-) = Hashtbl.add
let (.%{;..}) = Hashtbl.find
let (.%{;..}<-) = Hashtbl.add|foo} ;
     r_output = OK {foo|value ( .%[] ) = Hashtbl.find;
value ( .%[]<- ) = Hashtbl.add;
value ( .%() ) = Hashtbl.find;
value ( .%()<- ) = Hashtbl.add;
value ( .%{} ) = Hashtbl.find;
value ( .%{}<- ) = Hashtbl.add;
value ( .%[;..] ) = Hashtbl.find;
value ( .%[;..]<- ) = Hashtbl.add;
value ( .%(;..) ) = Hashtbl.find;
value ( .%(;..)<- ) = Hashtbl.add;
value ( .%{;..} ) = Hashtbl.find;
value ( .%{;..}<- ) = Hashtbl.add;
|foo}
    };
    {name="dotop-2"; implem = True ;
     exclude=[];
     o_input = OK {foo|
    let ( .%[] ) x y = Hashtbl.find
    let ( .%[] <- ) x y = Hashtbl.add
    let ( .%() ) x y = Hashtbl.find
    let ( .%() <- ) x y = Hashtbl.add
    let ( .%{} ) x y = Hashtbl.find
    let ( .%{} <- ) x y = Hashtbl.add
    let ( .%[;..] ) x y = Hashtbl.find
    let ( .%[;..] <- ) x y = Hashtbl.add
    let ( .%(;..) ) x y = Hashtbl.find
    let ( .%(;..) <- ) x y = Hashtbl.add
    let ( .%{;..} ) x y = Hashtbl.find
    let ( .%{;..} <- ) x y = Hashtbl.add
|foo} ;
     official_input = OK {foo|
    let ( .%[] ) x y = Hashtbl.find
    let ( .%[] <- ) x y = Hashtbl.add
    let ( .%() ) x y = Hashtbl.find
    let ( .%() <- ) x y = Hashtbl.add
    let ( .%{} ) x y = Hashtbl.find
    let ( .%{} <- ) x y = Hashtbl.add
    let ( .%[;..] ) x y = Hashtbl.find
    let ( .%[;..] <- ) x y = Hashtbl.add
    let ( .%(;..) ) x y = Hashtbl.find
    let ( .%(;..) <- ) x y = Hashtbl.add
    let ( .%{;..} ) x y = Hashtbl.find
    let ( .%{;..} <- ) x y = Hashtbl.add
|foo} ;
     r_input = OK {foo|
value ( .%[] ) x y = Hashtbl.find;
value ( .%[]<- ) x y = Hashtbl.add;
value ( .%() ) x y = Hashtbl.find;
value ( .%()<- ) x y = Hashtbl.add;
value ( .%{} ) x y = Hashtbl.find;
value ( .%{}<- ) x y = Hashtbl.add;
value ( .%[;..] ) x y = Hashtbl.find;
value ( .%[;..]<- ) x y = Hashtbl.add;
value ( .%(;..) ) x y = Hashtbl.find;
value ( .%(;..)<- ) x y = Hashtbl.add;
value ( .%{;..} ) x y = Hashtbl.find;
value ( .%{;..}<- ) x y = Hashtbl.add;|foo} ;
     o_output = OK {foo|let (.%[]) x y = Hashtbl.find;;
let (.%[]<-) x y = Hashtbl.add;;
let (.%()) x y = Hashtbl.find;;
let (.%()<-) x y = Hashtbl.add;;
let (.%{}) x y = Hashtbl.find;;
let (.%{}<-) x y = Hashtbl.add;;
let (.%[;..]) x y = Hashtbl.find;;
let (.%[;..]<-) x y = Hashtbl.add;;
let (.%(;..)) x y = Hashtbl.find;;
let (.%(;..)<-) x y = Hashtbl.add;;
let (.%{;..}) x y = Hashtbl.find;;
let (.%{;..}<-) x y = Hashtbl.add;;
|foo};
     official_output = OK {foo|let (.%[]) x y = Hashtbl.find
let (.%[]<-) x y = Hashtbl.add
let (.%()) x y = Hashtbl.find
let (.%()<-) x y = Hashtbl.add
let (.%{}) x y = Hashtbl.find
let (.%{}<-) x y = Hashtbl.add
let (.%[;..]) x y = Hashtbl.find
let (.%[;..]<-) x y = Hashtbl.add
let (.%(;..)) x y = Hashtbl.find
let (.%(;..)<-) x y = Hashtbl.add
let (.%{;..}) x y = Hashtbl.find
let (.%{;..}<-) x y = Hashtbl.add|foo} ;
     r_output = OK {foo|value ( .%[] ) x y = Hashtbl.find;
value ( .%[]<- ) x y = Hashtbl.add;
value ( .%() ) x y = Hashtbl.find;
value ( .%()<- ) x y = Hashtbl.add;
value ( .%{} ) x y = Hashtbl.find;
value ( .%{}<- ) x y = Hashtbl.add;
value ( .%[;..] ) x y = Hashtbl.find;
value ( .%[;..]<- ) x y = Hashtbl.add;
value ( .%(;..) ) x y = Hashtbl.find;
value ( .%(;..)<- ) x y = Hashtbl.add;
value ( .%{;..} ) x y = Hashtbl.find;
value ( .%{;..}<- ) x y = Hashtbl.add;
|foo}
    };
    {name="dot-array-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|x.(y)|foo} ;
     official_input = OK {foo|x.(y)|foo} ;
     r_input = OK {foo|x.(y);|foo} ;
     o_output = OK {foo|let _ = x.(y);;
|foo};
     official_output = OK {foo|;;x.(y)|foo} ;
     r_output = OK {foo|x.(y);
|foo}
    };
    {name="dot-array-2"; implem = True ;
     exclude=[];
     o_input = OK {foo|x.(y) <- z|foo} ;
     official_input = OK {foo|x.(y) <- z|foo} ;
     r_input = OK {foo|x.(y) := z;|foo} ;
     o_output = OK {foo|let _ = x.(y) <- z;;
|foo};
     official_output = OK {foo|;;x.(y) <- z|foo} ;
     r_output = OK {foo|x.(y) := z;
|foo}
    };
    {name="dotop-array-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|x.%(y)|foo} ;
     official_input = OK {foo|x.%(y)|foo} ;
     r_input = OK {foo|x.%(y);|foo} ;
     o_output = OK {foo|let _ = x.%(y);;
|foo};
     official_output = OK {foo|;;x.%(y)|foo} ;
     r_output = OK {foo|x.%(y);
|foo}
    };
    {name="dotop-array-2"; implem = True ;
     exclude=[];
     o_input = OK {foo|x.%(y) <- z|foo} ;
     official_input = OK {foo|x.%(y) <- z|foo} ;
     r_input = OK {foo|x.%(y) := z;|foo} ;
     o_output = OK {foo|let _ = x.%(y) <- z;;
|foo};
     official_output = OK {foo|;;x.%(y) <- z|foo} ;
     r_output = OK {foo|x.%(y) := z;
|foo}
    };
    {name="dotop-array-3"; implem = True ;
     exclude=[];
     o_input = OK {foo|x.%(y; z)|foo} ;
     official_input = OK {foo|x.%(y;z)|foo} ;
     r_input = OK {foo|x.%(y;z);|foo} ;
     o_output = OK {foo|let _ = x.%(y; z);;
|foo};
     official_output = OK {foo|;;x.%(y;z)|foo} ;
     r_output = OK {foo|x.%(y; z);
|foo}
    };
    {name="dotop-array-4"; implem = True ;
     exclude=[];
     o_input = OK {foo|x.%(y;y2) <- z|foo} ;
     official_input = OK {foo|x.%(y;y2) <- z|foo} ;
     r_input = OK {foo|x.%(y;y2) := z;|foo} ;
     o_output = OK {foo|let _ = x.%(y; y2) <- z;;
|foo};
     official_output = OK {foo|;;x.%(y;y2) <- z|foo} ;
     r_output = OK {foo|x.%(y; y2) := z;
|foo}
    };
    {name="dot-bigarray-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|x.{y}|foo} ;
     official_input = OK {foo|x.{y}|foo} ;
     r_input = OK {foo|x.{y};|foo} ;
     o_output = OK {foo|let _ = x.{y};;
|foo};
     official_output = OK {foo|;;x.{y}|foo} ;
     r_output = OK {foo|x.{y};
|foo}
    };
    {name="dot-bigarray-2"; implem = True ;
     exclude=[];
     o_input = OK {foo|x.{y} <- z|foo} ;
     official_input = OK {foo|x.{y} <- z|foo} ;
     r_input = OK {foo|x.{y} := z;|foo} ;
     o_output = OK {foo|let _ = x.{y} <- z;;
|foo};
     official_output = OK {foo|;;x.{y} <- z|foo} ;
     r_output = OK {foo|x.{y} := z;
|foo}
    };
    {name="dotop-bigarray-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|x.%{y}|foo} ;
     official_input = OK {foo|x.%{y}|foo} ;
     r_input = OK {foo|x.%{y};|foo} ;
     o_output = OK {foo|let _ = x.%{y};;
|foo};
     official_output = OK {foo|;;x.%{y}|foo} ;
     r_output = OK {foo|x.%{y};
|foo}
    };
    {name="dotop-bigarray-2"; implem = True ;
     exclude=[];
     o_input = OK {foo|x.%{y} <- z|foo} ;
     official_input = OK {foo|x.%{y} <- z|foo} ;
     r_input = OK {foo|x.%{y} := z;|foo} ;
     o_output = OK {foo|let _ = x.%{y} <- z;;
|foo};
     official_output = OK {foo|;;x.%{y} <- z|foo} ;
     r_output = OK {foo|x.%{y} := z;
|foo}
    };
    {name="dotop-bigarray-3"; implem = True ;
     exclude=[];
     o_input = OK {foo|x.%{y; z}|foo} ;
     official_input = OK {foo|x.%{y;z}|foo} ;
     r_input = OK {foo|x.%{y;z};|foo} ;
     o_output = OK {foo|let _ = x.%{y; z};;
|foo};
     official_output = OK {foo|;;x.%{y;z}|foo} ;
     r_output = OK {foo|x.%{y; z};
|foo}
    };
    {name="dotop-bigarray-4"; implem = True ;
     exclude=[];
     o_input = OK {foo|x.%{y;y2} <- z|foo} ;
     official_input = OK {foo|x.%{y;y2} <- z|foo} ;
     r_input = OK {foo|x.%{y;y2} := z;|foo} ;
     o_output = OK {foo|let _ = x.%{y; y2} <- z;;
|foo};
     official_output = OK {foo|;;x.%{y;y2} <- z|foo} ;
     r_output = OK {foo|x.%{y; y2} := z;
|foo}
    };
    {name="dot-string-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|x.[y]|foo} ;
     official_input = OK {foo|x.[y]|foo} ;
     r_input = OK {foo|x.[y];|foo} ;
     o_output = OK {foo|let _ = x.[y];;
|foo};
     official_output = OK {foo|;;x.[y]|foo} ;
     r_output = OK {foo|x.[y];
|foo}
    };
    {name="dot-string-2"; implem = True ;
     exclude=["r2official"; "o2official"];
     o_input = OK {foo|x.[y] <- z|foo} ;
     official_input = OK {foo|x.[y] <- z|foo} ;
     r_input = OK {foo|x.[y] := z;|foo} ;
     o_output = OK {foo|let _ = x.[y] <- z;;
|foo};
     official_output = OK {foo|;;x.[y] <- z|foo} ;
     r_output = OK {foo|x.[y] := z;
|foo}
    };
    {(skip) with
     name="dot-string-2-[or]2official" ;
     o_input = OK {foo|x.[y] <- z|foo} ;
     r_input = OK {foo|x.[y] := z;|foo} ;
     official_output = OK {foo|;;Bytes.set x y z|foo}
    };
    {name="dotop-string-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|x.%[y]|foo} ;
     official_input = OK {foo|x.%[y]|foo} ;
     r_input = OK {foo|x.%[y];|foo} ;
     o_output = OK {foo|let _ = x.%[y];;
|foo};
     official_output = OK {foo|;;x.%[y]|foo} ;
     r_output = OK {foo|x.%[y];
|foo}
    };
    {name="dotop-string-2"; implem = True ;
     exclude=[];
     o_input = OK {foo|x.%[y] <- z|foo} ;
     official_input = OK {foo|x.%[y] <- z|foo} ;
     r_input = OK {foo|x.%[y] := z;|foo} ;
     o_output = OK {foo|let _ = x.%[y] <- z;;
|foo};
     official_output = OK {foo|;;x.%[y] <- z|foo} ;
     r_output = OK {foo|x.%[y] := z;
|foo}
    };
    {name="dotop-string-3"; implem = True ;
     exclude=[];
     o_input = OK {foo|x.%[y; z]|foo} ;
     official_input = OK {foo|x.%[y;z]|foo} ;
     r_input = OK {foo|x.%[y;z];|foo} ;
     o_output = OK {foo|let _ = x.%[y; z];;
|foo};
     official_output = OK {foo|;;x.%[y;z]|foo} ;
     r_output = OK {foo|x.%[y; z];
|foo}
    };
    {name="dotop-string-4"; implem = True ;
     exclude=[];
     o_input = OK {foo|x.%[y;y2] <- z|foo} ;
     official_input = OK {foo|x.%[y;y2] <- z|foo} ;
     r_input = OK {foo|x.%[y;y2] := z;|foo} ;
     o_output = OK {foo|let _ = x.%[y; y2] <- z;;
|foo};
     official_output = OK {foo|;;x.%[y;y2] <- z|foo} ;
     r_output = OK {foo|x.%[y; y2] := z;
|foo}
    };
    {name="empty-constructor-decl"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = ||foo} ;
     official_input = OK {foo|type t = ||foo} ;
     r_input = OK {foo|type t = [ | ];|foo} ;
     o_output = OK {foo|type t = |;;
|foo};
     official_output = OK {foo|type t = ||foo} ;
     r_output = OK {foo|type t = [ | ];
|foo}
    };
    {name="function-unreached-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|function _ -> .|foo} ;
     official_input = OK {foo|function _ -> .|foo} ;
     r_input = OK {foo|fun _ -> .;|foo} ;
     o_output = OK {foo|let _ = function _ -> .;;
|foo};
     official_output = OK {foo|;;function | _ -> .|foo} ;
     r_output = OK {foo|fun _ → .;
|foo}
    };
    {name="extension-type-object-1"; implem = True ;
     exclude=["o2official";"r2official"];
     o_input = OK {foo|let [%foo: [`Foo] ] : [%foo: t -> t ] = [%foo: < foo : t > ]|foo} ;
     official_input = OK {foo|let [%foo: [`Foo] ] : [%foo: t -> t ] = [%foo: < foo : t > ]|foo} ;
     r_input = OK {foo|value [%foo: [ = `Foo ]] : [%foo: t → t] = [%foo: < foo : t > ];|foo} ;
     o_output = OK {foo|let [%foo: [ `Foo ]] = ([%foo: < foo : t > ] : [%foo: t -> t]);;
|foo};
     official_output = OK {foo|let ([%foo :[ `Foo ]] : [%foo :t -> t]) = [%foo :< foo: t   > ]|foo} ;
     r_output = OK {foo|value [%foo: [ = `Foo ]] : [%foo: t → t] = [%foo: < foo : t > ];
|foo}
    };
    {(skip) with
     name="extension-type-object-1-[or]2official" ;
     o_input = OK {foo|let [%foo: [`Foo] ] : [%foo: t -> t ] = [%foo: < foo : t > ]|foo} ;
     r_input = OK {foo|value [%foo: [ = `Foo ]] : [%foo: t → t] = [%foo: < foo : t > ];|foo} ;
     official_output = OK {foo|let [%foo :[ `Foo ]] = ([%foo :< foo: t   > ] : [%foo :t -> t])|foo}
    };
    {name="module-type-with-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|module type S = sig
  module rec A : (S with type t = t)
  and B : (S with type t = t)
end
|foo} ;
     official_input = OK {foo|module type S = sig
  module rec A : (S with type t = t)
  and B : (S with type t = t)
end
|foo} ;
     r_input = OK {foo|module type S =
  sig
    module rec A : (S with type t = t)
    and B : (S with type t = t);
  end;|foo} ;
     o_output = OK {foo|module type S =
  sig
    module rec A : (S with type t = t)
    and B : (S with type t = t)
  end;;
|foo};
     official_output = OK {foo|module type S  =
  sig module rec A: (S with type  t =  t) and B: (S with type  t =  t) end|foo} ;
     r_output = OK {foo|module type S =
  sig
    module rec A : (S with type t = t)
    and B : (S with type t = t);
  end;
|foo}
    };
    {name="irrefut-module-prefix-patt-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|let f M.N.(x) = ()|foo} ;
     official_input = OK {foo|let f M.N.(x) = ()|foo} ;
     r_input = OK {foo|value f M.N.x = ();|foo} ;
     o_output = OK {foo|let f M.N.(x) = ();;
|foo};
     official_output = OK {foo|let f M.N.(x)  = ()|foo} ;
     r_output = OK {foo|value f M.N.x = ();
|foo}
    };
    {name="module-prefix-patt-2"; implem = True ;
     exclude=[];
     o_input = OK {foo|match x with M.N.(a,b) -> ()|foo} ;
     official_input = OK {foo|match x with M.N.(a,b) -> ()|foo} ;
     r_input = OK {foo|match x with M.N.(a, b) → ();|foo} ;
     o_output = OK {foo|let _ = match x with M.N.(a, b) -> ();;
|foo};
     official_output = OK {foo|;;match x with | M.N.((a, b))  -> ()|foo} ;
     r_output = OK {foo|match x with M.N.(a, b) → ();
|foo}
    };
    {name="type-variables-with-quotes-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|type ' a' t = ' a'|foo} ;
     official_input = OK {foo|type ' a' t = ' a'|foo} ;
     r_input = OK {foo|type t ' a' = ' a';|foo} ;
     o_output = OK {foo|type ' a' t = ' a';;
|foo};
     official_output = OK {foo|type ' a' t = ' a'|foo} ;
     r_output = OK {foo|type t ' a' = ' a';
|foo}
    };
    {name="object-type-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = < a : int >|foo} ;
     official_input = OK {foo|type t = < a : int >|foo} ;
     r_input = OK {foo|type t = < a : int >;|foo} ;
     o_output = OK {foo|type t = < a : int > ;;
|foo};
     official_output = OK {foo|type t = < a: int   > |foo} ;
     r_output = OK {foo|type t = < a : int > ;
|foo}
    };
    {name="object-type-2"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = < a >|foo} ;
     official_input = OK {foo|type t = < a >|foo} ;
     r_input = OK {foo|type t = < a >;|foo} ;
     o_output = OK {foo|type t = <  a > ;;
|foo};
     official_output = OK {foo|type t = < a  > |foo} ;
     r_output = OK {foo|type t = <  a > ;
|foo}
    };
    {name="object-type-3"; implem = True ;
     exclude=[];
     o_input = OK {foo|type t = < a : int; b ; c : int ; d >|foo} ;
     official_input = OK {foo|type t = < a : int; b ; c : int ; d >|foo} ;
     r_input = OK {foo|type t = < a : int; b ; c : int ; d >;|foo} ;
     o_output = OK {foo|type t = < a : int;  b; c : int;  d > ;;
|foo};
     official_output = OK {foo|type t = < a: int  ;b ;c: int  ;d  > |foo} ;
     r_output = OK {foo|type t = < a : int;  b; c : int;  d > ;
|foo}
    };
    {name="object-val-1"; implem = True ;
     exclude=[];
     o_input = OK {foo|class ['a] c x =  object val x' : 'b = x  end|foo} ;
     official_input = OK {foo|class ['a] c x =  object val x' : 'b = x end|foo} ;
     r_input = OK {foo|class c ['a] x = object value x' : 'b = x; end;
|foo} ;
     o_output = OK {foo|class ['a] c x = object val x' = (x : 'b) end;;
|foo};
     official_output = OK {foo|class ['a] c x = object val x' = (x : 'b) end|foo} ;
     r_output = OK {foo|class c ['a] x = object value x' = (x : β); end;
|foo}
    };
    {name="another-bool"; implem = True ;
     exclude=[];
     o_input = OK {foo|type wrong = false | true|foo} ;
     official_input = OK {foo|type wrong = false | true|foo} ;
     r_input = OK {foo|type wrong = [ False | True ];|foo} ;
     o_output = OK {foo|type wrong = false | true;;
|foo};
     official_output = OK {foo|type wrong =
  | false 
  | true |foo} ;
     r_output = OK {foo|type wrong = [ False | True ];
|foo}
    };
    {name="type-subst-1"; implem = False ;
     exclude=["skip_reparse"];
     o_input = OK {foo|type t := int|foo} ;
     official_input = OK {foo|type t := int|foo} ;
     r_input = OK {foo|type t := int;|foo} ;
     o_output = OK {foo|type t := int;;
|foo};
     official_output = OK {foo|type nonrec t := int|foo} ;
     r_output = OK {foo|type t := int;
|foo}
    };
    {name="type-subst-2"; implem = False ;
     exclude=["skip_reparse"];
     o_input = OK {foo|type t := int and u := bool|foo} ;
     official_input = OK {foo|type t := int and u := bool|foo} ;
     r_input = OK {foo|type t := int and u := bool;|foo} ;
     o_output = OK {foo|type t := int
and u := bool;;
|foo};
     official_output = OK {foo|type nonrec t := int
and u := bool|foo} ;
     r_output = OK {foo|type t := int
and u := bool;
|foo}
    };
    {name="sig-item-module-subst-2"; implem = False ;
     exclude=[];
     o_input = OK {foo|module M := T|foo} ;
     official_input = OK {foo|module M := T|foo} ;
     r_input = OK {foo|module M := T;|foo} ;
     o_output = OK {foo|module M := T;;
|foo};
     official_output = OK {foo|module M := T|foo} ;
     r_output = OK {foo|module M := T;
|foo}
    };
    {name="test-prototype"; implem = True ;
     exclude=[];
     o_input = OK {foo||foo} ;
     official_input = OK {foo||foo} ;
     r_input = OK {foo||foo} ;
     o_output = OK {foo||foo};
     official_output = OK {foo||foo} ;
     r_output = OK {foo||foo}
    };
    {name="test-prototype"; implem = True ;
     exclude=[];
     o_input = OK {foo||foo} ;
     official_input = OK {foo||foo} ;
     r_input = OK {foo||foo} ;
     o_output = OK {foo||foo};
     official_output = OK {foo||foo} ;
     r_output = OK {foo||foo}
    }
]
;

value fmt_string s = Printf.sprintf "<<%s>>" s ;

value i2test ~{kind} (pa_implem,pa_interf) (pp_implem, pp_interf) pa_official_opt inputf outputf i =
  i.name >:: (fun _ ->
    let official_reparse0 implem s = match (implem,pa_official_opt) with [
      (_,None) -> ()
    | (True,Some (f,_)) -> ignore(f s)
    | (False,Some (_,f)) -> ignore(f s)
    ] in
    let official_reparse implem s =
    if List.mem "skip_reparse" i.exclude then () else
    try official_reparse0 implem s
    with exn -> do {
      Printf.fprintf stderr "Exception during reparse of <<%s>>:\n\t" s ;
      flush stderr ;
      Testutil.report_error exn ;
      raise exn
    } in

    if List.mem kind i.exclude then () else
    match (i.implem, inputf i, outputf i) with [

      (_,TODO msg, _) ->
        todo msg   

    | (_,_,TODO msg) ->
        todo msg   

    | (_,SKIP _ _ , _) -> ()
    | (_,OK _, SKIP _ _ ) -> ()

    | (True, OK inputs, OK outputs) -> do {
        assert_equal ~{msg=Printf.sprintf "on input <<%s>>" inputs} ~{printer=fmt_string}
          outputs (wrap_err pp_implem (wrap_err pa_implem inputs)) ;
          official_reparse True outputs
      }

    | (False, OK inputs, OK outputs) -> do {
        assert_equal ~{msg=Printf.sprintf "on input <<%s>>" inputs} ~{printer=fmt_string}
          outputs (wrap_err pp_interf (wrap_err pa_interf inputs)) ;
          official_reparse False outputs
      }

    | (True, OK inputs, EXN outputs exn) -> do {
        let ast = wrap_err pa_implem inputs in
        assert_raises_exn_pred ~{msg=i.name} (smart_exn_eq exn)
          (fun () -> pp_implem ast)
      }

    | (False, OK inputs, EXN outputs exn) -> do {
        let ast = wrap_err pa_interf inputs in
        assert_raises_exn_pred ~{msg=i.name} (smart_exn_eq exn)
          (fun () -> pp_interf ast)
      }

    | (True,EXN inputs exn, _) ->
        assert_raises_exn_pred ~{msg=i.name} (smart_exn_eq exn)
          (fun () -> pa_implem inputs)

    | (False,EXN inputs exn, _) ->
        assert_raises_exn_pred ~{msg=i.name} (smart_exn_eq exn)
          (fun () -> pa_interf inputs)

    ])
;

value r_input i = i.r_input ;
value r_output i = i.r_output ;
value o_input i = i.o_input ;
value o_output i = i.o_output ;
value official_output i = i.official_output ;
value official_input i = i.official_input ;

value r2r pa pp opa () = List.map (i2test ~{kind="r2r"} pa pp opa r_input r_output ) test_matrix ;
value r2o pa pp opa () = List.map (i2test ~{kind="r2o"} pa pp opa r_input o_output ) test_matrix ;
value o2r pa pp opa () = List.map (i2test ~{kind="o2r"} pa pp opa o_input r_output ) test_matrix ;
value o2o pa pp opa () = List.map (i2test ~{kind="o2o"} pa pp opa o_input o_output ) test_matrix ;
value o2official pa pp opa () = List.map (i2test ~{kind="o2official"} pa pp opa o_input official_output ) test_matrix ;
value r2official pa pp opa () = List.map (i2test ~{kind="r2official"} pa pp opa r_input official_output ) test_matrix ;
value official2official pa pp opa () = List.map (i2test ~{kind="official2official"} pa pp opa official_input official_output ) test_matrix ;

(*
;;; Local Variables: ***
;;; mode:tuareg ***
;;; End: ***

*)
