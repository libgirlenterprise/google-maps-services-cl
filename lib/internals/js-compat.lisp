(uiop/package:define-package :google-maps-services/lib/internals/js-compat
                             (:nicknames) (:use :cl) (:shadow) (:export :join :define :Object.keys)
                             (:intern))
(in-package :google-maps-services/lib/internals/js-compat)
;;;don't edit above

(defun join (x s)
  (format nil (format nil "~~{~~A~~^~A~~}" s) x))

(defmacro define (symbol lambda-list &body body)
  `(progn
     ,(if (not body)
          `(setf (fdefinition ',symbol) ,lambda-list)
          `(defun ,symbol ,lambda-list
             ,@body))
     (export (defparameter ,symbol #',symbol))))

(defun Object.keys (x)
  (loop for i in x by 'cddr
       collect i))
