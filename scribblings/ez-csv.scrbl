#lang scribble/manual
@require[@for-label[ez-csv
                    racket/base]]

@title{ez-csv}
@author{Steven Leibrock}

@defmodule[ez-csv]

ez-csv is a Racket package dedicated to reading and writing CSV files. It works by reading lines of data from a CSV file, and if given the proper CSV values, will create a list of data from your CSV file that you can directly use in your Racket programs.

@code{ez-csv} works for both comma-delimited files and tab-delimited files, provided you make sure you indicate that when writing code.


@section{Installation}

Installation can be done via @code{raco}, which will then bring the ez-csv package into your Racket library. From there you use the standard require expression to import some of the bindings.

@racketblock[
(require ez-csv)
]


@section{Usage}

The usage of @code{ez-csv} is simple now with the new macro system in place. We use a call to @code{defrec} to generate bindings for our CSV records.

@racketblock[
; initialize and import the macro
(require ez-csv)

; create a new record
(defrec Student ["Name" "StudentID"] [name id] ",")

; define some students
(define my-students
  (list
    (Student "Frog" "12345")
	(Student "Robo" "R-66Y")))

; write to a file
(Students->csv "mykids.csv" my-students)

; or, read a file
(define new-students (file->Students "new-year-students.csv"))

; print them out - each student is a hash
(for-each displayln new-students)
]
