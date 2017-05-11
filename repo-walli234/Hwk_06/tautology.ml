(*
Cole Wallin - 5117843
*)

type formula = And of formula * formula
	     | Or  of formula * formula
	     | Not of formula
	     | Prop of string
	     | True
	     | False

(*Raise an exception to indicate that the search process should continue*)

exception KeepLooking

type subst = (string * bool) list

let show_list show l =
  let rec sl l =
    match l with
    | [] -> ""
    | [x] -> show x
    | x::xs -> show x ^ "; " ^ sl xs
  in "[ " ^ sl l ^ " ]"

let show_string_bool_pair (s,b) =
  "(\"" ^ s ^ "\"," ^ (if b then "true" else "false") ^ ")"

let show_subst = show_list show_string_bool_pair

let is_elem v l =
  List.fold_right (fun x in_rest -> if x = v then true else in_rest) l false

let rec explode = function
  | "" -> []
  | s  -> String.get s 0 :: explode (String.sub s 1 ((String.length s) - 1))

let dedup lst =
  let f elem to_keep =
    if is_elem elem to_keep then to_keep else elem::to_keep
  in List.fold_right f lst []

let rec lookup (p:string) (subs:subst) : bool  =
  match subs with
  |(s, v)::xs -> if (p = s) then v else lookup p xs
  | _ -> raise (Failure (p ^ " not in scope"))

let rec eval (f:formula) (subs:subst) : bool =
	match f with
	| True -> true
	| False -> false
	| Prop p -> lookup p subs
	| And (f1, f2) -> (eval f1 subs) && (eval f2 subs)
	| Or (f1, f2) -> (eval f1 subs) || (eval f2 subs)
	| Not f -> not (eval f subs)

let rec freevars (f:formula) : string list =
	match f with
	| True -> []
	| False -> []
	| Prop p -> [p]
	| And (f1, f2) -> dedup (freevars f1 @ freevars f2)
	| Or (f1, f2) -> dedup (freevars f1 @ freevars f2)
	| Not f -> dedup (freevars f)

let first_sub f = List.map (fun x-> (x, true)) (freevars f)

let rec process_substitution show s =
  print_endline ( "Here is a substitution that evaluates to false:\n" ^ show s) ;
  print_endline ("Do you like it?") ;

  match is_elem 'Y' (explode (String.capitalize (read_line ()))) with
  | true  -> print_endline "Thanks for playing..." ; Some s
  | false -> raise KeepLooking

(*
This is the show funciton right?
process_substitution (show_list show_string_bool_pair)
*)

let is_tautology (f:formula) succ : subst option =
	let variables = freevars f
	in
	let rec try_solution partial_subset rest_of_vars =
		if (rest_of_vars = []) && not (eval f partial_subset)
		then succ partial_subset
		else match rest_of_vars with
		| [] -> raise KeepLooking
		| x::xs -> try try_solution (partial_subset @ [(x, true)]) xs with
										| KeepLooking -> try_solution (partial_subset @ [(x, false)]) xs
	in try try_solution [] variables with
		 | KeepLooking -> None

	let is_tautology_first f = is_tautology f (fun s -> Some s)

	let is_tautology_print_all f =
  is_tautology
    f
    (fun s -> print_endline (show_subst s);
	      raise KeepLooking)
