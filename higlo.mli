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

(** Syntax highligthing *)

(** Tokens read in the given code. These names are inspired from
 the [highlight] tool. [Keyword] and [Symbol] are parametrized by
 an integer to be able to distinguish different families of keywords
 and symbols, as [kwa], [kwb], ..., in [highlight].
*)
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

(** For debug printing. *)
val string_of_token : token -> string

(** Raised by {!get_lexer} when the required language is not found. *)
exception Unknown_lang of string

(** Lexers are based on Ulex. A lexer returns a list of tokens,
  in the same order they appear in the read string.
  [Text] tokens are merged by the {!parse} function.
*)
type lexer = Ulexing.lexbuf -> token list

(** [get_lexer lang] returns the lexer registered for the given language
  [lang] or raise {!Unknown_lang} is no such language was registered. *)
val get_lexer : string -> lexer

(** If a lexer was registered for the same language, it is not
  available any more. *)
val register_lang : string -> lexer -> unit

(** [parse ~lang code] get the lexer associated to [lang]
  and use it to build a list of tokens. Consecutive [Text]
  tokens are merged.
  If no lexer is associated to the given language, then
  the function returns [Text code].
*)
val parse : lang: string -> string -> token list

(** This structure defines the (X)HTML classes to use
  when producing XML. *)
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

(** Default X(HTML) classes. *)
val default_classes : classes

(** Map a token to an XML tree (just a <span class="...">code</span> node).
  @param classes is used to change the class names used in the generated
  node. *)
val token_to_xtmpl : ?classes: classes -> token -> Xtmpl.tree

(** [to_xtmpl ~lang code] gets the lexer associate to the language [lang],
  use it to retrieve a list of tokens (using the {!parse} function)
  and map these tokens to XML nodes. See {!token_to_xtmpl} about
  the [classes] parameter. *)
val to_xtmpl : ?classes: classes -> lang:string -> string -> Xtmpl.tree list
