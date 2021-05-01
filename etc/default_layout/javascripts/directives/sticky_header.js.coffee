app = angular.module("app")

app.directive "stickyHeader", ->
  {
    restrict: "A"
    controller: 'StickyHeaderController'
    scope:
      src: "@"
  }
