;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q2) (read-case-sensitive #t) (teachpacks ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "universe.rkt" "teachpack" "2htdp") (lib "image.rkt" "teachpack" "2htdp")) #f)))
(require "extras.rkt") 
(require rackunit)
(check-location "06" "q2.rkt")
 (provide
   simulation
  world-after-mouse-event
  racket-after-mouse-event
  racket-selected?
  initial-world
   world-ready-to-serve?
   world-after-tick
   world-after-key-event
   world-balls
   world-racket
   ball-x 
   ball-y 
   racket-x 
   racket-y
   ball-vx 
   ball-vy 
   racket-vx 
   racket-vy)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;CONSTANTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define RHW 23.5)
(define COURT_WIDTH 425)
(define COURT_LENGTH 649 )
(define DELAY 3)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Different mouse events
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define button-down-event "button-down")
(define drag-event "drag")
(define button-up-event "button-up")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;DATA DEFINITIONS:
;; A BlueCircle is represented by a struct, stores the position of mouse
;; (make blueCircle x,y)
;;INTERP
;;x    PosInt: position of x-coordinate of the centre the mouse (0<x<425)
;;y    PosInt: position of y coordinate of the centre of the mouse (0<y<649)
(define-struct blueCircle (x y ))

;;Constructor Template
;;(make blueCircle PosInt PosInt)
(define (blueCircle-fn c)
  (...(blueCircle-x c)
      (blueCircle-y c)
      
   ))
;; A Racket is represented by a struct with the following fields
;;(make x y vx vy  selected? rx ry)
;;INTERP:
;;x     PosInt: position of x-coordinate of the centre of the racket
;;              (23.5 < x< 401.5) 
;;y     PosInt: position of y-coordinate of the centre of the racket (0<y<649)
;;vx    Integer: x-component of velocity of the racket
;;vy    Integer: y-component of velocity of the racket
;;rx    PosInt: stores mouse's position (0<rx<425)
;;ry    PosInt: stores mouse's position  (0<ry<649)
;;selected? Boolean  true if racket is selected

;;IMPLEMENTATION:
(define-struct racket (x y vx vy selected?  rx ry))

;;CONSTRUCTOR TEMPLATE
;(make racket PosInt PosInt Integer Integer Boolean PosInt PosInt)
;;OBSERVER TEMPLATE
;;racket-fn:racket->??
(define (racket-fn r)
(...(racket-x r)
    (racket-y r)
    (racket-vx r)
    (racket-vy r)
    (racket-selected? r)
    (racket-rx r)
    racket-ry r))

;;DATA DFINITIONS:
;; A Ball is represented by a struct with the following fields
;;(make ball x y vx vy)
;;INTERP:
;;x  PosInt: position of x-coordinate of the ball (0<x<425)
;;y  PosInt: position of y-coordinate of the ball (0<y<649)
;;vx    Integer: x-component of velocity of the ball
;;vy    Integer: y-component of velocity of the ball
;;IMPLEMENTATION
(define-struct ball (x y vx vy))
;;CONSTRUCTOR TEMPLATE:
;;(make Ball PosInt PosInt Integer Integer)
;;;;OBSERVER TEMPLATE
;;ball-fn:ball->??
(define (ball-fn b)
  (...(ball-x b)
      (ball-y b)
      (ball-vx b)
      (ball-vy b)))


;;DATA DEFINITION 
;; A BallList is represented as a list of Balls

;; CONSTRUCTOR TEMPLATES:
;; empty
;; (cons (fb) (rb) )
;; WHERE
;;fb is the first ball in the list
;;rb represents rest of the ball of the list
;;where: there is no particular order
;; OBSERVER TEMPLATE:

;; ball-list-fn : balls -> ??
#|(define (balls-fn bl)
  (cond
    [(empty? bl) ...]
    [else (...
    (first bl )
    (balls-fn (rest bl)))])) |#
  



;;DATA DEFINITIONS:
;;A World is represented by a  struct with the following fields
;;(make world racket balls pause? ticks timer blueCircle)
;;INTERP:
;;racket    Racket    :   contains information
;;                       about the position and the velocity of the racket
;;balls    BallList   : contains the list of the ball
;;                       velocity of the ball
;;pause?    Boolean:  True if the current state is paused,false if unpasued
;;ticks      Real   :  Number of ticks in 3 secs, depends on simulation speed
;;timer      PosReal   :  Simulation speed in seconds per tick
;;blueCircle BlueCircle: stores co-ordinate position of the blue circle
;;IMPLEMENTATION:
(define-struct world (balls racket pause? ticks timer blueCircle))
;;CONSTRUCTOR TEMPLATE:
;;(make world Racket BallList Boolean Real PosReal BlueCircle)
;;OBSERVER TEMPLATE:
;;world-fn:world->??
(define (world-fn w)
  (...
   (world-racket w)
   (world-balls w)
   (world-pause w)
   (world-ticks w)
   (world-timer w)
   (world-blueCircle)
   
   ))




;;CONTRACT:
;;simulation:posReal-> World
;;PURPOSE STATEMENT:
;;GIVEN: the speed of the simulation, in seconds per tick
;;(so larger numbers run slower)
;;EFFECT: runs the simulation, starting with the initial world
;;RETURNS: the final state of the world
;;EXAMPLES:
;;(simulation 1) runs in super slow motion
;;(simulation 1/24) runs at a more realistic speed
;; DESIGN STRATERGY: Combing simpler function
(define (simulation x)
    (big-bang (initial-world x)
    (on-tick world-after-tick x)
    (on-draw world-to-scene)
    (on-key world-after-key-event)
    (on-mouse world-after-mouse-event))) 

;;CONTRACT:
;;initial-world: posReal->World
;;PURPOSE STATEMENT:
;;GIVEN: the speed of the simulation, in seconds per tick
;;(so larger numbers run slower)
;; RETURNS: the ready-to-serve state of the world
;; EXAMPLE: (initial-world 1)-> (make-ball 330 384 0 0)
;;(make-racket 330 384 0 0 false 0 0 )  true 1 1)
;;DESIGN STRATERGY: Using Template

(define (initial-world x)
 (make-world-ready-state x))
;;TESTS:
(begin-for-test(check-equal? (initial-world 1)
                        (make-world (list (make-ball 330 384 0 0))
                        (make-racket 330 384 0 0 false  0 0)true 1 1  
                        (make-blueCircle (+ 10 COURT_WIDTH) (+ 10 COURT_LENGTH))) 
                         "Result is the construction of initial state"))

;;CONTRACT:
;;make-world-ready-state:posReal->World
;;PURPOSE STATEMENT:
;;GIVEN: Simulation speed in ticks per second
;;RETURN: A world with the racket and ball in their ready to serve state
;;EXAMPLE
;;(make-world-ready-state 2)-> (make-world (make-ball 330 384 0 0)
;;(make-racket 330 384 0 0 false 0 0 )  true 2 2)
;;DESIGN STRATERGY: Using Template
(define (make-world-ready-state x)
                        (make-world  (cons (make-ball 330 384 0 0) empty)
                        (make-racket 330 384 0 0 false 0 0 ) true x x
                        (make-blueCircle (+ 10 COURT_WIDTH) (+ 10 COURT_LENGTH))))
;;TESTS:
(begin-for-test (check-equal? (make-world-ready-state 2)
                              (make-world (list (make-ball 330 384 0 0)) 
                              (make-racket 330 384 0 0   false 0 0) true 2 2
                              (make-blueCircle (+ 10 COURT_WIDTH)
                              ( + 10 COURT_LENGTH )))"World not in ready state"))

;;CONTRACT:
;;world-ready-to-serve?World->boolean
;;PURPOSE STATEMENT:
;;GIVEN: a world
;;RETURN: true if the world is in ready to serve state
;;EXAMPLE:
;;(world-ready-to-serve-state? (make-world (make-ball 330 384 0 0)
;;(make-racket 330 384 0 0 )  true 2 2)->true
;;DESIGN STRATERGY: Checking conditions using simpler functions   
(define (world-ready-to-serve? w)
                                 (if
                                 (and (world-ball-initial-state?  (world-balls w))
                                 (world-racket-initial-state? (world-racket w)))
                                  true false))

;;TESTS:
(begin-for-test (check-equal?(world-ready-to-serve?
                           (make-world  ( list(make-ball 330 384 0 0 ))
                           (make-racket 330 384 0 0 false  0 0) true 2 2
                           (make-blueCircle (+ 10 COURT_WIDTH) (+ 10 COURT_LENGTH)
                            ))) true
                            "true if the world is in ready to serve state")) 

(begin-for-test (check-equal?(world-ready-to-serve?
                                (make-world (list (make-ball 380 384 8 0 ) )
                                (make-racket 329 384 5 7 false  0 0) true 2 2
                                (make-blueCircle (+ 10 COURT_WIDTH)
                                (+ 10 COURT_LENGTH) ))) false
                                 "false if the world is in ready to
                                                      serve state"))
(begin-for-test (check-equal?(world-ready-to-serve?
                                (make-world (list (make-ball 330 384 0 0 ) )
                                (make-racket 339 374 5 7 false  0 0) true 2 2
                                (make-blueCircle (+ 10 COURT_WIDTH)
                                (+ 10 COURT_LENGTH) ))) false
                                 "false if the world is in ready to
                                                      serve state"))

;;CONTRACT:
;;world-ball-initial-state?: Ball->Boolean
;;PURPOSE STATEMENT
;;GIVEN: a list of ball with one ball (a field from world )
;;RETURN: true if the ball in the list is in ready to serve state
;;EXAMPLE
;;(world-ball-initial-state? (list(make-ball 330 384 0 0))->true
;;DESIGN STRATERGY: Checking values of different fields from Ball
;;Transcribe Formula
(define (world-ball-initial-state?  b)
                              (if (and( = (ball-x  (first b))330)
                               (= (ball-y(first b)) 384) 
                               (=(ball-vx (first b)) 0)
                               (=(ball-vy (first b))0)) true false ))


;;CONTRACT:
;;world-racket-initial-state?:Racket->Boolean
;;PURPOSE STATEMENT
;;GIVEN: a racket (a field from world )
;;RETURN: true if the racket is in ready to serve state
;;EXAMPLE:
;;(world-racket? (make-racket 330 384 0 0 false 0 0)->true
;;DESIGN STRATERGY: Checking values of different fields from Racket
;;Transcribe Formula
(define (world-racket-initial-state? r) (if
                              (and( = (racket-x r) 330) (= (racket-y r) 384)
                              (=(racket-vx r) 0) (=(racket-vy r) 0)) true false))

;;CONTRACT
;;world-after-tick:World->World
;;PURPOSE STATEMENT
;;GIVEN:  any world that's possible for the simulation
;;RETURN: the world that should follow the given world
;;        after a tick
;;DESIGN STRATERGY: Observer Template and Combining Simpler Functions
;;EXAMPLE:
;;(world-after-tick(make-world(list)(make-ball 330 390 6 5)
;;(make-struct 330 390 6 5)
;; false false )->(make-world
;;(make-ball 330 390 6 0)(make-struct 330 390 6 5 false false) false 59 0.005)
(define (world-after-tick w)

(cond

        [ (or (empty? (world-balls w))  (not(=(world-timer w) (world-ticks w)))) 
          (world-in-pause-state w) ] 

         [else (world-in-rally-state w)]))

;;TESTS:
(begin-for-test (check-equal?(world-after-tick
                             (make-world (list(make-ball 330 390 6 5))
                             (make-racket 320 150 25 21 false 0 0)
                             false 0.05 0.05
                             (make-blueCircle 20 20)))
                             (make-world (list(make-ball 336 395 6 5))
                              (make-racket 345 171 25 21 false 0 0)
                              false 0.05 0.05 (make-blueCircle 20 20))
                             " Function Failed"))

;;TEST:
  (begin-for-test (check-equal?(world-after-tick
                     (make-world (list(make-ball 330 384 0 0))
                     (make-racket 330 384 0 0 false  0 0) false .003 0.003
                     (make-blueCircle (+ COURT_WIDTH 10) (+ COURT_LENGTH 10))))
                     (make-world (list(make-ball 330 384 0 0))
                     (make-racket  330 384 0 0 false  0 0) false (/ 3 1000)
                     (/ 3 1000)
                     (make-blueCircle (+ COURT_WIDTH 10) (+ COURT_LENGTH 10)))
                     "Function Failure"))

(begin-for-test (check-equal? (world-after-tick
                        (make-world (list(make-ball 330 384 3 9))
                        (make-racket 330 384 0 0 true  0 0) false  300  .003
                        (make-blueCircle(+ COURT_WIDTH 10) (+ COURT_LENGTH 10))))
                        (make-world(list(make-ball 330 384 3 9))
                        (make-racket 330 384 0 0 true  0 0)
                         false 299 0.003 (make-blueCircle 435 659))
                        "Function Failure"))  


;;CONTRACT
;;(world-in-pause-state:World-> World
;;GIVEN: World in a particular state
;;RETURN: World in initial state
;;STRATERGY: Cases on Ticks (a field within World),Constructor Template
;; (world-in-pause-state   (make-world (list(make-ball 330 390 6 5))
;;                                     (make-racket 320 150 25 21 false 0 0)
;;                                     true 50 0.05 (make-blueCircle 20 20)))
;;  =>                     (make-world
;;                                      (list (make-ball 330 390 6 5))
;;                                      (make-racket 320 150 25 21 false 0 0)
;;                                       true 49 0.05 (make-blueCircle 20 20 ))
;;
(define (world-in-pause-state w) 
   (cond
                    [  (>(world-ticks w)0)   
                    (make-world (world-balls w ) (world-racket w) (world-pause? w)
                    (-(world-ticks w)1) (world-timer w ) (world-blueCircle w ))]
                    [(<=(world-ticks w)0) (initial-world (world-timer w))] ))

;;TESTS:
(begin-for-test(check-equal?(world-in-pause-state
                                        (make-world (list(make-ball 330 390 6 5))
                                        (make-racket 320 150 25 21 false 0 0)
                                        true 50 0.05 (make-blueCircle 20 20)))
                                        (make-world
                                        (list (make-ball 330 390 6 5))
                                        (make-racket 320 150 25 21 false 0 0)
                                        true 49 0.05 (make-blueCircle 20 20 ))
                                        "Function Failure"))

(begin-for-test(check-equal?(world-in-pause-state
                                        (make-world (list(make-ball 330 390 6 5))
                                        (make-racket 320 150 25 21 false 0 0)
                                        true 0 0.05 (make-blueCircle 20 20)))
                                        (make-world
                                        (list (make-ball 330 384 0 0))
                                        (make-racket 330 384 0 0 false 0 0)
                                        true 0.05 0.05 (make-blueCircle 435 659))
                                        "Error in World-in-pause-state"))

;;CONTRACT
;;world-in-rally-state: World -> World
;;GIVEN: a World
;;RETURN: if the world is in pause state then same as input
;;World else creates new World
;;STRATERGY: Cases on list of ball and racket's state,Observer Template
#|EXAMPLES: (world-in-rally-state
                                        (make-world
                                        (list (make-ball 330 390 6 5))
                                        (make-racket 320 150 25 21 false 0 0)
                                        true 49 0.05 (make-blueCircle 20 20 )))

                               =>       (make-world (list (make-ball 330 390 6 5))
                                        (make-racket 320 150 25 21 false 0 0) true
                                        49 0.05 (make-blueCircle 20 20))|#
;;
(define (world-in-rally-state w)   (if (world-pause? w) w (ball-status w) ))
;;TESTS:
(begin-for-test(check-equal? (world-in-rally-state
                                        (make-world
                                        (list (make-ball 330 390 6 5))
                                        (make-racket 320 150 25 21 false 0 0)
                                        true 49 0.05 (make-blueCircle 20 20 )))
                                        (make-world (list (make-ball 330 390 6 5))
                                        (make-racket 320 150 25 21 false 0 0) true
                                        49 0.05 (make-blueCircle 20 20))
                                        "Error in Rally-state Function"))
;;CONTRACT:
;;ball-status: World->World
;;GIVEN: a World
;;RETURN: a World depending on the list of balls and
;;racket's state after the tick
;;STRATERGY: Case on BallList, Racket,Observer Template
;;Examples:  (ball-status (make-world
#|                                     (list (make-ball 330 390 6 5))
                                       (make-racket 320 150 25 21 false 0 0)
                                       true 49 0.05 (make-blueCircle 20 20 )))
                                       (make-world (list (make-ball 336 395 6 5))
                                       (make-racket 345 171 25 21 false 0 0)false
                                        49 0.05 (make-blueCircle 20 20))|#

(define (ball-status w)         
(cond

       [ (empty? (list-of-balls (world-balls w) (world-racket w)) ) (end-state w)]
       [ (is-racket-final-collision? (world-racket w)) (end-state2 w)]
       [else (present-state  (list-of-balls (world-balls w)(world-racket w))
       (get-racket-after-tick (first (world-balls w)) (world-racket w)) w)]
       ))

;;TESTS:
(begin-for-test(check-equal? (ball-status (make-world
                                        (list (make-ball 330 390 6 5))
                                        (make-racket 320 150 25 21 false 0 0)
                                        true 49 0.05 (make-blueCircle 20 20 )))
                                        (make-world (list (make-ball 336 395 6 5))
                                        (make-racket 345 171 25 21 false 0 0)false
                                         49 0.05 (make-blueCircle 20 20))
                                        "Test Case Failed, Check your Code on
                                         the given line number"))

(begin-for-test(check-equal? (ball-status (make-world
                                         null
                                        (make-racket 320 150 25 21 false 0 0)
                                        true 60 0.05 (make-blueCircle 20 20 )))
                                        (make-world '()
                                        (make-racket 320 150 25 21 false 0 0) true
                                         60 0.05 (make-blueCircle 20 20))
                                        "Test Case Failed, Check your Code on the
                                         given line number"))


(begin-for-test(check-equal? (ball-status (make-world
                                         (list (make-ball 330 390 6 5))
                                        (make-racket 320 0 25 (- 0 2) false 0 0)
                                        true 60 0.05 (make-blueCircle 20 20 )))
                                        (make-world (list (make-ball 330 390 6 5))
                                        (make-racket 320 0 25 (- 0 2) false 0 0)
                                        true 60 0.05 (make-blueCircle 20 20))
                                        "Test Case Failed, Check your Code on
                                        the given line number"))
                                      
;;CONTRACT
;;end-state: World->World
;;GIVEN: a World not in rally state
;;RETURN:   a world which is now in pause state for 3 seconds
;;STRATERGY: Using Observer Templates
#|;;Examples:
                       (end-state    (make-world
                                      (list (make-ball 330 390 6 5))
                                      (make-racket 320 0 25 (- 0 2) false 0 0)
                                      false 0.05 0.05 (make-blueCircle 20 20 )))

                        =>            (make-world empty
                                      (make-racket 320 0 25 (- 0 2) false 0 0)
                                      true  60 0.05 (make-blueCircle 20 20 ))|#

(define(end-state w)
                     (make-world  empty (world-racket w) true
                     ( / DELAY (world-timer w)) (world-timer w)
                     (world-blueCircle w)))

;;CONTRACT
;;end-state2: World->World
;;GIVEN: a World not in rally state
;;RETURN:   a world which is now in pause state for 3 seconds
;;STRATERGY: Using Observer Templates
;;Examples:
  #|                     (end-state    (make-world
                                      (list (make-ball 330 390 6 5))
                                      (make-racket 320 0 25 (- 0 2) false 0 0)
                                      false 0.05 0.05 (make-blueCircle 20 20 )))

                        =>            (make-world (list (make-ball 330 390 6 5))
                                      (make-racket 320 0 25 (- 0 2) false 0 0)
                                      true  60 0.05 (make-blueCircle 20 20 ))|#

(define(end-state2 w)
                     (make-world  (world-balls w) (world-racket w) true
                     ( / DELAY (world-timer w)) (world-timer w)
                     (world-blueCircle w)))

;;CONTRACT
;;present-state BallList,Racket,World->World
;;GIVEN: BallList,acket and World in a state
;;RETURN: Creates a World that exists in present state
;;with updated number of balls
;;STRATERGY: Using Constructor Template Templates
;;Examples:
#| (present-state
                 (list (make-ball 330 390 6 5))
                  (make-racket 320 0 25 12 false 0 0)
                   (make-world
                               (list (make-ball 320 600 6 98))
                               (make-racket 320 0 25 12 false 0 0)
                               false 0.05 0.05 (make-blueCircle 20 20 ))))
=>                 (make-world
                               (list (make-ball 330 390 6 5))
                               (make-racket 320 0 25 12 false 0 0)
                               false 0.05 0.05 (make-blueCircle 20 20 ))
|#

 (define (present-state bl r w) 
                                (make-world bl r false (world-ticks w)
                                 (world-timer w) (world-blueCircle w)))
;;CONTRACT:
;;list-of-balls: BallList,Racket->BallList
;;GIVEN: BallList and Racket
;;RETURN: list of balls in the current world (BallList)
;;STRATERGY: Using HOF on BallList
 ;;filter and then map


(define (list-of-balls l r )
 (cond
         [  (empty? l) empty ]     
         [else
          ;;Ball->Ball
          ;;GIVEN: a Ball
          ;;RETURN: a Ball after the tick
          (map (lambda (x) (get-ball-after-tick x r))
          ;; Ball-> Ball
          ;; GIVEN: a Ball
          ;; RETURN: Ball which didnt collided with the bottom ball     
               (filter (lambda (x) (not(is-ball-final-collision? x))) l))]))



;;TEST:
(begin-for-test(check-equal?(list-of-balls (list
                                            (make-ball 20 600 20 150)
                                            (make-ball 10 50 50 50))
                                            (make-racket 40 40 0 0 false 0 0))
                                             (list (make-ball 60 100 50 50))
                                             "List of Balls is not correct"))
                          
;;CONTRACTS:
;;get-ball-after-tick Ball Racket->Ball
;;GIVEN: Ball and Racket at any instant
;;RETURN:Ball after Tick
;;STRATERGY: Combing Simpler Functions,Constructor Template on Ball
;;EXAMPLES:
         #|(get-ball-after-tick
                             (make-ball 325 332   5  8  )
                             (make-racket 330 340 0 0 false 0 0))

                          => (make-ball 330 340 5 -8)|#
(define (get-ball-after-tick b r)
                           (make-ball
                           (ball-x-after-tick b r)
                           (ball-y-after-tick b r)
                           (ball-vx-after-tick b r)
                           (ball-vy-after-tick b r)))

;;TESTS
  (begin-for-test(check-equal?(get-ball-after-tick
                              (make-ball 325 332   5  8  )
                             (make-racket 330 340 0 0 false 0 0))
                             (make-ball 330 340 5 -8)
                             "Incorrect Ball Values"))
                             
    (begin-for-test(check-equal?(get-ball-after-tick
                              (make-ball 400 332   150  8  )
                             (make-racket 330 340 0 0 false 0 0))
                               (make-ball 300 340 -150 8)
                               "Incorrect Ball Values"))
    
      (begin-for-test(check-equal?(get-ball-after-tick
                              (make-ball 0 332 (- 0 5) (- 0 8)  )
                             (make-racket 330 340 0 0 false 0 0))
                                  (make-ball 5 324 5 -8)
                                  "State of Ball Not Correct"))
      
        (begin-for-test(check-equal?(get-ball-after-tick
                              (make-ball 325 0   5  ( - 0 8  ))
                             (make-racket 330 340 0 0 false 0 0))
                                    (make-ball 330 8 5 8)
                                    "State of Ball Not Correct"))
        
          (begin-for-test(check-equal?(get-ball-after-tick
                              (make-ball 325 600   5  80  )
                              (make-racket 330 340 0 0 false 0 0))
                              (make-ball 325 600 5 80)
                              "State of Ball Not Correct"))
          
            (begin-for-test(check-equal?(get-ball-after-tick
                              (make-ball 325 348  5  8  )
                              (make-racket 330 340 0 0 false 0 0))
                              (make-ball 330 356 5 8)
                              "Check the code Again"))

;;CONTRACTS:
;;get-racket-after-tick Ball Racket->Racket
;;GIVEN: Ball and Racket at any instant
;;RETURN:Racket after Tick
;;STRATERGY: Combining Simpler Functions,Constructor Template on Racket
;; Examples:
 #|           (get-racket-after-tick
                             (make-ball 325 332   5  8  )
                             (make-racket 330 340 0 0 false 0 0))

                         =>  (make-racket 330 340 0 0 false 0 0)|#



(define (get-racket-after-tick b r)
                           (make-racket
                           (racket-x-after-tick b r)
                           (racket-y-after-tick b r)
                           (racket-vx-after-tick b r)
                           (racket-vy-after-tick b r)
                           (racket-selected? r)
                           (racket-rx r)
                           (racket-ry r)))

;;TESTS
(begin-for-test(check-equal?(get-racket-after-tick
                              (make-ball 325 332   5  8  )
                             (make-racket 330 340 0 0 false 0 0))
                             (make-racket 330 340 0 0 false 0 0)
                             "PLease Check the code"))

(begin-for-test(check-equal?(get-racket-after-tick
                              (make-ball 325 332   5  8  )
                             (make-racket 330 340 0 0 true 0 0))
                             (make-racket 330 340 0 0 true 0 0)
                             "PLease Check the code"))

(begin-for-test(check-equal?(get-racket-after-tick
                              (make-ball 325 332   5  8  )
                             (make-racket 400 40 100 0 false 0 0))
                             (make-racket 803/2 40 0 0 false 0 0)
                             "PLease Check the code"))

(begin-for-test(check-equal?(get-racket-after-tick
                              (make-ball 325 332   5  8  )
                             (make-racket 60 640 0 100 false 0 0))
                             (make-racket 60 649 0 100 false 0 0)
                             "PLease Check the code"))

(begin-for-test(check-equal?(get-racket-after-tick
                              (make-ball 325 332   5  8  )
                             (make-racket 0 34 (- 0 10)  0 false 0 0))
                             (make-racket 47/2 34 0 0 false 0 0)
                             "PLease Check the code"))

(begin-for-test(check-equal?(get-racket-after-tick
                              (make-ball 325 332   5  8  )
                             (make-racket 330 0 0 (- 0 5) false 0 0))
                             (make-racket 330 0 0 -5 false 0 0)
                             "PLease Check the code"))

(begin-for-test(check-equal?(get-racket-after-tick
                              (make-ball 325 341   5  8  )
                             (make-racket 330 340 0 0 false 0 0))
                             (make-racket 330 340 0 0 false 0 0)
                             "PLease Check the code"))

(begin-for-test(check-equal?(get-racket-after-tick
                              (make-ball 325 341   5  8  )
                             (make-racket 330 340 52 0 true 0 0))
                             (make-racket 330 340 52 0 true 0 0)
                             "PLease Check the code"))

(begin-for-test(check-equal?(get-racket-after-tick
                             (make-ball 325 341   5  8  )
                             (make-racket 420 40 50 0 true 0 0))
                             (make-racket 803/2 40 0 0 true 0 0)
                             "PLease Check the code"))

(begin-for-test(check-equal?(get-racket-after-tick
                              (make-ball 325 341   5  8  )
                             (make-racket 0 150 (- 0 2) 12 true 0 0))
                             (make-racket 47/2 150 0 12 true 0 0)
                             "PLease Check the code"))

(begin-for-test(check-equal?(get-racket-after-tick
                              (make-ball 325 341   5  8  )
                             (make-racket 330 600 52 100 true 0 0))
                             (make-racket 330 649 52 100 true 0 0)
                             "PLease Check the code"))




;;CONTRACT
;;ball-x-after-tick Ball,Racket->Integer
;;GIVEN: Ball Racket
;;RETURN: Position of x component of ball is updated
;;STRATERGY: Cases on x position of Ball,Observer Template on Ball
;; Examples:
#|         (ball-x-after-tick
                             (make-ball 325 332 5 8)
                             (make-racket 330 340 0 0 false 0 0))

=>                            330|#

(define (ball-x-after-tick b r)
  (cond

     [(is-ball-racket-collision? b r)
     (ball-bx b)]

      [(and(is-ball-right-wall-collision? b) (not(is-ball-racket-collision? b r)))
      (- COURT_WIDTH(-(ball-bx b) COURT_WIDTH))]
   
      [(and(is-ball-left-wall-collision? b) (not(is-ball-racket-collision? b r)))
      (- 0 (ball-bx b))]

      [(and(is-ball-front-wall-collision? b) (not(is-ball-racket-collision? b r)))
      (ball-bx b)]

       [(and(is-ball-final-collision? b )
             (not(is-ball-racket-collision? b r)))
        (ball-x b)]

       [else
       (ball-bx b)]
         ))

;;TEST:
(begin-for-test(check-equal?( ball-x-after-tick
                             (make-ball 325 332 5 8)
                             (make-racket 330 340 0 0 false 0 0)) 330
                             "Ball state not correct"))
(begin-for-test(check-equal?( ball-x-after-tick
                             (make-ball 400 332 80 8)
                             (make-racket 400 340 90 0 false 0 0)) 480
                              "Ball state not correct"))
(begin-for-test(check-equal?( ball-x-after-tick
                             (make-ball 5 332 (- 0 50) 8)
                             (make-racket 10 340 (- 0 60) 0 false 0 0)) -45
                              "Ball state not correct"))
(begin-for-test(check-equal?( ball-x-after-tick
                             (make-ball 325 5 5 (- 0 80))
                             (make-racket 330 2 0  (- 0 10) false 0 0)) 330
                              "Ball state not correct"))
(begin-for-test(check-equal?( ball-x-after-tick
                             (make-ball 325 600 5 200)
                             (make-racket 330 580 0 200 false 0 0)) 325
                             "Ball state not correct"))
;;CONTRACT
;;ball-y-after-tick: Ball Racket-> Integer
;;GIVEN: Racket and Ball
;;RETURN: Position of Y coordinate of Ball
;;STRATERGY: Cases on Ball and Racket, Observer Template on Ball and Racket
;; Examples:
#| (ball-y-after-tick
                              (make-ball 325 332 5 8)
                              (make-racket 330 340 0 0 false 0 0))

                              340 |#


(define (ball-y-after-tick b r)
              
  (cond
              
            [(is-ball-racket-collision? b r)
            (ball-by b)]

            [(and(is-ball-right-wall-collision? b)
            (not(is-ball-racket-collision? b r)))
             (ball-by b)]

            [(and(is-ball-left-wall-collision? b )
            (not(is-ball-racket-collision? b r)))
             (ball-by b)]

            [(and(is-ball-front-wall-collision? b )
            (not(is-ball-racket-collision? b r)))
             (- 0 (ball-by b))]

            [(and(is-ball-final-collision? b )
             (not(is-ball-racket-collision? b r)))
             (ball-y b)]

            [else
             (ball-by b)]
            ))

;;TESTS:
(begin-for-test(check-equal?(ball-y-after-tick
                              (make-ball 325 332 5 8)
                              (make-racket 330 340 0 0 false 0 0)) 340
                               "Ball state not correct"))

(begin-for-test(check-equal?(ball-y-after-tick
                              (make-ball 325 5 5 (- 0  25))
                             (make-racket 330 340 0 0 false 0 0)) 20
                               "Ball state not correct"))

(begin-for-test(check-equal?(ball-y-after-tick
                              (make-ball 325 600 5 200)
                             (make-racket 330 340 0 0 false 0 0))600
                              "Ball state not correct"))

(begin-for-test(check-equal?(ball-y-after-tick
                              (make-ball 485 332 150 8)
                             (make-racket 330 340 0 0 false 0 0))340
                                 "Ball state not correct"))

(begin-for-test(check-equal?(ball-y-after-tick
                              (make-ball 20 332 (- 0 50)  8)
                             (make-racket 330 340 0 0 false 0 0))340
                                "Ball state not correct"))
               
;;CONTRACT
;;ball-vx-after-tick: Ball Racket->Integer
;;GIVEN: Ball Racket
;;RETURN: Horizontal componenet of Ball's velocity
;;STRATERGY: Cases on Racket and Ball ,Observer Template on Ball and Racket
;;Examples
#|  (ball-vx-after-tick
                       (make-ball 20 332 (- 0 50)  8)
                       (make-racket 330 340 0 0 false 0 0))

=>                               50   |#

  (define (ball-vx-after-tick b r)

    (cond

            [(is-ball-racket-collision? b r)
             (ball-vx b)]

            [(and(is-ball-right-wall-collision? b )
              (not(is-ball-racket-collision? b r)))
             (- 0 (ball-vx b))]

            [(and(is-ball-left-wall-collision? b )
              (not(is-ball-racket-collision? b r)))
             (- 0 (ball-vx b))]

            [(and(is-ball-front-wall-collision? b )
              (not(is-ball-racket-collision? b r)))
             (ball-vx b)]

            [(and(is-ball-final-collision? b )
            (not(is-ball-racket-collision? b r)))
             ( ball-vx b)]
            
            [else
             (ball-vx b)]
           ))

  ;;TESTS:
  (begin-for-test(check-equal?(ball-vx-after-tick
                              (make-ball 20 332 (- 0 50)  8)
                             (make-racket 330 340 0 0 false 0 0))50
                               "Ball state not correct"))
  
  (begin-for-test(check-equal?(ball-vx-after-tick
                              (make-ball 400 332 80   8)
                             (make-racket 330 340 0 0 false 0 0))-80
                               "Ball state not correct"))
  
  (begin-for-test(check-equal?(ball-vx-after-tick
                              (make-ball 20 30   8 (- 0 50)  )
                             (make-racket 330 340 0 0 false 0 0))8
                                "Ball state not correct"))
  
  (begin-for-test(check-equal?(ball-vx-after-tick
                              (make-ball 20 600   8  200  )
                             (make-racket 330 340 0 0 false 0 0))8
                                "Ball state not correct"))
  (begin-for-test(check-equal?(ball-vx-after-tick
                              (make-ball 325 332   5  8  )
                             (make-racket 330 340 0 0 false 0 0))5
                               "Ball state not correct"))
  
               
;;CONTRACT
;;ball-vy-after-tick:Ball Racket->Integer
;;GIVEN: Ball and Racket
;; Vertical component of Ball's velocity
;;Stratergy: Cases on Ball and Racket,Observer Template on them
  ;;Examples:
 #|          ball-vy-after-tick
                              (make-ball 325 332   5  8  )
                             (make-racket 330 340 0 0 false 0 0))
                           => 8 |#
  
(define (ball-vy-after-tick b r)
  (cond

            [(is-ball-racket-collision? b r)
             (-(racket-vy r) (ball-vy b))]
            
            [(is-ball-right-wall-collision? b )
             (ball-vy b)]
            
            [(is-ball-left-wall-collision? b )
             (ball-vy b )]
            
            [(is-ball-front-wall-collision? b )
             (- 0 (ball-vy b))]
            
            [(and(is-ball-final-collision? b )
            (not(is-ball-racket-collision? b r)))
             (ball-vy b)]
            
            [else
             (ball-vy b)]
           ))


;;CONTRACT:
;;racket-x-after-tic:Ball Racket->Integer
;;GIVEN: Ball and Racket
;;RETURN: x coordinate of ball's location
;;STRATERGY: Cases on Ball and Racket and Observer Template on Racket,Ball
;;Examples:
 #|        racket-x-after-tick
                             (make-ball 325 332   5  8  )
                             (make-racket 330 340 5 0 false 0 0))
                           => 335 |#


(define (racket-x-after-tick b r)
  (cond

            [(is-ball-racket-collision? b r)
           (if(racket-selected? r)
           (racket-x r)
           (racket-nx r))]
             
            [(is-racket-right-wall-collision?  r)
            (- COURT_WIDTH RHW)]
            
            [(is-racket-left-wall-collision?  r)
             RHW]
            [(is-racket-final-collision? r)
             (racket-nx r)] 

            [(is-racket-bottom-wall-collision? r)
            (if(racket-selected? r)
            (racket-x r)
            (racket-nx r))]

            [else
            (if(racket-selected? r)
            (racket-x r)
            (racket-nx r)) ]
            ))

;;CONTRACT:
;;racket-y-after-tick: Ball Racket->Integer
;;GIVEN: Ball and Racket
;;RETURN: y coordinate of racket's location
;;STRATERGY: Observer Template on Racket and Ball
;;Examples:
 #|        racket-y-after-tick
                             (make-ball 325 332   5  8  )
                             (make-racket 330 340 0 0 false 0 0))
                           => 340 |#

(define (racket-y-after-tick b r)
  (cond

            [(is-ball-racket-collision? b r)
             (if(racket-selected? r)
              (racket-y r)
             (racket-ny r) )]
            
            [(is-racket-right-wall-collision? r)
             (if(racket-selected? r)
             (racket-y r)
            (racket-ny r))]
            
             [(is-racket-left-wall-collision?  r)
             (if(racket-selected? r)
             (racket-y r)
             (racket-ny r))]
            
            [(is-racket-final-collision? r)
             0]
            
            [(is-racket-bottom-wall-collision? r)
             COURT_LENGTH]
            
            [else
             (if(racket-selected? r)
             (racket-y r)
             (racket-ny r)) ]
             ))

;;CONTRACT:
;;racket-vx-after-tick: Ball Racket->Integer
;;GIVEN: Ball and Racket
;;RETURN: Horizontal  component of Racket;s velocity
;;STRATERGY: Observer Template on Racket and Ball and Combining Simpler Functions
;;Examples:
 #|        racket-vx-after-tick
                             (make-ball 325 332   5  8  )
                             (make-racket 330 340 5 0 false 0 0))
                           => 5 |#

(define (racket-vx-after-tick b r)
  (cond

            [(is-ball-racket-collision? b r)
             (racket-vx r)]

            [(is-racket-right-wall-collision? r)
             0]
            
            [(is-racket-left-wall-collision?  r)
             0]
            
            [(is-racket-final-collision? r)
             (racket-vx r)]
            
            [(is-racket-bottom-wall-collision? r)
             (racket-vx r)]
            
            [else
            (racket-vx r)]))

;;CONTRACT:
;;racket-vy-after-tick: Ball Racket->Integer
;;GIVEN: Ball and Racket
;;RETURN: Vertical  component of Racket's velocity
;;STRATERGY: Observer Template on Racket and Ball
;;Examples:
 #|        racket-vy-after-tick
                             (make-ball 325 332   5  8  )
                             (make-racket 330 340 0 0 false 0 0))
                           => 0 |#

(define (racket-vy-after-tick b r)
  (cond

         [(is-ball-racket-collision? b r)
          (if(<(racket-vy r)0) 0  (racket-vy r))]
         
         [(is-racket-right-wall-collision? r)
          (racket-vy r) ]
         
         [(is-racket-left-wall-collision?  r)
          (racket-vy r)]
         
         [(is-racket-final-collision? r)
          (racket-vy r) ]
         
         [(is-racket-bottom-wall-collision? r)
          (racket-vy r) ]
         
         [else
          (racket-vy r)]))

;;TESTS:
(begin-for-test(check-equal? (racket-vy-after-tick
                              (make-ball 12 12 2 2)
                              (make-racket 14 14 (- 0 2) (- 0 2) false 12 15))
                              0))

                                                 
                                              
            
         

;;CONTRACT:
;; is-ball-racket-collision? BALL RACKET  -> Boolean
;;GIVEN: ball, racket 
;;RETURN: true if there is a ball racket collision
;;STRATERGY: Observer Template on ball and racket

 
 (define (is-ball-racket-collision?  b r )

      (cond
            [(and (< (ball-y b) (racket-y r)) (>=(ball-vy b) 0)  
            (trajectory-of-ball? b r (/(ball-vy b) (ball-vx b))))true]
            [else false]))

  ;;CONTRACT
 ;;trajectory-of-ball? Integer Integer Integer->Boolean
 ;;GIVEN: Ball Racket and the slope of the line ball forms
 ;;RETURN: true if ball collides with the racket
 ;;STRATERGY: Transcribe Formula

 (define (trajectory-of-ball? b r m)
                          (point-of-contact? b r m
                          (/(-(racket-ny r)(-(ball-by b) (* m (ball-bx b)))) m)))

  ;;CONTRACT
 ;;point-of-contact? Integer Integer Integer Integer->Boolean
 ;;GIVEN: Ball Racket and the slope of the line ball forms and expected point
 ;;RETURN: true if ball collides with the racket
 ;;STRATERGY: Transcribe Formula

 (define (point-of-contact? b r m p)
   (cond
            [(and(>= p (-(racket-nx r)RHW)) (<= p (+( racket-nx r)RHW))
            (>= (racket-ny r) (ball-y b)) (<=(racket-ny r) (ball-by b))) true]
             [else false]
     ))
                       
   
;;TESTS:  
(begin-for-test(check-equal?        
                            ( is-ball-racket-collision? (make-ball 325 332 5 8) 
                            (make-racket 330 340 0 0 true  0 0 ) )true))

(begin-for-test(check-equal?( is-ball-racket-collision?
                              (make-ball 325 332 5 8) 
                              (make-racket 330 300 0 0 true  0 0 ))false))
 
;;CONTRACT:
;;is-ball-right-wall-collision? Ball->Boolean
 ;;GIVEN: Ball
;;RETURN: true if there is a ball right wall collision
;;STRATERGY: Cases on ball,Observer Template on Ball
(define (is-ball-right-wall-collision? b)
                         (if(>=(ball-bx b) COURT_WIDTH) true false))

;;TESTS:

(begin-for-test(check-equal?( is-ball-right-wall-collision?
                             (make-ball 420 332 100 8)) true))


(begin-for-test(check-equal?( is-ball-right-wall-collision?
                               (make-ball 325 332 5 8)) false))

;;CONTRACT:
;;is-ball-left-wall-collision? Ball->Boolean
;;GIVEN: Ball
;;RETURN: true if there is a ball-left wall collision
;;STRATERGY: Condition checked for the wall collision on Ball,Observer Template
(define(is-ball-left-wall-collision? b)
                               (if(<=(+(ball-x b) (ball-vx b)) 0) true false))

;;TESTS:
(begin-for-test(check-equal?( is-ball-left-wall-collision?
                               (make-ball 10 332 -11 8)) true))

(begin-for-test(check-equal?( is-ball-left-wall-collision?
                               (make-ball 30 332 5 8)) false))

;;CONTRACT:
;;is-ball-front-wall-collision?Ball->Boolean
;;GIVEN: a Ball
;;RETURN: true if there is a ball front wall collision
;;STRATERGY: Checking condition for front wall collision on Ball
;;Observer Template on Ball
(define (is-ball-front-wall-collision? b) (if(<=(+(ball-y b) (ball-vy b)) 0)
                                           true false))
;;TEST:
(begin-for-test(check-equal?( is-ball-front-wall-collision?
                               (make-ball 30 8 5 -8)) true))

(begin-for-test(check-equal?( is-ball-front-wall-collision?
                              (make-ball 30 50 5 8)) false))


;;CONTRACT
;;is-ball-final-collision? Ball -> Boolean
;;GIVEN: Ball
;;RETURN: true if Ball strikes the back wall
;;STRATERGY: Observer Template on Ball
(define (is-ball-final-collision? b ) (if (>=(+(ball-y b) (ball-vy b))
                                 COURT_LENGTH )  
                                 true false))

;;TESTS:

(begin-for-test(check-equal?( is-ball-final-collision?
                               (make-ball 400 550 94 200))
                                true))

(begin-for-test(check-equal?( is-racket-final-collision?
                            
                              (make-racket 250 400 2 80 false  0 0) ) false))

(begin-for-test(check-equal?( is-racket-final-collision?
                                (make-racket 50 40 -50 -85
                                  false  0 0) ) true)) 



;;CONTRACT
;;is-racket-right-wall-collision: Racket->Boolean
;;GIVEN: a Racket
;;RETURN: true if there is a racket right wall collision
;;STRATERGY: Observer Template on Racket
(define (is-racket-right-wall-collision? r) (if (>= (+(+(racket-x r)
                                     (racket-vx r))RHW ) COURT_WIDTH)
                                      true false))

;;TESTS:

(begin-for-test(check-equal?( is-racket-right-wall-collision?
                            (make-racket 400 650 100 100 false  0 0) ) true))

(begin-for-test(check-equal?( is-racket-left-wall-collision?
                               (make-racket 50 40 50 50 false  0 0) ) false))


;;CONTRACT:
;;is-racket-left-wall-collision: Racket->Boolean
;;GIVEN: a Racket
;;RETURN: true if there is a racket left wall collision
;;STRATERGY: Observer Template on Racket
(define (is-racket-left-wall-collision? r) (if
                                       (<=(-(+(racket-x r) (racket-vx r)) RHW) 0)
                                      true false))
;;CONRACT:
;;is-racket-final-collision: Racket->Boolean
;;GIVEN: a Racket
;;RETURN: true if there is a racket hits the front wall
;;STRATERGY: Observer Template on Racket
(define (is-racket-final-collision?  r) (if  (<=(+(racket-y r) (racket-vy r))0)
                                          true false))

;;CONTRACT:
;;is-racket-bottom-wall-collision: Racket->Boolean
;;GIVEN: a Racket
;;RETURN: true if there is a racket bottom wall collision
;;STRATERGY: Observer Template on Racket
(define (is-racket-bottom-wall-collision? r)
                                (if (>=(+(racket-y r) (racket-vy r)) COURT_LENGTH)
                                    true false))



;;CONTRACT:
;;world-after-key-event World,KeyEvent->World
;;GIVEN: a world and a keyevent
;;RETURN: state of world after key event
;;STRATERGY:Checks condition on World and key events,Combining Simpler Function
;;Example:
#|          (world-after-key-event (make-world 
                                (list(make-ball 330 384 0 0) )
                                (make-racket 330 384 0 0 false  0 0)
                                false 0.005 0.005 (make-blueCircle 0 0)) "b")

=>                               (make-world (list (make-ball 330 384 3 -9)
                                 (make-ball 330 384 0 0))
                                 (make-racket 330 384 0 0  false 0 0) false
                                 0.005 0.005 (make-blueCircle 0 0))|#


(define (world-after-key-event w kev)
  (cond
 [ (and(key=? " " kev) (world-ready-to-serve? w)) (switch-to-rally-state w)]
                          

 [(and (key=? " " kev) (not(world-ready-to-serve? w  ))
  (=(world-timer w) (world-ticks w)))
 (switch-to-pause-state w)]
                        

[(and(key=? kev "left") (not(world-pause? w)))
 (key-pressed w kev)]
                                   

 [(and(key=? kev "right")(not(world-pause? w)))
  (key-pressed w kev)] 
                                            
 
[(and(key=? kev "up") (not(world-pause? w)))
 (key-pressed w kev)]
                                           

[(and(key=? kev "down") (not(world-pause? w)))
 (key-pressed  w kev)]

[(and (key=? kev "b" ) (not (world-pause? w)))
 (add-new-ball w kev)]
                                       

[else w]
))

;;CONTRACT:
;;switch-to-rally-state :World->World
;;GIVEN: a world 
;;RETURN: state of world which is in rally state
;;STRATERGY:Constructor Template
;;Examples:
;;(switch-to-rally-state (make-world (list(make-ball 330 384 0 0))
;;                                   (make-racket 330 384 0 0 false 435 659)
;;                                    false 0.005 0.005
;;                                   (make-blueCircle 435 659))
;;                       (make-world (list (make-ball 330 384 3 -9))
;;                                   (make-racket 330 384 0 0 false 435 659)
;;                                    false 0.005 0.005 (make-blueCircle 435 659))
(define (switch-to-rally-state w) 
                              (make-world (cons (make-ball 330 384 3 -9) empty )
                              (make-racket 330 384 0 0 false  0 0) false
                              (world-ticks w) (world-timer w)
                              (world-blueCircle w)))


;;CONTRACT:
;;switch-to-pause-state :World->World
;;GIVEN: a world 
;;RETURN: state of world in pause state
;;STRATERGY:Constructor Template
;;(switch-to-pause-state (make-world (list(make-ball 330 384 70 12))
;;                                   (make-racket 330 384 0 0 false 435 659)
;;                                    false 0.05 0.05
;;                                   (make-blueCircle 435 659))
;;                       (make-world (list (make-ball 330 384 3 -9))
;;                                   (make-racket 330 384 0 0 false 435 659)
;;                                    true 60 0.05 (make-blueCircle 435 659))


(define (switch-to-pause-state w) 
                                 (make-world (world-balls w) (world-racket w)true
                                 ( / DELAY (world-timer w)) (world-timer w)
                                 (world-blueCircle w)))

;;CONTRACT:
;;key-pressed :World KeyEvent->World
;;GIVEN: a world and a keyEvent
;;RETURN: World with updated velocity
;;STRATERGY:Constructor Template and combine simpler function

                       
(define (key-pressed w kev)
                                  (make-world (world-balls w)
                                  (get-racket kev(world-racket w)) 
                                  (world-pause? w) (world-ticks w) (world-timer w)
                                  (world-blueCircle w)))

;;(key-pressed (make-world (list(make-ball 330 384 70 12))
;;                                   (make-racket 330 384 45 0 false 435 659)
;;                                    false 0.05 0.05
;;                                   (make-blueCircle 435 659)) "up"
;;                       (make-world (list (make-ball 330 384 70 11))
;;                                   (make-racket 330 384 0 0 false 435 659)
;;                                    false 0.05 0.05 (make-blueCircle 435 659))

#|
;;CONTRACT:
;;right-key-pressed :World KeyEvent->World
;;GIVEN: a world and a keyEvent
;;RETURN: World with racket's incresed horizontal velocity
;;STRATERGY:Constructor Template and combine simpler function

(define (right-key-pressed w kev)
                                  (make-world (world-balls w)
                                  (get-racket kev (world-racket w) )  
                                   (world-pause? w) (world-ticks w)
                                   (world-timer w) (world-blueCircle w)))

;;CONTRACT:
;;up-key-pressed :World KeyEvent->World
;;GIVEN: a world and a keyEvent
;;RETURN: World with decreased racket's velocity (vertical velocity)
;;STRATERGY:Constructor Template and combine simpler function

(define (up-key-pressed w kev)
                                    (make-world (world-balls w) 
                                    (get-racket kev (world-racket w)  )
                                     (world-pause? w) (world-ticks w)
                                     (world-timer w) (world-blueCircle w)))

;;CONTRACT:
;;down-key-pressed :World KeyEvent->World
;;GIVEN: a world and a keyEvent
;;RETURN: World with increased racket's velocity (vertical velocity)
;;STRATERGY:Constructor Template and combine simpler function

(define (down-key-pressed w kev)
                                     (make-world (world-balls w)
                                      (get-racket kev (world-racket w)  )
                                      (world-pause? w) (world-ticks w)
                                      (world-timer w) (world-blueCircle w)))|#

;;CONTRACT:
;;add-new-ball :World KeyEvent->World
;;GIVEN: a world and a keyEvent
;;RETURN: World after a new ball is added
;;STRATERGY:Constructor Template and combine simpler function

(define (add-new-ball w kev)
                        (make-world (cons (make-ball 330 384 3 -9)(world-balls w))
                        (world-racket w) (world-pause? w) (world-ticks w)
                        (world-timer w) (world-blueCircle w)))
                                    

;;TESTS

(begin-for-test(check-equal? (world-after-key-event (make-world 
                                (list(make-ball 330 384 0 0) )
                                (make-racket 330 384 0 0 false  0 0)
                                false 0.005 0.005 (make-blueCircle 0 0)) "b")
                                (make-world (list (make-ball 330 384 3 -9)
                                  (make-ball 330 384 0 0))
                                 (make-racket 330 384 0 0  false 0 0) false
                                 0.005 0.005 (make-blueCircle 0 0))
                                "New ball added"))

(begin-for-test(check-equal? (world-after-key-event (make-world 
                                (list(make-ball 330 384 0 0) )
                                (make-racket 330 384 0 0 false  0 0)
                                true 0.005 0.005 (make-blueCircle 0 0)) " ")
                                (make-world (list (make-ball 330 384 3 -9))
                                 (make-racket 330 384 0 0  false 0 0) false
                                 0.005 0.005 (make-blueCircle 0 0))
                                "KeyEvent Error"))

(begin-for-test(check-equal? (world-after-key-event (make-world
                                 (list (make-ball 350 384 0 0))
                                (make-racket 330 384 0 0 false  0 0)
                                false 0.005 0.005 (make-blueCircle 0 0)) " " ) 
                                (make-world (list (make-ball 350 384 0 0))
                                 (make-racket 330 384 0 0 false  0 0) true
                                 600 0.005 (make-blueCircle 0 0))
                                "KeyEvent Error"))


(begin-for-test(check-equal? (world-after-key-event (make-world
                                (list (make-ball 330 384 0 0)) 
                                (make-racket 330 358 0 0  false 0 0)
                                false 50 0.005 (make-blueCircle 0 0)) "up")
                             
                                (make-world (list (make-ball 330 384 0 0))
                                 (make-racket 330 358 0 -1 false  0 0) false
                                 50 0.005 (make-blueCircle 0 0))
                                "KeyEvent Error"))

(begin-for-test(check-equal? (world-after-key-event (make-world
                                (list (make-ball 330 384 0 0)) 
                                (make-racket 330 358 0 0  false 0 0)
                                false 50 0.005 (make-blueCircle 0 0)) "q")
                             
                                (make-world (list (make-ball 330 384 0 0))
                                 (make-racket 330 358 0 0 false  0 0) false
                                 50 0.005 (make-blueCircle 0 0))
                                "KeyEvent Error"))



(begin-for-test(check-equal? (world-after-key-event (make-world 
                                 (list (make-ball 330 384 0 0))
                                 (make-racket 330 358 0 0 false  0 0)
                                 false 50 0.005 (make-blueCircle 0 0)) "down")
                             
                                 (make-world (list (make-ball 330 384 0 0 ))
                                 (make-racket 330 358 0 1  false 0 0) false
                                 50 0.005 (make-blueCircle 0 0))
                                 "KeyEvent Error"))

(begin-for-test(check-equal? (world-after-key-event (make-world
                                (list (make-ball 350 384 0 0 ))
                                (make-racket 330 358 0 0 false 0 0)
                                false 50 0.005 (make-blueCircle 0 0)) "left")
                             
                                (make-world (list (make-ball 350 384 0 0 ))
                                 (make-racket 330 358 -1 0 false 0 0) false
                                 50 0.005 (make-blueCircle 0 0))
                                "KeyEvent Error"))

(begin-for-test (check-equal? (world-after-key-event (make-world
                                (list(make-ball 330 184 0 0))
                                (make-racket 330 358 0 0  false 0 0)
                                false 50 0.005 (make-blueCircle 0 0)) "right")
                             
                                (make-world (list(make-ball 330 184 0 0))
                                 (make-racket 330 358 1 0  false 0 0) false
                                 50 0.005 (make-blueCircle 0 0))
                                "KeyEvent Error"))


;;CONTRACT
;;get-racket:Racket,KeyEvent-> Racket
;;GIVEN: Present state of Racket,World and a KeyEvent
;;RETURN:State of the Racket after KeyEvent
;;STRATERGY: Cases on KeyEvents ,Checking the keyevevnts and then making
;;changes to racket;s velocity ,Constructor Template on Racket
;;Examples:
#|        (get-racket "left" (make-racket 45 12 12 2 false 20 20))
 =>         (make-racket 33 10 11 2 false 20 20)
                        |#
  (define (get-racket   k r )(cond

[(key=? k "left") (left-speed-increement r )]
[(key=? k "down")   (down-speed-increement r)]
[(key=?  k "right")  (right-speed-increement r)]
[(key=?  k "up")      (up-speed-increement r)]))

;;CONTRACT
;;left-speed-increement :Racket->Racket
;;GIVEN: Racket
;;RETURN: Racket with decreased horizontal velocity
;;STRATERGY: Constructor Template on Racket
  
(define (left-speed-increement r)
                            (make-racket (racket-x r) (racket-y r)
                            (- (racket-vx r) 1) (racket-vy r)
                            (racket-selected? r) (racket-rx r) (racket-ry r)))
;;CONTRACT
;;right-speed-increement :Racket->Racket
;;GIVEN: Racket
;;RETURN: Racket with increased horizontal velocity
;;STRATERGY: Constructor Template on Racket

(define (right-speed-increement r)
                         (make-racket (racket-x r )
                         (racket-y r) (+ (racket-vx r) 1)
                         (racket-vy r) (racket-selected? r) 
                         (racket-rx r) (racket-ry r)))
;;CONTRACT
;;down-speed-increement :Racket->Racket
;;GIVEN: Racket
;;RETURN: Racket with increased vertical velocity
;;STRATERGY: Constructor Template on Racket
 (define (down-speed-increement r)
                          (make-racket (racket-x r) (racket-y r) (racket-vx r)
                          (+ 1 (racket-vy r)) (racket-selected? r)
                          (racket-rx r) (racket-ry r)))

;;CONTRACT
;;up-speed-increement :Racket->Racket
;;GIVEN: Racket
;;RETURN: Racket with decreased vertical velocity
;;STRATERGY: Constructor Template on Racket
(define (up-speed-increement r)
                          (make-racket (racket-x r)
                          (racket-y r)  (racket-vx r)
                          (- (racket-vy r)1) (racket-selected? r)
                          (racket-rx r) (racket-ry r)))
                         





;;CONTRACT:
;;world-in-rally-state: World-> Boolean
;;GIVEN: a state of World
;;RETURN: True if the world is in rally state
;;STRATERGY: Checking status of Pause field and Timer field , Observer Template
;;           on World

(define (world-in-rally-state? w) (if(and(not(world-pause? w  ))
                                 (=(world-timer w) (world-ticks w))) true false))
;;TESTS
(begin-for-test (check-equal?(world-in-rally-state?
                                 (make-world (list(make-ball 330 184 0 0))
                                 (make-racket 330 358 1 0 false  0 0) false
                                  0.005 0.005 (make-blueCircle 0 0))) true
                                  "Error"))

(begin-for-test (check-equal?(world-in-rally-state?
                                 (make-world (list(make-ball 330 184 0 0))
                                 (make-racket 330 358 1 0 false  0 0) true
                                 0.005 0.005 (make-blueCircle 0 0))) false
                                 "Error"))

;;CONTRACT
;;world-after-mouse-event: World,MousePositionX , MousePositionY, MouseEvent
;;GIVEN: world in a state, x position of mouse, y position of mouse, mouse event
;;RETURN: World after the mouse event
;;STRATERGY: Constructor Template on World
;;Examples:
#|          (world-after-mouse-event 
                                    (make-world (make-ball 330 184 0 0)
                                    (make-racket 10 10 0 0 false  0 0) false
                                    0.005 0.005 (make-blueCircle 0 0)) 10 10
                                    "button-down" )

=>                                  (make-world (make-ball 330 184 0 0)
                                    (make-racket 10 10 0 0  true 10 10)false
                                    0.005 0.005 (make-blueCircle 10 10 ))|#

 (define (world-after-mouse-event w mx my mev)
   (cond                 [(world-in-rally-state? w)
                          
                         (make-world (world-balls w)
                         (racket-after-mouse-event  mx my mev (world-racket w))
                         (world-pause? w) (world-ticks w) (world-timer w)
                         (blue-circle-after-mouse-event mx my mev
                         (world-blueCircle w) (world-racket w)))]

                         [else
                          w]))
                 
   

 (begin-for-test(check-equal?(world-after-mouse-event 
                                    (make-world (make-ball 330 184 0 0)
                                    (make-racket 10 10 0 0 false  0 0) false
                                    0.005 0.005 (make-blueCircle 0 0)) 10 10
                                    "button-down" )
                                    (make-world (make-ball 330 184 0 0)
                                    (make-racket 10 10 0 0  true 10 10)false
                                    0.005 0.005 (make-blueCircle 10 10 ))
                                    "Mouse Event Error"))

 
 (begin-for-test(check-equal?(world-after-mouse-event 
                                    (make-world (make-ball 330 184 0 0)
                                    (make-racket 10 10 0 0 false  0 0) true
                                    60 0.005 (make-blueCircle 0 0)) 10 10
                                    "button-down" )
                                    (make-world (make-ball 330 184 0 0)
                                    (make-racket 10 10 0 0  false 0 0)true
                                    60 0.005 (make-blueCircle 0 0 ))
                                    "Mouse Event Error"))
 
(begin-for-test(check-equal?(world-after-mouse-event 
                                    (make-world (make-ball 330 184 0 0)
                                    (make-racket 10 10 0 0  true 50 50) false
                                    0.005 0.005 (make-blueCircle 60 60)) 60 60
                                    "drag" )
                                    (make-world (make-ball 330 184 0 0)
                                    (make-racket 20 20 0 0 true 60 60)false
                                    0.005 0.005 (make-blueCircle 60 60 ))
                                    "Mouse Event Error"))

(begin-for-test(check-equal?(world-after-mouse-event 
                                    (make-world (make-ball 330 184 0 0)
                                    (make-racket 10 10 0 0 true  50 50) false
                                    0.005 0.005 (make-blueCircle 60 60)) 60 60
                                    "button-up" )
                                    (make-world (make-ball 330 184 0 0)
                                    (make-racket 10 10 0 0 false  50 50)false
                                    0.005 0.005 (make-blueCircle 525 749 ))
                                    "Mouse Event Error"))

(begin-for-test(check-equal?(world-after-mouse-event 
                                    (make-world (make-ball 330 184 0 0)
                                    (make-racket 10 10 0 0 false  0 0) false
                                    0.005 0.005 (make-blueCircle 435 659)) 0 0 
                                    "move" )
                                    (make-world (make-ball 330 184 0 0)
                                    (make-racket 10 10 0 0 false  0 0)false
                                    0.005 0.005 (make-blueCircle 435 659 ))
                                    "Mouse Event Error"))


;;CONTRACT:
;;racket-after-mouse-event MousePositionX,MousePositionY,MouseEvent,Racket->Racket
;;GIVEN: Position of the mouse-(x,y),MouseEvent,Racket
;;RETURN: Racket after mouse event
;;STRATERGY: Cases on Mouse Event and combining simpler function
;;Examples:
#| (racket-after-mouse-event  45 62 "button-down"
                              (make-racket 40 62 20 12 false 45 62))
 =>                            (make-racket 40 62 20 12 true 45 62)|#

 
 (define (racket-after-mouse-event  mx my mev r)
  
  (cond
    [(mouse=? mev "button-down")  (racket-after-button-down    mx my  r)]
    [(mouse=? mev "drag")         (racket-after-drag  mx my r )  ]
    [(mouse=? mev "button-up")    (racket-after-button-up  mx my r )]
    [else r]))

  
;;CONTRACT:
;; racket-after-button-down : Racket Integer Integer -> Racket
;;GIVEN: Racket, Mouse Position (x,y)
;; RETURNS: the racket following a button-down at the given location.
;; STRATEGY: Conditions on Racket and Constructor Template on Racket

(define (racket-after-button-down  x y r )
                                 (if (<=(in-racket? r x y)25.0)
                                 (make-racket  (racket-x r) (racket-y r)
                                 (racket-vx r) (racket-vy r) true   x   y) r))

;;TESTS
(begin-for-test(check-equal? (racket-after-button-down
                             23 45 (make-racket 150 160 25 120 false 0 0))
                             (make-racket 150 160 25 120 false 0 0))) 

 
                                     
  
;;CONTRACT
;; racket-after-drag : Racket Integer Integer Mouse Event -> Racket
;;;;GIVEN: Racket, Mouse's Position (x,y)
;; RETURNS: the Racket following a drag at the given location
;; STRATEGY:  Conditions on Racket and Constructor Templateon Racket

(define (racket-after-drag  x y r )
                          (if (racket-selected? r) 
                          (make-racket (get-racket-x (racket-x r) (racket-rx r) x)
                          ( get-racket-y (racket-y r) (racket-ry r) y)
                          (racket-vx r) (racket-vy r) true 
                           x y ) r))
;;TESTS
(begin-for-test(check-equal? (racket-after-drag
                             45 95 (make-racket 23 45 0 0 false 0 0))
                             (make-racket 23 45 0 0 false 0 0))) 


;;CONTRACT
;; racket-after-button-up : Racket Integer Integer -> Racket
;;GIVEN: Racket, Mouse's Position (x,y)
;; RETURNS: the racket following a button-up at the given location
;; STRATEGY:  Conditions on Racket and Constructor Template on Racket

(define (racket-after-button-up  x y r )
                                      (if (racket-selected? r)
                                      (make-racket (racket-x r)
                                      (racket-y r) (racket-vx r)
                                      (racket-vy r) false  (racket-rx r)
                                      (racket-ry r)) r))

;;TESTS
(begin-for-test(check-equal? (racket-after-button-up
                             23 45 (make-racket 150 160 25 120 false 0 0))
                             (make-racket 150 160 25 120 false 0 0))) 


;;CONTRACT
;; blue-circle-after-mouse-event : BlueCircle,Racket Integer Integer -> BlueCircle
;;GIVEN: Racket, Mouse's Position (x,y),BlueCircle,MouseEvent
;; RETURNS: the BlueCircle following a mouse event
;; STRATEGY: Cases on Mouse Event and Combing Simpler Function
;;Examples:
#|(blue-circle-after-mouse-event 20 25 "button-down
                                  (make-bluCircle 435 659 )
                                  (make-racket 12 12 45 95 false 20 25))
=>                                (make-bluCircle 20 25)|#

(define (blue-circle-after-mouse-event mx my mev bc r)

(cond
    [(mouse=? mev "button-down")  (blue-circle-after-button-down  mx my  bc r)]
    [(mouse=? mev "drag")          (blue-circle-after-drag  mx my bc r )  ]
    [(mouse=? mev "button-up")    (blue-circle-after-button-up  mx my bc r )]
    [else bc]))


;; blue-circle-after-button-down :  Integer Integer BlueCircle Rcket -> BlueCircle
;;GIVEN: Mouse Position -(x,y),BlueCircle and Racket
;; RETURNS: the BlueCircle following a button-down event
;; STRATEGY:Condition on Racket and Constructor Template 

(define (blue-circle-after-button-down  x y bc r )
  (if (<=(in-racket? r x y)25.0)
      (make-blueCircle x y  ) bc)) 

;;TESTS
(begin-for-test(check-equal? (blue-circle-after-button-down
                             23 45 (make-blueCircle 435 659)
                             (make-racket 150 160 25 120 false 0 0))
                             (make-blueCircle 435 659))) 


;; blue-circle-after-drag :  Integer Integer BlueCircle Racket -> BlueCircle
;;GIVEN: Mouse Position -(x,y),BlueCircle and Racket
;; RETURNS: the BlueCircle following a drag at the given location
;; STRATEGY: Condition on Racket and Constructor Template 

(define (blue-circle-after-drag  x y bc r )
                                          (if (racket-selected? r) 
                                          (make-blueCircle x y) bc))

;;TESTS
(begin-for-test(check-equal? (blue-circle-after-drag
                             23 45 (make-blueCircle 435 659)
                             (make-racket 150 160 25 120 false 0 0))
                             (make-blueCircle 435 659))) 

;; cat-after-button-up :  Integer Integer BlueCircle Racket -> BlueCircle
;;GIVEN: Mouse Position -(x,y),BlueCircle and Racket
;; RETURNS: the BlueCircle  following a button-up at the given location
;; STRATEGY: Condition on Racket and Constructor Template 

(define (blue-circle-after-button-up  x y bc r )
                                               (if (racket-selected? r)
                                              (make-blueCircle (+ COURT_WIDTH 100)
                                              (+ COURT_LENGTH 100)) bc))
;;TESTS
(begin-for-test(check-equal? (blue-circle-after-button-up
                             23 45 (make-blueCircle 435 659)
                             (make-racket 150 160 25 120 false 0 0))
                             (make-blueCircle 435 659))) 
 

;;CONTRACT
;;in-racket:Racket, Integer, Integer -> Boolean
;;GIVEN: Racket and the position of the mouse -(x,y)
;;RETURN: True if the distance between the mouse and the racket's centre is
;;less than 25
;;STRATERGY: Observer Template
(define (in-racket? r x y )  (distance-calculator (racket-x r) (racket-y r) x y))


;;CONTRACT
;;distance-calculator: Integer,Integer,Integer,Integer->Integer
;;GIVEN: Racket Position (x,y) and Mouse Position (x,y)
;;RETURN: Distance bettween the two given points
;;STRATERGY: TRANSCRIBE FORMULA
(define (distance-calculator rx ry x y)
                                               (sqrt(+(expt ( - rx x) 2)
                                                (expt (- ry y) 2))))

;;CONTRACT
;;get-circle-x: Integer Integer Integer->Integer
;;GIVEN: Racket Position (rx) in prevois tick ,Mouse Position (cx) in the
;;previous tick and Mouse currrent position (x)
;;RETURN: Racket's current x position
;;STRATERGY:Combing Simpler Functions
                      (define (get-racket-x rx cx x) (+(- rx cx)x))

;;CONTRACT:
;;get-circle-y: Integer,Integer,Integer->Integer
;GIVEN: Racket Position (ry) in prevois tick ,Mouse Position (cy) in the
;;previous tick and Mouse currrent position (y)
;;RETURN: Racket's current y position
;;STRATERGY:Combining Simpler Functions
                      (define (get-racket-y ry cy y) (+(- ry cy)y))
                                       
  
 


;;CONTRACT
;;world-to-scene:World-> Scene
;;GIVEN: World
;;RETURN:World placed on a Scene
;;STRATERGY: Conditions on World and Combining Simpler Functions
;; Examples:
#|             world-to-scene
                             (make-world
                             (list(make-ball 120 150 0 0))
                             (make-racket 151 136 0 0 false 0 0)
                             false 0.05 0.05 (make-blueCircle 151 136)))
=>
                            (scene-with-circle (make-blueCircle 151 136 )
                             (scene-with-ball (list(make-ball 120 150 0 0))
                             (scene-with-racket(make-racket 151 136 0 0 false 0 0)
                             SCENE2))) |#
(define (world-to-scene w)

  
 (if (and(world-pause? w) (not(=(world-timer w) (world-ticks w)) )) 
                          (scene-with-circle (world-blueCircle w) (scene-with-ball
                          (  world-balls w)   (scene-with-racket
                          (world-racket w) SCENE1)))  
                           
                          (scene-with-circle (world-blueCircle w) (scene-with-ball
                          (world-balls w)   (scene-with-racket
                          (world-racket w) SCENE2)))))

;;TESTS
(begin-for-test(check-equal?(world-to-scene
                             (make-world
                             (list(make-ball 120 150 0 0))
                             (make-racket 151 136 0 0 false 0 0)
                             false 0.05 0.05 (make-blueCircle 151 136)))
                            (scene-with-circle (make-blueCircle 151 136 )
                             (scene-with-ball (list(make-ball 120 150 0 0))
                             (scene-with-racket(make-racket 151 136 0 0 false 0 0)
                             SCENE2))) "Error in Scene Construction"))

(begin-for-test(check-equal?(world-to-scene
                             (make-world
                             (list(make-ball 120 150 0 0))
                             (make-racket 151 136 0 0 false 0 0)
                             true 58 0.05 (make-blueCircle 151 136)))
                            (scene-with-circle (make-blueCircle 151 136 )
                             (scene-with-ball (list(make-ball 120 150 0 0))
                             (scene-with-racket(make-racket 151 136 0 0 false 0 0)
                             SCENE1))) "Error in Scene Construction"))


  

;;CONTRACT
;;scene-with-circle-> BlueCircle,Scene->Scene
;;GIVEN: BlueCircle,Scene
;;RETURN: BlueCircle placed on a Scene
;;STRATERGY: Observer Templates and Simpler Functions

(define (scene-with-circle c s )
                                 (place-image
                                 CIRCLE-IMAGE
                                 (blueCircle-x c) (blueCircle-y c)
                                 s))
(begin-for-test(check-equal? (scene-with-circle
                              (make-blueCircle 250 150  ) SCENE1)
                             (place-image CIRCLE-IMAGE 250 150 SCENE1)
                             "Scene Function Failed"))
 

;;CONTRACT
;;scene-with-ball-> BallList,Scene->Scene
;;GIVEN: Ball,Scene
;;RETURN: BallList placed on a Scene
;;STRATERGY: Using H.O.F, foldr on BallList

(define (scene-with-ball bl s )

  ;; BallList Scene -> Scene
  ;; GIVEN:  Ball, Scene
  ;; RETURN: an updated Scene with balls pasted on the given Scene
  (foldr (lambda (a s) (place-image BALL-IMAGE (ball-x a) (ball-y a) s)) s bl))
                                        
  

;;TESTS
(begin-for-test(check-equal? (scene-with-ball
                              (list(make-ball 250 150 0 0 )) SCENE1)
                             (place-image BALL-IMAGE 250 150 SCENE1)
                              "Scene Function Failed"))
       
 

;;CONTRACT
;;scene-with-racket-> Racket,Scene->Scene
;;GIVEN: Racket,Scene
;;RETURN: Racket placed on a Scene
;;STRATERGY: Observer Templates and Simpler Functionse

(define (scene-with-racket r s ) 
                                   (place-image
                                    RACKET-IMAGE
                                   (racket-x r) (racket-y r)
                                   s))

;;TESTS
(begin-for-test(check-equal? (scene-with-racket
                              (make-racket 250 150 0 0 false 0 0) SCENE1)
                             (place-image RACKET-IMAGE 250 150 SCENE1)
                             "Scene Function Failed"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;CIRCLE'S IMAGE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define CIRCLE-IMAGE (circle 4 "solid" "blue"))
                           (define RACKET-IMAGE (rectangle 47 7 "solid" "green"))
                           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                           ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;;                           SCENE1->When world is in pause state
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                           ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define SCENE1 (place-image
                          (rectangle COURT_WIDTH COURT_LENGTH "solid" "yellow")
                          (/ COURT_WIDTH 2) (/ COURT_LENGTH 2)
                          (rectangle COURT_WIDTH COURT_LENGTH "outline"
                          (pen "black" 10 "solid" "butt" "round"))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;SCENE1->When world is in rally state state or ready to serve state
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define SCENE2
                         (rectangle COURT_WIDTH  COURT_LENGTH "outline"
                         (pen "black" 10 "solid" "butt" "round")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;BALL'SIMAGE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define BALL-IMAGE (circle 3 "solid" "black"))

;;CONTRACT
;; next-bx :Ball-> Integer
;;next-by :Ball->Integer
;;GIVEN: Ball
;;RETURN: Position of Ball coordinate in next tick
;;STRATERGY: Using Templates
(define (ball-bx ball) (+(ball-x ball)(ball-vx ball)))
(define (ball-by ball) (+(ball-y ball)(ball-vy ball)))

;;CONTRACT
;;next-rx racket:Racket-> Integer
;;next-ry  :Racket->Integer
;;GIVEN: Racket
;;RETURN: Position of Racket coordinate in next tick
;;STRATERGY: Using Templates
 (define (racket-nx racket) (+(racket-x racket)(racket-vx racket)))
 (define (racket-ny racket) (+(racket-y racket) (racket-vy racket)))

               


