var slypApp = window.slypApp || {};

$(function() {
  slypApp.addInitializer(function() {
    return slypApp.router = new Backbone.Router({
      controller: new slypApp.Controller
    });
  });
  _toastr('info', 'Hi! Thank you for coming back. The functionality involved in retrieving the web content from a link has gone offline temporarily. Check in later or ask us questions below.', { 'positionClass': 'toast-top-center', 'timeOut': 30000 })
  return slypApp.start();
});

console.debug('Hey! There you are taking a peek :)')