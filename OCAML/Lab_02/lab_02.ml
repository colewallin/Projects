let rec power i x = 
  if i = 0 then 1.0
  else (power (i-1) x) *. x ;;

let circle_area_v1 x =  3.1415 *. (x /. 2.0) *. (x /. 2.0);;

let circle_area_v2 x =
  let pi=3.1415 
  in 
  let rad = x /. 2.
  in 
  pi *. power 2 rad ;;

let rec product xs = 
  match xs with
  | [] -> 1	
  | x::rest -> x * product rest ;;

let rec sum_diffs xs = 
  match xs with
  | [] -> 0
  | x1::[] -> 0
  | x1::(x2::[]) -> (x1 - x2)
  | x1::x2::xs -> (x1 - x2) + sum_diffs (x2::xs) ;;

let distance (x1, y1) (x2, y2) = 
  let x = x2 -. x1
  in 
  let y = y2 -. y1
  in 
  sqrt ((power 2 x) +. (power 2 y)) ;; 

let triangle_perimeter (x1, y1) (x2, y2) (x3, y3)=
  let side1 =  distance (x1, y1) (x2, y2)
  in
  let side2 =  distance (x2, y2) (x3, y3)
  in
  let side3 =  distance (x1, y1) (x3, y3)
  in
  side1 +. side2 +. side3
