var NoSlypsMessage = Backbone.Marionette.ItemView.extend({
  template: '#js-no-slyps-message-tmpl',
  attributes: {
    'style' : 'min-width: 100%;'
  }
});

slypApp.Views.FeedLayout = Backbone.Marionette.CompositeView.extend({
  template           : '#js-feed-region-tmpl',
  className          : 'ui center aligned container',
  childView          : slypApp.Views.UserSlyp,
  childViewContainer : '.js-user-slyps-container',
  emptyView          : NoSlypsMessage,
  initialize: function(options){
    this.collection.bind('change:archived update reset', this.zeroState, this);
  },
  onRender: function(){
    this.binder = rivets.bind(this.$el, {
      appState: slypApp.state,
      user: slypApp.user,
      persons: slypApp.persons.models
    });
  },
  onShow: function() {
    $('#filter-dropdown').dropdown({
      onChange: function(value, text, selectedItem) {
        switch(value){
          case 'all':
            slypApp.userSlyps.meta('friendID', null);
            slypApp.userSlyps.meta('recent', false);
            slypApp.state.showArchived = true;
            slypApp.userSlyps.paginate({ reset: true });
            break;
          case 'search':
            slypApp.userSlyps.meta('friendID', null);
            slypApp.userSlyps.meta('recent', false);
            slypApp.state.searchMode = true;
            slypApp.state.toPaginate = false;
            slypApp.state.showArchived = true;
            $('#searcher input').focus();
            break;
          default: // View friendship
            if (!isNaN(value)){
              slypApp.state.showArchived = true;
              slypApp.userSlyps.meta('friendID', value);
              slypApp.userSlyps.meta('recent', false);
              slypApp.userSlyps.paginate({ reset: true });
            } else{
              toastr['error']('Our robots cannot perform that action right now :(');
            }
            break;
        }
      }
    });
    $('#filter-dropdown').dropdown('set selected', 'all'); // Performs initial fetch!
  },
  events: {
    'click #paginate-button'  : 'paginate',
    'click #compact-layout'   : 'toggleLayout',
    'click #explore'          : function(){ notImplemented('Explore'); },
    'click #add-friends'      : 'showFriendsSettings'
  },
  showFriendsSettings: function(){
    openFriendsSettings();

    // Analytics
    analytics.track('Clicked Add Friends');
  },
  paginate: function(){
    this.collection.paginate();
  },
  toggleLayout: function(){
    if (shepherd.isActive()){
      _toastr('error', 'our onboarding tour only works with the one card feed right now. You\'ll be able to change the layout after you finish the tour!');
    } else {
      slypApp.state.compactLayout = !slypApp.state.compactLayout;
      $.cookie('_compact_layout', slypApp.state.compactLayout);
    }
  }
});