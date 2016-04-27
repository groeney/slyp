slypApp.Collections.Reslyps = Backbone.Collection.extend({
  model: slypApp.Models.Reslyp,
  initialize: function(models, options) {
    this.id = options.id;
  },
  url: function(){
    return '/reslyps/' + this.id
  }
});