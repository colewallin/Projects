type expr
  = Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

  | Lt of expr * expr
  | Eq of expr * expr
  | And of expr * expr

  | If of expr * expr * expr

  | Id of string

  | Let of string * expr * expr
  | LetRec of string * expr * expr

  | App of expr * expr
  | Lambda of string * expr

  | Value of value

and value
  = Int of int
  | Bool of bool
  | Ref of value ref
  | Closure of string * expr * environment


and environment = (string * value) list

 (*You may need an extra constructor for this type. *)

let rec freevars (e:expr) : string list =
  match e with
  | Value _ -> []
  | Add (e1, e2) -> freevars e1 @ freevars e2
  | Sub (e1, e2) -> freevars e1 @ freevars e2
  | Mul (e1, e2) -> freevars e1 @ freevars e2
  | Div (e1, e2) -> freevars e1 @ freevars e2
  | App (f, a) -> freevars f @ freevars a
  | Lambda (i, body) -> List.filter (fun i' -> i' <> i) (freevars body)
  | Id i -> [i]
  | Let (i, dexpr, body) ->
        freevars dexpr @ List.filter (fun i' -> i' <> i) (freevars body)
  | LetRec (i, body, id) ->
        List.filter (fun i' -> i' <> i) (freevars body)
  | Lt (e1, e2) -> freevars e1 @ freevars e2
  | Eq (e1, e2) -> freevars e1 @ freevars e2
  | And (e1, e2) -> freevars e1 @ freevars e2
  | If (e1, e2, e3) -> freevars e1 @ freevars e2 @ freevars e3
  (*| Id e -> [e]
  | App (e1, e2) -> raise (Failure "App freevar")
  | Lambda (s, e) -> raise (Failure "Labmda freevar")
  | App (e1, e2) -> raise (Failure "Value freevar")*)

let rec lookup (n:string) (env:environment) : value =
  match env with
  |(s, v)::xs -> if (n = s) then v else lookup n xs
  | _ -> raise (Failure (n ^ " not in scope"))

let rec eval (env:environment) (e:expr) : value =
  match e with
  | Value v -> v
  | Add(e1, e2) ->
        (match eval env e1, eval env e2 with
          | Int i1, Int i2 -> Int(i1 + i2)
          | _ -> raise (Failure "Incompatable types on Add")
        )
  | Sub(e1, e2) ->
        (match eval env e1, eval env e2 with
          | Int i1, Int i2 -> Int(i1 - i2)
          | _ -> raise (Failure "Incompatable types on Sub")
        )
  | Mul(e1, e2) ->
        (match eval env e1, eval env e2 with
          | Int i1, Int i2 -> Int(i1 * i2)
          | _ -> raise (Failure "Incompatable types on Mul")
        )
  | Div(e1, e2) ->
          (match eval env e1, eval env e2 with
            | Int i1, Int i2 -> Int(i1 / i2)
            | _ -> raise (Failure "Incompatable types on Div")
          )
  | Lt(e1, e2) ->
        (match eval env e1, eval env e2 with
          | Int i1, Int i2 -> Bool(i1 < i2)
          | _ -> raise (Failure "Incompatable types on Lt")
        )
  | Eq(e1, e2) ->
        (match eval env e1, eval env e2 with
          | Int i1, Int i2 -> Bool(i1 = i2)
          | Bool i1, Bool i2 -> Bool(i1 && i2)
          | _ -> raise (Failure "Incompatable types on Eq")
        )
  | And(e1, e2) ->
        (match eval env e1, eval env e2 with
          | Bool i1, Bool i2 -> Bool(i1 && i2)
          | _ -> raise (Failure "Incompatable types on And")
        )
  | If(e1, e2, e3) ->
        (match eval env e1 with
          | Bool(true) -> eval env e2
          | Bool(false) -> eval env e3
          | _ -> raise (Failure "Incompatable types on If")
        )
  | Id n -> lookup n env
  | Let(i, dexpr, body) ->
        let dexpr_v = eval env dexpr in
        let body_v = eval ((i, dexpr_v)::env) body in
        body_v
  | LetRec(name, somelambda, funcID) ->
          (match somelambda with
            | Lambda(i, e) ->
                let recRef = ref (Int 999) in
                let c = (eval ((name, Ref recRef)::env) somelambda) in
                let () = recRef := c in
                eval ((name, c)::env) funcID
            | _ -> raise (Failure "let rec expressions must declare a function")
          )
  | App (func_ex, value) ->
    let v = eval env func_ex in
          (match v with
            | Closure(var, e, env2) -> eval ((var, eval env value)::env2) e
            | Ref r -> (match !r with
                          | Closure(var, e, env2) -> eval ((var, eval env value)::env2) e
                          | _ -> raise(Failure "AGH")
                        )
            | _ -> raise(Failure "Missing the Closure in App")
          )
  | Lambda(i, e) -> Closure(i, e, env)



let evaluate (e:expr) : value = eval [] e



(* Some sample expressions *)

let inc = Lambda ("n", Add(Id "n", Value (Int 1)))

let add = Lambda ("x",
                  Lambda ("y", Add (Id "x", Id "y"))
                 )

(* The 'sumToN' function *)
let sumToN_expr : expr =
    LetRec ("sumToN",
            Lambda ("n",
                    If (Eq (Id "n", Value (Int 0)),
                        Value (Int 0),
                        Add (Id "n",
                             App (Id "sumToN",
                                  Sub (Id "n", Value (Int 1))
                                 )
                            )
                       )
                   ),
            Id "sumToN"
           )

let twenty_one : value = evaluate (App (sumToN_expr, Value (Int 6)));
