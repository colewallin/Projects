let even x = 
 match x mod 2 with
 | 1 -> false
 | 0 -> true ;;

let rec euclid a b =
 if a = b then a 
 else if a < b then euclid a (b-a)
 else euclid (a-b) b ;;

let frac_add (n1, d1) (n2, d2) = 
 let n = n1*d2 + n2*d1
 in 
 let d = d1 * d2
 in 
 (n, d) ;;

let frac_simplify (n, d) = 
 let factor = euclid n d 
 in 
 (n/factor, d/factor) ;;


let square_approx n accuracy = 
 let upper = n
 in 
 let lower = 1.0
 in
 let rec converge hi low = 
  if ((hi -. low) < accuracy) then (low, hi)
  else let guess = ((low +. hi) /. 2.0) in 
   if ((guess *. guess) > n) then converge guess low
   else converge hi guess
 in 
 converge upper lower ;;


let rec max_list vals = 
(* Originally I had a max variable that was set to -100 so the elements
 in the list all would have needed to be above that value but then I 
 figured out how to do this without using a temporary variable so I did*)
  match vals with
  | anything::[] -> anything
  | val1::val2::rest -> if(val1 > val2) then max_list (val1::rest) else max_list (val2::rest) ;;

let rec drop i xs = 
 if i = 0 then xs
 else
 match xs with
 |[]->[]
 |h::t -> drop (i-1) t ;;

let rev xs =
 let flip = [] 
 in 
 let rec fill xs f= 
 match xs with
 |[] -> f
 |a::rest ->  fill rest ([a] @ f)
 in 
 fill xs flip ;;

let rec power i x = 
 if i = 0 then 1.0
 else (power (i-1) x) *. x ;;

let distance (x1, y1) (x2, y2) = 
 let x = x2 -. x1
 in 
 let y = y2 -. y1
 in 
 sqrt((power 2 x) +. (power 2 y)) ;;

let perimeter xs = 
 let rec helper first_point vals = 
 match vals with
 |final_point::[] -> distance final_point first_point 
 |x1::x2::rest -> distance x1 x2 +. helper first_point (x2::rest)
 in
 match xs with
 | p1::rest -> helper p1 xs ;;

let rec length l =
 match l with
 | [] -> 0
 | x::[] -> 1
 | x::rest -> 1 + length rest ;;

let rec is_matrix mat = 
 match mat with 
 |x1::x2::rest -> if (length x1 <> length x2) then false else is_matrix (x2::rest)
 |x1::[] -> true ;;

let rec matrix_scalar_add matrix scalar = 
 let rec adder mat scale = 
  match mat with
  |x::[] -> [x+scale]
  |x::rest -> [x+scale] @ adder rest scale 
 in
 match matrix with 
 |x::[] -> [adder x scalar]
 |x::rest -> [adder x scalar] @ matrix_scalar_add rest scalar;;








 






