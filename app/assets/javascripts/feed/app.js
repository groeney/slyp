var slypApp = new Backbone.Marionette.Application();
slypApp.Collections = {};
slypApp.Views = {};
slypApp.Models = {};

slypApp.addRegions({
  mainRegion: '#main-region'
});

window.slypApp = slypApp;

rivets.adapters[':'] = {
  observe: function(obj, keypath, callback) {
    obj.on('change:' + keypath, callback)
  },
  unobserve: function(obj, keypath, callback) {
    obj.off('change:' + keypath, callback)
  },
  get: function(obj, keypath) {
    return obj.get(keypath)
  },
  set: function(obj, keypath, value) {
    obj.set(keypath, value)
  }
}

rivets.formatters.fromNow = function(value){
  return moment(value).fromNow()
}

rivets.formatters.numReslyps = function(value){
  return 'reslyp'.pluralize(value)
}

rivets.formatters.numComments = function(value){
  return 'comment'.pluralize(value.length)
}

rivets.formatters.numFriends = function(value){
  return 'friend'.pluralize(value.length)
}

rivets.formatters.duration = function(value){
  return (value == undefined) ? 'brief' : Math.ceil(value/60) + ' min'
}

rivets.formatters.consumptionVerb = function(value){
  return (value == 'video') ? 'watch' : 'read'
}

rivets.formatters.displaySiteName = function(value){
  return value ? value + ' | by ' : ''
}

rivets.formatters.trunc = function(value){
  return value.trunc(70)
}

rivets.binders["fade-hide"] = function(el, value) {
  return value ? $(el).fadeOut() : $(el).fadeIn();
};



