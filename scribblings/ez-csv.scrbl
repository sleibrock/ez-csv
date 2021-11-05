#lang scribble/manual
@require[@for-label[ez-csv
                    racket/base]]

@title{ez-csv}
@author{Steven Leibrock}

@defmodule[ez-csv]

ez-csv is a Racket package dedicated to reading and writing CSV files. It works by reading lines of data from a CSV file, and if given the proper CSV settings, will create a list of data from your CSV file that you can directly use in your Racket programs.


@section{Installation}

Installation can be done via @code{raco}, which will then bring the ez-csv package into your Racket library. From there you use the standard require expression to import some of the bindings.

@racketblock[
(require ez-csv) ; to import all bindings
(require (only-in ez-csv file->struct-gen)) ; to import file->struct-gen
]


@section{Usage}

The idea behind ez-csv is the idea that a row in a CSV file should be treated as a struct. The struct is a core macro behind Racket such that it adds accessor bindings to a list of items, we can think of it as a "named" list. A struct will generate bindings like a constructor and a predicate check, as well as all the named accessors, and provide other goodies like mutators or guards.

When you import a CSV line, the only way to parse it in a functional-style language like Racket or others, is to simply split it by a string delimiter. So at the heart of all this code, is string-split. But before that we need to define some extra data before we get to the splitting part.

First is file->struct-gen. It exists as a wrapper to create a function which will parse your CSV files later on. It has the name format following other functions like file->lines, but ideally you should bind the value of this function to a new function like file->MyStructs, that way you have an easy and convenient function to turn whole files into lists of your struct object.

Next is understanding how it all works; I said the code mainly uses a string-split call to break apart the CSV rows into sliced bits. file->struct-gen takes an optional argument for delimiter to change the default delimiter. Commas are often times used in systems to describe text or items, but tabs might be more convenient to use in that case. So you can use the #:delimiter optional argument to change the delimiter split to anything you want.

After that, the code will pack the values into your struct's constructor function using apply. It will apply every value in the chopped list and pass it onto the constructor. This by no means is a way of parsing data, and if you need to parse strings into numbers, you should consider adding a guard or post-struct functions for handling that. If you have 30+ columns, a guard is probably not the best idea, since your guard function will need to have 31 arguments...

After that, you have a way of reading CSV files with very little overhead. You only need to define your struct and create a file->struct-gen wrapper. 
