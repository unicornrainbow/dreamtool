$(function() {
  $.fn.sectionNav = function() {

    var addSection  = $('.add-section'),
        sectionsNav = $('.sections-nav'),
        authenticityToken = Newstime.Composer.authenticityToken;

    // Handle Add Section Click
    addSection.click(function(e){
      e.preventDefault();
      e.stopPropagation();

      var input = $(" <input class='section-nav-input' type='text'></input> ");
      addSection.before(input);

      addSection.hide();

      link = $("<a href=''></a>");
      span = $(" <span class='section-nav-input-span for-size'></span> ");
      span.html(link);
      addSection.before(span);
      span.addClass('for-sizing');

      input.focus();

      var cancel = function() {
        input.remove();
        span.remove();
      }

      var createSection = function(editionID, sectionName, opts) {
        // TODO: Do we need to be passing in the editionID in two places?
        var url         = "/editions/" + editionID + "/sections";
        var sectionPath = sectionName + ".html"
        $.ajax({
          type: "POST",
          url: url,
          data: {
            authenticity_token: authenticityToken,
            section: {
              name: sectionName,
              path: sectionPath,
              sequence: 100,
              edition_id: editionID
            }
          },
          dataType: 'json'
        });
      }

      $document = $(document);
      var submit = function() {
        var sectionName = input.val();
        if (sectionName == '') {
          cancel();
        } else {
          var value = input.val();

          input.remove()

          link.html(value);
          link.attr({'href': value + ".html"});

          span.removeClass('for-sizing');

          addSection.before(" "); // Induce proper spacing.
          addSection.show();

          createSection(composer.editionID, sectionName);
        }
      }

      var resize = function() {
        // Measure Invisible Span.
        link.text(input.val());
        input.css({'width': link.width() + 15 + 'px'});
      }

      // ESC to Cancel, Enter to submit.
      $(input).keyup(function(e){
        switch(e.keyCode) {
          case 27: // ESC
            cancel();
            break;
          case 13: // ENTER
            submit();
            break;
          default:
            resize();
        }
      });

    });
  }
});
