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

let foo = false

type token =
| Id of string
| Keyword of int * string
| Lcomment of string
| Bcomment of string
| String of string
| Text of string
| Numeric of string
| Directive of string
| Escape of string
| Symbol of int * string
| Constant of string

module Smap = Map.Make (String)
let langs = ref Smap.empty

let register_lang name f = langs := Smap.add name f !langs ;;

let parse ~lang s =
  match try Some (Smap.find lang !langs) with Not_found -> None with
    None -> [Text s]
  | Some lexer ->
      let lexbuf = Ulexing.from_utf8_string s in
      let len = Array.length (Ulexing.get_buf lexbuf) in
      let b = Buffer.create 256 in
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
            let token = lexer lexbuf in
            match token with
              Text s -> Buffer.add_string b s ; iter acc
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
                iter (token :: acc)
          end
      in
      try iter []
      with Ulexing.Error ->
        let pos = Ulexing.get_pos lexbuf in
        let msg = Printf.sprintf "Lexing error at character %d" pos in
        prerr_endline msg ;
        [Text s]
;;

let string_of_token = function
| Id s -> Printf.sprintf "Id(%S)" s
| Keyword (n, s) -> Printf.sprintf "Keyword(%d, %S)" n s
| Lcomment s -> Printf.sprintf "Lcomment(%S)" s
| Bcomment s -> Printf.sprintf "Bcomment(%S)" s
| String s -> Printf.sprintf "String(%S)" s
| Text s -> Printf.sprintf "Text(%S)" s
| Numeric s -> Printf.sprintf "Numeric(%S)" s
| Directive s -> Printf.sprintf "Directive(%S)" s
| Escape s -> Printf.sprintf "Escape(%S)" s
| Symbol (n, s) -> Printf.sprintf "Symbol(%d, %S)" n s
| Constant s -> Printf.sprintf "Constant(%S)" s
