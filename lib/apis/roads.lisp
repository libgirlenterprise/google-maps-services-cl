(uiop/package:define-package :google-maps-services/lib/apis/roads (:use :cl))
(in-package :google-maps-services/lib/apis/roads)
;;;don't edit above

#|
/**
 * Makes a snap-to-roads request.
 *
 * @name GoogleMapsClient#snapToRoads
 * @function
 * @param {Object} query
 * @param {LatLng[]} query.path
 * @param {boolean} [query.interpolate]
 * @param {ResponseCallback} callback Callback function for handling the result
 * @return {RequestHandle}
 */
exports.snapToRoads = {
  url: 'https://roads.googleapis.com/v1/snapToRoads',
  supportsClientId: false,
  validator: v.object({
    path: utils.pipedArrayOf(utils.latLng),
    interpolate: v.optional(v.boolean),
    retryOptions: v.optional(utils.retryOptions),
    timeout: v.optional(v.number)
  })
};

/**
 * Makes a nearest roads request.
 *
 * @name GoogleMapsClient#nearestRoads
 * @function
 * @param {Object} query
 * @param {LatLng[]} query.points
 * @param {ResponseCallback} callback Callback function for handling the result
 * @return {RequestHandle}
 */
exports.nearestRoads = {
  url: 'https://roads.googleapis.com/v1/nearestRoads',
  supportsClientId: false,
  validator: v.object({
    points: utils.pipedArrayOf(utils.latLng),
    retryOptions: v.optional(utils.retryOptions),
    timeout: v.optional(v.number)
  })
};

/**
 * Makes a speed-limits request for a place ID. For speed-limits
 * requests using a path parameter, use the snappedSpeedLimits method.
 *
 * @name GoogleMapsClient#speedLimits
 * @function
 * @param {Object} query
 * @param {string[]} query.placeId
 * @param {string} [query.units] Either 'KPH' or 'MPH'
 * @param {ResponseCallback} callback Callback function for handling the result
 * @return {RequestHandle}
 */
exports.speedLimits = {
  url: 'https://roads.googleapis.com/v1/speedLimits',
  supportsClientId: false,
  validator: v.object({
    placeId: v.array(v.string),
    units: v.optional(v.oneOf(['KPH', 'MPH'])),
    retryOptions: v.optional(utils.retryOptions),
    timeout: v.optional(v.number)
  })
};

/**
 * Makes a speed-limits request for a path.
 *
 * @name GoogleMapsClient#snappedSpeedLimits
 * @function
 * @param {Object} query
 * @param {LatLng[]} query.path
 * @param {string} [query.units] Either 'KPH' or 'MPH'
 * @param {ResponseCallback} callback Callback function for handling the result
 * @return {RequestHandle}
 */
exports.snappedSpeedLimits = {
  url: 'https://roads.googleapis.com/v1/speedLimits',
  supportsClientId: false,
  validator: v.object({
    path: utils.pipedArrayOf(utils.latLng),
    units: v.optional(v.oneOf(['KPH', 'MPH'])),
    retryOptions: v.optional(utils.retryOptions),
    timeout: v.optional(v.number)
  })
};
|#
