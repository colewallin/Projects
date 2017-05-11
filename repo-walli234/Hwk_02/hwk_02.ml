(* This file contains a few helper functions and type declarations
   that are to be used in Homework 2. *)

(* Place part 1 functions 'take', 'drop', 'length', 'rev',
   'is_elem_by', 'is_elem', 'dedup', and 'split_by' here. *)

(*Length takes an argument of type 'a list and retuns an int*)

let length l =
  List.fold_left (fun n _ -> n+1) 0 l

let rev lst =
  List.fold_left (fun accum head -> head::accum) [] lst

let is_elem_by func target lst =
  List.filter (fun x -> func x target) lst != []

let is_elem target vals =
  is_elem_by (=) target vals

(*this funciton compares the target value to a value in the list and returns
true if they are not the same.*)
let helper_dedup target listvalue =
  target <> listvalue

(*This funciton will return the dedupped list in the order that the list was originally in*)
let dedup lst =
  List.fold_right (fun x accum -> ([x] @ (List.filter (helper_dedup x) accum))) lst []

let helper_split (func:'a -> 'b -> bool) (listlist, builder) (droppers: 'a list) v =
  if (is_elem_by func v droppers)
  then  (builder :: listlist, [])
  else listlist, v :: builder

(*   ('a -> 'b -> bool) -> 'b list -> 'a list -> 'b list list
split_by :
takes a function, a list of values and a list of delimiters.
It folds over the list of values with the funciton and stores the non-drop
values into the accumulator which is a tuple. If the value is in the splitter
list, the list that had been created on one side of the tuple will be appended
to the list of lists on the other side of the tuple. Finally, it returns the
cumulative list of lists from the tuple.  *)

let split_by func mainlist droppers =
  let (x,y) =
  List.fold_right (fun x accum -> (helper_split func accum droppers x)) mainlist ([], [])
  in y::x

(*Head takes a list and returns the first ELEMENT of the list*)
let head l =
  match l with
  | [] -> raise (Failure "there is no head of this list.")
  | x::xs -> x

(*Tail takes a list and returns the LIST without the first element in the list*)
let tail l =
  match l with
  | [] -> raise (Failure "there is no tail of this list.")
  | x::xs -> xs

let rec take n l = match l with
  | [] -> []
  | x::xs -> if n > 0 then x::take (n-1) xs else []

let rec drop n l = match l with
  | [] -> []
  | x::xs -> if n > 0 then drop (n-1) xs else l

(* Some functions for reading files. *)
let read_file (filename:string) : char list option =
  let rec read_chars channel sofar =
    try
      let ch = input_char channel
      in read_chars channel (ch :: sofar)
    with
    | _ -> sofar
  in
  try
    let channel = open_in filename
    in
    let chars_in_reverse = read_chars channel []
    in Some (rev chars_in_reverse)
  with
    _ -> None

(*Type declarations*)
type word = char list
type line = word list
type result = OK
	    | FileNotFound of string
	    | IncorrectNumLines of int
	    | IncorrectLines of (int * int) list
	    | IncorrectLastStanza


let ridemptys value =
  value <> []

(*Splits the text into lines by splitting at the '\n' character. Then it
splits those individual lines into lines of words by splitting on any
: . ! ? , ; : - : character and a few others that might seperate words.*)
let convert_to_non_blank_lines_of_words (charlist:word) =
  let lines =
  List.map Char.lowercase charlist
  in
  let x = List.filter ridemptys (split_by (=) lines ['\n'])
  in
  List.map (fun y -> (List.filter ridemptys (split_by (=) y [' ';'*';'!';'.';'?';';';':';'-';',']))) (x)

(*Returns the number of lines in a list.  *)
let numlines paradelle =
  length paradelle

(*Returns true if and only if the words in the first argument are the same as
the words in the second argument. *)
let samelines line1 line2 =
  (List.fold_right (fun x accum -> (is_elem x line2) && accum) line1 true) && (List.fold_right (fun x accum -> (is_elem x line1) && accum) line2 true)

(*Takes two line lists and compares that they use all of each others words. returns true or false*)
let checkwords words1 words2 =
  let words1' = dedup (List.concat words1)
  in
  let words2' = dedup (List.concat words2)
  in
  samelines words1' words2'

(*This funciton serves the purpose of dropping ONLY the first instance of an
element from a list and nothing more.*)
let helperhelper ele (x,y) =
  if x then
            match y with
            |[]->(false, y)
            |x::xs -> if x = ele then (false, xs) else (true, x::xs)
  else (false, y)

(*ultimately returns y which is a LIST that is the acucmulator in the higher funciton*)
let samehelper lst ele =
  let templist = lst
  in
  let (t,y) =
  (List.fold_right (fun x accum -> helperhelper x accum) templist (true, lst))
  in
  y

(*have the accumulator be a tuple that is a boolean and a list *)
let samelines2 line1 line2 =
  let check1 = List.concat line1
  in
  let check2 = List.concat line2
  in
  let final = List.fold_right (fun x accum -> samehelper accum x) check1 check2
  in
  final = []

(*Checks the first four lines and RETURNS A LIST of the pairs of rows that are wrong *)
let teststanza astanza =
  let oneandtwo = samelines (take 1 astanza) (take 1 (drop 1 astanza))
  in
  let threeandfour = samelines (take 1 (drop 2 astanza)) (take 1 (drop 3 astanza))
  in
  let fiveandsix = samelines2 (take 2 (drop 1 astanza)) (take 2 (drop 4 astanza))
  in
  let lst = []
  in
  if not (oneandtwo) && (not (threeandfour)) && (not (fiveandsix))
  then (1,2)::(3,4)::(5,6)::lst
  else if not (threeandfour) && (not (oneandtwo))
  then (1,2)::(3,4)::lst
  else if not (oneandtwo) && (not (fiveandsix))
  then (1,2)::(5,6)::lst
  else if (not (threeandfour)) && (not (fiveandsix))
  then (3,4)::(5,6)::lst
  else if not (oneandtwo)
  then (1,2)::lst
  else if (not (threeandfour))
  then (3,4)::lst
  else if not (fiveandsix)
  then (5,6)::lst
  else lst

(*Helper funciton to scale up the values in the tuple to accomodate for what
stanza of the poem they're in.  *)
let scaletup n (x, y) = (n+x, n+y)

(*Checks the first three stanzas of the poem and returns a list containing the incorrect rows.  *)
let checkfirst3 paradelle =
  let firstp = (take 6 paradelle)
  in
  let secondp = (take 6 (drop 6 paradelle))
  in
  let thirdp = (take 6 (drop 12 paradelle))
  in
  let incorrectrows = []
  in
  teststanza firstp :: List.map (scaletup 6) (teststanza secondp) :: List.map (scaletup 12) (teststanza thirdp) :: incorrectrows

(*Checks that the last stanza contains all the correct words from the first 3 stanzas.  *)
let laststanza paradelle =
  checkwords (take 18 paradelle) (drop 18 paradelle)


let test (filename:string) =
  match read_file(filename) with
  | Some x ->
    let paradelleinquestion = convert_to_non_blank_lines_of_words (x)
    in paradelleinquestion


(*Penultimate function that takes a .txt file containing a paradelle and returns
a value of type RESULT depending on if the text in the file actually is a paradelle.  *)
let paradelle (filename:string) =
  match read_file(filename) with
  | None -> FileNotFound filename
  | Some x ->
    let paradelleinquestion = convert_to_non_blank_lines_of_words (x)
    in
    if (numlines paradelleinquestion = 24) && (checkfirst3 paradelleinquestion = [[];[];[]]) && laststanza paradelleinquestion
    then OK
    else if numlines paradelleinquestion <> 24
    then IncorrectNumLines (numlines paradelleinquestion)
    else if checkfirst3 paradelleinquestion <> [[];[];[]]
    then IncorrectLines (List.concat(checkfirst3 paradelleinquestion))
    else IncorrectLastStanza
