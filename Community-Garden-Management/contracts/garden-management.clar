;; Community Garden Management Smart Contract
;; Connect mentors and mentees with tokenized incentives

(impl-trait 'SP3FBR2AGK5H9QBDH3EEN6DF8EK8JY7RX8QJ5SVTE.sip-010-trait-ft-standard.sip-010-trait)

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-OWNER-ONLY (err u100))
(define-constant ERR-NOT-AUTHORIZED (err u101))
(define-constant ERR-INVALID-MENTOR (err u102))
(define-constant ERR-INVALID-MENTEE (err u103))
(define-constant ERR-INSUFFICIENT-BALANCE (err u104))
(define-constant ERR-ALREADY-PAIRED (err u105))
(define-constant ERR-SESSION-NOT-FOUND (err u106))
(define-constant ERR-INVALID-RATING (err u107))
(define-constant ERR-GARDEN-FULL (err u108))

;; Token Configuration
(define-fungible-token garden-token)
(define-data-var token-name (string-ascii 32) "Community Garden Token")
(define-data-var token-symbol (string-ascii 10) "CGT")
(define-data-var token-decimals uint u6)

;; Garden Management
(define-data-var total-gardens uint u0)
(define-data-var max-garden-capacity uint u50)

;; Mentor Data Structure
(define-map mentors
  { mentor-id: principal }
  {
    name: (string-ascii 50),
    expertise: (string-ascii 100),
    rating: uint,
    total-sessions: uint,
    tokens-earned: uint,
    is-active: bool,
    garden-id: (optional uint)
  }
)

;; Mentee Data Structure  
(define-map mentees
  { mentee-id: principal }
  {
    name: (string-ascii 50),
    experience-level: (string-ascii 20),
    goals: (string-ascii 200),
    tokens-balance: uint,
    sessions-completed: uint,
    current-mentor: (optional principal),
    garden-id: (optional uint)
  }
)

;; Mentorship Sessions
(define-map sessions
  { session-id: uint }
  {
    mentor: principal,
    mentee: principal,
    garden-id: uint,
    topic: (string-ascii 100),
    duration-hours: uint,
    status: (string-ascii 20), ;; "pending", "completed", "cancelled"
    mentor-rating: (optional uint),
    mentee-rating: (optional uint),
    tokens-rewarded: uint,
    timestamp: uint
  }
)

;; Garden Plots
(define-map gardens
  { garden-id: uint }
  {
    name: (string-ascii 50),
    location: (string-ascii 100),
    capacity: uint,
    current-members: uint,
    mentor-count: uint,
    mentee-count: uint,
    total-sessions: uint,
    is-active: bool
  }
)

;; Counters
(define-data-var next-session-id uint u1)

;; SIP-010 Token Standard Implementation
(define-read-only (get-name)
  (ok (var-get token-name))
)

(define-read-only (get-symbol)
  (ok (var-get token-symbol))
)

(define-read-only (get-decimals)
  (ok (var-get token-decimals))
)

(define-read-only (get-balance (who principal))
  (ok (ft-get-balance garden-token who))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply garden-token))
)

(define-public (transfer (amount uint) (from principal) (to principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq from tx-sender) ERR-NOT-AUTHORIZED)
    (ft-transfer? garden-token amount from to)
  )
)

;; Garden Management Functions
(define-public (create-garden (name (string-ascii 50)) (location (string-ascii 100)) (capacity uint))
  (let
    (
      (garden-id (+ (var-get total-gardens) u1))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-OWNER-ONLY)
    (map-set gardens 
      { garden-id: garden-id }
      {
        name: name,
        location: location,
        capacity: capacity,
        current-members: u0,
        mentor-count: u0,
        mentee-count: u0,
        total-sessions: u0,
        is-active: true
      }
    )
    (var-set total-gardens garden-id)
    (ok garden-id)
  )
)

;; Mentor Registration
(define-public (register-mentor (name (string-ascii 50)) (expertise (string-ascii 100)) (garden-id uint))
  (let
    (
      (garden (unwrap! (map-get? gardens { garden-id: garden-id }) ERR-INVALID-MENTOR))
    )
    (asserts! (get is-active garden) ERR-INVALID-MENTOR)
    (asserts! (< (get current-members garden) (get capacity garden)) ERR-GARDEN-FULL)
    
    (map-set mentors
      { mentor-id: tx-sender }
      {
        name: name,
        expertise: expertise,
        rating: u5,
        total-sessions: u0,
        tokens-earned: u0,
        is-active: true,
        garden-id: (some garden-id)
      }
    )
    
    ;; Update garden stats
    (map-set gardens
      { garden-id: garden-id }
      (merge garden {
        current-members: (+ (get current-members garden) u1),
        mentor-count: (+ (get mentor-count garden) u1)
      })
    )
    
    ;; Mint welcome tokens
    (try! (ft-mint? garden-token u1000000 tx-sender))
    (ok true)
  )
)

;; Mentee Registration  
(define-public (register-mentee (name (string-ascii 50)) (experience-level (string-ascii 20)) (goals (string-ascii 200)) (garden-id uint))
  (let
    (
      (garden (unwrap! (map-get? gardens { garden-id: garden-id }) ERR-INVALID-MENTEE))
    )
    (asserts! (get is-active garden) ERR-INVALID-MENTEE)
    (asserts! (< (get current-members garden) (get capacity garden)) ERR-GARDEN-FULL)
    
    (map-set mentees
      { mentee-id: tx-sender }
      {
        name: name,
        experience-level: experience-level,
        goals: goals,
        tokens-balance: u500000,
        sessions-completed: u0,
        current-mentor: none,
        garden-id: (some garden-id)
      }
    )
    
    ;; Update garden stats
    (map-set gardens
      { garden-id: garden-id }
      (merge garden {
        current-members: (+ (get current-members garden) u1),
        mentee-count: (+ (get mentee-count garden) u1)
      })
    )
    
    ;; Mint welcome tokens
    (try! (ft-mint? garden-token u500000 tx-sender))
    (ok true)
  )
)

;; Create Mentorship Session
(define-public (create-session (mentor principal) (mentee principal) (garden-id uint) (topic (string-ascii 100)) (duration-hours uint))
  (let
    (
      (session-id (var-get next-session-id))
      (mentor-data (unwrap! (map-get? mentors { mentor-id: mentor }) ERR-INVALID-MENTOR))
      (mentee-data (unwrap! (map-get? mentees { mentee-id: mentee }) ERR-INVALID-MENTEE))
      (garden (unwrap! (map-get? gardens { garden-id: garden-id }) ERR-SESSION-NOT-FOUND))
    )
    
    (asserts! (get is-active mentor-data) ERR-INVALID-MENTOR)
    (asserts! (is-eq (unwrap! (get garden-id mentor-data) ERR-INVALID-MENTOR) garden-id) ERR-INVALID-MENTOR)
    (asserts! (is-eq (unwrap! (get garden-id mentee-data) ERR-INVALID-MENTEE) garden-id) ERR-INVALID-MENTEE)
    
    (map-set sessions
      { session-id: session-id }
      {
        mentor: mentor,
        mentee: mentee,
        garden-id: garden-id,
        topic: topic,
        duration-hours: duration-hours,
        status: "pending",
        mentor-rating: none,
        mentee-rating: none,
        tokens-rewarded: u0,
        timestamp: block-height
      }
    )
    
    (var-set next-session-id (+ session-id u1))
    (ok session-id)
  )
)

;; Complete Session and Distribute Rewards
(define-public (complete-session (session-id uint) (mentor-rating uint) (mentee-rating uint))
  (let
    (
      (session (unwrap! (map-get? sessions { session-id: session-id }) ERR-SESSION-NOT-FOUND))
      (mentor-data (unwrap! (map-get? mentors { mentor-id: (get mentor session) }) ERR-INVALID-MENTOR))
      (mentee-data (unwrap! (map-get? mentees { mentee-id: (get mentee session) }) ERR-INVALID-MENTEE))
      (base-reward (* (get duration-hours session) u100000))
      (bonus-reward (if (>= mentor-rating u8) u50000 u0))
      (total-reward (+ base-reward bonus-reward))
    )
    
    (asserts! (or (is-eq tx-sender (get mentor session)) (is-eq tx-sender (get mentee session))) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status session) "pending") ERR-SESSION-NOT-FOUND)
    (asserts! (and (<= mentor-rating u10) (>= mentor-rating u1)) ERR-INVALID-RATING)
    (asserts! (and (<= mentee-rating u10) (>= mentee-rating u1)) ERR-INVALID-RATING)
    
    ;; Update session
    (map-set sessions
      { session-id: session-id }
      (merge session {
        status: "completed",
        mentor-rating: (some mentor-rating),
        mentee-rating: (some mentee-rating),
        tokens-rewarded: total-reward
      })
    )
    
    ;; Update mentor stats and reward
    (map-set mentors
      { mentor-id: (get mentor session) }
      (merge mentor-data {
        total-sessions: (+ (get total-sessions mentor-data) u1),
        tokens-earned: (+ (get tokens-earned mentor-data) total-reward),
        rating: (/ (+ (* (get rating mentor-data) (get total-sessions mentor-data)) mentee-rating) (+ (get total-sessions mentor-data) u1))
      })
    )
    
    ;; Update mentee stats
    (map-set mentees
      { mentee-id: (get mentee session) }
      (merge mentee-data {
        sessions-completed: (+ (get sessions-completed mentee-data) u1)
      })
    )
    
    ;; Mint reward tokens to mentor
    (try! (ft-mint? garden-token total-reward (get mentor session)))
    
    ;; Update garden session count
    (let
      (
        (garden (unwrap! (map-get? gardens { garden-id: (get garden-id session) }) ERR-SESSION-NOT-FOUND))
      )
      (map-set gardens
        { garden-id: (get garden-id session) }
        (merge garden {
          total-sessions: (+ (get total-sessions garden) u1)
        })
      )
    )
    
    (ok total-reward)
  )
)

;; Read-only functions
(define-read-only (get-mentor (mentor-id principal))
  (map-get? mentors { mentor-id: mentor-id })
)

(define-read-only (get-mentee (mentee-id principal))
  (map-get? mentees { mentee-id: mentee-id })
)

(define-read-only (get-session (session-id uint))
  (map-get? sessions { session-id: session-id })
)

(define-read-only (get-garden (garden-id uint))
  (map-get? gardens { garden-id: garden-id })
)

(define-read-only (get-total-gardens)
  (var-get total-gardens)
)

(define-read-only (get-next-session-id)
  (var-get next-session-id)
)