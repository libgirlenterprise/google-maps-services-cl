(uiop/package:define-package :google-maps-services/lib/apis/geolocation
                             (:use :cl :google-maps-services/lib/internals/convert
                                   :google-maps-services/lib/internals/validate)
                             (:shadow) (:export :*geolocate*)
                             (:intern))
(in-package :google-maps-services/lib/apis/geolocation)
;;;don't edit above

#|
 | Makes a geolocation request.
 |
 | For a detailed guide, see https://developers.google.com/maps/documentation/geolocation/intro
 |
 | @name GoogleMapsClient#geolocate
 | @function
 | @param {Object} query
 | @param {number} [query.homeMobileCountryCode]
 | @param {number} [query.homeMobileNetworkCode]
 | @param {string} [query.radioType]
 | @param {string} [query.carrier]
 | @param {boolean} [query.considerIp]
 | @param {Object[]} [query.cellTowers]
 | @param {Object[]} [query.wifiAccessPoints]
 | @param {ResponseCallback} callback Callback function for handling the result
 | @return {RequestHandle}
 |#

(defvar *geolocate* (list
                     :url "https://www.googleapis.com/geolocation/v1/geolocate"
                     :options (list
                               :method :post
                               :headers `(("content-type" . "application/json"))
                               :canRetry  (lambda (response) {
                                                  (= (getf response :status) 403))
                               :isSuccessful (lambda (response)
                                               (or (= (getf response :status) 200)
                                                   (= (getf response :status) 404))))
                     :validator (v.object (list
                                           :homeMobileCountryCode (v.optional v.number)
                                           :homeMobileNetworkCode (v.optional v.number)
                                           :radioType (v.optional v.string)
                                           :carrier (v.optional v.string)
                                           :considerIp (v.optional v.boolean)
                                           :cellTowers (v.optional (v.array (v.object (list
                                                                                       :cellId v.number
                                                                                       :locationAreaCode v.number
                                                                                       :mobileCountryCode v.number
                                                                                       :mobileNetworkCode v.number
                                                                                       :age (v.optional v.number)
                                                                                       :signalStrength (v.optional v.number)
                                                                                       :timingAdvance (v.optional v.number)))))
                                           :wifiAccessPoints (v.optional (v.array (v.object(list
                                                                                            :macAddress v.string
                                                                                            :signalStrength (v.optional v.number)
                                                                                            :age (v.optional v.number)
                                                                                            :channel (v.optional v.number)
                                                                                            :signalToNoiseRatio (v.optional v.number)))))
                                           :retryOptions (v.optional utils.retryOptions)
                                           :timeout (v.optional v.number)
                                           ))))
