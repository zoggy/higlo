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


let files = ref [];;
let lang = ref "ocaml";;

type mode = Tokens | Xtmpl | Html
let mode = ref Xtmpl

let options = [
    "--tokens", Arg.Unit (fun () -> mode := Tokens), " Output tokens only" ;
    "--html", Arg.Unit (fun () -> mode := Html), " Output an HTML page" ;
    "--lang", Arg.Set_string lang, "<s> set language to <s>; default is ocaml" ;
  ]
;;

let handle_file file =
  match !mode with
    Tokens ->
      let tokens = Higlo.parse ~lang: !lang (string_of_file file) in
      List.iter (fun t -> print_endline (Higlo.string_of_token t)) tokens
  | Xtmpl ->
      let xmls = Higlo.to_xtmpl ~lang: !lang (string_of_file file) in
      print_endline (Xtmpl.string_of_xmls xmls)
  | Html ->
      let xmls = Higlo.to_xtmpl ~lang: !lang (string_of_file file) in
      print_string "<html><head>
      <meta content=\"text/html; charset=utf-8\" http-equiv=\"Content-Type\"/>
      <link href=\"style.css\" rel=\"stylesheet\" type=\"text/css\"/>
      </head>
      <body><pre>";
      print_string (Xtmpl.string_of_xmls xmls);
      print_string "</pre></body></html>"
;;

let () =
  try
    Arg.parse options
      (fun f  -> files := f :: !files)
      (Printf.sprintf "Usage: %s [options]\nwhere options are:" Sys.argv.(0));
    List.iter handle_file (List.rev !files)
  with
    Failure s ->
      prerr_endline s ;
      exit 1
;;
    