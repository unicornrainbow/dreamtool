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

//$(function() {
  //$(".add-page-btn").click(function() {
    //alert("Add Page")
  //});
//});

app = angular.module("app", ["templates"])

//angular.element(document).ready(function() {
  //angular.bootstrap(document, ['app']);
//});
//
$(function() {
  var editionTab   = $("#edition-tab"),
      sectionTab   = $("#section-tab"),
      editionPanel = $("#edition-tab-panel"),
      sectionPanel = $("#section-tab-panel"),
      editionCancel= $(".cancel", editionPanel),
      sectionCancel= $(".cancel", sectionPanel);

  editionPanel.hide();
  sectionPanel.hide();

  editionTab.click(function(){
    sectionTab.removeClass('active')
    sectionPanel.hide()

    editionTab.toggleClass('active');
    editionPanel.toggle();
  });

  sectionTab.click(function(){
    editionTab.removeClass('active')
    editionPanel.hide()

    sectionTab.toggleClass('active');
    sectionPanel.toggle();
  });

  editionCancel.click(function(e) {
    e.preventDefault();

    editionTab.removeClass('active')
    editionPanel.hide()
  });

  sectionCancel.click(function(e) {
    e.preventDefault();

    sectionTab.removeClass('active')
    sectionPanel.hide()
  });

  $('.add-section').click(function(){
    // 1. Add a list item at the end of the section nav stuff.
    // 2. Capture input until enter or escape.
    // 3. For each letter, add it tho the item
    // 4. On backspace, remove last letter.
    //
    // On escape, delete span and free keyboard.
    // On enter, post to backend, and free keyboard.
    //
  });

})
