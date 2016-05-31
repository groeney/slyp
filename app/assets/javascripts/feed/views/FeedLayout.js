slypApp.Views.FeedLayout = Backbone.Marionette.LayoutView.extend({
  template: '#js-feed-region-tmpl',
  className: 'ui container',
  regions: {
    feedRegion : '.feed-region'
  },
  initialize: function(){
    this.collection.bind('change:archived add remove', this.zeroState, this);
    slypApp.user.bind('change', this.setProgress, this);
    this.collection.bind('sync', this.zeroState, this);
  },
  onRender: function(){
    this.binder = rivets.bind(this.$el, { appState: slypApp.state, user: slypApp.user })
  },
  onShow: function() {
    this.feedRegion.show(new slypApp.Views.UserSlyps({
      collection: this.collection
    }));
  },
  setProgress: function(){
    if (slypApp.user.friendsCount() >= 5){
      $('#friends-progress').remove();
    } else {
        $('#friends-progress').progress({
          value: slypApp.user.friendsCount(),
          text: {
            active  : 'You need {left} more friends'
          },
          label: 'ratio',
          onChange: function(p,v,t){
            if (v>=5){
              $('.ui.progress').remove();
            }
          }
        });
    }
  },
  zeroState: function(){
    if (this.collection.where({ archived: false }).length === 0 && !slypApp.state.showArchived){
      this.$('#zero-state').show();
    } else if (this.collection.where({ archived: false }).length > 0){
      this.$('#zero-state').hide();
    }
  },
  events: {
    'click #friends-progress' : 'openInviteModal'
  },
  openInviteModal: function(){
    console.debug('Opening invite modal');
  }
});


