
var App = Dreamtool;

var MobilePropertiesPanelView = App.View.extend({

  className: "mobile-properties-panel",

  initialize: function() {
    this.$addClass('newstime-properties-panel');
    this.$hide()
    this.$html(
      "" +
      "" +
      "");
    this.enabled = true;
  },

  send: function(msg, ...args) {
    var fish = this[msg];
    if (fish && typeof fish == 'function') {
      fish(...args);
    } else {
      this.methodMissing(msg, ...args);
    }
  },

  methodMissing: function(name, ...args) {
    if (name.match(/^\$(.*)$/)) {
      return this.$prop(name);
    }

  },

  $prop: function (name) {
    var fish = this[name];
    if (fish) {

    }
  },


  render: function() {

  },

  mount: function(propertiesView) {
    this.$el.html(propertiesView.el);
  },

  hide: function() {
    if (!this.enabled) return false;
    this.$css('opacity', 0)
    that = this;
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout);
      this.hideTimeout = null;
      console.log("clear")
    }
    this.hideTimeout = setTimeout(function() {
      that.$hide();
      that.hideTimeout = null;
    }, 1000);
  },

  show: function() {
    if (!this.enabled) return false;
    // console.log(this.hideTimeout);
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout);
      this.hideTimeout = null;
      console.log("clear")
    }
    this.$show();
    this.$css('opacity', 1)
  },

  disable: function() {
      this.enabled = false;
      this.$toggle();
      // this.$css('display', 'none');
  },

  enable: function() {
      this.enabled = true;
      this.$toggle();
      // this.$css('display', null);
  },



  // position: (fn [selection]
  //   (let
  //     [geo (. selection getGeometry)
  //      winHeight (-> ($ window) .height) (. ($ window) height)]
  //   )
  //   )

  position: function(selection) {
    /*# To properly position the panel
    # we need to know the window width and height
    # as well as the document dimensions and the
    # scroll offset to corrdinate the two (horizontal if that is a factor too)
    # We also need to know about extra space to the left and right. Canvas items get
    # positioned from the top left of the canvas, which may not be the left edge.
    # the panel needs to always be fully on screen, so it is being positioned according
    # to the window dimenstions, and should be "fix" positioned.
    */

    var geo = selection.getGeometry()
    var winHeight = $(window).height(),
        winWidth = $(window).width(),
        scrollLeft = $(window).scrollLeft(),
        scrollTop = $(window).scrollTop(),
        docHeight = $(document).height(),
        docWidth = $(document).width();

    var topOffset = docHeight - scrollTop;
    var leftOffset = docWidth - scrollLeft;

    this.$css('top', geo.top + 60);
    var margin = 10;
    var minWidth = 120;
    var maxWidth = 170;
    //var positionVertical = false;


    // Position to the left or right?
    if (geo.left > winWidth - geo.left - geo.width) {
      // position to left
      var width = geo.left - margin*2;
      width = Math.min(width, maxWidth);
      var left = geo.left - margin - width;

      this.$css({
        left: left,
        width: Math.min(width, maxWidth)
      });

    } else {
      // Position to the right
      var width = winWidth - geo.left - geo.width - margin*2;

      this.$css({
        left: geo.left + geo.width + margin,
        width: Math.min(width, maxWidth)
      })

    }

    if (width < minWidth) {
      // Try to position vertically.

      // (let
      //   [maxWidth 250]
      //   ())


      var maxHeight = 170,
          minHeight = 120;


      this.$css({
        top: geo.top + geo.height + margin + 60,
        left: geo.left,
        width: geo.width,
        height: maxHeight
      })
    }

  }


});

App.MobilePropertiesPanelView = MobilePropertiesPanelView;
