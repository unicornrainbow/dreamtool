app = angular.module("app")

app.controller "sectionMenuController", ['$scope', '$element', '$attrs', ($scope, $element, $attrs) ->
  #$element.hide()
  #$element.addClass('slidein-nav')
  $scope.sectionMenu = {}
  $scope.sectionMenu.menuVisible = false


]
