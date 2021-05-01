$(function() {

  $.fn.contentModal = function() {
    contentItemModal = this,
    contentItemModalForm = $("form", contentItemModal);

    // HACK: This entire file needs to be designed and rewritten when the
    // prototype is done. I'm doing it this was to save time upfront.
    var handelContentItemTypeChange = function() {
      var contentRegionID = $(".content-region-id", contentItemModal).val(); // Capture content region id until we get to crazy.
      var type = $(this).val();
      $.ajax({
        type: "GET",
        url: "/content_items/form",
        data: { type: type },
        dataType: 'html',
        success: function(html){
          contentItemModalForm = $(html).replaceAll(contentItemModalForm) // Replace form

          // Rewire and reset content-region-id
          $(".content-region-id", contentItemModal).val(contentRegionID);
          $(".type-selector", contentItemModalForm).change(handelContentItemTypeChange);
        }
      });
    }

    $(".type-selector", contentItemModalForm).change(handelContentItemTypeChange);

    return this;
  }
});
