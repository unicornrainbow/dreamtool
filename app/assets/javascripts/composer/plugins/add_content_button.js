$(function() {
  $.fn.addContentButton = function(contentItemModal) {
    this.click(function() {
      $(".content-region-id", contentItemModal).val($(this).data("content-region-id"))
      contentItemModal.removeClass("hidden")
    });
  }
});
