var slypApp = window.slypApp || {};

slypApp.Controller = Marionette.Object.extend({
  initialize: function() {
    slypApp.userSlyps = new slypApp.Collections.UserSlyps([{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}]);
    slypApp.user = new slypApp.Models.User();
    slypApp.persons = new slypApp.Collections.Persons();
    slypApp.persons.fetch().done(function(){
      slypApp.navBarRegion.show(new slypApp.Views.NavBar());
    });
    slypApp.feedRegion.show(new slypApp.Views.FeedLayout({
      collection: slypApp.userSlyps
    }));
  }
});