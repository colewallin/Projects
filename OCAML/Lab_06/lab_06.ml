type 'a tree = Leaf of 'a
             | Fork of 'a * 'a tree * 'a tree

let t1 = Leaf 5
let t2 = Fork (3, Leaf 3, Fork (2, t1, t1))
let t3 = Fork ("Hello", Leaf "World", Leaf "!")
let t4 = Fork (7, Fork (5, Leaf 1, Leaf 2), Fork (6, Leaf 3, Leaf 4))
let t5 = Fork (Some "a", Leaf (Some "b"), Fork (Some "c", Leaf None, Leaf (Some "d")))
let t7 = (Fork (Some 1, Leaf (Some 2), Fork (Some 3, Leaf None, Leaf None)))
let t8 = (Fork (Some "a", Leaf (Some "b"), Fork (Some "c", Leaf None, Leaf (Some "d"))))

let rec t_size t =
  match t with
  | Leaf _ -> 1
  | Fork (_, t1, t2) -> 1 + t_size t1 + t_size t2

let rec t_sum t =
  match t with
  | Leaf x -> x
  | Fork (x, t1, t2) -> x + t_sum t1 + t_sum t2

let rec t_charcount t =
  match t with
  | Leaf x -> String.length x
  | Fork (x, t1, t2) -> String.length x + t_charcount t1 + t_charcount t2

let rec t_concat t =
  match t with
  | Leaf x -> x
  | Fork (x, t1, t2) -> x ^ t_concat t1 ^ t_concat t2

let rec t_opt_size t =
  match t with
  | Leaf Some _ -> 1
  | Leaf None -> 0
  | Fork (Some _, t1, t2) -> 1 + t_opt_size t1 + t_opt_size t2
  | Fork (None, t1, t2) -> t_opt_size t1 + t_opt_size t2

let rec t_opt_sum t =
  match t with
  | Leaf Some x -> x
  | Leaf None -> 0
  | Fork (Some x, t1, t2) -> x + t_opt_sum t1 + t_opt_sum t2
  | Fork (None, t1, t2) -> t_opt_sum t1 + t_opt_sum t2

let rec t_opt_charcount t =
  match t with
  | Leaf Some x -> String.length x
  | Leaf None -> 0
  | Fork (Some x, t1, t2) -> String.length x + t_opt_charcount t1 + t_opt_charcount t2
  | Fork (None, t1, t2) -> t_opt_charcount t1 + t_opt_charcount t2

let rec t_opt_concat t =
  match t with
  | Leaf Some x -> x
  | Leaf None -> ""
  | Fork (Some x, t1, t2) -> x ^ t_opt_concat t1 ^ t_opt_concat t2
  | Fork (None, t1, t2) -> t_opt_concat t1 ^ t_opt_concat t2

let rec tfold (l:'a -> 'b) (f:'a -> 'b -> 'b -> 'b)  (t:'a tree) : 'b =
         match t with
         | Leaf v -> l v
         | Fork (v, t1, t2) -> f v (tfold l f t1) (tfold l f t2)

let tf_size t = tfold (fun _ -> 1) (fun a b c -> 1 + b + c) t

let tf_sum t = tfold (fun x -> x) (fun a b c -> a + b + c) t

let tf_char_count t = tfold (fun x -> String.length x) (fun a b c -> String.length a + b + c) t

let tf_concat t = tfold (fun x -> x) (fun a b c -> a ^ b ^ c) t

let tf_opt_size t = tfold (fun x ->
                                  match x with
                                  | Some _ -> 1
                                  | None -> 0) (fun a b c ->
                                                          match a with
                                                          | Some _ -> 1 + b + c
                                                          | None -> b + c) t

let tf_opt_sum t = tfold (fun x ->
                                match x with
                                | Some x -> x
                                | None -> 0) (fun a b c ->
                                                        match a with
                                                        | Some a -> a + b + c
                                                        | None -> b + c) t

let tf_opt_char_count t = tfold (fun x ->
                                      match x with
                                      | Some x -> String.length x
                                      | None -> 0) (fun a b c ->
                                                              match a with
                                                              | Some a -> String.length a + b + c
                                                              | None -> b + c) t

let tf_opt_concat t = tfold (fun x ->
                                    match x with
                                    | Some x -> x
                                    | None -> "") (fun a b c ->
                                                              match a with
                                                              | Some a -> a ^ b ^ c
                                                              | None -> b ^ c) t

type 'a btree = Empty
              | Node of 'a btree * 'a * 'a btree

let t6 = Node (Node (Empty, 3, Empty), 4, Node (Empty, 5, Empty))


let rec bt_insert_by func elem t =
  match t with
  | Node (l, v, r) when func elem v > 0 -> Node (l, v, bt_insert_by func elem r)
  | Node (l, v, r) when func elem v < 0 -> Node (bt_insert_by func elem l, v, r)
  | Node (l, v, r) when func elem v = 0 -> Node (bt_insert_by func elem l, v, r)
  | Empty -> Node (Empty, elem, Empty)
  | Node (_, _, _) -> raise (Failure ("There is something wrong with the node."))

let rec bt_elem_by func elem t = (*tfold (fun x -> func elem x) (fun a b c -> a || )*)
  match t with
  | Node (l, v, r) -> func v elem || bt_elem_by func elem l || bt_elem_by func elem r
  | Empty -> false

let rec bt_to_list t =
  match t with
  | Empty -> []
  | Node (l, v, r) -> bt_to_list l @ [v] @ bt_to_list r

let rec btfold (x:'b) (func:'b -> 'a -> 'b -> 'b) (t:'a btree) =
  match t with
  |Node (l, v, r) -> func (btfold x func l) v (btfold x func r)
  |Empty -> x

let btf_elem_by func elem t = btfold false (fun l v r -> l || func v elem || r) t

let btf_to_list t = btfold [] (fun l v r -> l @ [v] @ r) t

(*Writing btf_insert_by would be very difficult because the insert funciton is predicated on building
a whole new tree with the target element inserted into it. Doing this with fold would involved a very
complex accumulator that not only builds this new tree, but also is able to deal with the fact that
we are only trying to put the target element into a specific spot. This specificity is where the
trouble lies.*)
