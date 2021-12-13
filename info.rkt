#lang info
(define collection "ez-csv")
(define deps '("base"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/ez-csv.scrbl" ())))
(define pkg-desc "Reading and writing CSV files from Racket... Except easier.")
(define version "0.2")
(define pkg-authors '(sleibrock))
