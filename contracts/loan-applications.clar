;; Loan Application Processing Contract
;; Evaluates creditworthiness and processes loan applications

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u200))
(define-constant ERR-APPLICATION-NOT-FOUND (err u201))
(define-constant ERR-INVALID-AMOUNT (err u202))
(define-constant ERR-INVALID-TERM (err u203))
(define-constant ERR-APPLICATION-EXISTS (err u204))
(define-constant ERR-INSUFFICIENT-CREDIT (err u205))
(define-constant ERR-GROUP-REQUIRED (err u206))

;; Data Variables
(define-data-var next-application-id uint u1)
(define-data-var min-loan-amount uint u100)
(define-data-var max-loan-amount uint u10000)
(define-data-var min-loan-term uint u30)
(define-data-var max-loan-term uint u365)
(define-data-var base-credit-score uint u500)
(define-data-var timestamp-counter uint u1)

;; Data Maps
(define-map loan-applications
  { application-id: uint }
  {
    borrower: principal,
    group-id: uint,
    amount: uint,
    term-days: uint,
    purpose: (string-ascii 100),
    status: (string-ascii 20),
    applied-at: uint,
    processed-at: (optional uint),
    credit-score: uint,
    interest-rate: uint,
    collateral-type: (string-ascii 50),
    guarantors: uint
  }
)

(define-map borrower-applications
  { borrower: principal }
  {
    current-application: (optional uint),
    total-applications: uint,
    approved-count: uint,
    rejected-count: uint
  }
)

(define-map credit-profiles
  { borrower: principal }
  {
    base-score: uint,
    payment-history: uint,
    group-standing: uint,
    education-bonus: uint,
    total-score: uint,
    last-updated: uint
  }
)

;; Public Functions

;; Submit a new loan application
(define-public (submit-application
  (group-id uint)
  (amount uint)
  (term-days uint)
  (purpose (string-ascii 100))
  (collateral-type (string-ascii 50))
  (guarantors uint))
  (let
    (
      (application-id (var-get next-application-id))
      (current-timestamp (var-get timestamp-counter))
      (borrower-data (default-to
        { current-application: none, total-applications: u0, approved-count: u0, rejected-count: u0 }
        (map-get? borrower-applications { borrower: tx-sender })
      ))
    )
    ;; Validate loan parameters
    (asserts! (and (>= amount (var-get min-loan-amount)) (<= amount (var-get max-loan-amount))) ERR-INVALID-AMOUNT)
    (asserts! (and (>= term-days (var-get min-loan-term)) (<= term-days (var-get max-loan-term))) ERR-INVALID-TERM)
    (asserts! (> group-id u0) ERR-GROUP-REQUIRED)
    (asserts! (is-none (get current-application borrower-data)) ERR-APPLICATION-EXISTS)

    ;; Calculate initial credit score
    (let ((credit-score (calculate-credit-score tx-sender)))
      ;; Create application record
      (map-set loan-applications
        { application-id: application-id }
        {
          borrower: tx-sender,
          group-id: group-id,
          amount: amount,
          term-days: term-days,
          purpose: purpose,
          status: "pending",
          applied-at: current-timestamp,
          processed-at: none,
          credit-score: credit-score,
          interest-rate: u0,
          collateral-type: collateral-type,
          guarantors: guarantors
        }
      )

      ;; Update borrower application history
      (map-set borrower-applications
        { borrower: tx-sender }
        {
          current-application: (some application-id),
          total-applications: (+ (get total-applications borrower-data) u1),
          approved-count: (get approved-count borrower-data),
          rejected-count: (get rejected-count borrower-data)
        }
      )

      ;; Increment counters
      (var-set next-application-id (+ application-id u1))
      (var-set timestamp-counter (+ current-timestamp u1))

      (ok application-id)
    )
  )
)

;; Process application (approve or reject)
(define-public (process-application (application-id uint) (decision (string-ascii 20)) (interest-rate uint))
  (let
    (
      (app-data (unwrap! (map-get? loan-applications { application-id: application-id }) ERR-APPLICATION-NOT-FOUND))
      (current-timestamp (var-get timestamp-counter))
      (borrower (get borrower app-data))
      (borrower-data (unwrap! (map-get? borrower-applications { borrower: borrower }) ERR-APPLICATION-NOT-FOUND))
    )
    ;; Only contract owner can process applications
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    ;; Check if application is still pending
    (asserts! (is-eq (get status app-data) "pending") ERR-NOT-AUTHORIZED)

    ;; Update application status
    (map-set loan-applications
      { application-id: application-id }
      (merge app-data {
        status: decision,
        processed-at: (some current-timestamp),
        interest-rate: interest-rate
      })
    )

    ;; Update borrower statistics
    (if (is-eq decision "approved")
      (map-set borrower-applications
        { borrower: borrower }
        (merge borrower-data {
          current-application: none,
          approved-count: (+ (get approved-count borrower-data) u1)
        })
      )
      (map-set borrower-applications
        { borrower: borrower }
        (merge borrower-data {
          current-application: none,
          rejected-count: (+ (get rejected-count borrower-data) u1)
        })
      )
    )

    ;; Increment timestamp
    (var-set timestamp-counter (+ current-timestamp u1))

    (ok true)
  )
)

;; Update credit profile
(define-public (update-credit-profile
  (borrower principal)
  (payment-history uint)
  (group-standing uint)
  (education-bonus uint))
  (let
    (
      (current-timestamp (var-get timestamp-counter))
      (base-score (var-get base-credit-score))
      (total-score (+ base-score payment-history group-standing education-bonus))
    )
    ;; Only contract owner can update credit profiles
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)

    (map-set credit-profiles
      { borrower: borrower }
      {
        base-score: base-score,
        payment-history: payment-history,
        group-standing: group-standing,
        education-bonus: education-bonus,
        total-score: total-score,
        last-updated: current-timestamp
      }
    )

    ;; Increment timestamp
    (var-set timestamp-counter (+ current-timestamp u1))

    (ok total-score)
  )
)

;; Private Functions

;; Calculate credit score for borrower
(define-private (calculate-credit-score (borrower principal))
  (match (map-get? credit-profiles { borrower: borrower })
    profile (get total-score profile)
    (var-get base-credit-score)
  )
)

;; Read-only Functions

;; Get application details
(define-read-only (get-application (application-id uint))
  (map-get? loan-applications { application-id: application-id })
)

;; Get borrower application history
(define-read-only (get-borrower-history (borrower principal))
  (map-get? borrower-applications { borrower: borrower })
)

;; Get credit profile
(define-read-only (get-credit-profile (borrower principal))
  (map-get? credit-profiles { borrower: borrower })
)

;; Get loan limits
(define-read-only (get-loan-limits)
  {
    min-amount: (var-get min-loan-amount),
    max-amount: (var-get max-loan-amount),
    min-term: (var-get min-loan-term),
    max-term: (var-get max-loan-term)
  }
)

;; Get next application ID
(define-read-only (get-next-application-id)
  (var-get next-application-id)
)

;; Check application eligibility
(define-read-only (check-eligibility (borrower principal) (amount uint))
  (let
    (
      (credit-score (calculate-credit-score borrower))
      (min-score-required (/ amount u20))
    )
    (>= credit-score min-score-required)
  )
)

;; Admin Functions

;; Update loan limits
(define-public (update-loan-limits (new-min-amount uint) (new-max-amount uint) (new-min-term uint) (new-max-term uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (< new-min-amount new-max-amount) ERR-INVALID-AMOUNT)
    (asserts! (< new-min-term new-max-term) ERR-INVALID-TERM)
    (var-set min-loan-amount new-min-amount)
    (var-set max-loan-amount new-max-amount)
    (var-set min-loan-term new-min-term)
    (var-set max-loan-term new-max-term)
    (ok true)
  )
)

;; Update base credit score
(define-public (update-base-credit-score (new-score uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (var-set base-credit-score new-score)
    (ok true)
  )
)
