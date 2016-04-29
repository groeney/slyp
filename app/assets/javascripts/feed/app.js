var slypApp = new Marionette.Application();
slypApp.Collections = {};
slypApp.Views = {};
slypApp.Models = {};
slypApp.Base = {};

slypApp.addRegions({
  navBarRegion : '#js-nav-bar-region',
  feedRegion   : '#js-feed-region'
});

slypApp.state = {
  searchMode    : false,
  resettingFeed : false,
  addMode       : false,
  actionsMode   : false,
  screenWidth   : getScreenWidth(),
  isMobile      : function() { return slypApp.state.screenWidth < 767 }
}

// Want to keep updated so that rivets can use as dependency attr
$(window).on('resize', function(){
  slypApp.state.screenWidth = getScreenWidth();
})

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

rivets.formatters.fromNow = function(value, updatedAt){
  updatedAt = typeof updatedAt !== 'undefined' ? updatedAt : value;
  var edited = value != updatedAt;
  return edited ? moment(value).fromNow() + ' edited' : moment(value).fromNow()
}

rivets.formatters.numReslyps = function(value){
  return value ? 'reslyp'.pluralize(value) : 'few reslyps'
}

rivets.formatters.numFriends = function(value){
  return value ? 'friend'.pluralize(value) : '0 friends'
}

rivets.formatters.numReplies = function(value){
  return value ? 'reply'.pluralize(value, 'replies') : '0 replies'
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
  return value ? value.trunc(55) : ''
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
    return $(this).attr('style', 'display: none !important');

  }) : $(el).fadeIn();
};

rivets.binders['fade-show'] = function(el, value) {
  return value ? $(el).fadeIn() : $(el).fadeOut();
};

rivets.binders['class-unless-*'] = function(el, value) {
  return value ? $(el).removeClass(this.args[0]) : $(el).addClass(this.args[0]);
};

rivets.binders['hide-if'] = function(el, value) {
  if (value){
    return $(el).hide();
  }
}

rivets.binders['live-value'] = {
  publishes: true,
  bind: function(el) {
    return $(el).on('keyup', this.publish);
  },
  unbind: function(el) {
    return $(el).off('keyup', this.publish);
  },
  routine: function(el, value) {
    return rivets.binders.value.routine(el, value);
  }
};
