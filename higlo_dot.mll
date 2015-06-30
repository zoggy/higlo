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

let regexp echar = ['t' 'b' 'n' 'r' 'f' '\\' '"' '\'']

let regexp escaped_char = '\\' echar
let regexp string = '"' ( ([^0x22]) | escaped_char )* '"'
let regexp char = "'" ( ([^0x27]) | escaped_char ) "'"

let regexp space = [' ' '\n' '\t' '\r' ]+

let regexp comment = "/*" ([^0x2A] | ('*'[^'/']))* "*/"

let regexp keyword = "digraph" |"edge" |"graph" |"subgraph"

let regexp attribute =
  "arrowhead" | "arrowsize" | "arrowtail" | "bgcolor" | "center" | "color" | "constraint" | "decorateP" | "dir" | "distortion" | "fillcolor" | "fontcolor" | "fontname" | "fontsize" | "headclip" | "headlabel" | "height" | "labelangle" | "labeldistance" | "labelfontcolor" | "labelfontname" | "labelfontsize" | "label" | "layers" | "layer" | "margin" | "mclimit" | "minlen" | "name" | "nodesep" | "nslimit" | "ordering" | "orientation" | "pagedir" | "page" | "peripheries" | "port_label_distance" | "rankdir" | "ranksep" | "rank" | "ratio" | "regular" | "rotate" | "samehead" | "sametail" | "shapefile" | "shape" | "sides" | "size" | "skew" | "style" | "tailclip" | "taillabel" | "URL" | "weight" | "width"

let regexp symbol = ("--"|"->")

let rec main = lexer
| space -> [Text (lexeme lexbuf)]
| keyword -> [Keyword (0, lexeme lexbuf)]
| attribute -> [Keyword (1, lexeme lexbuf)]
| string -> [String (lexeme lexbuf)]
| char -> [String (lexeme lexbuf)]
| comment -> [Bcomment (lexeme lexbuf)]
| symbol -> [Keyword(2,lexeme lexbuf)]
| _ -> [Text (lexeme lexbuf)]
;;

let () = Higlo.register_lang "dot" main;;
