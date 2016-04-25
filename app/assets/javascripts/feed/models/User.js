slypApp.Models.User = Backbone.Model.extend({
  urlRoot: '/user',
  initialize: function(){
    this.fetch();
  }
})