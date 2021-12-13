#lang racket/base

#|
The ez-csv library

ez-csv depends solely on one macro doing it's job - defrec
defrec is a macro I designed to expand upon some of the flaws
I felt existed within struct. I designed it as a near drop-in
replacement for the default `struct` macro in Racket.

defrec will create a CSV object packer for you, and a bunch of
bindings at macro expansion time. It is similar to struct in
that sense, but it goes a little bit above and beyond
and creates additional bindings like thing->csv or file->things
on your behalf. This makes it even easier to write CSV handling
code, so you don't have to define a reader/writer every time
for each record type.

The key difference against a struct design is the fact that
in a regular CSV code base, keeping the headers alongside the
data is tricky, because when using struct natively, headers
aren't typically kept near the data, and it's kept somewhere
else. The design with defrec is to create an immutable-hash
that contains the headers as well as the data, so you don't
actually lose anything, and it's easy to contain information.
Delimiter, header, and field values are all contained
in each Record's hash fields.

Downside: I don't have a means of exporting all fields
magically like `struct-out` would, so you must use
`all-defined-out` when defining a Record type module.
|#

; Import bindings for the macro procedure
(require (for-syntax racket/syntax racket/base racket/string)
         (only-in racket/string string-join string-split)
         (only-in racket/port port->lines))

(provide defrec)

(define-syntax (defrec stx)
  (syntax-case stx ()
    [(_ id (col-headers ...) (fields ...) delim)
     ; Check for free identifiers first
     (for-each (lambda (x)
                 (unless (identifier? x)
                   (raise-syntax-error #f "not an identifier" stx x)))
               (cons #'id (syntax->list #'(fields ...))))
     (with-syntax ([pred-id         (format-id #'id "~a?" #'id)]
                   [delim           (syntax->datum #'delim)]
                   [headers-lst     (cons list (syntax->datum #'(col-headers ...)))]
                   [thing-delimiter (format-id #'id "~a-delimiter" #'id)]
                   [thing-headers   (format-id #'id "~a-headers"   #'id)]
                   [id-update       (format-id #'id "~a-update"    #'id)]
                   [thing=?         (format-id #'id "~a=?"         #'id)]
                   [thing->string   (format-id #'id "~a->string"   #'id)]
                   [file->things    (format-id #'id "file->~as"    #'id)]
                   [things->csv     (format-id #'id "~as->csv"      #'id)]
                   [list->thing     (format-id #'id "list->~a"     #'id)])
       #`(begin
           ; The main constructor method
           (define (id fields ...)
             (make-immutable-hash
              `((type      . id)
                (delimiter . ,delim)
                (headers   . ,headers-lst)
                ,@(for/list ([head (syntax->list #'(fields ...))]
                             [val (list fields ...)])
                    (cons (syntax->datum head) val)))))
           
           ; Create constant access to the delimiter
           (define (thing-delimiter v) delim)
           
           ; Create a constant access for the record's headers
           (define (thing-headers v) headers-lst)
           
           ; Create the predicate here using whatever means
           (define (pred-id v)
             (and (hash? v)
                  (eq? (hash-ref v 'type) 'id)
                  (equal? (hash-ref v 'headers) headers-lst)))
           
           ; Equality check to determine if things are equal
           (define (thing=? v1 v2)
             (and (= (pred-id v1) (pred-id v2))))
           
           ; Convert a list of data to our struct
           (define (list->thing listof-vals)
             (apply id listof-vals))
           
           ; Update a list of values with their matching keys
           ; if no key is found, throws an error
           (define (id-update v kv-pairs)
             (define (reducer item acc)
               (let ([key (car item)] [val (cdr item)])
                 (unless (hash-has-key? acc key)
                   (error 'id-update "No key in record"))
                 (hash-update acc key (λ (_) val))))
             (foldl reducer v kv-pairs))
           
           ; Convert a thing to a string in order of the id fields
           (define (thing->string v #:delimiter [delimit delim])
             (string-join
              (map (λ (key-id) (hash-ref v (syntax->datum key-id)))
                   (syntax->list #'(fields ...)))
              delimit))
           
           ; Convert a generic file port into a list of things (incomplete)
           (define (file->things fpath #:skip-fn [sfn (λ (x) x)])
             (call-with-input-file (build-path (string->path fpath))
               (λ (input-f)
                 (map
                  (λ (row)
                    (list->thing (string-split row delim #:trim? #f)))
                  (sfn (port->lines input-f))))))
           
           ; Convert a list of things into a CSV formatted file using the delimiter
           (define (things->csv fpath listof-v)
             (call-with-output-file #:exists 'replace
               fpath
               (λ (output)
                 (parameterize ([current-output-port output])
                   (displayln (string-join headers-lst delim))
                   (for-each
                    (λ (v) (displayln (thing->string v)))
                    listof-v)))))
           
           ; Accessor funcs for each field
           ; The for/list generates a pairing of (Field * Identifier)
           ; where Hash(Identifer => Value)
           #,@(for/list ([h (syntax->list #'(fields ...))])
                (with-syntax ([accessor-id (format-id #'id "~a-~a" #'id h)]
                              [hs (syntax->datum h)])
                  #`(define (accessor-id v)
                      (unless (pred-id v)
                        (error 'acc-id "~a is not a ~a struct" v 'id))
                      (hash-ref v (quote hs)))))
           ))]
    [else (raise-syntax-error #f "Not a valid macro pattern" stx)]))


; Testing area begins
(module+ test
  (require (only-in rackunit test-case check-equal?)
           (only-in racket/port port->lines with-input-from-string))

  (defrec Student ["Name" "ID"] [name id] ",")
  (define my-students
    (list
     (Student "Frog"   "FROG")
     (Student "Marle"  "NADI")
     (Student "Crono"  "CRIT")
     (Student "Robo"   "R66Y")
     (Student "Magus"  "JANS")
     (Student "Lucca"  "NERD")
     (Student "Ayla"   "UNGA")))
    
  
  (test-case "Record Write/Read #1"
    (Students->csv "test.csv" my-students)
    (file->Students "test.csv"))
  )


(module+ main
  (displayln "Not a main program!")
  (exit))

; end main.rkt
