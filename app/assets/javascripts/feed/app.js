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