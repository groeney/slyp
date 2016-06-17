slypApp.Models.Person = Backbone.Model.extend({
  urlRoot: '/person',
  isFriend: function(){
    return this.get('friendship_id') != null
  },
  toggleFriendship: function(callback){
    return this.isFriend() ? this.destroyFriendship(callback) : this.createFriendship(callback)
  },
  createFriendship: function(callback){
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
    }).complete(callback);
  },
  destroyFriendship: function(callback){
    if (this.get('friendship_id') == null){
      return callback()
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
    }).complete(callback);
  }
});