$(function() {
  $.fn.addPageButton = function() {
    var createPage = function(sectionID, opts) {
      // TODO: Do we need to be passing in the sectionID in two places?
      Newstime.Util.postForm("/sections/" + sectionID + "/pages", "post", { authenticity_token: Newstime.Composer.authenticityToken });
    }

    this.click(function() {
      createPage(composer.sectionID); // Temp solution, should be pulling this from the dom and using a directive.
    });
  }
});
