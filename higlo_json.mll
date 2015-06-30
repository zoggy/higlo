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

let regexp digit = ['0'-'9' '_']
let regexp hex = digit | ['A'-'F'] | ['a'-'f']
let regexp integer = digit+
let regexp decimal = ['0'-'9']* '.' ['0'-'9']+
let regexp exponent = ['e''E'] ['+''-']? ['0'-'9']+
let regexp double = ['0'-'9']+ '.' ['0'-'9']* exponent | '.' (['0'-'9'])+ exponent | (['0'-'9'])+ exponent
let regexp integer_positive = '+'integer
let regexp decimal_positive = '+'decimal
let regexp double_positive = '+'double
let regexp integer_negative = '-'integer
let regexp decimal_negative = '-'decimal
let regexp double_negative = '-'double

let regexp binary = "0b" ('0' | '1')+
let regexp octal = "0o" ['0'-'7']+
let regexp hexa = "0x" hex +

let regexp numeric = integer_positive | decimal_positive | double_positive | integer_negative | decimal_negative | double_negative | integer | decimal | double | binary | octal | hexa

let regexp boolean = "true" | "false"
let regexp echar = ['t' 'b' 'n' 'r' 'f' '\\' '"' '\'']

let regexp escaped_char = '\\' echar
let regexp string = '"' ( ([^0x22]) | escaped_char )* '"'
let regexp char = "'" ( ([^0x27]) | escaped_char ) "'"

let regexp space = [' ' '\n' '\t' '\r' ]+

let regexp capchar = ['A'-'Z']
let regexp lowchar = ['a'-'z']
let regexp idchar =  lowchar | capchar | '_' | digit

let regexp id = ('_'|lowchar) idchar*

let regexp obj_field = (id|string)space?":"

let rec main = lexer
| '{' | '}' -> [Symbol(0, lexeme lexbuf)]
| '[' | ']' -> [Symbol(0, lexeme lexbuf)]
| ',' -> [Symbol(0, lexeme lexbuf)]
| space -> [Text (lexeme lexbuf)]
| numeric -> [Numeric (lexeme lexbuf)]
| boolean -> [Constant (lexeme lexbuf)]
| obj_field -> Ulexing.rollback lexbuf ; obj_field lexbuf
| id -> [Keyword (1,lexeme lexbuf)]
| string -> [String (lexeme lexbuf)]
| char -> [String (lexeme lexbuf)]
| eof -> []
| _ -> [Text (lexeme lexbuf)]

and obj_field = lexer
| id | string ->
  let t = Keyword (1,lexeme lexbuf) in
  t :: obj_field lexbuf
| space ->
  let t = Text (lexeme lexbuf) in
  t :: obj_field lexbuf
| ':' -> [Symbol(0, lexeme lexbuf)]
| _ -> Ulexing.rollback lexbuf; main lexbuf

let () = Higlo.register_lang "json" main
