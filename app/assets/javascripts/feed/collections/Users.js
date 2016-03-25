slypApp.Collections.Users = Backbone.Collection.extend({
  model: slypApp.Models.User,
  url: "/users",
  filterWithIds: function(ids) {
      return _(this.models.filter(function(c) { return _.contains(ids, c.id); }));
  }
})
