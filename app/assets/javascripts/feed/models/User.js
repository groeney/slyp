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
  },
  fbReferral: function(){
    return 'https://www.facebook.com/sharer/sharer.php?quote=Your content-sharing network that doesn\'t use algorithms; built for the people, by the people, of the people.&u=' + encodeURIComponent(this.get('referral_link')) + '&amp;src=sdkpreparse'
  },
  tweetReferral: function(){
    return 'https://twitter.com/intent/tweet?text=Come join me on Slyp!&url=' + this.get('referral_link')
  },
  mailToReferral: function(){
    return 'mailto:?to=&body=Hey I\'ve been using Slyp to share and discuss content with friends. Join me! ' + this.get('referral_link') + '&subject=Join me on Slyp!'
  }
});