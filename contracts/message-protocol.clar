;; Message Protocol Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-parameters (err u101))

;; Data Variables
(define-data-var protocol-counter uint u0)
(define-map message-protocols uint {
    name: (string-ascii 50),
    description: (string-utf8 500),
    creator: principal,
    active: bool
})

;; Public Functions
(define-public (create-protocol (name (string-ascii 50)) (description (string-utf8 500)))
    (let ((protocol-id (+ (var-get protocol-counter) u1)))
        (map-set message-protocols protocol-id {
            name: name,
            description: description,
            creator: tx-sender,
            active: true
        })
        (var-set protocol-counter protocol-id)
        (ok protocol-id)
    )
)

(define-public (update-protocol (protocol-id uint) (new-description (string-utf8 500)))
    (let ((protocol (unwrap! (map-get? message-protocols protocol-id) err-invalid-parameters)))
        (asserts! (is-eq (get creator protocol) tx-sender) err-owner-only)
        (map-set message-protocols protocol-id (merge protocol {
            description: new-description
        }))
        (ok true)
    )
)

(define-public (toggle-protocol (protocol-id uint))
    (let ((protocol (unwrap! (map-get? message-protocols protocol-id) err-invalid-parameters)))
        (asserts! (is-eq (get creator protocol) tx-sender) err-owner-only)
        (map-set message-protocols protocol-id (merge protocol {
            active: (not (get active protocol))
        }))
        (ok true)
    )
)

;; Read-only Functions
(define-read-only (get-protocol (protocol-id uint))
    (map-get? message-protocols protocol-id)
)

(define-read-only (get-protocol-count)
    (var-get protocol-counter)
)

