(* On suppose que le texte est écrit uniquement avec des caractères ASCII. *)


(* I - LECTURE *)
            
(* Lit un fichier et retourne le txt + le tableau des fréquences *)            
let read_txt_and_frequencies filename = 
  let f = open_in filename in
  let freq = Array.make 256 0 in
  let txt = ref "" in
  let ret_l = Char.code '\n' in
  try
    while true do
      let l = input_line f in
      txt := !txt ^ l ^ "\n" ; 
      for i=0 to (String.length l)-1 do 
        let c = Char.code (l.[i]) in
        freq.(c) <- freq.(c) + 1 ;
      done ;
      freq.(ret_l) <- freq.(ret_l) + 1 ;
    done ;
    (!txt, freq) ;
  with
  | End_of_file -> close_in f ; (!txt, freq) 
  | exn -> close_in f ; raise exn ;;
  
  
(* II - ECRITURE *)

(* Ecrit un txt dans un fichier*)
let write txt filename = 
  let f = open_out filename in
  output_string f txt ;
  close_out f ;;
  

(* III - CONVERSION BINAIRE--STRING *)
          
(* Comme OCAML ne sait manipuler que des octets et pas des bits directement, il faut ruser : 

On écrit une fonction qui convertit une string ne contenant que des caractères '0' et '1', les lit 
8 par 8 et produit une chaine de caractère dont l'écriture en mémoire sera exactement celle que l'on veut.

Réciproquement, étant donné une string quelconque s, on produit la string OCaml 
ne contenant que des '0' et des '1' qui correspond à la représentation mémoire de s. 

*)

(* Passage d'un octet au code ASCII du caractère qu'il représente *)
let bin_to_dec oct =
  let res = ref 0
  and pow = ref 1 in
  for i=7 downto 0 do 
    res := !res + (((int_of_char oct.[i])+1) mod 49)*(!pow) ; (* 49 = int_of_char '1' *)
    pow := !pow * 2 ;
  done ;
  !res ;;

(* Passage d'un code ASCII à l'octet représentant le caractère associé *)
let dec_to_bin n =
  let res = ref ""
  and k = ref n in
  while !k <> 0 do
    let bit = !k mod 2 in
    k := !k / 2 ;
    res := (string_of_int bit) ^ !res ;
  done ;
  res := (String.make (8-(String.length !res)) '0') ^ !res ;
  !res ;;

(* Coversion d'une chaîne de caractère à sa représentation en '0' et '1' *)
let convert_to_bin s = 
  let len = String.length s
  and res = ref "" in
  for i=0 to len-1 do
    let n = Char.code s.[i] in 
    let bin = dec_to_bin n in 
    res := !res ^ bin ;
  done ;
  !res ;;

(* Conversion d'une suite d'octets à la chaîne de caractère qu'il représente *)
let convert_from_bin b = 
  let i = ref 0
  and len = String.length b
  and res = ref "" in
  while !i <= len-8 do
    let oct = String.sub b !i 8 in 
    let n = bin_to_dec oct in 
    let c = Char.chr n in
    res := !res ^ (String.make 1 c) ;
    i := !i + 8 ;
  done ;
  !res ;;

  
(* IV - Compression *)

type codage = Leaf of char | Node of codage * codage ;;
           
(*  Entrée : le tableau des fréquences des char dans le texte 
  Sortie : le codage optimal sous forme d'arbre *)
let code_huffman frequencies =
  let pq = Priority_queue.create () in
  for i=0 to 255 do
    let c = Char.chr i in
    Priority_queue.add pq frequencies.(i) (Leaf c) ;
  done ;
  
  for i=0 to 254 do
    let (p1, a1) = Priority_queue.extract_min pq in
    let (p2, a2) = Priority_queue.extract_min pq in
    Priority_queue.add pq (p1+p2) (Node (a1, a2)) ;
  done ; 
  let (_, c) = Priority_queue.extract_min pq in
  c ;;
  
(* Convertit un codage sous forme d'arbre en un tableau de longueur 256 tel que 
t.(i) donne le mot de {0,1}* qui code le caractère numéro i *)    
let tree_to_array c =    
  let tab = Array.make 256 "" in
  let rec aux t code = match t with
    | Leaf a -> tab.(Char.code a) <- code
    | Node (c1, c2) ->
        aux c1 (code ^ "0") ;
        aux c2 (code ^ "1") 
  in
  aux c "" ;
  tab ;;
  
(* Compresse le txt selon le codage c, donné sous forme de tableau *)    
let compress txt c =
  let res = ref "" in
  for i=0 to (String.length txt)-1 do
    res := !res ^ (c.(Char.code txt.[i])) ;
  done ;
  !res ;;

  
(* V - Décompression *)
  
(* Decompresse le txt selon le codage c, donné sous forme d'arbre *)
let decompress txt c = 
  let res = ref "" in
  let len = String.length txt in
  let rec aux code i = match code with
    | Leaf a ->
        res := !res ^ (String.make 1 a) ;
        if i < len then
          aux c i
    | Node (c1, c2) when txt.[i] = '0' -> aux c1 (i+1)
    | Node (c1, c2) -> aux c2 (i+1)
  in
  aux c 0 ;
  !res ;;
  
  
(* VI - MAIN *)
                 
let main () = 
  let argv = Sys.argv in
  let argc = Array.length argv in
  if argc <> 2 then begin
    Printf.fprintf stderr "Arguments manquants" ;
    assert false ;
  end ;

  (* On récupère le txt dans le fichier donné par Sys.argv *)
  let (txt, freq) = read_txt_and_frequencies argv.(1) in

  (* On le compresse optimalement *)
  let c1 = code_huffman freq in
  let c2 = tree_to_array c1 in
  let txt_compress = ref (compress txt c2) in

  let len = String.length !txt_compress in

  let n = (String.length !txt_compress) mod 8 in
  if n <> 0 then
    txt_compress := !txt_compress ^ (String.make (8-n) '0') ;
  let txt_compress_unbin = convert_from_bin !txt_compress in

  (* On écrit la compression dans un fichier *)
  write txt_compress_unbin "compression" ;

  (* On lit la compression et on la décompresse *)
  let f = open_in "compression" in
  let compression = ref "" in
  try 
    while true do
      let l = input_line f in
      compression := !compression ^ l ^ "\n" ;
    done ;
  with
  | End_of_file -> close_in f ;
  let txt_compress_bin = ref (convert_to_bin !compression) in
  txt_compress_bin := String.sub !txt_compress_bin 0 len ;
  let txt_decomp = decompress !txt_compress_bin c1 in

  (* On compare au fichier d'origine pour détecter les erreurs *)
  if txt_decomp <> txt then
    Printf.printf "Il y a une erreur.\n" 
  else
    Printf.printf "La compression et la décompression ont fonctionné.\n" ; 
;;
  
  
main () ;;