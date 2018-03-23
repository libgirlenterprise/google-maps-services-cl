(uiop/package:define-package
 :google-maps-services/lib/internals/make-url-request (:use :cl))
(in-package :google-maps-services/lib/internals/make-url-request)
;;;don't edit above

(defun makeUrlRequest (url options)
  (let ((body)
        (headers (getf options :headers))
        (version (asdf:component-version (asdf:find-system :google-maps-services))))
    (multiple-value-bind (body
                          status
                          response-headers
                          uri)
        (dex:request (quri:render-uri url)
                     :method (or (getf options :method) :get)
                     :content (and body (jojo:to-json body))
                     :headers `(("User-agent" . ,(format nil "GoogleGeoApiClientCL/~A" version))
                                ,@headers))
      (cond ((equal (gethash "content-type" response-headers) "application/json; charset=UTF-8")
             (list :status status
                   :headers (loop
                               for k being the hash-keys in response-headers
                               using (hash-value v)
                               collect k
                               collect v)
                   :json (jojo:parse body)))
            (t (list body status
                      (loop
                         for k being the hash-keys in response-headers
                         using (hash-value v)
                         collect (format nil "~A:~A" k v))
                      uri))))))


