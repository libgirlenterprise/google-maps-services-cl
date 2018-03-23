;;don't edit
(DEFSYSTEM "google-maps-services" :VERSION "0.0.1" :DEPENDS-ON (:DEXADOR :JONATHAN)
 :LICENSE "apache-2.0" :CLASS :PACKAGE-INFERRED-SYSTEM :COMPONENTS
 ((:FILE "lib/internals/make-url-request")
  (:FILE "lib/internals/make-api-call") (:FILE "lib/internals/js-compat")
  (:FILE "lib/internals/validate") (:FILE "lib/internals/convert")
  (:FILE "lib/apis/geocode") (:FILE "lib/apis/geolocation")
  (:FILE "lib/apis/timezone") (:FILE "lib/apis/directions")
  (:FILE "lib/apis/distance-matrix") (:FILE "lib/apis/elevation")
  (:FILE "lib/apis/roads") (:FILE "lib/apis/places") (:FILE "lib/index"))
 :AUTHOR "SANO Masatoshi" :MAILTO "snmsts@gmail.com")
