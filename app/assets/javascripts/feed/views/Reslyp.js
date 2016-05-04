slypApp.Views.Reslyp = slypApp.Base.CompositeView.extend({
  template   : '#js-reslyp-tmpl',
  className  : 'comment',
  childView: slypApp.Views.Reply,
  childViewContainer: '.js-replies-container',
  events     : {
    'click #reply'        : 'toggleReplies',
    'click #replies'      : 'toggleReplies',
    'click #reply-button' : 'reply',
    'keypress input'      : 'replyIfValid'
  },
  initialize: function(options){
    this.collection = options.model.get('replies');
    var context = this;
    this.state = {
      hideReplies: true,
      replyText  : ''
    }
    this.state.hasReplyText = function(){
      return context.state.replyText.length > 0
    }
  },
  onRender: function(){
    this.binder = rivets.bind(this.$el, { reslyp: this.model, state: this.state });
  },
  onShow: function(){
    this.$('.avatar').popup();
  },
  toggleReplies: function(){
    this.model.get('replies').fetch();
    this.state.hideReplies = !this.state.hideReplies;
    if (!this.state.hideReplies){
      this.$('.ui.action.input input').focus();
    }
  },
  replyIfValid: function(e){
    if (e.keyCode == 13 && this.state.hasReplyText()){
      this.$('#reply-button').click();
    }
  },
  reply: function(){
    var context = this;
    Backbone.ajax({
      url: '/replies',
      method: 'POST',
      accepts: {
        json: 'application/json'
      },
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify({
        reslyp_id: context.model.get('id'),
        text: context.state.replyText
      }),
      success: function(response) {
        context.state.replyText = '';
        context.collection.add(response);
        context.model.fetch();
      },
      error: function(status, err) {
        context.toastr('error', 'Couldn\'t add that reply for some reason :(')
      }
    });
  }
});
