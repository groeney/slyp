var slypApp = window.slypApp || {};

slypApp.Controller = Marionette.Object.extend({
  initialize: function() {
    slypApp.users = new slypApp.Collections.Users();
    slypApp.users.fetch();
    slypApp.userSlyps = new slypApp.Collections.UserSlyps();
    slypApp.userSlyps.fetch();
    return slypApp.mainRegion.show(new slypApp.Views.FeedLayout());
  }
});