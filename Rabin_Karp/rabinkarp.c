#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <assert.h>


/// Fonctions de base

int expo (int e, int n) {
    if (n == 0) {
        return 1 ;
    } else {
        return (e * expo(e, n-1)) ;
    }
}

int hash(char* m) {
    int n = 0 ;
    int pow_255 = 1 ;
    for (int i=strlen(m)-1 ; -1 < i ; i--) {
        int x = (int) m[i] ;
        n = (((n + x * pow_255) % 6644843) + 6644843) % 6644843 ;
        pow_255 = (pow_255 * 255) % 6644843 ;
        printf("(%d, %d) ", n, x) ;
    }
    return n ;
}

/// Recherche du motif m dans le texte T

int rabinkarp(char* m, char* T) {
    int len_m = strlen(m) ;
    int len_T = strlen(T) ;
    
    /// Cas de base
    if (len_T < len_m) {
        return -1 ;
    }
    
    /// Calcul haché et 255^(len_m-1)
    int hm = 0 ;
    int hT = 0 ;
    int p = 1 ;
    for (int i=len_m-1 ; -1 < i ; i--) {
        int x1 = (int) m[i] ;
        int x2 = (int) T[i] ;
        hm = (((hm + (x1 * p)) % 6644843) + 6644843) % 6644843 ;
        hT = (((hT + (x2 * p)) % 6644843) + 6644843) % 6644843 ;
        if (i != 0) {
            p = (p * 255) % 6644843 ;
        }
    }

    /// Vérification rang 0
    if (hm == hT) {
        bool b = true ;
        for (int j=0 ; j<len_m ; j++) {
            if (m[j] != T[j]) {
                b = false ;
            }
        }
        if (b) {
            return 0 ;
        }
    }

    /// Vérification
    for (int i=1 ; i<len_T-len_m ; i++) {
        int x = (int) T[i-1] ;
        int y = (int) T[i+len_m-1] ;
        hT = (((((hT - x*p) % 6644843) * 255 + y) % 6644843) + 6644843) % 6644843 ;
        if (hm == hT) {
            bool b = true ;
            for (int j=i ; j<i+len_m ; j++) {
                if (m[j-i] != T[j]) {
                    b = false ;
                }
            }
            if (b) {
                return i ;
            }
        }
    }
    
    /// Fin
    return -1 ;
}

/// Version avec lecture dans un fichier

int rabinkarp2(char* m, char* filename) {
    int len_m = strlen(m) ;
    FILE* f = fopen(filename, "r") ;
    int pos = 0 ;

    /// Test ouverture fichier
    if (f == NULL) {
        fprintf(stderr, "Le fichier n'a pas pu être ouvert.\n") ;
        exit(1) ;
    }
    
    /// Calcul haché et 255^(len_m-1)
    char* T = malloc(sizeof(char)*len_m) ;
    int head_T = 0 ;
    char c = fgetc(f) ;
    for (int i=0 ; i < len_m ; i++) {
        if (c != EOF) {
            T[i] = c ;
        } else {
            fclose(f) ;
            return -1 ;
        }
        c = fgetc(f) ;
    }
    int hm = 0 ;
    int hT = 0 ;
    int p = 1 ;
    for (int i=len_m-1 ; -1 < i ; i--) {
        int x1 = (int) m[i] ;
        int x2 = (int) T[i] ;
        hm = (((hm + (x1 * p)) % 6644843) + 6644843) % 6644843 ;
        hT = (((hT + (x2 * p)) % 6644843) + 6644843) % 6644843 ;
        if (i != 0) {
            p = (p * 255) % 6644843 ;
        }
    }

    /// Vérification rang 0
    if (hm == hT) {
        bool b = true ;
        for (int j=0 ; j<len_m ; j++) {
            if (m[j] != T[j]) {
                b = false ;
            }
        }
        if (b) {
            fclose(f) ;
            return pos ;
        }
    }

    /// Vérification
    while (c != EOF) {
        int x = (int) T[head_T] ;
        int y = (int) c ;
        hT = (((((hT - x*p) % 6644843) * 255 + y) % 6644843) + 6644843) % 6644843 ;
        T[head_T] = c ;
        head_T = (head_T+1) % len_m ;
        pos++ ;
        c = fgetc(f) ;
        if (hm == hT) {
            bool b = true ;
            for (int j=0 ; j<len_m ; j++) {
                if (m[j] != T[(head_T+j)%len_m]) {
                    b = false ;
                }
            }
            if (b) {
                fclose(f) ;
                return pos ;
            }
        }
    }

    /// Fin
    fclose(f) ;
    return -1 ;
}



int main(int argc, char** argv) {
    if (argc != 3) {
        fprintf(stderr, "Arguments manquants.\n") ;
        assert(false) ;
    }
    int n = rabinkarp2(argv[1], argv[2]) ;
    if (n == -1) {
        printf("Le motif n'est pas présent dans le texte.\n") ;
    } else {
        printf("Le motif se trouve à l'indice %d dans le texte.\n", n) ;
    }
}