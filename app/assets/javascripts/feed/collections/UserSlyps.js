slypApp.Collections.UserSlyps = Backbone.Collection.extend({
  model: slypApp.Models.UserSlyp,
  url: '/user_slyps',
  moveToFront: function(model) {
    var index = this.indexOf(model);
    if (index > 0) {
      this.remove(model);
      this.add(model, {at: 0});
    }
  },
  moveToBack: function(model) {
    var index = this.indexOf(model);
    var backIndex = this.models.length - 1;
    if (index < backIndex) {
      this.remove(model);
      this.add(model, {at: backIndex});
    }
  },
  fetchMutualUserSlyps: function(friend_id) {
    slypApp.state.resettingFeed = true;
    this.fetch({
      url: '/search/mutual_user_slyps',
      data: {
        friend_id: friend_id
      },
      reset: true,
      success: function(model, response, options){
        slypApp.state.resettingFeed = false;
      },
      error: function(model, response, options){
        slypApp.state.resettingFeed = false;
        toastr['error']('Something went wrong, sorry :(');
      }
    });
  },
  fetchArchived: function(){
    slypApp.state.resettingFeed = true;
    this.fetch({
      data: {
        archived: true
      },
      reset: true,
      success: function(model, response, options){
        slypApp.state.resettingFeed = false;
      },
      error: function(model, response, options){
        slypApp.state.resettingFeed = false;
        toastr['error']('Something went wrong, sorry :(');
      }
    });
  }
});
