type 'a abr ;;

val empty_tree : unit -> 'a abr ;;
val is_empty : 'a abr -> bool ;;

val min_elt : 'a abr -> 'a ;;
val mem : 'a abr -> 'a -> bool ;;

val add : 'a abr -> 'a -> 'a abr ;;
val remove_min : 'a abr -> 'a * 'a abr ;;
val remove_max : 'a abr -> 'a * 'a abr ;;
val remove : 'a abr -> 'a -> 'a abr ;;
