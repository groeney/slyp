slypApp.Views.Reply = slypApp.Base.CompositeView.extend({
  template : '#js-reply-tmpl',
  className: 'comment',
  events   : {
    'click a.edit'         : 'enterEditMode',
    'click #cancel-update' : 'resetFromEditMode',
    'click #update'        : 'updateReply',
    'click #delete'        : 'deleteReply',
    'keypress input'       : 'handleInput'
  },
  enterEditMode: function(){
    this.state.cachedText = this.model.get('text');
    this.$('.text input').val(this.model.get('text'));
    this.state.editMode = true;
  },
  exitEditMode: function(){
    this.state.cachedText = '';
    this.state.editMode = false;
  },
  resetFromEditMode: function(){
    this.model.fetch();
    this.exitEditMode();
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
  handleInput: function(e){
    if (e.keyCode == 13){
      this.updateReply();
    } else if (e.keyCode == 27){
      this.resetFromEditMode();
    }
  },
  initialize: function(){
    this.state = {
      editMode   : false,
      cachedText : ''
    }
    this.binder = rivets.bind(this.$el, { reply: this.model, state: this.state });
  },
  onRender: function(){
    this.binder = rivets.bind(this.$el, { reply: this.model, state: this.state });
  },
  onShow: function(){
    this.$('.avatar')
      .popup({
        delay :{
          show: 100,
          hide: 200
        }
      });
    this.renderAvatars();
  },
  renderAvatars: function(){
    window.LetterAvatar.transform_el(this.el);
  }
});