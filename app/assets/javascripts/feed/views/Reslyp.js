slypApp.Views.Reslyp = slypApp.Base.CompositeView.extend({
  template           : '#js-reslyp-tmpl',
  className          : 'ui basic segment comment',
  childView          : slypApp.Views.Reply,
  childViewContainer : '.js-replies-container',
  attributes         : {
    'rv-class-loading' : 'state.loading'
  },
  initialize: function(options){
    this.collection = options.model.get('replies');
  },
  onRender: function(){
    var context = this;
    this.state = {
      hideReplies: true,
      replyText  : '',
      loading    : false
    }
    this.state.hasReplyText = function(){
      return context.state.replyText.length > 0
    }
    this.binder = rivets.bind(this.$el, { reslyp: this.model, state: this.state });
  },
  onShow: function(){
    this.$('.avatar').popup();
    this.$('textarea').each(function () {
      this.setAttribute('style', 'height:' + (this.scrollHeight) + 'px;overflow-y:hidden;');
    }).on('input', function () {
      this.style.height = 'auto';
      this.style.height = (this.scrollHeight) + 'px';
    });
    var userSlyp = this.model.get('user_slyp');
    if (userSlyp != null && userSlyp.get('reslyps').length <= 1){ // If only 1 reslyp, open replies by default
      this.toggleReplies();
    }
  },
  onDestroy: function(){
    if (this.binder) this.binder.unbind();
  },
  events: {
    'click .actions a'        : 'toggleReplies',
    'click #reply-button'     : 'reply',
    'keypress .form textarea' : 'handleKeypress',
    'keydown .form textarea'  : 'handleKeydown',
    'click a.user-display'    : 'fetchMutualUserSlyps'
  },

  // Event functions
  toggleReplies: function(){
    if (this.state.hideReplies){
      this.state.loading = true;
      var context = this;
      this.collection.fetch({
        reset: true,
        success: function(model, response, options){
          context.state.loading = false;
          context.state.hideReplies = false;
          context.$('#reply-area').focus();
          context.model.get('user_slyp').fetch();
          context.model.fetch();
        },
        error: function(model, response, options){
          context.state.loading = false;
          context.toastr('error', 'eeek. We had troubles fetching your conversations.')
        }
      });
    } else {
      this.state.hideReplies = true;
    }
  },
  reply: function(){
    var replyText = this.state.replyText;
    this.state.replyText = '';
    this.state.loading = true;
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
        text: replyText
      }),
      success: function(response) {
        context.collection.add(response);
        context.model.fetch();
        context.model.get('user_slyp').fetch();
        context.state.loading = false;
      },
      error: function(status, err) {
        context.state.replyText = replyText;
        context.state.loading = false;
        context.toastr('error', 'Couldn\'t add that reply for some reason :(')
      }
    });
  },
  handleKeypress: function(e){
    if (e.keyCode == 13 && this.state.hasReplyText()){
      e.preventDefault();
      this.$('#reply-button').click();
    }
  },
  handleKeydown: function(e){
    if (e.keyCode == 38 && !this.state.hasReplyText()){
      var validReplies = this.model.get('replies').where({ sender_id: slypApp.user.get('id') });
      if (validReplies.length > 0){
        this.$('.comment[data-reply-id="' + validReplies[validReplies.length-1].get('id') + '"] i.edit').click();
      }
    }
  },
  fetchMutualUserSlyps: function(e){
    $('.ui.right.sidebar').sidebar('toggle');
    var friend_id = $(e.toElement).attr('data-user-id');
    if (!friend_id){
      return
    }

    if (parseInt(friend_id) !== slypApp.user.get('id')) {
      if ($('#filter-dropdown').dropdown('get item', friend_id)){
        $('#filter-dropdown').dropdown('set selected', friend_id);
      } else {
        slypApp.user.fetch({
          success: function(){
            $('#filter-dropdown').dropdown('set selected', friend_id);
          }
        })
      }
    } else {
      $('#filter-dropdown').dropdown('set selected', 'recent');
    }
  }
});