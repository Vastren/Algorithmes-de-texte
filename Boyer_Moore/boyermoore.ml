open Hashtbl

(* Table des décalages = table de hachage dont les clés sont des caractères et les valeurs des entiers *)
type offset = (char, int) t ;; 

(* Pour la version améliorée, les clés sont des string *)
type offset2 = (string, int) t ;; 



(* I - Lecture et écriture de l'offset *)

(*  Entrée : s string et c char
    Sortie : une liste [s1; s2; ...; sk] de string telles que 
    s = s1 ^ c ^ s2 ^ c ^ s3 ... ^ c ^ sk 
    et le caractere c n'apparait dans aucune chaine s1, ..., sk
*)
let split s c = 
  let len = String.length s in
  let i = ref (len-1)
  and j = ref (len-1)
  and l = ref [] in
  while -1 < !i  do
    if s.[!i] = c then begin
      l := (String.sub s (!i+1) (!j - !i))::(!l) ;
      j := !i-1 ;
    end ;
    decr i ;
  done ;
  l := (String.sub s (!i+1) (!j - !i))::(!l) ;
  !l ;;

(* Lecture de l'offset dans un fichier *)
let read_offset filename = 
  let f = open_in filename in
  let offset = create 20 in
  try
    while true do
      let s = input_line f in
      match split s ':' with 
      | [c; n] -> 
          assert (String.length c = 1) ;
          add offset c.[0] (int_of_string n)
      | _ -> failwith "Erreur de lecture"
    done ; 
    offset
  with
  | End_of_file -> close_in f; offset
  | exn -> close_in f; raise exn ;;

(* Ecriture de l'offset dans un fichier *)
let write_offset offset filename = 
  let f = open_out filename in
  let lign c n =
    output_char f c ;
    output_char f ':' ;
    output_char f (char_of_int n) ;
    output_char f '\n' ;
  in
  iter (fun c n -> lign c n) offset ;
  close_out f ;;
    
    
(* II - CALCUL DE L'OFFSET *)

(* Calucl de l'offset pour un motif *)
let compute_offset m = 
  let offset = create 20 in
  let len = String.length m in
  for i=0 to len-2 do
    match find_opt offset m.[i] with
    | None -> add offset m.[i] (len-i-1)
    | Some n -> replace offset m.[i] (len-i-1)
  done ;
  offset ;; 
    
    
(* III - LECTURE DU TEXTE *)

(* Lecture du texte d'un fichier *)
let read_text filename =
  let f = open_in filename in
  let res = ref "" in
  try
    while true do
      let s = input_line f in
      res := !res ^ s ;
    done ;
    !res ;
  with
  | End_of_file -> close_in f ; !res ;; 

    
(* IV - ALGORITHME DE BOYER MOORE *) 

exception Find of int ;;

(* m : motif, t : texte, offset : table des décalage *)            
let boyer_moore m t offset = 
  let i = ref 0
  and len_m = String.length m
  and len_t = String.length t in
  try
    while !i < len_t - len_m + 1 do
      let j = ref (len_m-1) in
      
      (* Vérification en partant de la fin *)
      while -1 < !j && m.[!j] = t.[!i + !j] do
        decr j ;
      done ;
      
      (* Si motif trouvé stop sinon décalage *)
      if !j = -1 then 
        raise (Find !i)
      else
        match find_opt offset t.[!i + !j] with
        | None -> i := !i + !j + 1
        | Some n -> i := !i + n
    done ;
    -1 ;
  with
  | Find n -> n ;;
  
    



(* Fonction Main *)

let main () = 
  let argv = Sys.argv in
  let argc = Array.length argv in 

  if argc != 4 then
    Printf.fprintf stderr "Arguments manquants.\n" ;

  (* Lecture de l'offset si existe *)
  (* Création + écriture de l'offset sinon *)
  (* Appel à Boyer Moore *)
  (* Impression Réponse *)
  let file_exist () =
    try
      let f = open_in argv.(3) in
      ignore (input_line f) ;
      close_in f ;
      true ;
    with
    | Sys_error _ | End_of_file -> false
  in

  if file_exist () then begin
    let m = argv.(1)
    and t = read_text argv.(2)
    and offset = read_offset argv.(3) in
    let n = boyer_moore m t offset in
    if n = -1 then
      Printf.printf "Le motif n'a pas été trouvé.\n"
    else
      Printf.printf "Le motif se trouve en position %d.\n" n ;
  end else begin
    let m = argv.(1)
    and t = read_text argv.(2) in
    let offset = compute_offset m in
    write_offset offset argv.(3) ;
    let n = boyer_moore m t offset in
    if n = -1 then
      Printf.printf "Le motif n'a pas été trouvé.\n"
    else
      Printf.printf "Le motif se trouve en position %d.\n" n ;
  end ;
;;

main () ;;