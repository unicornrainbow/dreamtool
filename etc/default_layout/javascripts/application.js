// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//
//= require jquery
//= require jquery_ujs
//
//= require angular
//= require_self
//= require_tree ./templates
//= require_tree ./controllers
//= require_tree ./directives
//
//= require lib/jquery.easing

try {
  angular.module("app"); // Check for app module.
} catch(err) {
  angular.module("app", ["templates"]); // Otherwise create it.
}

// Disabling the grid for now...
//$(document).keypress(function(event) {
  //// Map t to toggle grid.
  //if (event.which == 116) {
    //$('.grid-overlay').toggle();
    //event.preventDefault();
  //}
//});

//$(function() {
  //// Toggle to hide grid, handy during dev, remove for release.
  //$('.grid-overlay').hide();
//});


$(function() {
  var hash;
  hash = window.location.hash.substring(1);
  $(".anchor-" + hash.replace('/', '-')).addClass('anchor-highlight');
})

$(function() {
  $('.video-feature').click(function() {
    $(this).addClass('active')
    $('video', this)[0].play()
  });
});
