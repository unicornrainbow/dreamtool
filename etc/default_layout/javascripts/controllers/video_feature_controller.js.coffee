app = angular.module("app")

app.controller "videoFeatureController", ['$scope', '$element', '$attrs', ($scope, $element, $attrs) ->
  #$element.hide()
  #$element.addClass('slidein-nav')
  video = $element.find('video')


  #$element.show()
  $scope.beginVideo = ->
    $element.toggleClass('active')
    video[0].play()


  #console.log $element.css top: '0', position: 'absolute'
  # On each scroll, update the position of all in range objects.
  # Get reference to element
  # Detect when element hits top of page.
  #   Lock position
  # Detect when next element in chain touches the bottom
  #   move the touched on up
  #
  # Free the pushed one, lock the new one, repeat.
  #

]
