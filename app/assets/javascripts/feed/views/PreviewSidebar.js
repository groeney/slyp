slypApp.Views.PreviewSidebar = slypApp.Base.CompositeView.extend({
  template: '#js-preview-sidebar-region-tmpl',
  className: 'ui basic right aligned segment',
  onRender: function(){
    this.binder = rivets.bind(this.$el, { userSlyp: this.model });
  },
  onShow: function(){
    this.initializeSemanticElements();
    this.$('p').css('text-align', 'left').
                css('font-size', 'larger').
                css('font-family', "'Palatino Linotype','Book Antiqua',Palatino,serif");
    var context = this;
    $('#close-left-pane').on('click', function(){
      context.closePreview();
    });
    $('#open-conversations').on('click', function(){
      context.toggleConversations();
    })
  },
  events: {
    'click #conversations'         : 'toggleConversations'
  },
  closePreview: function(){
    $('#js-preview-sidebar-region').sidebar('toggle');
  },
  toggleConversations: function(){
    if (slypApp.state.rightPaneActive){
      slypApp.state.rightPaneActive = false;
      $('.ui.right.sidebar').sidebar('toggle');
    } else {
      slypApp.state.rightPaneActive = true;
      this.model.save({ unseen_activity: false });
      $('.ui.right.sidebar').sidebar('toggle');
      slypApp.sidebarRegion.show(new slypApp.Views.Sidebar({ model: this.model }));
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
  }
});
