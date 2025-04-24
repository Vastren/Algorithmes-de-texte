type 'a abr = Nil | Node of 'a * 'a abr * 'a abr ;;


let empty_tree () = Nil ;;

let is_empty t = (t = Nil) ;;

let rec min_elt t = match t with
    | Nil -> failwith "vide"
    | Node (n, Nil, _) -> n
    | Node (_, g, _) -> min_elt g ;;
    
let rec mem t e = match t with
    | Nil -> false
    | Node (n, _, _) when n = e -> true
    | Node (n, g, d) when n >= e -> mem g e
    | Node (n, g, d) -> mem d e ;;
    
let rec add t e = match t with
    | Nil -> Node (e, Nil, Nil)
    | Node (n, g, d) when n >= e -> Node (n, (add g e), d)
    | Node (n, g, d) -> Node (n, g, (add d e)) ;;

let rec remove_min t = match t with
    | Nil -> failwith "vide"
    | Node (n, Nil, d) -> (n, d)
    | Node (n, g, d) -> 
        let (m, gg) = remove_min g in
        (m, Node (n, gg, d)) ;;
        
let rec remove_max t = match t with
    | Nil -> failwith "vide"
    | Node (n, g, Nil) -> (n, g)
    | Node (n, g, d) ->
        let (m, dd) = remove_max d in
        (m, Node (n, g, dd)) ;;

let rec remove t e = match t with
    | Nil -> failwith "vide"
    | Node (n, Nil, d) when n = e -> d
    | Node (n, g, Nil) when n = e -> g
    | Node (n, g, d) when n = e -> 
        let (m, gg) = remove_max g in
        Node (m, gg, d) 
    | Node (n, g, d) when n >= e -> remove g e
    | Node (n, g, d) -> remove d e ;;