(uiop/package:define-package :google-maps-services/lib/apis/geocode
                             (:use :cl :google-maps-services/lib/internals/convert
                                   :google-maps-services/lib/internals/validate)
                             (:shadow) (:export :*reversegeocode* :*geocode*)
                             (:intern))
(in-package :google-maps-services/lib/apis/geocode)
;;;don't edit above

#|
 | Makes a geocode request.
 |
 | @name GoogleMapsClient#geocode
 | @function
 | @param {Object} query
 | @param {string} [query.address]
 | @param {Object} [query.components]
 | @param {Object} [query.bounds]
 | @param {number} query.bounds.south
 | @param {number} query.bounds.west
 | @param {number} query.bounds.north
 | @param {number} query.bounds.east
 | @param {string} [query.region]
 | @param {string} [query.language]
 | @param {ResponseCallback} callback Callback function for handling the result
 | @return {RequestHandle}
 |#

(defvar *geocode* (list
                   :url "https://maps.googleapis.com/maps/api/geocode/json"
                   :validator (v.object (list
                                         :address (v.optional v.string)
                                         :components (v.optional utils.pipedKeyValues)
                                         :bounds (v.optional utils.bounds)
                                         :region (v.optional v.string)
                                         :language (v.optional v.string)
                                         :retryOptions (v.optional utils.retryOptions)
                                         :timeout (v.optional v.number)))))

#|
 | Makes a reverse geocode request.
 |
 | @name GoogleMapsClient#reverseGeocode
 | @function
 | @param {Object} query
 | @param {LatLng} [query.latlng]
 | @param {string} [query.place_id]
 | @param {string} [query.result_type]
 | @param {string} [query.location_type]
 | @param {string} [query.language]
 | @param {ResponseCallback} callback Callback function for handling the result
 | @return {RequestHandle}
 |#
(defvar *reverseGeocode* (list
                          :url "https://maps.googleapis.com/maps/api/geocode/json"
                          :validator (v.compose (list
                                                 (v.mutuallyExclusiveProperties (list :place_id :latlng))
                                                 (v.mutuallyExclusiveProperties (list :place_id :result_type))
                                                 (v.mutuallyExclusiveProperties (list :place_id :location_type))
                                                 (v.object (list
                                                            :latlng (v.optional utils.latLng)
                                                            :place_id (v.optional v.string)
                                                            :result_type (v.optional (utils.pipedArrayOf v.string))
                                                            :location_type (v.optional (utils.pipedArrayOf
                                                                                        (v.oneOf (list
                                                                                                  :ROOFTOP :RANGE_INTERPOLATED :GEOMETRIC_CENTER
                                                                                                  :APPROXIMATE))))
                                                            :language (v.optional v.string)
                                                            :retryOptions (v.optional utils.retryOptions)
                                                            :timeout (v.optional v.number)))))))
