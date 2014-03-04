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

open Higlo

let lexeme = Ulexing.utf8_lexeme;;


let regexp space = [' ' '\n' '\t' '\r' ]+

let regexp digit = ['0'-'9']
let regexp capchar = ['A'-'Z']
let regexp lowchar = ['a'-'z']
let regexp idchar =  lowchar | capchar | '_' | '-' | ':' | digit

let regexp entity = '&' [^'&' ';']+ ';'

let regexp tag_start = '<' '/'? idchar+
let regexp tag_end = '/'? '>'

let regexp string = '"' [^'"']* '"'

let regexp comment = "<!--" ([^0x3E] | ([^'-']'>'))* "-->"

let regexp id = idchar+

let rec main = lexer
| space -> [Text (lexeme lexbuf)]
| comment -> [Bcomment (lexeme lexbuf)]
| entity -> [Keyword(1, lexeme lexbuf)]
| tag_start ->
  let t = Keyword(0, lexeme lexbuf) in
  t :: (tag lexbuf)
| _ -> [Text (lexeme lexbuf)]

and tag = lexer
| id -> let t = Id (lexeme lexbuf) in t :: tag lexbuf
| string -> let t = String (lexeme lexbuf) in t :: tag lexbuf
| tag_end -> [Keyword(0, lexeme lexbuf)]
| _ -> let t = Text (lexeme lexbuf) in t :: tag lexbuf

let () = Higlo.register_lang "xml" main;;
