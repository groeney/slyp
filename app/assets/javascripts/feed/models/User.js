slypApp.Models.User = Backbone.Model.extend({
  urlRoot: '/user',
  initialize: function(){
    this.fetch({
      success: function(model, response, options){
        var skipTo = getParameterByName('skip_to');
        if (skipTo == 'email_settings'){
          openEmailsSettings();
          window.history.pushState({}, document.title, window.location.pathname); // requires HTML5
        } else if (skipTo == 'friends_settings'){
          openFriendsSettings();
          window.history.pushState({}, document.title, window.location.pathname); // requires HTML5
        }

        // Analytics
        analytics.identify(model.get('id'), {
          display_name: model.get('display_name'),
          email: model.get('email')
        });
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
    return friends.length > 0 ? friends.length : 10
  },
  needsFriends: function(){
    return this.friendsCount() < 10
  }
});