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
(defrec NinjaWeapon
  ["Name of Weapon" "Material" "Color"]
  [name material color]
  ",")

; Load in your CSV text file
(define weapons-closet (file->NinjaWeapons "weapon_closet.csv"))

; Treat it like you would any regular list type
(for-each
 (lambda (item)
   (displayln (NinjaWeapon-name item)))
 weapons-closet)

; Katana
; Nunchuku
; Throwing Star
; ...
```

Todo List

1. Add lazy-reading method for stream/generator purposes
2. Add ability to include headers for CSV output
