(*****************************************************************************)
(********************************  UNIT TESTS  *******************************)
(*****************************************************************************)
#use "hwk_01.ml"

(* even or odd *)
let () =
    assert (even 4);
    assert (not (even 5));
    assert (not (odd 4));
    assert (odd 5)

(* Another GCD, Euclid's algorithm *)
let () =
    assert (euclid 6 9 == 3);
    assert (euclid 5 9 == 1)

(* Adding and multiplying fractions *)
let () =
    assert (frac_add (1, 2) (1, 3) = (5, 6));
    assert (frac_add (1, 4) (1, 4) = (8, 16))

(* Simplifying fractions *)
let () =
    (* Man, if this were Lisp, I could macro out the annoyance of making the
     * exact same assertion/test block every time... *)
    assert (frac_simplify (8, 16) = (1, 2));
    assert (frac_simplify (4, 9) = (4, 9));
    assert (frac_simplify (3, 9) = (1, 3))

(* Square root approximation *)
let () =
    (* Oh, also, why does OCaml have = as being distinct from == ? When are
     * pointer comparisons useful in a functional language? Java tried to pull
     * this too... *)
    assert (square_approx  9.0 0.001 = (3., 3.0009765625));
    assert (square_approx 81.0 0.1   = (8.96875, 9.046875))

(* Maximum in a list *)
let () =
    assert (max_list [1;2;5;3;2] = 5);
    assert (max_list [-1;-2;-5;-3;-2] = -1)

(* Dropping list elements *)
let () =
    assert (drop 3 [1;2;3;4;5] = [4;5]);
    assert (drop 5 ["A","B","C"] = []);
    assert (drop 0 [1] = [1])

(* List reverse *)
let () =
    assert (rev [1;2;3;4;5] = [5;4;3;2;1]);
    assert (rev [] = [])

(* Closed polygon perimeter *)
let () =
    assert (perimeter
        [ (1.0, 1.0)
        ; (1.0, 3.0)
        ; (4.0, 4.0)
        ; (7.0, 3.0)
        ; (7.0, 1.0)
        ] -. 16.32 < 0.01)

(* Representing matrices as lists of lists *)
let () =
    assert (is_matrix
        [ [1; 2; 3]
        ; [4; 5; 6]
        ]);
    assert (not (is_matrix
        [ [1; 2; 3]
        ; [4; 6]
        ]));
    assert (is_matrix [[1]])

(* A simple matrix operation: matrix scalar addition *)
let () =
    assert (matrix_scalar_add
        [ [1; 2; 3]
        ; [4; 5; 6]
        ] 5 =
        [ [6; 7; 8]
        ; [9; 10; 11]
        ])


(* All unit tests passed *)
let () = print_string "Oll Korrect\n"
