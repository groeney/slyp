slypApp.Views.FeedLayout = Backbone.Marionette.LayoutView.extend({
  template: '#js-feed-region-tmpl',
  className: 'ui center aligned container',
  regions: {
    feedRegion : '.feed-region'
  },
  initialize: function(){
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
    this.feedRegion.show(new slypApp.Views.UserSlyps({
      collection: this.collection
    }));
    this.updateFriendsProgress()
    $('#filter-dropdown').dropdown({
      onChange: function(value, text, selectedItem) {
        switch(value){
          case 'recent':
            slypApp.userSlyps.meta('friendID', null);
            slypApp.userSlyps.meta('recent', true);
            slypApp.state.searchMode = false;
            slypApp.state.showArchived = false;
            slypApp.userSlyps.paginate({ reset: true });
            break;
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
    $('#filter-dropdown').dropdown('set selected', 'recent'); // Performs initial fetch!
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
          active: 'You need {left} more friends'
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
    'click #explore-button'   : function(){ notImplemented('Explore'); }
  },
  showFriendsSettings: function(){
    openFriendsSettings();
  },
  paginate: function(){
    this.collection.paginate();
  }
});