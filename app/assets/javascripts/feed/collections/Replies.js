slypApp.Collections.Replies = Backbone.Collection.extend({
  model: slypApp.Models.Reply,
  initialize: function(models, options){
    this.id = options.id;
  },
  url: function() {
    return '/replies/' + this.id
  }
});
