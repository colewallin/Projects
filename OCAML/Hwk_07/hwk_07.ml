(*
Cole Wallin - 5117843
*)


(*
A signature for the vector modules
*)

module type Coordinate = sig
    type t
    val add_element : t -> t -> t
    val mul_element : t -> t -> t
    val to_string : t -> string
  end


module type Arithmetic_intf = sig
    type t
    type element
    val create :  int -> element -> t
    val from_list : element list -> t
    val to_list : t -> element list
    val scalar_add : element -> t -> t
    val scalar_mul : element -> t -> t
    val scalar_prod : t -> t -> element option
    val to_string : t -> string
    val size : t -> int
  end



(*
A functor for creating vector modules that implements the signature for vector
 modules.
*)


module Make_vector(Element : Coordinate) :
    (Arithmetic_intf with type element := Element.t) = struct

  type element = Element.t

  type t = | Vector of int * Element.t list
           | Empty

  let create (n : int) (init : element) =
    let rec helper (dim : int) (v : element)=
      match dim with
      | 0 -> []
      | _ -> v :: helper (dim-1) v
    in
    if n=0 then Empty
    else
     Vector (n, helper n init)

  let from_list (lst : element list) : t =
    Vector(List.length lst, lst)

  let to_list (vec : t) : element list =
    match vec with
    | Vector(_ , l) -> l
    | _ -> failwith "This should match all vectors"

  let scalar_add (scalar : element) (vec : t) : t =
    match vec with
    | Vector(s, l) -> Vector(s,
                                List.map (fun x -> Element.add_element x scalar) l
                            )
    | _ -> failwith "This should match all vectors"

  let scalar_mul (scalar : element) (vec : t) : t =
    match vec with
    | Vector(s, l) -> Vector(s,
                                List.map (fun x -> Element.mul_element x scalar) l
                            )
    | _ -> failwith "This should match all vectors"

  let scalar_prod (v1 : t) (v2 : t) : element option =
    let rec helper f a b =
      match a,b with
      | (x1::[] , x2::[]) -> f x1 x2
      | (x::xs , s::ss) -> Element.add_element (f x s) (helper f xs ss)
      | _ -> failwith "This should match all vector situations of a dot product"
    in
    match v1, v2 with
    | Vector(s1 , l1) , Vector(s2 , l2) -> if s1 = s2 then Some (helper Element.mul_element l1 l2)
                                           else None

    | _ -> failwith "This should match all vectors"

  let size (vec : t) : int =
    match vec with
    | Vector(s , _) -> s
    | Empty -> 0

  let to_string (vec : t) : string =
    let rec helper l =
      match l with
      | [] -> ""
      | x::[] -> Element.to_string x
      | x::xs -> Element.to_string x ^ ", " ^ (helper xs)
    in
    match vec with
    | Empty -> "Empty"
    | Vector(s, l) -> "<< " ^ string_of_int s ^ " | " ^ (helper l) ^ " >>"

end




module Int_arithmetic : (Coordinate with type t = int) = struct
  type t = int
  let add_element t1 t2 = t1 + t2
  let mul_element t1 t2 = t1 * t2
  let to_string = string_of_int
end

module Complex_arithmetic : (Coordinate with type t = (float * float)) = struct
  type t = float * float
  let add_element (r1 , i1) (r2 , i2) = (r1 +. r2 , i1 +. i2)
  let mul_element (r1 , i1) (r2 , i2) = ((r1 *. r2) -. (i1 *. i2) , (i1 *. r2) +. (i2 *. r1) )
  let to_string ((r, i) : t) = "(" ^ string_of_float r ^ "+" ^ string_of_float i ^ "i)"
end

module Int_vector = Make_vector(Int_arithmetic)

module Complex_vector = Make_vector(Complex_arithmetic)


(* The following line now works. *)
let i = Int_vector.create 10 1
