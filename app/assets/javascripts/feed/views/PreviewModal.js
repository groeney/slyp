slypApp.Views.PreviewModal = Backbone.Marionette.ItemView.extend({
  template: '#js-modal-preview-tmpl',
  className: 'ui fullscreen modal',
  attributes: {
    'rv-href'              : 'userSlyp:url',
    'rv-data-user-slyp-id' : 'userSlyp:id',
    'target'               : '_blank'
  },
  modelEvents : {
    'change:html' : 'htmlChanged'
  },
  htmlChanged: function(){
    var context = this;
    setTimeout(function(){
      context.$('p').addClass('preview-text');
      context.$('.video_frame').first().addClass('ui').addClass('embed');
    }, 100);
  },
  onRender: function(){
    if (this.model.get('html') == null){
      this.model.fetch();
    }
    this.binder = rivets.bind(this.$el, { userSlyp: this.model });
  },
  onShow: function(){
    this.initializeSemanticUI();
    this.$('p').addClass('preview-text');
  },
  events: {
    'click #conversations' : 'showConversations'
  },
  showConversations: function(){
    this.$el.modal('hide');
    this.model.save({ unseen_activity: false });
    slypApp.sidebarRegion.show(new slypApp.Views.Sidebar({ model: this.model }));
    $('.ui.right.sidebar').sidebar('show');
  },

  // Helpers
  initializeSemanticUI: function(){
    this.$('.video_frame').first().addClass('ui').addClass('embed');
    this.$el.modal({
      onHidden: function() { // Buggy if more than one video
        iframe = $(this).find('.ui.embed iframe').first();
        iframe.attr('src', iframe.attr('src'));
      },
      onShow: function(){
        $('#drift-widget-container').hide();
      },
      onHide: function(){
        $('#drift-widget-container').show();
      }
    }).modal('show');
  }
});