(* Stream examples *)

type 'a stream = Cons of 'a * (unit -> 'a stream)

let rec ones = Cons (1, fun () -> ones)

(* So, where are all the ones?  We do not evaluate "under a lambda", 
   which means that the "ones" on the right hand side is not evaluated. *)

(* Note, "unit" is the only value of the type "()".  This is not too
   much unlike "void" in C.  We use the unit type as the output type
   for functions that perform some action like printing but return no
   meaningful result.

   Here the lambda expressions doesn't use the input unit value,
   we just use this technique to delay evaluation of "ones". 

   Sometimes lambda expressions that take a unit value with the
   intention of delaying evaluation are called "thunks".  *)

let head (s: 'a stream) : 'a = match s with
  | Cons (v, _) -> v

let tail (s: 'a stream) : 'a stream = match s with
  | Cons (_, tl) -> tl ()

let rec from n = 
  Cons ( n, 
         fun () -> print_endline ("step " ^ string_of_int (n+1)) ; 
                   from (n+1) )

let nats = from 1

(* what is
    head nats,   head (tail nats),     head (tail (tail nats))     ?
 *)

let rec take (n:int) (s : 'a stream) : ('a list) =
 if n = 0 then []
 else match s with
      | Cons (v, tl) -> v :: take (n-1) (tl ())


(* Can we write functions like map and filter for streams? *)

let rec filter (f: 'a -> bool) (s: 'a stream) : 'a stream =
  match s with
  | Cons (hd, tl) ->
     let rest = (fun () -> filter f (tl ()))
     in
     if f hd then Cons (hd, rest) else rest ()

let even x = x mod 2 = 0

let rec squares_from n : int stream = Cons (n*n, fun () -> squares_from (n+1) )

let t1 = take 10 (squares_from 1)

let squares = squares_from 1


let rec zip (f: 'a -> 'b -> 'c) (s1: 'a stream) (s2: 'b stream) : 'c stream =
  match s1, s2 with
  | Cons (hd1, tl1), Cons (hd2, tl2) ->
     Cons (f hd1 hd2, fun () -> zip f (tl1 ()) (tl2 ()) )

let rec nats2 = Cons ( 1, fun () -> zip (+) ones nats2)

(* Computing factorials

   nats       = 1   2   3   4    5     6 
                 \   \   \   \    \     \
                  *   *   *   *    *     *
                   \   \   \   \    \     \
   factorials = 1-*-1-*-2-*-6-*-24-*-120-*-720

   We can define factorials recursively.  Each element in the stream
   is the product of then "next" natural number and the previous
   factorial.
 *)

let rec factorials = Cons ( 1, fun () -> zip ( * ) nats factorials )


(* The Sieve of Eratosthenes

   We can compute prime numbers by starting with the sequence of
   natual numbers beginning at 2. 

   We take the first element in the sequence save it as a prime number
   and then cross of all multiples of that number in the rest of the
   sequence.

   Then repeat for the next number in the sequence.

   This process will find all the prime numbers.
 *)

let non f x = not (f x)
let multiple_of a b = b mod a = 0

let sift (a:int) (s:int stream) = filter (non (multiple_of a)) s

let rec sieve s = match s with
  | Cons (x, xs) -> Cons(x, fun () -> sieve (sift x (xs ()) ))

let primes = sieve (from 2)


(*Everything above this comment was done by Eric Van Wyk. Everything below was done by Cole Wallin*)

let rec cubes_from (n:int) : int stream = Cons(n*n*n, fun () -> cubes_from (n+1))

let rec drop (n:int) (s: 'a stream) = 
  if n = 0 then s else drop (n-1) (tail s)

let rec drop_until (f:'a -> bool) (s:'a stream) : 'a stream = 
  if f (head s) then s else drop_until f (tail s)

let rec map (f: 'a -> 'b) (s: 'a stream) : 'b stream = 
  Cons(f (head s), fun () -> map f (tail s))

let squares_again = map (fun x -> x*x) nats ;;

let sqrt_approximations (n:float) : float stream = 
  let upper = n in 
  let lower = 1.0 in 
  let rec converge hi low = 
    let guess = ((low +. hi) /. 2.0) in
    if ((guess *. guess) > n) then Cons(guess, fun () -> converge guess low)
    else Cons(guess, fun () -> converge hi guess)
  in
  converge upper lower

let diminishing = 
  let rec help x = Cons(x, fun () -> help (x /. 2.0)) in
  help 16.0

let rec epsilon_diff (epsilon: float) (s:float stream) : float = 
  match s with 
  | Cons(h, t) -> if(abs_float(h -.(head (t ()))) < epsilon) then head (t ()) else epsilon_diff epsilon (t ())

let rough_guess = epsilon_diff 1.0 (sqrt_approximations 50.0)

let precise_calculation = epsilon_diff 0.00001 (sqrt_approximations 50.0)



(*The values are more accurate than we might think due to the quadratic nature of the problem. Evaulating 50.0 at
 a threshold of 3.0 gives a range of 47 to 53. The difference between sqrt(47) and sqrt(53) will be a lot smaller 
 than 3 as a result of this relationship. If we calculated the squareroot of larger and larger values but kept the 
threshold the same, the results would get more and more accurate due to this exponential growth of squares. *)


(*This function zips together a stream of sqrt approximations and threshold tests into one stream of tuples of
those values. It simply checks until the correct threshold is met and then returns the corresponding value in the
tuple.*)

let rec sqrt_threshold (v:float) (t:float) : float = 
  let str = map (fun x -> (x *. x) -. v) (sqrt_approximations v) in
  let strrr = zip (fun a b -> (a, b)) str (sqrt_approximations v) in
  let rec test teststream thresh = 
  match teststream with 
  | Cons((diff, s),tl) -> if (diff < thresh) then s else test (tl ()) thresh
  in 
  test strrr t 






