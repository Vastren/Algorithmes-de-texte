type ('a,'b) priority_queue = ('a * 'b) Abr.abr ref;;

let create () = ref (Abr.empty_tree ()) ;;

let is_empty pq = Abr.is_empty !pq ;;
let mem pq elt = true ;;

let add pq prio elt = 
    pq := Abr.add !pq (prio, elt) ;;

let min_elt pq = Abr.min_elt !pq ;;

let extract_min pq = 
    let (m, p) = Abr.remove_min !pq in
    pq := p ;
    m ;;

let priority pq elt = failwith "Not Implemented" ;;

let update_priority pq elt prio = failwith "Not Implemented" ;;