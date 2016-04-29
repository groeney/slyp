slypApp.Models.Reply = Backbone.RelationalModel.extend({
  urlRoot: '/replies',
  hasText: function(){
    return this.get('text').length > 0
  },
  ownedByCurrentUser: function(){
    return this.get('sender').id == slypApp.user.get('id')
  }
})