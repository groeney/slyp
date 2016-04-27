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
    }
  }]
})