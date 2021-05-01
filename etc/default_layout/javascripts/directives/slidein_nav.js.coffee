app = angular.module("app")

app.directive "slideinNav", [ '$window', '$document', ( $window, $document ) ->
  {
    restrict: "A"
    controller: 'slideinNavController'
    scope:
      src: "@"

    link: ($scope, $element, $attrs) ->
      $window = $(window)
      showingSlideinNav = false
      offset =  parseInt($attrs['offset'] || 0)

      angular.element($window).bind 'scroll', ->
        scrollTop    = $window.scrollTop()
        windowHeight = $window.height()

        if scrollTop < 800
          if showingSlideinNav
            # Hide nav
            showingSlideinNav = false
            $element.animate { top: -$element.height() + offset }, 200, 'easeInOutSine', ->
              $element.hide()

            $('body').removeClass 'mini-mast-showing'

        else if scrollTop >= 800
          unless showingSlideinNav
            # Show nav
            showingSlideinNav = true
            $element.css top: -$element.height() + offset
            $element.show()
            $element.animate { top: 0 + offset }, 200, 'easeInOutSine'

            $('body').addClass 'mini-mast-showing'


  }
]
