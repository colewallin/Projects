(*Cole Wallin, Mateos Namera*)


(*This was the first file that I started to put error handling in. I eliminated all of the warnings
in the pattern matching of the function by handling the cases where the function is given the empty list.
We did get a little confused because I still need to handle the empty list in the helper function even though
the outer funciton takes care of that error and the helper funciton will never get passed the empty list*)

let rec matrix_scalar_add matrix scalar = 
 let rec adder mat scale = 
  match mat with
  |x::[] -> [x+scale]
  |x::rest -> [x+scale] @ adder rest scale
  | _ -> raise (Failure "Cannot scale a row if there are no elements in the row") 
 in
 match matrix with 
 |x::[] -> [adder x scalar]
 |x::rest -> [adder x scalar] @ matrix_scalar_add rest scalar
 | _ -> raise (Failure "Cannot scale a matirx if it doesn't exist")
  
(*In my rev function, I was originall using 'fill rest ([a] @ rest)' but in this case Mateos pointed out to me 
that I will always know that 'a' is just a single element and not a list that I do not know the length of so I 
can just use the cons operator instead of treating it like a list and appending it to the rest of the recursive call  . *)
let rev xs =
 let flip = [] 
 in 
 let rec fill xs f= 
 match xs with
 |[] -> f
 |a::rest ->  fill rest (a::f)
 in 
 fill xs flip 

let rec power i x = 
 if i = 0 then 1.0
 else (power (i-1) x) *. x ;;

let distance (x1, y1) (x2, y2) = 
 let x = x2 -. x1
 in 
 let y = y2 -. y1
 in 
 sqrt((power 2 x) +. (power 2 y)) 

(*Originally I had planned to handle the cases in the periemeter funciton with errors but then mateos pointed out 
to me how I can change my perimeter funciton two handle the two special cases without error messages. The 
first case is where you are given an empty list, just return 0.0 because the perimeter of nothing is zero. 
The second case is when you are given just a single point. Since the helper function passes in the first point
down the recursive chain, it is always being kept track of. If I pass in the first point and then compare it to a
list of just one point, and then call the distance function on it, I will be calling the distance funciton on two points 
that are the same and the resulting distance will just be 0. Problem solved. Thanks Mateos*)

let perimeter xs = 
 let rec helper first_point vals = 
  match vals with
  |final_point::[] -> distance final_point first_point 
  |x1::x2::rest -> distance x1 x2 +. helper first_point (x2::rest)
  | [] -> 0.0
 in
 match xs with
 | x::rest -> helper x xs
 | [] -> 0.0


let even x = 
 match x mod 2 with
 | 1 -> false
 | 0 -> true 
 | _ -> raise (Failure "The remainder of anything mod 2 should just be zero or one")

let rec euclid a b =
 if (a <= 0 || b <= 0) then raise (Failure  "a and b must both be positive integers")
 else
 if a = b then a 
 else if a < b then euclid a (b-a)
 else euclid (a-b) b 

let frac_add (n1, d1) (n2, d2) =
 if (d1 = 0 || d2 = 0) then raise (Failure  "Cannot divide by zero")
 else 
 let n = n1*d2 + n2*d1
 in 
 let d = d1 * d2
 in 
 (n, d) 

let frac_simplify (n, d) = 
 if (d = 0) then raise (Failure  "Cannot divide by zero")
 else
 let factor = euclid n d 
 in 
 (n/factor, d/factor) 


let square_approx n accuracy =
 if n <= 1.0 then raise (Failure  "The input must be greater than one")
 else
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
  converge upper lower 


let rec max_list vals = 
(* Originally I had a max variable that was set to -100 so the elements
 in the list all would have needed to be above that value but then I 
 figured out how to do this without using a temporary variable so I did*)
  match vals with
  | anything::[] -> anything
  | val1::val2::rest -> if(val1 > val2) then max_list (val1::rest) else max_list (val2::rest)
  | _ -> raise (Failure "There cannot be a max in a list of zero elements.") 

let rec drop i xs = 
 if i = 0 then xs
 else
 match xs with
 |[]->[]
 |h::t -> drop (i-1) t 



let perimeter xs = 
 let rec helper first_point vals = 
  match vals with
  |final_point::[] -> distance final_point first_point 
  |x1::x2::rest -> distance x1 x2 +. helper first_point (x2::rest)
  | [] -> 0.0
 in
 match xs with
 | x::rest -> helper x xs
 | [] -> 0.0


let rec length l =
 match l with
 | [] -> 0
 | x::[] -> 1
 | x::rest -> 1 + length rest 

let rec is_matrix mat = 
 match mat with 
 |x1::x2::rest -> if (length x1 <> length x2) then false else is_matrix (x2::rest)
 |x1::[] -> true
 | _ -> raise (Failure "Cannot test a matrix with nothing in it") 










 






