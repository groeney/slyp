slypApp.Models.User = Backbone.Model.extend({
  urlRoot: '/user',
  initialize: function(){
    this.fetch({
      success: function(){
        var skipTo = getParameterByName('skip_to');
        if (skipTo == 'email_settings'){
          openEmailsSettings();
          window.history.pushState({}, document.title, window.location.pathname); // requires HTML5
        }
      }
    });
  },
  friends: function(){
    return slypApp.persons.whereNot({ friendship_id: null })
  },
  scrubFriends: function(friends){
    var friendsToScrub = this.friends();
    return _.filter(friends, function(friend) {
      return !_.some(friendsToScrub, function(userSlypFriend){
        return friend.email == userSlypFriend.email
      });
    });
  },
  friendsCount: function(){
    var friends = this.friends();
    return friends.length > 0 ? friends.length : 5
  },
  needsFriends: function(){
    return this.friendsCount() < 5
  }
});