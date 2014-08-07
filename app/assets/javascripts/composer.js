// ## Libraries
//= require lib/zepto
//= require lib/underscore
//= require lib/backbone
//= require faye
//
// ## App
//= require newstime_util
//= require_tree ./composer/plugins
//= require_tree ./composer/views

var Newstime = Newstime || {};

Newstime.Composer = {
  init: function() {
    this.captureAuthenticityToken();

    //var composerModals = $(".composer-modal"),
        //contentRegionModal = $(".add-content-region"),
        //contentItemModal = $(".add-content-item").contentModal();

    var headlineProperties = new Newstime.HeadlinePropertiesView();

    // Initialize Plugins
    $('#edition-toolbar').editionToolbar();
    $('#section-nav').sectionNav();
    $('[headline-control]').headlineControl(headlineProperties);

    var storyPropertiesView = new Newstime.StoryPropertiesView();
    $('[story-text-control]').each(function(i, el) {
      new Newstime.StoryTextControlView({el: el, toolPalette: storyPropertiesView});
    });

    var contentRegionPropertiesView = new Newstime.ContentRegionPropertiesView();
    $('[content-region-control]').each(function(i, el) {
      new Newstime.ContentRegionControlView({el: el, propertiesView: contentRegionPropertiesView});
    });

    var photoPropertiesView = new Newstime.PhotoPropertiesView();
    $('[photo-control]').each(function(i, el) {
      new Newstime.PhotoControlView({el: el, propertiesView: photoPropertiesView});
    });

    $('[page-compose]').each(function(i, el) {
      new Newstime.PageComposeView({el: el});
    });

    //$(".add-page-btn").addPageButton()
    //$(".add-content-region-btn").addContentRegionButton(contentRegionModal)
    //$(".add-content-btn").addContentButton(contentItemModal)

    //$(".composer-modal-dismiss").click(function(){
      //composerModals.addClass("hidden");
    //});

    // Create Vertical Rule
    //verticalRulerView = new Newstime.VerticalRulerView()
    //$('body').append(verticalRulerView.el);


    //log = console.log;  // example code, delete if you will.
    //console.log = function(message) {
      //log.call(console, message);
    //}
    //console.log("Tapping into console.log");


  },

  captureAuthenticityToken: function() {
    this.authenticityToken = $("input[name=authenticity_token]").first().val();
  }
}


$(function() { Newstime.Composer.init(); });
