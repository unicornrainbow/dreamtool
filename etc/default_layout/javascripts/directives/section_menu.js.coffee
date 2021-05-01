app = angular.module("app")

app.directive "sectionMenu", ->
  {
    restrict: "E"
    replace: true
    controller: 'sectionMenuController'
    templateUrl: 'section_menu.html'
    link: (scope, elem, attr, ctrl) ->
      elem.bind 'click', (e) ->
        scope.sectionMenu.menuVisible = !scope.sectionMenu.menuVisible
        elem.toggleClass('menu-open')
        scope.$apply()
  }
