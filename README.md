# 🔍 Projet Algorithmes de Recherche & Compression

Ce projet contient trois implémentations d’algorithmes utilisés pour la **recherche de motifs** dans du texte et la **compression** de texte.

---

## 📦 Sommaire

1. 🔎 Rabin-Karp (C)
2. 📘 Boyer-Moore (OCaml)
3. 🌲 Huffman & Arbres de Codage (OCaml)

---

## 🔎 Rabin-Karp

📁 Fichier : `rabinkarp.c`  
📝 Langage : C

### Description

L’algorithme de Rabin-Karp utilise une fonction de **hachage** pour rechercher un motif dans un texte. Il est optimisé pour détecter rapidement les correspondances en comparant des **valeurs de hachage** plutôt que les chaînes elles-mêmes.

### Fonctionnalités

- Recherche d’un motif dans une chaîne (fonction `rabinkarp`)
- Recherche dans un fichier texte (fonction `rabinkarp2`)
- Affichage de la position du motif s’il est trouvé

### Compilation & Exécution

```bash
gcc rabinkarp.c -o rabinkarp
./rabinkarp motif fichier.txt
```

---

## 📘 Boyer-Moore

📁 Fichier : `boyermoore.ml`  
📝 Langage : OCaml

### Description

L’algorithme de Boyer-Moore est efficace pour la recherche de motifs. Il saute intelligemment des portions de texte en utilisant deux heuristiques : **bad character** et **good suffix**.

### Fonctionnalités

- Recherche rapide d’un motif dans une chaîne
- Optimisation basée sur la connaissance du motif

### Compilation

```bash
ocamlc -o boyermoore boyermoore.ml
./boyermoore
```

---

## 🌲 Huffman & Arbres de Codage

📁 Fichiers : `huffman.ml`, `priority_queue.ml`, `abr.ml`  
📝 Langage : OCaml

### Description

L’algorithme de Huffman est un algorithme de compression sans perte qui construit un **arbre binaire de codage** à partir des fréquences des caractères. Ce module s’appuie sur une **file de priorité** et un **arbre binaire de recherche (ABR)** pour construire et manipuler l’arbre de Huffman.

### Fonctionnalités

- Construction d’un arbre de Huffman
- Encodage basé sur les fréquences
- Structures auxiliaires :
  - `abr.ml` : implémentation d’un arbre binaire de recherche
  - `priority_queue.ml` : file de priorité pour construire l’arbre de Huffman

### Compilation

```bash
ocamlc -o huffman priority_queue.ml abr.ml huffman.ml
./huffman
```

