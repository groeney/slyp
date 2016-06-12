slypApp.Views.PreviewModal = Backbone.Marionette.ItemView.extend({
  template: '#js-modal-preview-tmpl',
  className: 'ui fullscreen modal',
  attributes: {
    'rv-href'              : 'userSlyp:url',
    'rv-data-user-slyp-id' : 'userSlyp:id',
    'target'               : '_blank'
  },
  onRender: function(){
    this.binder = rivets.bind(this.$el, { userSlyp : this.model });
  },
  onShow: function(){
    this.$('.video_frame').first().addClass('ui').addClass('embed');
    this.$el.modal({
      onHidden: function() { // Buggy if more than one video
        iframe = $(this).find('.ui.embed iframe').first();
        iframe.attr('src', iframe.attr('src'));
      }
    }).modal('show');
  }
});