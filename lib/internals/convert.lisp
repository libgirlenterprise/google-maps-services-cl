(uiop/package:define-package :google-maps-services/lib/internals/convert
                             (:nicknames)
                             (:use
                              :google-maps-services/lib/internals/js-compat
                              :google-maps-services/lib/internals/validate :cl)
                             (:shadow)
                             (:export)
                             (:intern))
(in-package :google-maps-services/lib/internals/convert)
;;;don't edit above

(defun asArray (arg)
  (if (listp arg)
      arg
      (list arg)))

(define utils.pipedKeyValues (arg)
  (etypecase arg
    (hash-table
     (format nil "~{~A~^|~}"
             (loop
                for k being the hash-keys in arg
                using (hash-value v)
                collect (format nil "~A:~A" k v))))
    (list
     (format nil "~{~A:~A~^|~}" arg))))

(define utils.locations (arg)
  (when (and (listp arg)
             (= (length arg) 2)
             (numberp (first arg))
             (numberp (second arg)))
    (setf arg (list arg)))
  (join (mapcar 'utils.latLng (asArray arg)) "|"))


(define utils.pipedArrayOf (validateItem)
  (let ((validateArray (v.array validateItem)))
    (lambda (value)
      (join (funcall validateArray (asArray value)) "|"))))


(define utils.latLng (arg)
  (cond ((not arg)
         (v.InvalidValueError""))
        ((and (getf arg :lat)
              (getf arg :lng))
         (setf arg (list (getf arg :lat)
                         (getf arg :lng))))
        ((and (getf arg :latitude)
              (getf arg :longitude))
         (setf arg (list (getf arg :latitude)
                         (getf arg :longitude)))))
  (join (asArray arg)","))


(defparameter validateBounds
  (v.object (list
             :south v.number
             :west v.number
             :north v.number
             :east v.number)))

(define utils.bounds (arg)
  (setf arg (funcall validateBounds arg))
  (format nil "~@{~A~}"
          (getf arg :south) ","
          (getf arg :west) "|"
          (getf arg :north) ","
          (getf arg :east)))


(define utils.timeStamp (arg)
  #|
  if (arg == undefined) {
  arg = new Date()                      
  }
  if (arg.getTime) {
  arg = arg.getTime()
  // NOTE: Unix time is seconds past epoch.
  return Math.round(arg / 1000)
  }

  // Otherwise assume arg is Unix time
  return arg
  |#
  nil
  )

(define utils.retryOptions
    (v.object
     (list
      :timeout (v.optional v.number)
      :interval (v.optional v.number)
      :increment (v.optional v.number)
      :jitter (v.optional v.number))))
