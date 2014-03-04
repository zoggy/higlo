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

type token =
| Bcomment of string (** block comment *)
| Constant of string
| Directive of string
| Escape of string (** Escape sequence like [\123] *)
| Id of string
| Keyword of int * string
| Lcomment of string (** one line comment *)
| Numeric of string
| String of string
| Symbol of int * string
| Text of string (** Used for everything else *)

let string_of_token = function
| Bcomment s -> Printf.sprintf "Bcomment(%S)" s
| Constant s -> Printf.sprintf "Constant(%S)" s
| Directive s -> Printf.sprintf "Directive(%S)" s
| Escape s -> Printf.sprintf "Escape(%S)" s
| Id s -> Printf.sprintf "Id(%S)" s
| Keyword (n, s) -> Printf.sprintf "Keyword(%d, %S)" n s
| Lcomment s -> Printf.sprintf "Lcomment(%S)" s
| Numeric s -> Printf.sprintf "Numeric(%S)" s
| String s -> Printf.sprintf "String(%S)" s
| Symbol (n, s) -> Printf.sprintf "Symbol(%d, %S)" n s
| Text s -> Printf.sprintf "Text(%S)" s

module Smap = Map.Make (String)
exception Unknown_lang of string

type lexer = Ulexing.lexbuf -> token list

let langs = ref Smap.empty

let get_lexer lang =
  try Smap.find lang !langs
  with Not_found -> raise (Unknown_lang lang)
;;
let register_lang name f = langs := Smap.add name f !langs ;;

let parse ~lang s =
  try
    let lexer = get_lexer lang in
    let lexbuf = Ulexing.from_utf8_string s in
    let len = Array.length (Ulexing.get_buf lexbuf) in
    let b = Buffer.create 256 in
    let rec add_tokens acc = function
      Text s -> Buffer.add_string b s ; acc
    | t ->
        let acc =
          if Buffer.length b > 0 then
            (
             let acc = (Text (Buffer.contents b)) :: acc in
             Buffer.reset b ;
             acc
            )
          else acc
        in
        t :: acc
    in
    let rec iter acc =
      if Ulexing.get_pos lexbuf >= len then
        begin
          let acc =
            if Buffer.length b > 0
            then (Text (Buffer.contents b)) :: acc
            else acc
          in
          List.rev acc
        end
      else
        begin
          let tokens = lexer lexbuf in
          iter (List.fold_left add_tokens acc tokens)
        end
    in
    try iter []
    with Ulexing.Error ->
        let pos = Ulexing.get_pos lexbuf in
        let msg = Printf.sprintf "Lexing error at character %d" pos in
        prerr_endline msg ;
        [Text s]
  with
    Unknown_lang _ -> [Text s]
;;

type classes =
  {
    bcomment : string ;
    constant : string ;
    directive : string ;
    escape : string ;
    id : string ;
    keyword : int -> string ;
    lcomment : string ;
    numeric : string ;
    string : string ;
    symbol : int -> string ;
    text : string ;
  }

let default_classes = {
    bcomment = "comment" ;
    constant = "constant" ;
    directive = "directive" ;
    escape = "escape" ;
    id = "id" ;
    keyword = (function 0 -> "kw" | n -> "kw"^(string_of_int n)) ;
    lcomment = "comment" ;
    numeric = "numeric" ;
    string = "string" ;
    symbol = (function 0 -> "sym" | n -> "sym"^(string_of_int n)) ;
    text = "text" ;
  }
;;

let token_to_xtmpl =
  let node cl cdata =
    let atts = Xtmpl.atts_one ("","class") [Xtmpl.D cl] in
    Xtmpl.E (("","span"), atts, [Xtmpl.D cdata])
  in
  fun ?(classes=default_classes) ->
    function
    | Bcomment s -> node classes.bcomment s
    | Constant s -> node classes.constant s
    | Directive s -> node classes.directive s
    | Escape s -> node classes.escape s
    | Id s -> node classes.id s
    | Keyword (n, s) -> node (classes.keyword n) s
    | Lcomment s -> node classes.lcomment s
    | Numeric s -> node classes.numeric s
    | String s -> node classes.string s
    | Symbol (n, s) -> node (classes.symbol n) s
    | Text s -> node classes.text s
;;

let to_xtmpl ?classes ~lang s =
  List.map (token_to_xtmpl ?classes) (parse ~lang s)
;;
