ez-csv
======

Reading and writing CSV files made painless and easy. Drops into any kind or Racket code base easily.

* Easy to incorporate CSV logic into your pre-existing code
* Converts to plain lists or pre-defined structures (`struct`/`define-struct`)
* Customizable delimiters
* MIT License, share with your friends / family / co-workers / pets.
* Can be lazy or non-lazy Racket.


```racket
#lang racket

; Load the ez-csv library
(require ez-csv)

; Create our CSV struct
(struct NinjaWeapon (name material color))

; Create a file loading helper
(define file->NinjaWeapons (file->struct-gen NinjaWeapon))

; Load in your CSV text file
(define weapons (file->NinjaWeapons "weapon_closet.csv"))

; Treat it like you would any regular list type
(for-each displayln weapons)

; #<NinjaWeapon "Katana" "Steel" "grey/silver")
; #<NinjaWeapon "Nunchuku" "Wood" "black")
; #<NinjaWeapon "Throwing Star" "Aluminum" "black/red")
; ...
```
