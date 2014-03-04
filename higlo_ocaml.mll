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

let regexp digit = ['0'-'9']
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

let regexp numeric = integer_positive | decimal_positive | double_positive | integer_negative | decimal_negative | double_negative | integer | decimal | double

let regexp boolean = "true" | "false"
let regexp echar = ['t' 'b' 'n' 'r' 'f' '\\' '"' '\'']

let regexp escaped_char = '\\' echar
let regexp string = '"' ( ([^0x22]) | escaped_char )* '"'
let regexp char = "'" ( ([^0x27]) | escaped_char ) "'"

let regexp space = [' ' '\n' '\t' '\r' ]+

let regexp capchar = ['A'-'Z']
let regexp lowchar = ['a'-'z']
let regexp idchar =  lowchar | capchar | '_' | digit

let regexp modname = capchar idchar*

let regexp comment = "(*" ([^0x2A] | ('*'[^')']))* "*)"

let regexp id = ('_'|lowchar) idchar*

let regexp decl_kw = "and" |"class" |"constraint" |"exception" |"external" |"let" |"fun" |"function" |"functor" |"in" |"include" |"inherit" |"initializer" |"method" |"module" |"mutable" |"of" |"open" |"private" |"rec" |"type" |"val" |"virtual"

let regexp expr_kw ="asr" |"do" |"else" |"for" |"if" |"while" |"as" |"assert" |"begin" |"do" |"done" |"downto" |"else" |"end" |"for" |"if" |"land" |"lazy" |"lor" |"lsl" |"lsr" |"lxor" |"match" |"mod" |"new" |"object" |"or" | "ref" |"sig" |"struct" |"then" |"to" |"try" |"when" |"while" |"with" |"#"

let regexp type_kw =  "bool" | "int" |"string" |"list" |"array" |"float" |"char" |"unit"
let regexp label = '~' id

let rec main = lexer
| space -> [Text (lexeme lexbuf)]
| numeric -> [Numeric (lexeme lexbuf)]
| boolean -> [Constant (lexeme lexbuf)]
| decl_kw -> [Keyword (0, lexeme lexbuf)]
| expr_kw -> [Keyword (1, lexeme lexbuf)]
| modname -> [Keyword (2, lexeme lexbuf)]
| type_kw -> [Keyword (3, lexeme lexbuf)]
| label -> [Keyword (4, lexeme lexbuf)]
| id -> [Id (lexeme lexbuf)]
| string -> [String (lexeme lexbuf)]
| char -> [String (lexeme lexbuf)]
| comment -> [Bcomment (lexeme lexbuf)]
| _ -> [Text (lexeme lexbuf)]
;;

let () = Higlo.register_lang "ocaml" main;;
