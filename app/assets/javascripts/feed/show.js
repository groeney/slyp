var slypApp = window.slypApp || {};

$(function() {
  slypApp.addInitializer(function() {
    return slypApp.router = new Backbone.Router({
      controller: new slypApp.Controller
    });
  });
  return slypApp.start();
});

console.debug('Hey! There you are taking a peek :)')