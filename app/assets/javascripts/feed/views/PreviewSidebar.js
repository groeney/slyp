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
  },
  events: {
    'click #close-preview-sidebar' : 'closePreview',
    'click #conversations'         : 'toggleConversations'
  },
  closePreview: function(){
    $('#js-preview-sidebar-region').sidebar('toggle');
  },
  toggleConversations: function(){
    if (slypApp.state.viewingConversations){
      $('.ui.right.sidebar').sidebar('toggle');
    } else {
      this.model.save({ unseen_activity: false });
      slypApp.sidebarRegion.show(new slypApp.Views.Sidebar({ model: this.model }));
      $('.ui.right.sidebar').sidebar('toggle');
      if (slypApp.state.isMobile()){
        this.closePreview();
      } else {
        $('#js-preview-sidebar-region').animate({
          width: '60%'
        }, 450);
      }
    }
  },

  // Helper functions
  initializeSemanticElements: function(){
    // Misc UI
    this.$('.video_frame').first().addClass('ui').addClass('embed');

    // Preview sidebar
    $('#js-preview-sidebar-region').sidebar('setting', 'onShow', function(){
      slypApp.state.previewingSlyp = true;
      if (slypApp.state.viewingConversations){
        $(this).css('width', '60%');
      } else {
        $(this).css('width', '100%');
      }
    });
    $('#js-preview-sidebar-region').sidebar('setting', 'onHide', function(){
      slypApp.state.previewingSlyp = false;
    });
  }
});
