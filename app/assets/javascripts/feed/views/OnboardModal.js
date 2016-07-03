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
        if (slypApp.state.isMobile()){
          toastr['info']('Onboarding tour is disabled for mobiles and tablets. Login again from a desktop to take the tour!');
          $.cookie('_onboard_tour', true);
        } else {
          $('#close-left-pane').click();
          $('html, body').animate({ scrollTop: '0px' });
          shepherd.cancel();
          shepherd.start();
        }
      },
      onDeny: function($el){
        $.cookie('_onboard_tour', true);
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