slypApp.Models.UserSlyp = Backbone.RelationalModel.extend({
  defaults: {
    friends: []
  },
  relations: [{
    type: Backbone.HasMany,
    key: 'reslyps',
    relatedModel: 'slypApp.Models.Reslyp',
    collectionType: 'slypApp.Collections.Reslyps',
    reverseRelation: {
      key: 'userSlyp',
      includeInJSON: 'id'
    },
    collectionOptions: function(userSlyp){
      return {
        id: userSlyp.get('id')
      }
    }
  }],
  moveToFront: function() {
    this.collection.moveToFront(this);
  },
  moveToBack: function(){
    this.collection.moveToBack(this);
  },
  displayTitle: function(){
    return this.get('title') ? this.get('title') : this.get('url')
  },
  hideArchived: function(){
    return this.get('archived') && !slypApp.state.searchMode
  },
  hasConversations: function(){
    return this.get('friends').length > 0
  }
});