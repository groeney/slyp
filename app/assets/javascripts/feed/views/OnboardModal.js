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
        if (getScreenWidth() < 950){
          toastr['info']('Your browser width is too small. If you are on a mobile, try coming back on your laptop. Otherwise try to make your browser the full width of your screen.');
          $.cookie('_onboard_tour', true);
        } else {
          toastr['info']('For the best experience, make sure your browser is taking up the full width of your screen!')
          $('#close-left-pane').click();
          $('html, body').animate({ scrollTop: '0px' });
          slypApp.state.compactLayout = false;
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