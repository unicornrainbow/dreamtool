$(function() {
  $.fn.addContentRegionButton = function(contentRegionModal) {

    this.click(function() {
      var pageID = $(this).data("page-id");
      var rowSequence = $(this).data("row-sequence");

      // Set hidden form field values
      $("[name='content_region[page_id]']", contentRegionModal).val(pageID);
      $("[name='content_region[row_sequence]']", contentRegionModal).val(rowSequence);

      contentRegionModal.removeClass("hidden");
    });

  }

});
