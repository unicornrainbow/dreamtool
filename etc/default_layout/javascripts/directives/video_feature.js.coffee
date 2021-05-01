app = angular.module("app")

app.directive "videoFeature", [ '$window', '$document', ( $window, $document ) ->
  {
    restrict: "E"
    replace: true
    controller: 'videoFeatureController'
    templateUrl: 'video_feature.html'
    scope:
      src: "@"
      thumbnail: "@"
  }
]
