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
      key: 'user_slyp',
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
    return this.get('archived') && !slypApp.state.showArchived
  },
  hasConversations: function(){
    return this.get('friends').length > 0
  },
  alreadyExchangedWith: function(user_email){
    _.some(this.get('friends'), function(friend) {
      return friend.email == user_email;
    });
  },
  scrubFriends: function(friends){
    var friendsToScrub = this.get('friends');
    return _.filter(friends, function(friend) {
      return !_.some(friendsToScrub, function(userSlypFriend){
        return friend.email == userSlypFriend.email
      });
    });
  },
  hasLove: function(){
    return this.get('unseen_activity') || this.get('unseen_replies')
  },
  loveAmount: function(){
    return this.get('unseen_replies') || 1;
  }
});