(* camlp5r *)
(* papr_official.ml,v *)

value rec sep_last = fun [
    [] -> failwith "sep_last"
  | [ hd ] -> (hd,[])
  | [ hd::tl ] ->
      let (l,tl) = sep_last tl in (l,[ hd::tl ])
  ]
;

value input_magic ic magic = do {
  let maglen = String.length magic in
  let b = Bytes.create maglen in
  really_input ic b 0 maglen ;
  let s = Bytes.to_string b in
  magic = s
}
;

value input_implem ic = do {
  assert (input_magic ic Config.ast_impl_magic_number) ;
  let _ = input_value ic in
  (input_value ic : Parsetree.structure)
}
;

value input_interf ic = do {
  assert (input_magic ic Config.ast_intf_magic_number) ;
  let _ = input_value ic in
  (input_value ic : Parsetree.signature)
}
;

value binary_input = ref False ;
value files = ref [] ;
value filetype = ref None ;

value set_impl s = filetype.val := Some "-impl" ;
value set_intf s = filetype.val := Some "-intf" ;

value papr_official () = do {
    Arg.(parse [
             ("-binary-input",Set binary_input," binary input");
             ("-impl", Unit set_impl , " implementation");
             ("-intf", Unit set_intf , " interface")
      ]
      (fun s -> files.val := [ s :: files.val ])
      "papr_official: usage") ;
      let open_or opener ifminus = fun [
        "-" -> ifminus | f -> opener f
      ] in
      let (ic, oc) = match List.rev files.val with [
        [] -> (stdin, stdout)
      | [ifile] -> (open_or open_in stdin ifile,
                    stdout)
      | [ifile; ofile] -> (open_or open_in stdin ifile,
                           open_or open_out stdout ofile)
      | _ -> failwith "too many filenames provided"
      ] in
    let ofmt = Format.formatter_of_out_channel oc in
      match (filetype.val, binary_input.val) with [
        (None,_) -> failwith "must specify filetype (-impl or -intf)"
      | (Some "-impl", False) ->
        ic |> Lexing.from_channel |> Parse.implementation |> Pprintast.structure ofmt
      | (Some "-impl", True) ->
        ic |> input_implem |> Pprintast.structure ofmt
      | (Some "-intf", False) ->
        ic |> Lexing.from_channel |> Parse.interface |> Pprintast.signature ofmt
      | (Some "-intf", True) ->
        ic |> input_interf |> Pprintast.signature ofmt
      | _ -> failwith "unrecognized filetype"
      ] ;
      Format.pp_print_flush ofmt () ;
    close_out oc ;
    close_in ic
  }
;

papr_official () ;

(*
;;; Local Variables: ***
;;; mode:tuareg ***
;;; End: ***

*)
