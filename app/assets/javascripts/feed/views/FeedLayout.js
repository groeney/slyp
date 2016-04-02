slypApp.Views.FeedLayout = Backbone.Marionette.LayoutView.extend({
  template: '#js-feed-region-tmpl',
  className: 'ui container',
  regions: {
    feedRegion : '.feed-region'
  },
  onRender: function(){
    this.state = {
      collection: slypApp.userSlyps
    }
    this.binder = rivets.bind(this.$el, { collection: slypApp.userSlyps })
  },
  onShow: function() {
    this.feedRegion.show(new slypApp.Views.UserSlyps({
      collection: this.collection
    }));
  }
});


