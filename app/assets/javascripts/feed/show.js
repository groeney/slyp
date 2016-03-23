var slypApp = window.slypApp || {};

$(function() {
  slypApp.addInitializer(function() {
    return Slyp.App.router = new Slyp.Router({
      controller: new Slyp.Controller
    });
  });
  return slypApp.start();
});