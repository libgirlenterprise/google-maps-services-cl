(uiop/package:define-package :google-maps-services/lib/internals/validate
                             (:nicknames) (:use :google-maps-services/lib/internals/js-compat :cl) (:shadow)
                             (:export)
                             (:intern))
(in-package :google-maps-services/lib/internals/validate)
;;;don't edit above
(define-condition InvalidValueError (error)
  ((message :initarg :message)
   (name :initarg :name))
  (:report (lambda (condition stream)
             (with-slots (message name) condition
               (format stream
                       "~A~:[~;~:* (~A)~]"
                       message name)))))

(defun v.InvalidValueError (message)
  (error 'InvalidValueError :name 'InvalidValueError :message message))

(defun acceptAll (value)
  value)

(define v.optional (validator)
  (lambda (value)
    (if (null value) ;; origin (value == undefined)
        value
        (funcall validator value))))

(defun that (predicate message)
  (lambda (value)
    (if (funcall predicate value)
        value
        (v.InvalidValueError message))))

(define v.number (that 
                  (lambda (value) 
                    (typep value 'number))
                  "not a number"))

(define v.string
    (that
     (lambda (value)
       (typep value 'string))
     "not a string"))

(define v.object
    (lambda (propertyValidators)
      (lambda (object)
        (let ((result '()))
          (unless (loop for i in object by 'cddr
                     always (keywordp i))
            (v.InvalidValueError "not an Object"))
          ;; Validate all properties.
          (loop for key in propertyValidators by 'cddr
             for validator = (getf propertyValidators key)
             for valid =
               (prog1
                   (funcall validator (getf object key))
                 '(if (getf object key)
                   (throw InvalidValueError.prepend("in property \"" + key + "\"" error))
                   (throw new InvalidValueError("missing property \"" + key + "\""))))
             do (when valid
                  (setf (getf result key) valid)))
          ;; Check for unexpected properties.
          (loop for key in object by 'cddr
             unless (getf propertyValidators key)
             do (progn '(throw new InvalidValueError("unexpected property \"" + key + "\""))))
          result))))

(define v.array (validator)
  (lambda (array)
    (unless (listp array)
      (v.InvalidValueError "not an Array"))
    (loop for i from 0
       for e in array
       collect (funcall validator e)
       ;;InvalidValueError.prepend('at index ' + i, error)
         )))

(define v.oneOf (names)
  (let ((myObject ())
        (quotedNames ()))
    (loop for name in names
       do (setf (getf myObject name) t)
         (push (format nil "\"~A\"" name) quotedNames))
    (lambda (value)
      (or (getf myObject value)
          (v.InvalidValueError (format nil "not one of ~A" (join quotedNames ", ")))))))

(define v.mutuallyExclusiveProperties (names)
  (lambda (value)
    (when value
      (let ((present ()))
        (loop for name in names
           do (when (getf value name)
                (push (format nil "\"~A\"" name) present)))
        (when (> (length present) 1)
          (v.InvalidValueError "cannot specify properties ")
          ;;+ present.slice(0, -1).join(', ')
          ;;+ ' and '
          ;;+ present.slice(-1)
          ;;+ ' together')
          )
        value))))

(define v.compose (validators)
  (lambda (value)
    (loop for validate in validators
       do (setf value (funcall validate value)))
    value))

(define v.boolean (v.compose (list
                              (that (lambda (value)
                                      (or (eql t value)
                                          (eql nil value)))
                                    "not a boolean")
                              (lambda (value)
                                ;; In each API, boolean fields default to false, and the presence of
                                ;; a querystring value indicates true, so we omit the value if
                                ;; explicitly set to false.
                                (if value value nil)))))
