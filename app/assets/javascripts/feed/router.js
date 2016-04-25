var slypApp = window.slypApp || {};

slypApp.Controller = Marionette.Object.extend({
  initialize: function() {
    slypApp.userSlyps = new slypApp.Collections.UserSlyps([{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}]);
    slypApp.feedRegion.show(new slypApp.Views.FeedLayout({
      collection: slypApp.userSlyps
    }));
    slypApp.navBarRegion.show(new slypApp.Views.NavBar());
    slypApp.user = new slypApp.Models.User();
  }
});