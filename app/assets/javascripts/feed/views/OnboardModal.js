slypApp.Views.OnboardModal = Backbone.Marionette.ItemView.extend({
  template: '#js-onboard-modal-tmpl',
  className: 'ui fullscreen modal',
  onRender: function(){
    this.binder = rivets.bind(this.$el, { user : this.model });
  },
  onShow: function(){
    this.initializeSemanticUI();
    this.$('p').css('text-align', 'left').
                css('font-size', 'larger').
                css('font-family', "'Palatino Linotype','Book Antiqua',Palatino,serif");
  },
  initializeSemanticUI: function(){
    this.$el.modal({
      onApprove: function($el){
        $('#close-left-pane').click();
        $('html, body').animate({ scrollTop: '0px' });
        shepherd.cancel();
        shepherd.start();
      }
    }).modal('show');
  }
});