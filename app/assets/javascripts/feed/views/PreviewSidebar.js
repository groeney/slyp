slypApp.Views.PreviewSidebar = Backbone.Marionette.CompositeView.extend({
  template: '#js-preview-sidebar-region-tmpl',
  className: 'ui basic right aligned segment',
  modelEvents : {
    'change:html' : 'htmlChanged'
  },
  htmlChanged: function(e){
    var context = this;
    setTimeout(function(){
      context.$('p').css('text-align', 'left').
                  css('font-size', 'larger').
                  css('font-family', "'Palatino Linotype','Book Antiqua',Palatino,serif");
      context.$('.video_frame').first().addClass('ui').addClass('embed');
    }, 100);
  },
  onRender: function(){
    if (this.model.get('html') == null){
      this.model.fetch();
    }
    this.model.touch();
    this.binder = rivets.bind(this.$el, { userSlyp: this.model });
  },
  onShow: function(){
    this.initializeSemanticElements();
    this.$('p').css('text-align', 'left').
                css('font-size', 'larger').
                css('font-family', "'Palatino Linotype','Book Antiqua',Palatino,serif");

    // ###### DANGER ZONE ######
    var context = this;
    $('#close-left-pane').on('click', function(){
      context.closePreview();
    });
    $('#open-conversations').on('click', function(){
      context.toggleConversations();

      // Analytics
      analytics.track('Open Sidebar');
    });
  },
  events: {
    'click #conversations'        : 'toggleConversations',
    'click .fb-share-button'      : 'fbShareAttempt',
    'click .twitter-share-button' : 'twitterShareAttempt'
  },
  toggleConversations: function(){
    if (slypApp.state.rightPaneActive){
      $('.ui.right.sidebar').sidebar('toggle');
    } else {
      this.model.save({ unseen_activity: false });
      slypApp.sidebarRegion.show(new slypApp.Views.Sidebar({ model: this.model }));
      $('.ui.right.sidebar').sidebar('toggle');
      if (slypApp.state.isMobile()){
        this.closePreview();
      }

      // Analytics
      analytics.track('Open Sidebar');
    }
  },
  fbShareAttempt: function(){
    // Analytics
    analytics.track('FB Share', {
      slyp_id: this.model.get('slyp_id'),
      slyp_title: this.model.get('title'),
      slyp_url: this.model.get('url')
    });
  },
  twitterShareAttempt: function(){
    // Analytics
    analytics.track('Twitter Share', {
      slyp_id: this.model.get('slyp_id'),
      slyp_title: this.model.get('title'),
      slyp_url: this.model.get('url')
    });
  },

  // Helper functions
  initializeSemanticElements: function(){
    // Misc UI
    this.$('.video_frame').first().addClass('ui').addClass('embed');

    // Preview sidebar
    $('#js-preview-sidebar-region').sidebar('setting', 'onShow', function(){
      slypApp.state.leftPaneActive = true;
      $('#drift-widget-container').hide();
    });

    $('#js-preview-sidebar-region').sidebar('setting', 'onHide', function(){
      slypApp.state.leftPaneActive = false;
      var sidebarVisible = $('.ui.right.sidebar').sidebar('is visible');
      if (!sidebarVisible){
        $('#drift-widget-container').show();
      }
    });

    $('#js-preview-sidebar-region').sidebar('setting', 'transition', 'overlay');
  },
  closePreview: function(){
    $('#js-preview-sidebar-region').sidebar('toggle');

    // ###### SAFETY ZONE ######
    $('#close-left-pane').unbind();
    $('#open-conversations').unbind();
    this.destroy();
  }
});
