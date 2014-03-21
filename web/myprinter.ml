
open Higlo;;

let token_to_string = function
| Bcomment s
| Constant s
| Directive s
| Escape s
| Id s
| Keyword (_, s)
| Lcomment s
| Numeric s
| String s
| Symbol (_, s)
| Text s -> s
;;

let printer tokens =
  List.iter (fun t -> print_string (token_to_string t)) tokens
;;

let () = Higlo_printers.register_printer "raw" printer;;