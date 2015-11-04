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

type printer = Higlo.token list -> unit

module SMap = Map.Make(String);;

let printers = ref SMap.empty ;;

let get_printer name =
  try SMap.find name !printers
  with Not_found -> failwith (Printf.sprintf "Unknown printer %S" name)
;;

let register_printer name f = printers := SMap.add name f !printers;;

let xml_printer tokens =
  let xmls = List.map Higlo.token_to_xml tokens in
  print_string (Xtmpl_xml.to_string xmls)
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
