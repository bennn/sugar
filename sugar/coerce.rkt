#lang racket/base
(require (for-syntax racket/base racket/syntax) sugar/define net/url)

(require-via-wormhole "../typed/sugar/coerce.rkt")


(provide+safe [->int (any/c . -> . integer?)]
              [->string (any/c . -> . string?)]
              [->symbol (any/c . -> . symbol?)]
              [->path (any/c . -> . path?)]
              [->complete-path (any/c . -> . complete-path?)]
              [->url (any/c . -> . url?)]
              [->list (any/c . -> . list?)]
              [->vector (any/c . -> . vector?)]
              [->boolean (any/c . -> . boolean?)])

(define-syntax-rule (make-blame-handler try-proc expected-sym)
  (λ(b)
    (λ(x)
      (with-handlers ([exn:fail? (λ(e)
                                   (raise-blame-error
                                    b x
                                    '(expected: "~a" given: "~e")
                                    expected-sym x))])
        (try-proc x)))))

(provide make-coercion-contract)
(define-syntax (make-coercion-contract stx)
  (syntax-case stx ()
    [(_ stem coerce-proc)
     (with-syntax ([coerce/stem? (format-id stx "coerce/~a?" #'stem)]
                   [can-be-stem? (format-id stx "can-be-~a?" #'stem)])
       #'(make-contract
          #:name 'coerce/stem?
          #:projection (make-blame-handler coerce-proc 'can-be-stem?)))]
    [(_ stem)
     (with-syntax ([->stem (format-id stx "->~a" #'stem)])
       #'(make-coercion-contract stem ->stem))]))

(define-syntax (define+provide-coercion-contract stx)
  (syntax-case stx ()
    [(_ stem)
     (with-syntax ([coerce/stem? (format-id stx "coerce/~a?" #'stem)])
       #'(define+provide coerce/stem? (make-coercion-contract stem)))]))

(define+provide-coercion-contract int)
(define+provide-coercion-contract string)
(define+provide-coercion-contract symbol)
(define+provide-coercion-contract path)
(define+provide-coercion-contract boolean)
(define+provide-coercion-contract list)
