slypApp.Views.FeedLayout = Backbone.Marionette.LayoutView.extend({
  template: '#js-feed-region-tmpl',
  className: 'ui container',
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
  events: {
    'click #friends-progress'         : 'showFriendsSettings',
    'click #extend-feed i.add.circle' : 'paginate',
    'click #extend-feed i.map'        : 'notImplemented'
  },
  showFriendsSettings: function(){
    openFriendsSettings();
  },
  paginate: function(){
    this.collection.paginate();
  },
  notImplemented: function(){
    toastr['info']('We\'ve logged your interest. Coming soon :)');
  }
});