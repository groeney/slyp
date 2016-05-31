slypApp.Views.Sidebar = slypApp.Base.CompositeView.extend({
  template: '#js-sidebar-region-tmpl',
  childView: slypApp.Views.Reslyp,
  childViewContainer: '.js-reslyps-container',
  className: 'ui basic segment',
  initialize: function(options){
    this.state = {
      loading  : true,
      expanded : false
    }
    this.collection = this.model.get('reslyps');
    if (this.collection != null){
      var context = this;
      this.collection.fetch({
        reset: true,
        success: function(collection, response, options){
          context.state.loading = false;
        },
        error: function(collection, response, options){
          context.state.loading = false;
        }
      });
    }
  },
  onRender: function(){
    this.binder = rivets.bind(this.$el, { userSlyp: this.model, state: this.state });
  },
  events: {
    'click #expand-description'   : 'expandDescription',
    'click #collapse-description' : 'collapseDescription',
    'click #close-sidebar'        : 'closeSidebar',
    'click #facebook-share'       : 'shareOnFacebook',
    'click #twitter-share'        : 'shareOnTwitter'
  },
  expandDescription: function(){
    this.state.expanded = true;
  },
  collapseDescription: function(){
    this.state.expanded = false;
  },
  closeSidebar: function(){
    $('.ui.sidebar').sidebar('toggle');
  },
  shareOnFacebook: function(){
    this.toastrFeatNotImplemented();
  },
  shareOnTwitter: function(){
    this.toastrFeatNotImplemented();
  }
})