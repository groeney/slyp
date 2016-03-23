var slypApp = new Backbone.Marionette.Application();
slypApp.Collections = {};
slypApp.Views = {};
slypApp.Models = {};

slypApp.addRegions({
  mainRegion: '#main-region'
});

window.slypApp = slypApp;