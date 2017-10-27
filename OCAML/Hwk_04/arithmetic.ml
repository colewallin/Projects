
type expr
  = Const of int
  | Add of  expr * expr
  | Mul of expr * expr
  | Sub of expr * expr
  | Div of expr * expr

let rec show_expr (e:expr) =
  match e with
  | Const x -> string_of_int x
  | Add(e1, e2) -> "(" ^ show_expr e1 ^ "+" ^ show_expr e2 ^ ")"
  | Mul(e1, e2) -> "(" ^ show_expr e1 ^ "*" ^ show_expr e2 ^ ")"
  | Sub(e1, e2) -> "(" ^ show_expr e1 ^ "-" ^ show_expr e2 ^ ")"
  | Div(e1, e2) -> "(" ^ show_expr e1 ^ "/" ^ show_expr e2 ^ ")"

(*The precedence is just passes to tell if the functions are the same or not:
Add = 1
Sub = 2
Mul = 3
Div = 4
*)
let rec put_perens (e:expr) (p:int) (on_the_left: bool) =
  match e with
  | Const x -> string_of_int x
  | Add(e1, e2) -> if (on_the_left && (p = 1)) then put_perens e1 1 true ^ "+" ^ put_perens e2 1 false
                   else if (on_the_left && (1 < p)) then "(" ^ put_perens e1 1 true ^ "+" ^ put_perens e2 1 false ^ ")"
                   else "(" ^ put_perens e1 1 true ^ "+" ^ put_perens e2 1 false ^ ")"
  | Sub(e1, e2) -> if (on_the_left && (p = 2)) then put_perens e1 2 true ^ "-" ^ put_perens e2 2 false
                   else if (on_the_left && (2 < p)) then "(" ^ put_perens e1 2 true ^ "+" ^ put_perens e2 2 false ^ ")"
                   else "(" ^ put_perens e1 2 true ^ "-" ^ put_perens e2 2 false ^ ")"
  | Mul(e1, e2) -> if (on_the_left) then put_perens e1 3 true ^ "*" ^ put_perens e2 3 false
                   else if (not on_the_left) && 3 > p then put_perens e1 3 true ^ "*" ^ put_perens e2 3 false
                   else "(" ^ put_perens e1 3 true ^ "*" ^ put_perens e2 3 false ^ ")"
  | Div(e1, e2) -> if (on_the_left) then put_perens e1 4 true ^ "/" ^ put_perens e2 4 false
                   else if (not on_the_left) && 4 > p then put_perens e1 4 true ^ "/" ^ put_perens e2 4 false
                   else "(" ^ put_perens e1 4 true ^ "/" ^ put_perens e2 4 false ^ ")"

let rec show_pretty_expr (e:expr) =
  match e with
  | Const x -> string_of_int x
  | Add(e1, e2) -> put_perens e1 1 true ^ "+" ^ put_perens e2 1 false
  | Sub(e1, e2) -> put_perens e1 2 true ^ "-" ^ put_perens e2 2 false
  | Mul(e1, e2) -> put_perens e1 3 true ^ "*" ^ put_perens e2 3 false
  | Div(e1, e2) -> put_perens e1 4 true ^ "/" ^ put_perens e2 4 false
