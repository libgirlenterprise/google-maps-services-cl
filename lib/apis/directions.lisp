(uiop/package:define-package :google-maps-services/lib/apis/directions
                             (:use :cl :google-maps-services/lib/internals/convert
                                   :google-maps-services/lib/internals/validate)
                             (:shadow) (:export )
                             (:intern))
(in-package :google-maps-services/lib/apis/directions)
;;;don't edit above

#|
 | Makes a directions request.
 |
 | @name GoogleMapsClient#directions
 | @function
 | @param {Object} query
 | @param {LatLng} query.origin
 | @param {LatLng} query.destination
 | @param {string} [query.mode]
 | @param {LatLng[]} [query.waypoints]
 | @param {boolean} [query.alternatives]
 | @param {string[]} [query.avoid]
 | @param {string} [query.language]
 | @param {string} [query.units]
 | @param {string} [query.region]
 | @param {Date|number} [query.departure_time]
 | @param {Date|number} [query.arrival_time]
 | @param {string} [query.traffic_model]
 | @param {string[]} [query.transit_mode]
 | @param {string} [query.transit_routing_preference]
 | @param {boolean} [query.optimize]
 | @param {ResponseCallback} callback Callback function for handling the result
 | @return {RequestHandle}
|#
(defvar *directions* (list
                      :url "https://maps.googleapis.com/maps/api/directions/json"
                      :validator (v.compose (list
                                             (v.mutuallyExclusiveProperties (list :arrival_time  :departure_time))
                                             (v.object (list
                                                        :origin utils.latLng
                                                        :destination utils.latLng
                                                        :mode (v.optional (v.oneOf (list
                                                                                    :driving  :walking :bicycling :transit)))
                                                        :waypoints (v.optional (utils.pipedArrayOf utils.latLng))
                                                        :alternatives  (v.optional v.boolean)
                                                        :avoid (v.optional (utils.pipedArrayOf (v.oneOf(list
                                                                                                        :tolls :highways :ferries :indoor))))
                                                        :language (v.optional v.string)
                                                        :units (v.optional (v.oneOf (list
                                                                                     :metric :imperial)))
                                                        :region (v.optional v.string)
                                                        :departure_time (v.optional utils.timeStamp)
                                                        :arrival_time (v.optional utils.timeStamp)
                                                        :traffic_model (v.optional (v.oneOf (list
                                                                                             :best_guess :pessimistic :optimistic)))
                                                        :transit_mode (v.optional (utils.pipedArrayOf (v.oneOf (list
                                                                                                                :bus :subway :train :tram :rail))))
                                                        :transit_routing_preference (v.optional (v.oneOf (list
                                                                                                          :less_walking :fewer_transfers)))
                                                        :optimize (v.optional v.boolean)
                                                        :retryOptions (v.optional utils.retryOptions)
                                                        :timeout (v.optional v.number)
                                                        ))
                                             (lambda (query)
                                               (when (and (getf query :waypoints)
                                                          (getf query :optimize))
                                                 (setf (getf query :waypoints) (format nil "optimize:true|~A" (getf query :waypoints))))

                                               #|
                                               delete query.optimize; ;
                                               
                                               if (query.waypoints && query.mode === 'transit') {
                                               throw new v.InvalidValueError('cannot specify waypoints with transit'); ;
                                               }
                                               
                                               if (query.traffic_model && !query.departure_time) {
                                               throw new v.InvalidValueError('traffic_model requires departure_time'); ;
                                               }
                                               return query
                                               |#
                                               )))))
