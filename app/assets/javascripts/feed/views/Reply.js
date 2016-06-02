slypApp.Views.Reply = slypApp.Base.CompositeView.extend({
  template : '#js-reply-tmpl',
  className: 'comment',
  attributes: {
    'rv-data-reply-id' : 'reply:id'
  },
  onRender: function(){
    this.state = {
      editMode   : false,
      cachedText : ''
    }
    this.binder = rivets.bind(this.$el, { reply: this.model, state: this.state });
  },
  onShow: function(){
    this.$('.avatar').popup();
    this.$('textarea').each(function () {
      this.setAttribute('style', 'height:' + (this.scrollHeight) + 'px;overflow-y:hidden;');
    }).on('input', function () {
      this.style.height = 'auto';
      this.style.height = (this.scrollHeight) + 'px';
    });
  },
  events: {
    'click i.edit'         : 'enterEditMode',
    'keypress area'        : 'handleKeypress',
    'keydown textarea'     : 'handleKeydown',
    'click #update'        : 'updateReply',
    'click #delete'        : 'deleteReply',
    'click #cancel-update' : 'resetFromEditMode'
  },

  // Event functions
  enterEditMode: function(){
    this.state.cachedText = this.model.get('text');
    this.state.editMode = true;
    this.$('textarea').focus();
    this.$('textarea').val(this.model.get('text'));
    this.$('textarea').trigger('input');
  },
  handleKeypress: function(e){
    if (e.keyCode == 13){
      this.updateReply();
    }
  },
  handleKeydown: function(e){
    if (e.keyCode == 27){
      this.resetFromEditMode();
    }
  },
  updateReply: function(e){
    var context = this;
    this.model.save(null, {
      success: function(model, response, options){
        context.exitEditMode();
      },
      error: function(model, response, options){
        context.toastr('error', 'Having trouble updating this reply right now, try reloading?');
      }
    });
  },
  deleteReply: function(){
    this.model.destroy();
  },
  resetFromEditMode: function(){
    this.model.fetch();
    this.exitEditMode();
  },

  // Helper functions
  exitEditMode: function(){
    this.state.cachedText = '';
    this.state.editMode = false;
  }
});