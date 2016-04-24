var slypApp = new Backbone.Marionette.Application();
slypApp.Collections = {};
slypApp.Views = {};
slypApp.Models = {};

slypApp.addRegions({
  navBarRegion : '#js-nav-bar-region',
  feedRegion   : '#js-feed-region'
});

slypApp.state = {
  searchMode    : false,
  resettingFeed : false,
  addMode       : false,
  actionsMode   : false
}

slypApp.state.actionsOnMobile = function(){
  return slypApp.state.actionsMode && ($(window).width() < 767)
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
  return value ? 'reslyp'.pluralize(value) : 'few reslyps'
}

rivets.formatters.numComments = function(value){
  return value ? 'comment'.pluralize(value.length) : ''
}

rivets.formatters.numFriends = function(value){
  return value ? 'friend'.pluralize(value.length) : ''
}

function readDuration(value){
  return (value === undefined || value <= 60) ? 'short read' : Math.ceil(value/60) + ' min read'
}

rivets.formatters.consumption = function(duration, type){
  return (type === 'video') ? 'video' : readDuration(duration)
}

rivets.formatters.displaySiteName = function(value){
  return value ? value + ' | by ' : ''
}

rivets.formatters.trunc = function(value){
  return value ? value.trunc(70) : ''
}

rivets.formatters.slypDirection = function(value){
  return value ? 'You sent this slyp.' : 'This slyp was sent to you.'
}

rivets.formatters.userDisplay = function(firstName, lastName, email){
  return firstName ? firstName.concat(' ', lastName) : email
}

rivets.formatters.fallback = function(firstName, email){
  return firstName ? firstName : email
}

rivets.formatters.authorship = function(author, siteName, url){
  if (author && siteName){
    return [siteName, author].join(' | by ')
  } else if (author){
    return [urlDomain(url), author].join(' | by ')
  } else if (siteName){
    return [siteName, urlDomain(url)].join(' | ')
  } else {
    return urlDomain(url) == 'localhost' ? '' : urlDomain(url)
  }
}

rivets.binders['fade-hide'] = function(el, value) {
  return value ? $(el).fadeOut(function(){
    $(this).attr('style', 'display: none !important')
  }) : $(el).fadeIn();
};

rivets.binders['fade-show'] = function(el, value) {
  return value ? $(el).fadeIn() : $(el).fadeOut();
};

rivets.binders['class-unless'] = function(el, value) {
  return value ? $(el).removeClass(value) : $(el).addClass(value);
};

rivets.binders['hide-if'] = function(el, value) {
  if (value){
    return $(el).hide();
  }
}
