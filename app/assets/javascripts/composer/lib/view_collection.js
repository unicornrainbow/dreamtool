var ViewCollection = function() {
  this.views  = [];
};

_.extend(ViewCollection.prototype, {
  view: Backbone.View,

  add: function(view, options) {
    // Initialize object hash as view instance if neccessary.
    if (!(view instanceof this.view)) {
      view = new this.view(view);
    }

    this.views.push(view)

    return view;
  }

});

this.Newstime.ViewCollection = ViewCollection;
