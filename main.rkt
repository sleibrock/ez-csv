#lang racket/base

(require (only-in racket/contract define/contract -> ->* any/c and/c or/c parameter/c)
         (only-in racket/string string-split string-join)
         (only-in racket/file file->lines)
         (only-in racket/function identity)
         (only-in racket/struct struct->list))


(provide file->struct-gen
         data->csv
         )



; Delimiter parameter to control the default converter behavior
(define/contract default-delimiter (parameter/c string?)
  (make-parameter ","))


; Way of mapping symbols to delimiters
; in case we want to be more expressive about our delimiter choices(?)
(define (sym->delim sym)
  (case sym
    ('comma   ",")
    ('tab     "\t")
    (else     ","))) ; add more as needed 


; Create a function that splits strings based on an initial separator
(define (csv-split-gen sep)
  (-> string? (-> string? list?))
  (λ (str)
    (string-split str sep #:trim? #f)))


; Create a friendly way of packing data into a given structure init
(define/contract (struct-wrap struct-init)
  (-> struct-constructor-procedure? (-> list? struct?))
  (λ (data)
    (let ([v (apply struct-init data)])
      (if (struct? v)
          v
          (error 'struct-wrap
                 "Invalid struct type given; is your struct #:transparent?")))))


; Create a friendly way of loading a file into a list of structs
; Creates a function that can read from a file into a list of data
(define/contract (file->struct-gen struct-fun #:delimiter [sep ","] #:skip-fn [skip identity])
  (->* (procedure?) (#:delimiter (or/c symbol? string?) #:skip-fn procedure?) procedure?)
  (let ([split-and-pack (compose (struct-wrap struct-fun)
                                 (csv-split-gen sep))])
    (compose (λ (lines) (map split-and-pack lines))
             skip file->lines string->path)))


; This is the default converter for CSV records
(define/contract (record->string rec)
  (-> (or/c list? struct?) string?)
  (string-join
   (cond
     ([struct? rec] (struct->list rec))
     ([list?   rec] rec)
     (else (error 'record->string "Invalid record type")))
   (default-delimiter)))


; Convert a data list into a CSV file
; Must supply a converter function to convert a record type
; to a delimited string
(define/contract (data->csv fname data converter)
  (-> (or/c path? string?) list? procedure? boolean?)
  ;(error 'data->csv "Not implemented yet 🙂 -steve")
  (call-with-output-file fname #:exists 'replace
    (λ (out)
      (parameterize ([current-output-port out])
        (for-each (compose displayln converter) data)
        (values #t)))))


; Testing area begins
(module+ test
  (require (only-in rackunit test-case check-equal?)
           (only-in racket/port port->lines with-input-from-string))

  (struct tester (x y z) #:transparent)
  (define splitter (csv-split-gen (default-delimiter)))
  (define struct-pack (struct-wrap tester))
  (define packer (compose struct-pack splitter))
  (define file->testers (file->struct-gen tester #:skip-fn identity))

  ; Test whether string splitting works or not
  (test-case "String splitting"
    (define splitter (csv-split-gen ","))
    (define other-splitter (csv-split-gen "\t"))
    (define t1 (splitter "hello,world"))
    (define t2 (other-splitter "hello\tworld"))
    (check-equal? t1 '("hello" "world"))
    (check-equal? t2 '("hello" "world")))

  ; Test if our CSV parsing works or not
  ; Pretend we have a file using with-input-from-string
  ; and port->lines
  (test-case "CSV parsing test 1"
    (begin
      (define data
        (with-input-from-string "x,y,z\n1,2,3\n4,5,6"
          (λ ()
            (map (λ (line) (struct-pack (splitter line)))
                 (cdr (port->lines (current-input-port)))))))
      (check-equal? data (list (tester "1" "2" "3") (tester "4" "5" "6")))
      (displayln data)))

  ; Begin a baby writing test, then read it back and compare
  (test-case "CSV writing test 1"
    (begin
      (define data (list (tester "1" "2" "3") (tester "4" "5" "6")))
      (data->csv "test.csv" data record->string)
      (for-each displayln data)
      (check-equal? #t (file-exists? "test.csv"))
      (define readdata (file->testers "test.csv"))
      (delete-file "test.csv")
      (check-equal? data readdata)))

  )

; end main.rkt
