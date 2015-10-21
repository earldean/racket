;; The recursive-nfa benchmark.  (Figure 45, page 143.)

;; Changed by Matthew 2006/08/21 to move string->list out of the loop
;; Changed by Vincent 2010/04/05 to convert to typed Scheme

(define-type Result (U 'state2 'state4 #f))

(: recursive-nfa ((Listof Char) -> (U 'state2 'state4 'fail)))
(define (recursive-nfa input)

  (: state0 ((Listof Char) -> Result))
  (define (state0 input)
    (or (state1 input) (state3 input) #f))

  (: state1 ((Listof Char) -> Result))
  (define (state1 input)
    (and (not (null? input))
         (or (and (char=? (car input) #\a)
                  (state1 (cdr input)))
             (and (char=? (car input) #\c)
                  (state1 input))
             (state2 input))))

  (: state2 ((Listof Char) -> Result))
  (define (state2 input)
    (and (not (null? input))
         (char=? (car input) #\b)
         (not (null? (cdr input)))
         (char=? (cadr input) #\c)
         (not (null? (cddr input)))
         (char=? (caddr input) #\d)
         'state2))

  (: state3 ((Listof Char) -> Result))
  (define (state3 input)
    (and (not (null? input))
         (or (and (char=? (car input) #\a)
                  (state3 (cdr input)))
             (state4 input))))

  (: state4 ((Listof Char) -> Result))
  (define (state4 input)
    (and (not (null? input))
         (char=? (car input) #\b)
         (not (null? (cdr input)))
         (char=? (cadr input) #\c)
         'state4))

  (or (state0 input)
      'fail))

(time (let ((input (string->list (string-append (make-string 133 #\a) "bc"))))
        (let: loop : 'done ((n : Integer 2000000))
              (if (zero? n)
                  'done
                  (begin
                    (recursive-nfa input)
                    (loop (- n 1)))))))
