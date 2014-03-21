(*********************************************************************************)
(*                Higlo                                                          *)
(*                                                                               *)
(*    Copyright (C) 2014 Institut National de Recherche en Informatique          *)
(*    et en Automatique. All rights reserved.                                    *)
(*                                                                               *)
(*    This program is free software; you can redistribute it and/or modify       *)
(*    it under the terms of the GNU Lesser General Public License version        *)
(*    3 as published by the Free Software Foundation.                            *)
(*                                                                               *)
(*    This program is distributed in the hope that it will be useful,            *)
(*    but WITHOUT ANY WARRANTY; without even the implied warranty of             *)
(*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *)
(*    GNU Library General Public License for more details.                       *)
(*                                                                               *)
(*    You should have received a copy of the GNU Lesser General Public           *)
(*    License along with this program; if not, write to the Free Software        *)
(*    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA                   *)
(*    02111-1307  USA                                                            *)
(*                                                                               *)
(*    Contact: Maxence.Guesdon@inria.fr                                          *)
(*                                                                               *)
(*                                                                               *)
(*********************************************************************************)

(** *)

type to_load = Pkgs of string list | Files of string list

let verbose = ref false;;
let verb msg = if !verbose then prerr_endline msg;;

type printer = Higlo.token list -> unit

module SMap = Map.Make(String);;

let printers = ref SMap.empty ;;

let get_printer name =
  try SMap.find name !printers
  with Not_found -> failwith (Printf.sprintf "Unknown printer %S" name)
;;

let register_printer name f = printers := SMap.add name f !printers;;

let xml_printer tokens =
  let xmls = List.map Higlo.token_to_xtmpl tokens in
  print_string (Xtmpl.string_of_xmls xmls)
;;

let html_printer tokens =
  print_string "<html>
  <head>
    <meta content=\"text/html; charset=utf-8\" http-equiv=\"Content-Type\"/>
    <link href=\"style.css\" rel=\"stylesheet\" type=\"text/css\"/>
  </head>
  <body><pre>";
  xml_printer tokens;
  print_string "</pre></body></html>"
;;

let token_printer tokens =
  List.iter (fun t -> print_string (Higlo.string_of_token t)) tokens
;;

let () =
  List.iter (fun (name, f) -> register_printer name f)
    [ "xml", xml_printer ;
      "html", html_printer ;
      "tokens", token_printer ;
    ]
;;

(*c==v=[File.string_of_file]=1.0====*)
let string_of_file name =
  let chanin = open_in_bin name in
  let len = 1024 in
  let s = String.create len in
  let buf = Buffer.create len in
  let rec iter () =
    try
      let n = input chanin s 0 len in
      if n = 0 then
        ()
      else
        (
         Buffer.add_substring buf s 0 n;
         iter ()
        )
    with
      End_of_file -> ()
  in
  iter ();
  close_in chanin;
  Buffer.contents buf
(*/c==v=[File.string_of_file]=1.0====*)

let handle_file lang printer file =
  let tokens = Higlo.parse ~lang (string_of_file file) in
  printer tokens
;;

(*c==v=[String.split_string]=1.2====*)
let split_string ?(keep_empty=false) s chars =
  let len = String.length s in
  let rec iter acc pos =
    if pos >= len then
      match acc with
        "" -> if keep_empty then [""] else []
      | _ -> [acc]
    else
      if List.mem s.[pos] chars then
        match acc with
          "" ->
            if keep_empty then
              "" :: iter "" (pos + 1)
            else
              iter "" (pos + 1)
        | _ -> acc :: (iter "" (pos + 1))
      else
        iter (Printf.sprintf "%s%c" acc s.[pos]) (pos + 1)
  in
  iter "" 0
(*/c==v=[String.split_string]=1.2====*)

(*c==v=[List.list_remove_doubles]=1.0====*)
let list_remove_doubles ?(pred=(=)) l =
  List.fold_left
    (fun acc e -> if List.exists (pred e) acc then acc else e :: acc)
    []
    (List.rev l)
(*/c==v=[List.list_remove_doubles]=1.0====*)

let load_file file =
  let file = Dynlink.adapt_filename file in
  verb (Printf.sprintf "Loading file %s" file);
  try Dynlink.loadfile file
  with Dynlink.Error e ->
      failwith (Dynlink.error_message e)

let files_of_packages pkg_names =
  let kind = if Dynlink.is_native then "native" else "byte" in
  let tmp_file = Filename.temp_file "higlo" ".txt" in
  let com =
    Printf.sprintf "ocamlfind query %s -predicates plugin,%s -r -format %%d/%%a > %s"
      (String.concat " " (List.map Filename.quote pkg_names))
      kind (Filename.quote tmp_file)
  in
  match Sys.command com with
    0 ->
      let s = string_of_file tmp_file in
      Sys.remove tmp_file ;
      split_string s ['\n']
  | n ->
      Sys.remove tmp_file ;
      let msg = Printf.sprintf "Command failed (%d): %s" n com in
      failwith msg
;;


let files_of_to_load = function
  Pkgs pkgs -> files_of_packages pkgs
| Files files -> files
;;

let dynload_code l =
  let files = List.fold_left
    (fun acc to_load ->
       List.fold_left
         (fun acc f -> if List.mem f acc then acc else f :: acc)
         acc (files_of_to_load to_load)
    )
    [] l
  in
  List.iter load_file (List.rev files)
;;

let to_load = ref [];;

let add_pkgs s = to_load := (Pkgs (split_string s [','; ' '])) :: !to_load ;;
let add_dynf s = to_load := (Files (split_string s [','; ' '])) :: !to_load;;

let files = ref [];;
let lang = ref "ocaml";;
let out_format = ref "xml";;

let options = [
    "-v", Arg.Set verbose, " verbose mode";

    "-f", Arg.Set_string out_format,
    "<s> set output format to <s>; default is xml" ;

    "-l", Arg.Set_string lang, "<s> set language to <s>; default is ocaml" ;

    "--pkg", Arg.String add_pkgs,
    "pkg1,pkg2,... dynmically load the given packages" ;

    "--load", Arg.String add_dynf,
    "file1.cm[xs|o|a],... dynmically load the given object files" ;
  ]
;;

let () =
  try
    Arg.parse (Arg.align options)
      (fun f  -> files := f :: !files)
      (Printf.sprintf "Usage: %s [options]\nwhere options are:" Sys.argv.(0));
    dynload_code (List.rev !to_load);
    let printer = get_printer !out_format in
    ignore(
     try let _x = Higlo.get_lexer !lang in ()
     with Higlo.Unknown_lang name -> failwith (Printf.sprintf "Unknown language %S" name)
    );
    List.iter (handle_file !lang printer) (List.rev !files)
  with
    Failure s ->
      prerr_endline s ;
      exit 1
;;
    