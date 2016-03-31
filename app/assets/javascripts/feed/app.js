var slypApp = new Backbone.Marionette.Application();
slypApp.Collections = {};
slypApp.Views = {};
slypApp.Models = {};

slypApp.addRegions({
  navBarRegion : '#nav-bar-region',
  feedRegion   : '#feed-region'
});

// Object for application wide state, global analog of [view].state obj
slypApp.state = {
  searching  : false,
  searchMode : false
}

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
  return (value == undefined || value == 0) ? 'short' : Math.ceil(value/60) + ' min'
}

rivets.formatters.consumptionVerb = function(value){
  return (value == 'video') ? 'view' : 'read'
}

rivets.formatters.displaySiteName = function(value){
  return value ? value + ' | by ' : ''
}

rivets.formatters.trunc = function(value){
  return value ? value.trunc(70) : ''
}

rivets.binders['fade-hide'] = function(el, value) {
  return value ? $(el).fadeOut() : $(el).fadeIn();
};

rivets.binders['fade-show'] = function(el, value) {
  return value ? $(el).fadeIn() : $(el).fadeOut();
};

rivets.binders['class-unless'] = function(el, value) {
  return value ? $(el).removeClass(value) : $(el).addClass(value);
};
