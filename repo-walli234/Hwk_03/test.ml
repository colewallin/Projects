type nat = Zero | Succ of Nat

let toInt = function
  | Zero -> 0
  | Succ n -> n + 1

let rec power n x = match n with
  | Zero -> 1.0
  | Succ n' -> x *. power n' x
