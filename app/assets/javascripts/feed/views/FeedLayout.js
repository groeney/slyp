slypApp.Views.FeedLayout = Backbone.Marionette.LayoutView.extend({
  template: '#js-feed-region-tmpl',
  className: 'ui container',
  regions: {
    feedRegion : '.feed-region'
  },
  initialize: function(){
    this.collection.bind('change:archived add remove', this.zeroState, this);
    this.collection.bind('sync', this.zeroState, this);
  },
  onRender: function(){
    this.binder = rivets.bind(this.$el, { appState: slypApp.state })
  },
  onShow: function() {
    this.feedRegion.show(new slypApp.Views.UserSlyps({
      collection: this.collection
    }));
  },
  zeroState: function(){
    if (this.collection.where({archived: false}).length === 0 && !slypApp.state.searchMode){
      this.$('#zero-state').show();
    } else if (this.collection.where({archived: false}).length > 0){
      this.$('#zero-state').hide();
    }
  }
});


