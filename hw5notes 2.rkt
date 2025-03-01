;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname |hw5notes 2|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(define resolve
  (lambda (varName env)
    (cond
      ((null? env) #f)
      ((eq? varName (caar env)) (cadar env))
      (else (resolve varName (cdr env))))))


(define do-mathy-stuff-toaster
  (lambda (op num1 num2)
    (cond
      ((eq? op '+) (+ num1 num2))
      ((eq? op '-) (- num1 num2))
      ((eq? op '/) (/ num1 num2))
      ((eq? op '//) (quotient num1 num2)) ;integer division 
      ((eq? op '%) (modulo num1 num2)) ;remainder of integer division
      ((eq? op '*) (* num1 num2))
      (else #f))))
      


(define no-parser
  (lambda (no-code)
    (cond
      ((number? no-code) (list 'num-lit-exp no-code))
      ((symbol? no-code) (list 'var-exp no-code))
      ((eq? (car no-code) 'do-mathy-stuff)
       (list 'math-exp (cadr no-code)  (no-parser (caddr no-code)) (no-parser (cadddr no-code)))) ;boils down to the parsed first number and the second number
      ((eq? (car no-code) 'function)
       (list 'func-exp
             (append (list 'params) (cadr no-code))
             (list 'body
                   (no-parser (caddr no-code)))))
      (else (list 'call-exp
                  (no-parser (cadr no-code))
                  (no-parser (caddr no-code)))))))
  
(define env '((age 21) (a 7) (b 5) (c 23)))
;(define sample-no-code '(call (function (x) x) a))
(define sample-no-code '(call (function (x) x) (do-mathy-stuff + a b))) ;what we want to accomplish,

;(math-exp + )var-exp a) (var-exp b))


(define run-parsed-code
  (lambda (parsed-no-code env)
    (cond
      ((eq? (car parsed-no-code) 'num-lit-exp)
       (cadr parsed-no-code))
      ((eq? (car parsed-no-code) 'var-exp)
       (resolve (cadr parsed-no-code) env))
      ((eq? (car parsed-no-code) 'math-exp)
       (do-mathy-stuff-toaster
        (cadr parsed-no-code)
        (run-parsed-code (caddr parsed-no-code) env)
        (run-parsed-code (cadddr parsed-no-code) env)))
      ((eq? (car parsed-no-code) 'func-exp)
       (run-parsed-code (cadr (caddr parsed-no-code)) env))
      (else
       (run-parsed-code
        (cadr parsed-no-code)
        (cons (list (cadr (cadr (cadr parsed-no-code)))
                    (run-parsed-code (caddr parsed-no-code) env))
              env))))))

      

;hw modify our language to support functions that take zero or more parameters
;submit a link to code (Github)
(run-parsed-code (no-parser sample-no-code) env)