slypApp.Views.FeedLayout = Backbone.Marionette.LayoutView.extend({
  template: '#js-feed-region-tmpl',
  className: 'ui container',
  regions: {
    feedRegion : '.feed-region'
  },
  onShow: function() {
    this.feedRegion.show(new slypApp.Views.UserSlyps({
      collection: slypApp.userSlyps
    }));
  }
});


