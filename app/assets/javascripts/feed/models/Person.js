slypApp.Models.Person = Backbone.Model.extend({
  urlRoot: '/person',
  isFriend: function(){
    return this.get('friendship_id') != null
  },
  toggleFriendship: function(){
    return this.isFriend() ? this.destroyFriendship() : this.createFriendship()
  },
  createFriendship: function(){
    var context = this;
    Backbone.ajax({
      url: '/friendships',
      method: 'POST',
      accepts: {
        json: 'application/json'
      },
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify({
        user_id: this.get('id')
      }),
      success: function(response) {
        context.set('friendship_id', response.id);
        context.set('email', response.email);
      }
    });
  },
  destroyFriendship: function(){
    if (this.get('friendship_id') == null){
      return
    }

    var context = this;
    Backbone.ajax({
      url: '/friendships/' + this.get('friendship_id'),
      method: 'DELETE',
      accepts: {
        json: 'application/json'
      },
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify({
        id: this.get('friendship_id')
      }),
      success: function(response) {
        context.set('friendship_id', null);
        context.set('email', null);
      },
      error: function(model, error){
        toastr['error'](model.responseJSON[0].message.message);
      }
    });
  }
});