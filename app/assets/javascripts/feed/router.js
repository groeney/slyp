var slypApp = window.slypApp || {};

slypApp.Controller = Marionette.Object.extend({
  initialize: function() {
    slypApp.userSlyps = new slypApp.Collections.UserSlyps();
    slypApp.mainRegion.show(new slypApp.Views.FeedLayout());
    slypApp.navBarRegion.show(new slypApp.Views.NavBar());
  }
});