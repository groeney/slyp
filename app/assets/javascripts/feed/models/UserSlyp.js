slypApp.Models.UserSlyp = Backbone.RelationalModel.extend({
  urlRoot: '/user_slyp',
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
  reslypableFriends: function(){
    var allFriends = slypApp.user.friends();
    var userSlypFriends = this.get('friends');
    return _.filter(allFriends, function(friend){
      return !_.some(userSlypFriends, function(userSlypFriend){
        return friend.get('email') == userSlypFriend.email
      });
    });
  },
  otherPersons: function(){
    return slypApp.persons.where({ friendship_id: null });
  },
  hasLove: function(){
    return this.get('unseen_activity') || this.get('unseen_replies')
  },
  loveAmount: function(){
    return this.get('unseen_replies') || 1;
  },
  needsAttention: function(){
    return this.hasLove() || this.get('unseen')
  },
  fbURL: function(){
    return 'https://www.facebook.com/sharer/sharer.php?u=' + encodeURIComponent(this.get('url')) + '&amp;src=sdkpreparse'
  },
  tweetURL: function(){
    return 'https://twitter.com/intent/tweet?url=' + this.get('url')
  },
  index: function(){
    return slypApp.userSlyps.indexOf(this);
  }
});