var slypApp = new Marionette.Application();
slypApp.Collections = {};
slypApp.Views = {};
slypApp.Models = {};
slypApp.Base = {};

slypApp.addRegions({
  navBarRegion          : '#js-nav-bar-region',
  feedRegion            : '#js-feed-region',
  sidebarRegion         : '#js-sidebar-region',
  previewSidebarRegion  : '#js-preview-sidebar-region',
  settingsSidebarRegion : '#js-settings-sidebar-region',
  modalsRegion          : '#js-modals-region'
});

slypApp.state = {
  searchMode      : false,
  toPaginate      : true,
  addMode         : false,
  showArchived    : false,
  resettingFeed   : false,
  addMode         : false,
  screenWidth     : getScreenWidth(),
  leftPaneActive  : false,
  rightPaneActive : false,
  isMobile        : function() { return slypApp.state.screenWidth < 767 },
  slypURL         : '',
  compactLayout   : $.cookie('_compact_layout') == 'true'
}

slypApp.state.usingNavBar = function(){
  return slypApp.state.addMode || slypApp.state.searchMode
}

// Want to keep updated so that rivets can use as dependency attr
$(window).on('resize', function(){
  slypApp.state.screenWidth = getScreenWidth();
})

window.slypApp = slypApp;
toastr.options = { 'positionClass' : 'toast-top-center' }
