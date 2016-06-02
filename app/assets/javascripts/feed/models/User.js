slypApp.Models.User = Backbone.Model.extend({
  urlRoot: '/user',
  initialize: function(){
    this.fetch();
  },
  scrubFriends: function(friends){
    var friendsToScrub = this.get('friends');
    return _.filter(friends, function(friend) {
      return !_.some(friendsToScrub, function(userSlypFriend){
        return friend.email == userSlypFriend.email
      });
    });
  },
  friendsCount: function(){
    return this.get('friends') ? this.get('friends').length : 5
  },
  needsFriends: function(){
    return this.friendsCount() < 5
  }
})