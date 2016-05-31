slypApp.Views.Reply = slypApp.Base.CompositeView.extend({
  template : '#js-reply-tmpl',
  className: 'comment',
  onRender: function(){
    this.state = {
      editMode   : false,
      cachedText : ''
    }
    this.binder = rivets.bind(this.$el, { reply: this.model, state: this.state });
  },
  onShow: function(){
    this.$('.avatar').popup();
  },
  events: {
    'click i.edit'         : 'enterEditMode',
    'keypress input'       : 'handleInput',
    'click #update'        : 'updateReply',
    'click #delete'        : 'deleteReply',
    'click #cancel-update' : 'resetFromEditMode'
  },

  // Event functions
  enterEditMode: function(){
    this.state.cachedText = this.model.get('text');
    this.$('.text textarea').val(this.model.get('text'));
    this.state.editMode = true;
  },
  handleInput: function(e){
    if (e.keyCode == 13){
      this.updateReply();
    } else if (e.keyCode == 27){
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