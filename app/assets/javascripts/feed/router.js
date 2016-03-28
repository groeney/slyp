var slypApp = window.slypApp || {};

slypApp.Controller = Marionette.Object.extend({
  initialize: function() {
    slypApp.userSlyps = new slypApp.Collections.UserSlyps();
    return slypApp.mainRegion.show(new slypApp.Views.FeedLayout());
  }
});