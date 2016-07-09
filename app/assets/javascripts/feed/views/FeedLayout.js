var NoSlypsMessage = Backbone.Marionette.ItemView.extend({
  template: '#js-no-slyps-message-tmpl'
});

slypApp.Views.FeedLayout = Backbone.Marionette.CompositeView.extend({
  template           : '#js-feed-region-tmpl',
  className          : 'ui center aligned container',
  childView          : slypApp.Views.UserSlyp,
  childViewContainer : '.js-user-slyps-container',
  emptyView          : NoSlypsMessage,
  initialize: function(options){
    this.collection.bind('change:archived update reset', this.zeroState, this);
    slypApp.persons.on('change:friendship_id update', this.updateFriendsProgress, this);
  },
  onRender: function(){
    this.binder = rivets.bind(this.$el, {
      appState: slypApp.state,
      user: slypApp.user,
      persons: slypApp.persons.models
    });
  },
  onShow: function() {
    this.updateFriendsProgress()
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
  updateFriendsProgress: function(){
    var progressMeter = this.$('#friends-progress');
    if (slypApp.user.needsFriends()){
      progressMeter.show();
      $('#progress-divider').show();
      progressMeter.progress({
        label: 'ratio',
        value: slypApp.user.friendsCount(),
        text: {
          active: 'Slyp is way more fun with friends... you need {left} more :-)'
        }
      });
    } else {
      progressMeter.hide();
      $('#progress-divider').hide();
    }
  },
  events: {
    'click #friends-progress' : 'showFriendsSettings',
    'click #paginate-button'  : 'paginate',
    'click #explore-button'   : function(){ notImplemented('Explore'); },
    'click #compact-layout'   : 'toggleLayout'
  },
  showFriendsSettings: function(){
    openFriendsSettings();
  },
  paginate: function(){
    this.collection.paginate();
  },
  toggleLayout: function(){
    slypApp.state.compactLayout = !slypApp.state.compactLayout;
  }
});