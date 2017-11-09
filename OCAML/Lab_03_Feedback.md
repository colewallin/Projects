### Feedback for Lab 03

Run on February 02, 16:05:05 PM.

+ Pass: Change into directory "Lab_03".

+ Pass: Check that file "hwk_01.ml" exists.

+ Fail: Check that an OCaml file "hwk_01.ml" has no syntax or type errors.

    OCaml file hwk_01.ml has errors.

    Run "ocaml hwk_01.ml" to see them.



+ Skip: Check that an OCaml file "hwk_01.ml" has warnings.

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `even 4` matches the pattern `true`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `even 5` matches the pattern `false`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `euclid 6 9` matches the pattern `3`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `euclid 5 9` matches the pattern `1`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `frac_add (1,2) (1,3)` matches the pattern `(5,6)`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `frac_add (1,4) (1,4)` matches the pattern `(8,16)`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `frac_simplify (8,16)` matches the pattern `(1,2)`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `frac_simplify (4,9)` matches the pattern `(4,9)`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `frac_simplify (3,9)` matches the pattern `(1,3)`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `fst (square_approx 9.0 0.001)` matches the pattern `3.`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `snd (square_approx 9.0 0.001)` matches the pattern `3.0`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `fst (square_approx 81.0 0.1)` matches the pattern `8.9`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `snd (square_approx 81.0 0.1)` matches the pattern `9.0`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `max_list [1; 2; 5; 3; 2]` matches the pattern `5`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `max_list [-1; -2; -5; -3; -2]` matches the pattern `-1`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `drop 3 [1; 2; 3; 4; 5]` matches the pattern `[4; 5]`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `drop 5 ["A"; "B"; "C"]` matches the pattern `[ ]`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `drop 0 [1]` matches the pattern `[1]`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `rev [1; 2; 3; 4; 5]` matches the pattern `[5; 4; 3; 2; 1]`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `rev []` matches the pattern `[]`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `perimeter [ (1.0, 1.0); (1.0, 3.0); (4.0, 4.0); (7.0, 3.0); (7.0, 1.0) ]` matches the pattern `16.3`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `is_matrix [ [1;2;3]; [4;5;6] ]` matches the pattern `true`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `is_matrix [ [1;2;3]; [4;6] ]` matches the pattern `false`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `is_matrix [ [1] ]` matches the pattern `true`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `matrix_scalar_add [ [1; 2; 3]; [4; 5; 6] ] 5` matches the pattern `[ [6; 7; 8]; [9; 10; 11] ]`.

   

  This test was not run because of an earlier failing test.

#### Bonus Round!!

+ Skip: Check that the result of evaluating `matrix_transpose [ [1; 2; 3]; [4; 5; 6] ]` matches the pattern `[ [1; 4]; [2; 5]; [3; 6] ]`.

   

  This test was not run because of an earlier failing test.

+ Skip: Check that the result of evaluating `matrix_multiply  [ [1; 2; 3]; [4; 5; 6] ] [ [1; 4]; [2; 5]; [3; 6] ]` matches the pattern ` [ [14; 32]; [32; 77]]`.

   

  This test was not run because of an earlier failing test.

