(*This funciton operates on the assertion that ands over the empty list returns true*)

let rec ands (l: bool list) : bool = 
  match l with 
  | x::xs -> if x then x && (ands xs) else false
  | [] -> true
