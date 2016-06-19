slypApp.Views.FeedLayout = Backbone.Marionette.LayoutView.extend({
  template: '#js-feed-region-tmpl',
  className: 'ui container',
  regions: {
    feedRegion : '.feed-region'
  },
  initialize: function(){
    this.collection.bind('change:archived update reset', this.zeroState, this);
    this.collection.bind('sync', this.zeroState, this);
    slypApp.persons.on('change:friendship_id update', this.updateFriendsProgress, this);
  },
  onRender: function(){
    this.binder = rivets.bind(this.$el, {
      appState: slypApp.state,
      user: slypApp.user
    });
  },
  onShow: function() {
    this.feedRegion.show(new slypApp.Views.UserSlyps({
      collection: this.collection
    }));
    this.updateFriendsProgress()
  },
  updateFriendsProgress: function(){
    var progressMeter = this.$('#friends-progress');
    if (slypApp.user.needsFriends()){
      progressMeter.show();
      progressMeter.progress({
        label: 'ratio',
        value: slypApp.user.friendsCount(),
        text: {
          active: 'You need {left} more friends'
        }
      });
    } else {
      progressMeter.hide();
    }
  },
  zeroState: function(){
    if (this.collection.where({ archived: false }).length === 0){
      this.$('#zero-state').show();
    } else if (this.collection.where({ archived: false }).length > 0){
      this.$('#zero-state').hide();
    }
  },
  events: {
    'click #friends-progress' : 'showFriendsSettings'
  },
  showFriendsSettings: function(){
    openFriendsSettings();
  }
});