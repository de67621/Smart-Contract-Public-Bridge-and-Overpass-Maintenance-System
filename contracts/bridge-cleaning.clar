;; Bridge Cleaning Coordination Contract
;; Manages removal of graffiti, debris, and vegetation from bridge structures

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u200))
(define-constant ERR-BRIDGE-NOT-FOUND (err u300))
(define-constant ERR-INVALID-INPUT (err u100))
(define-constant ERR-CLEANING-NOT-FOUND (err u301))
(define-constant ERR-CREW-NOT-FOUND (err u302))

;; Data Variables
(define-data-var next-bridge-id uint u1)
(define-data-var next-cleaning-id uint u1)
(define-data-var contract-admin principal CONTRACT-OWNER)

;; Data Maps
(define-map bridges
  { bridge-id: uint }
  {
    name: (string-ascii 100),
    location: (string-ascii 200),
    last-cleaning: uint,
    next-cleaning: uint,
    cleaning-frequency: uint,
    crew-assigned: (optional principal),
    priority-level: uint,
    created-by: principal,
    created-at: uint
  }
)

(define-map cleaning-jobs
  { cleaning-id: uint }
  {
    bridge-id: uint,
    crew: principal,
    scheduled-date: uint,
    completed-date: (optional uint),
    cleaning-type: (string-ascii 50),
    status: (string-ascii 20),
    materials-used: (optional (string-ascii 200)),
    cost: (optional uint),
    quality-rating: (optional uint),
    created-at: uint
  }
)

(define-map cleaning-crews
  { crew: principal }
  {
    name: (string-ascii 100),
    specialization: (string-ascii 100),
    active: bool,
    total-jobs: uint,
    average-rating: uint,
    registered-at: uint
  }
)

;; Authorization Functions
(define-private (is-admin (user principal))
  (is-eq user (var-get contract-admin))
)

(define-private (is-registered-crew (user principal))
  (match (map-get? cleaning-crews { crew: user })
    crew-data (get active crew-data)
    false
  )
)

;; Bridge Management Functions
(define-public (register-bridge (name (string-ascii 100)) (location (string-ascii 200)) (cleaning-frequency uint) (priority-level uint))
  (let ((bridge-id (var-get next-bridge-id)))
    (asserts! (is-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len location) u0) ERR-INVALID-INPUT)
    (asserts! (> cleaning-frequency u0) ERR-INVALID-INPUT)
    (asserts! (and (>= priority-level u1) (<= priority-level u5)) ERR-INVALID-INPUT)

    (map-set bridges
      { bridge-id: bridge-id }
      {
        name: name,
        location: location,
        last-cleaning: u0,
        next-cleaning: u0,
        cleaning-frequency: cleaning-frequency,
        crew-assigned: none,
        priority-level: priority-level,
        created-by: tx-sender,
        created-at: block-height
      }
    )

    (var-set next-bridge-id (+ bridge-id u1))
    (ok bridge-id)
  )
)

(define-public (register-cleaning-crew (crew principal) (name (string-ascii 100)) (specialization (string-ascii 100)))
  (begin
    (asserts! (is-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len specialization) u0) ERR-INVALID-INPUT)

    (map-set cleaning-crews
      { crew: crew }
      {
        name: name,
        specialization: specialization,
        active: true,
        total-jobs: u0,
        average-rating: u0,
        registered-at: block-height
      }
    )

    (ok true)
  )
)

;; Cleaning Job Management Functions
(define-public (schedule-cleaning (bridge-id uint) (crew principal) (scheduled-date uint) (cleaning-type (string-ascii 50)))
  (let ((cleaning-id (var-get next-cleaning-id)))
    (asserts! (is-admin tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-some (map-get? bridges { bridge-id: bridge-id })) ERR-BRIDGE-NOT-FOUND)
    (asserts! (is-registered-crew crew) ERR-CREW-NOT-FOUND)
    (asserts! (> scheduled-date block-height) ERR-INVALID-INPUT)
    (asserts! (> (len cleaning-type) u0) ERR-INVALID-INPUT)

    (map-set cleaning-jobs
      { cleaning-id: cleaning-id }
      {
        bridge-id: bridge-id,
        crew: crew,
        scheduled-date: scheduled-date,
        completed-date: none,
        cleaning-type: cleaning-type,
        status: "scheduled",
        materials-used: none,
        cost: none,
        quality-rating: none,
        created-at: block-height
      }
    )

    ;; Update bridge with assigned crew
    (match (map-get? bridges { bridge-id: bridge-id })
      bridge-data (map-set bridges
        { bridge-id: bridge-id }
        (merge bridge-data { crew-assigned: (some crew), next-cleaning: scheduled-date })
      )
      false
    )

    (var-set next-cleaning-id (+ cleaning-id u1))
    (ok cleaning-id)
  )
)

(define-public (complete-cleaning (cleaning-id uint) (materials-used (string-ascii 200)) (cost uint) (quality-rating uint))
  (match (map-get? cleaning-jobs { cleaning-id: cleaning-id })
    cleaning-data
    (begin
      (asserts! (is-eq tx-sender (get crew cleaning-data)) ERR-NOT-AUTHORIZED)
      (asserts! (is-eq (get status cleaning-data) "scheduled") ERR-INVALID-INPUT)
      (asserts! (> (len materials-used) u0) ERR-INVALID-INPUT)
      (asserts! (> cost u0) ERR-INVALID-INPUT)
      (asserts! (and (>= quality-rating u1) (<= quality-rating u5)) ERR-INVALID-INPUT)

      ;; Update cleaning job record
      (map-set cleaning-jobs
        { cleaning-id: cleaning-id }
        (merge cleaning-data {
          completed-date: (some block-height),
          status: "completed",
          materials-used: (some materials-used),
          cost: (some cost),
          quality-rating: (some quality-rating)
        })
      )

      ;; Update bridge last cleaning
      (match (map-get? bridges { bridge-id: (get bridge-id cleaning-data) })
        bridge-data (map-set bridges
          { bridge-id: (get bridge-id cleaning-data) }
          (merge bridge-data { last-cleaning: block-height })
        )
        false
      )

      ;; Update crew stats
      (match (map-get? cleaning-crews { crew: (get crew cleaning-data) })
        crew-data
        (let ((new-total (+ (get total-jobs crew-data) u1))
              (current-avg (get average-rating crew-data))
              (new-avg (if (is-eq current-avg u0)
                         quality-rating
                         (/ (+ (* current-avg (get total-jobs crew-data)) quality-rating) new-total))))
          (map-set cleaning-crews
            { crew: (get crew cleaning-data) }
            (merge crew-data {
              total-jobs: new-total,
              average-rating: new-avg
            })
          )
        )
        false
      )

      (ok true)
    )
    ERR-CLEANING-NOT-FOUND
  )
)

(define-public (report-emergency-cleaning (bridge-id uint) (description (string-ascii 200)))
  (let ((cleaning-id (var-get next-cleaning-id)))
    (asserts! (is-some (map-get? bridges { bridge-id: bridge-id })) ERR-BRIDGE-NOT-FOUND)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)

    (map-set cleaning-jobs
      { cleaning-id: cleaning-id }
      {
        bridge-id: bridge-id,
        crew: tx-sender,
        scheduled-date: block-height,
        completed-date: none,
        cleaning-type: "emergency",
        status: "urgent",
        materials-used: (some description),
        cost: none,
        quality-rating: none,
        created-at: block-height
      }
    )

    (var-set next-cleaning-id (+ cleaning-id u1))
    (ok cleaning-id)
  )
)

;; Read-only Functions
(define-read-only (get-bridge (bridge-id uint))
  (map-get? bridges { bridge-id: bridge-id })
)

(define-read-only (get-cleaning-job (cleaning-id uint))
  (map-get? cleaning-jobs { cleaning-id: cleaning-id })
)

(define-read-only (get-cleaning-crew (crew principal))
  (map-get? cleaning-crews { crew: crew })
)

(define-read-only (get-next-bridge-id)
  (var-get next-bridge-id)
)

(define-read-only (get-next-cleaning-id)
  (var-get next-cleaning-id)
)
