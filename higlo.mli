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

val string_of_token : token -> string

exception Unknown_lang of string

type lexer = Ulexing.lexbuf -> token list

val get_lexer : string -> lexer
val register_lang : string -> lexer -> unit
val parse : lang: string -> string -> token list

type classes =
  { id : string ; keyword : int -> string ; lcomment : string ; bcomment : string ;
    string : string ; text : string ; numeric : string ; directive : string ;
    escape : string ; symbol : int -> string ; constant : string ;
  }

val default_classes : classes

val token_to_xtmpl : ?classes: classes -> token -> Xtmpl.tree
val to_xtmpl : ?classes: classes -> lang:string -> string -> Xtmpl.tree list
