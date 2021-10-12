#lang racket/base

(require (only-in racket/contract define/contract -> ->* any/c and/c or/c)
         (only-in racket/string string-split)
         (only-in racket/file file->lines))


(provide file->struct-gen
         data->csv
         )

; Create a function that splits strings based on an initial separator
(define (csv-split-gen sep)
  (-> string? (-> string? list?))
  (λ (str)
    (string-split str sep #:trim? #f)))


; Create a friendly way of packing data into a given structure init
(define/contract (struct-wrap struct-init)
  (-> procedure? (-> list? struct?))
  (λ (data)
    (apply struct-init data)))


; Create a friendly way of loading a file into a list of structs
; Creates a function that can read from a file into a list of data
(define/contract (file->struct-gen struct-fun #:delimiter [sep ","])
  (->* (procedure?) (#:delimiter string?) procedure?)
  (let ([split-and-pack (compose (struct-wrap struct-fun)
                                 (csv-split-gen sep))])
    (compose (λ (lines) (map split-and-pack lines))
             cdr file->lines string->path)))


; Convert a data list into a CSV file
(define/contract (data->csv fname data
                            #:delimiter [sep ","]
                            #:converter [fn (λ (id) id)])
  (->* ((or/c path? string?) list?)
       (#:delimiter string? #:converter procedure?) boolean?)
  (error 'data->csv "Not implemented yet 🙂 -steve"))


; Testing area begins
(module+ test
  (require rackunit
           (only-in racket/port
                    port->lines
                    with-input-from-string))

  (test-case "String splitting"
    (define splitter (csv-split-gen ","))
    (define other-splitter (csv-split-gen "\t"))
    (define t1 (splitter "hello,world"))
    (define t2 (other-splitter "hello\tworld"))
    (check-equal? t1 '("hello" "world"))
    (check-equal? t2 '("hello" "world")))


  (test-case "CSV parsing test 1"
    (with-input-from-string "1,2,3\n4,5,6"
      (λ ()
        (read-line (current-input-port)))))

  )

; end main.rkt
