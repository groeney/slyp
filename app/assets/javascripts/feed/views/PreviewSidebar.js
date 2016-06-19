slypApp.Views.PreviewSidebar = slypApp.Base.CompositeView.extend({
  template: '#js-preview-sidebar-region-tmpl',
  className: 'ui basic right aligned segment',
  modelEvents : {
    'change:html' : 'htmlChanged'
  },
  htmlChanged: function(e){
    setTimeout(function(){
      this.$('.video_frame').first().addClass('ui').addClass('embed');
    }, 100);
  },
  onRender: function(){
    if (this.model.get('html') == null){
      this.model.fetch();
    }
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
    });
  },
  events: {
    'click #conversations' : 'toggleConversations'
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
    }
  },

  // Helper functions
  initializeSemanticElements: function(){
    // Misc UI
    this.$('.video_frame').first().addClass('ui').addClass('embed');

    // Preview sidebar
    $('#js-preview-sidebar-region').sidebar('setting', 'onShow', function(){
      slypApp.state.leftPaneActive = true;
    });
    $('#js-preview-sidebar-region').sidebar('setting', 'onHide', function(){
      slypApp.state.leftPaneActive = false;
    });
  },
  closePreview: function(){
    $('#js-preview-sidebar-region').sidebar('toggle');

    // ###### SAFETY ZONE ######
    $('#close-left-pane').unbind();
    $('#open-conversations').unbind();
    this.destroy();
  }
});
