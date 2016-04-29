slypApp.Models.Reslyp = Backbone.RelationalModel.extend({
  urlRoot: '/reslyp',
  relations: [{
    type: Backbone.HasMany,
    key: 'replies',
    relatedModel: 'slypApp.Models.Reply',
    collectionType: 'slypApp.Collections.Replies',
    reverseRelation: {
      key: 'reslyp',
      includeInJSON: 'id'
    },
    collectionOptions: function(reslyp){
      return {
        id: reslyp.get('id')
      }
    }
  }],
  sentBySelf: function(){
    return this.get('sender').id == slypApp.user.get('id')
  },
  hasReplies: function(){
    return this.get('replies').models.length > 0
  }
})