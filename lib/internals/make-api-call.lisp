(uiop/package:define-package :google-maps-services/lib/internals/make-api-call
                             (:nicknames) (:use :cl) (:shadow)
                             (:export :makeapicall :*options*) (:intern))
(in-package :google-maps-services/lib/internals/make-api-call)
;;don't edit above

(defvar *options* nil)

(defun str.indexOf (obj a)
  (loop with len = (length a)
     for i from 0 to (- (length obj) len)
     when (string= obj a :start1 i :end1 (+ i len))
     do (return i)))

#|
 * @param {string} secret
 * @param {string} payload
 * @return {string}
 |#
(defun computeSignature(secret payload)
  #|
  var signature =
  new Buffer(
             require('crypto')
             .createHmac('sha1', secret)
             .update(payload)
             .digest('base64'))
  .toString()
  .replace(/\+/g, '-')
  .replace(/\//g, '_')
  .replace(/=+$/, '')                   ;
  while (signature.length % 4) {
  signature += '='                      ;
  }
  signature
  |#
  )

 #|
  * Adds auth information to the query, and formats it into a URL.
  * @param {string} path
  * @param {Object} query
  * @param {boolean} useClientId
  * @return {string} The formatted URL.
  |#

(defun makeApiCall (path query)
  (let* ((options *options*)
         Task
         (key (or (getf options :key) (uiop:getenv "GOOGLE_MAPS_API_KEY")))
         (channel (getf options :channel))
         (clientId (or (getf options :clientId) (uiop:getenv "GOOGLE_MAPS_API_CLIENT_ID;")))
         (clientSecret (or (getf options :clientSecret) (uiop:getenv "GOOGLE_MAPS_API_CLIENT_SECRET")))

         (rate (getf options :rate))
         (rateLimit (or (getf rate :limit) 50)) ;;50 requests per ratePeriod.
         (ratePeriod (or (getf rate :period) 1000)) ;; 1 second.

         (makeUrlRequest (getf options :makeUrlRequest)) ;;require('./make-url-request')
         (mySetTimeout (or (getf options :setTimeout)
                           (lambda (fn ms &rest params) (sleep (* ms 0.001)) (apply fn params))))
         (myClearTimeout (or (getf options :clearTimeout)
                             (lambda(x) (declare (ignore x)))))
         (getTime (or (getf options :getTime)
                      (lambda () (* (- (get-universal-time) (* 70 365 24 60 60)) 1000))))
         (wait) ;;= require('./wait').inject(mySetTimeout, myClearTimeout);
         (attempt ) ;;require('./attempt').inject(wait).attempt;
         (ThrottledQueue) ;;require('./throttled-queue').inject(wait, getTime);
         (requestQueue)) ;;ThrottledQueue.create(rateLimit, ratePeriod);
    (let* ((retryOptions (or (getf query :retryOptions)
                             (getf options :retryOptions)
                             '()))
           (timeout (or (getf query :timeout)
                        (getf options :timeout)
                        (* 60 1000)))
           (useClientId (and (getf query :supportsClientId)
                             clientId
                             clientSecret))
           (queryOptions (or (getf query :options)))
           (isPost (equal (getf queryOptions :method) "POST"))
           (requestUrl (flet ((formatRequestUrl (path query useClientId)
                                (when channel
                                  (setf (getf query :channel) channel))
                                (if useClientId
                                    (setf (getf query :client) clientId)
                                    (if (and key (= 0 (str.indexOf key "AIza")))
                                        (setf (getf query :key) key)
                                        (error "Missing either a valid API key, or a client ID and secret")))
                                (let ((requestUrl (quri:make-uri :path path :query
                                                                 (loop for (i j) on query
                                                                    by #'cddr
                                                                    when j
                                                                    collect (cons (string-downcase i) j)))))
                                  ;; When using client ID, generate and append the signature param.
                                  (when useClientId
                                    (error "WIP  client ID")
                                    ;;var secret = new Buffer(clientSecret "base64")
                                    ;;var payload = url.parse(requestUrl).path
                                    ;;var signature = computeSignature(secret payload)
                                    ;;requestUrl += "&signature=" + (encodeURIComponent signature)
                                    )
                                  requestUrl)))
                         (formatRequestUrl path (if isPost ()  query) useClientId)))
           ;; Determines whether a response indicates a retriable error.
           (canRetry (or (getf queryOptions :canRetry)
                         (lambda (response)
                           (or
                            (null response)
                            (= (getf response :status) 500)
                            (= (getf response :status) 503)
                            (= (getf response :status) 504)
                            (and (getf response :json)
                                 (or 
                                  (equal (getf (getf response :json) :status) "OVER_QUERY_LIMIT")
                                  (equal (getf (getf response :json) :status) "RESOURCE_EXHAUSTED")))))))
           ;; Determines whether a response indicates success.
           (isSuccessful (or (getf queryOptions :isSuccessful)
                             (lambda (response) 
                               (and (= (getf response :status) 200)
                                    (or (null (getf response :json)) 
                                        (null (getf (getf response :json) :status))
                                        (equal (getf (getf response :json) :status) "OK")
                                        (equal (getf (getf response :json) :status) "ZERO_RESULTS")))))))
      #|
      | Makes an API request using the injected makeUrlRequest.
      |
      | Inserts the API key (or client ID and signature) into the query
      | parameters. Retries requests when the status code requires it.
      | Parses the response body as JSON.
      |
      | The callback is given either an error or a response. The response
      | is an object with the following entries:
      | {
      |   status: number,
      |   body: string,
      |   json: Object
      | }
      |
      | @param {string} path
      | @param {Object} query This function mutates the query object.
      | @param {Function} callback
      | @return {{
      |   cancel: function(),
      |   finally: function(function()),
      |   asPromise: function(): Promise
      | }}
      |#
      (setf query (remf query :retryOptions)
            query (remf query :timeout)
            query (remf query :supportsClientId)
            query (remf query :options)
            query (remf queryOptions :canRetry)
            queryOptions (remf queryOptions :isSuccessful))
      (when isPost
        (setf (getf queryOptions :body) query))
      (labels (#+nil
               (rateLimitedGet ()
                 (requestQueue.add
                  (lambda () 
                    (Task.start (lambda (resolve reject)
                                  (makeUrlRequest requestUrl resolve reject queryOptions)))))))
        (google-maps-services/lib/internals/make-url-request::makeUrlRequest requestUrl queryOptions)
        
        #|
      var timeoutTask = wait(timeout).thenDo(function() {
        throw 'timeout'
        })
      var requestTask = attempt({
        'do': rateLimitedGet,
        until: function(response) { return !canRetry(response) ; }, ;
        interval: retryOptions.interval,
        increment: retryOptions.increment,
        jitter: retryOptions.jitter
        })

      var task =
      Task.race([timeoutTask, requestTask])
      .thenDo(function(response) {
        // We add the request url and the original query to the response
        // to be able to use them when debugging errors.
        response.requestUrl = requestUrl
        response.query = query

        if (isSuccessful(response)) {
        return Task.withValue(response)
        } else {
        return Task.withError(response)
        }
        })
      .thenDo(
        function(response) { callback(null, response) ; }, ;
        function(err) { callback(err)                 ; }) ;

        if (options.Promise) {
        var originalCallback = callback 
        var promise = new options.Promise(function(resolve, reject) {
        callback = function(err, result) {
        if (err != null) {
        reject(err)
        } else {
        resolve(result)
        }
        originalCallback(err, result)
        }
        })
        task.asPromise = function() { return promise ; } ;
        }

        delete task.thenDo
        return task
        |#
        ))))
