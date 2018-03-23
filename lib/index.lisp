(uiop/package:define-package :google-maps-services/lib/index
                             (:nicknames :google-maps-services)
                             (:use
                              :google-maps-services/lib/internals/make-api-call
                              :cl
                              :google-maps-services/lib/internals/js-compat)
                             (:shadow) (:export) (:intern))
(in-package :google-maps-services/lib/index)
;;don't edit above

(defmacro makeApiMethod (name apiConfig)
  `(progn
     (export
      (defun ,name (query &optional customParams)
        (let ((apiConfig ,apiConfig)
              (*options* *options*))
          (setf query (funcall (getf apiConfig :validator) query))
          (setf (getf query :supportsClientId) (not (not (getf apiConfig :supportsClientId))))
          (setf (getf query :options) (getf apiConfig :options))
          (when (and (getf *options* :language)
                     (not (getf query :language)))
            (setf (getf query :language)
                  (getf *options* :language)))
          ;; Merge query and customParams.
          (let (finalQuery)
            (loop for obj in (list customParams query)
               do (loop for key in (sort (Object.keys obj) #'string<)
                     do (setf (getf finalQuery key) (getf obj key))))
            (makeApiCall (getf apiConfig :url) finalQuery)))))
     ',name))

(makeApiMethod geocode        google-maps-services/lib/apis/geocode:*geocode*)
(makeApiMethod reverseGeocode google-maps-services/lib/apis/geocode:*reversegeocode*)
