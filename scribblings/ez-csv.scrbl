#lang scribble/manual
@require[@for-label[ez-csv
                    racket/base]]

@title{ez-csv}
@author{Steven Leibrock}

@defmodule[ez-csv]

ez-csv is a Racket package dedicated to reading and writing CSV files. It works by reading lines of data from a CSV file, and if given the proper CSV settings, will create a list of data from your CSV file that you can directly use in your Racket programs.

