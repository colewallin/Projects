(*
Cole Wallin - 5117843
*)


let rec is_not_elem set v =
  match set with
  | [] -> true
  | s::ss -> if s = v then false else is_not_elem ss v

let run e = (fun x -> ()) e

let is_elem v l =
  List.fold_right (fun x in_rest -> if x = v then true else in_rest) l false

let rec explode = function
  | "" -> []
  | s  -> String.get s 0 :: explode (String.sub s 1 ((String.length s) - 1))


(* Location: x position and a y position on the graph. *)
type loc = int * int

exception KeepLooking

let rec process_solution show s =
  print_endline ( "Here is a solution:\n" ^ show s) ;
  print_endline ("Do you like it?") ;

  match is_elem 'Y' (explode (String.capitalize (read_line ()))) with
  | true  -> print_endline "Thanks for playing..." ; Some s
  | false -> raise KeepLooking


(* Some function for printing a sequence of moves. *)
let show_list show l =
  let rec sl l =
    match l with
    | [] -> ""
    | [x] -> show x
    | x::xs -> show x ^ "; " ^ sl xs
  in "[ " ^ sl l ^ " ]"

let show_pos (x,y) = "(" ^ (string_of_int x) ^ ", " ^ (string_of_int y) ^ ")"

let show_path = show_list show_pos

let win ( (x,y) :loc) : bool =  (x = 3 && y = 5) || (x = 5 && y = 1)


let maze_moves (pos:loc) : loc list =
    match pos with
    | (1, 1) -> [(2,1)]
    | (1, 2) -> [(1,3); (2,2)]
    | (1, 3) -> [(1,2); (1,4); (2,3)]
    | (1, 4) -> [(1,3); (1,5)]
    | (1, 5) -> [(1,4); (2,5)]
    | (2, 1) -> [(1,1); (3,1)]
    | (2, 2) -> [(1,2); (3,2)]
    | (2, 3) -> [(1,3)]
    | (2, 4) -> [(2,5); (3,4)]
    | (2, 5) -> [(1,5); (2,4)]
    | (3, 1) -> [(2,1); (3,2)]
    | (3, 2) -> [(2,2); (3,1); (3,3); (4,2)]
    | (3, 3) -> [(3,2); (4,3); (3,4)]
    | (3, 4) -> [(2,4); (3,3); (4,4)]
    | (3, 5) -> [(4,5)]
    | (4, 1) -> [(4,2)]
    | (4, 2) -> [(3,2)]
    | (4, 3) -> [(3,3); (5,3)]
    | (4, 4) -> [(3,4); (4,5)]
    | (4, 5) -> [(3,5); (5,5)]
    | (5, 1) -> [(5,2)]
    | (5, 2) -> [(5,3); (5,1)]
    | (5, 3) -> [(4,3); (5,2); (5,4)]
    | (5, 4) -> [(5,3)]
    | (5, 5) -> [(4,5)]
    | _ -> failwith "There are no other positions on the graph"

let x = is_not_elem [(2,3); (2,3)]

let maze () =
  let rec go_from pos path =
    if win pos
    then Some path
    else
      match List.filter (is_not_elem path) (maze_moves pos) with
      | [] -> raise KeepLooking
      | [a] -> (go_from a (path @ [a]) )
      | [a;b] ->
          (try go_from a (path @ [a]) with
           | KeepLooking -> go_from b (path @ [b])
          )
      | [a;b;c] ->
          (try go_from a (path @ [a]) with
           | KeepLooking -> (try go_from b (path @ [b]) with
                             | KeepLooking -> go_from c (path @ [c])
                            )
          )
      | [a;b;c;d] ->
          (try go_from a (path @ [a]) with
           | KeepLooking -> (try go_from b (path @ [b]) with
                             | KeepLooking -> (try go_from c (path @ [c]) with
                                               | KeepLooking -> go_from d (path @ [d])
                                              )
                            )
          )
      | _ -> failwith "Not a possbility on this maze"
  in go_from (2,3) [(2,3)]
