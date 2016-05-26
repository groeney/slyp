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
    this.binder = rivets.bind(this.$el, { appState: slypApp.state, user: slypApp.user })
  },
  onShow: function() {
    this.feedRegion.show(new slypApp.Views.UserSlyps({
      collection: this.collection
    }));
    this.$('#filter-dropdown').dropdown({
      onChange: function(value, text, $selectedItem) {
        switch(value){
          case "reading list":
            slypApp.state.resettingFeed = true;
            slypApp.userSlyps.fetch({
              success: function(collection, response, options) {
                slypApp.state.searchMode = false;
                slypApp.state.showArchived = false;
                slypApp.state.resettingFeed = false;
              }
            });
            break;
          case "done":
            slypApp.state.showArchived = true;
            slypApp.userSlyps.fetchArchived();
            break;
          case "search":
            slypApp.state.searchMode = true;
            slypApp.state.showArchived = true;
            $('#searcher input').focus();
            break;
          default:
            if (!isNaN(value)){
              slypApp.state.showArchived = true;
              slypApp.userSlyps.fetchMutualUserSlyps(value);
            } else{
              toastr['error']('Our robots cannot perform that action right now :(');
            }
            break;
        }
      },
      onLabelCreate: function($label){
        debugger
      }
    });
    this.$('#filter-dropdown').dropdown('set selected', 'reading list'); // Performs initial fetch!
  },
  zeroState: function(){
    if (this.collection.where({ archived: false }).length === 0 && !slypApp.state.showArchived){
      this.$('#zero-state').show();
    } else if (this.collection.where({ archived: false }).length > 0){
      this.$('#zero-state').hide();
    }
  }
});


