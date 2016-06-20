slypApp.Collections.UserSlyps = Backbone.Collection.extend({
  initialize: function(){
    this._meta = {
        recent: true,
        friendID: null
    };
  },
  model: slypApp.Models.UserSlyp,
  meta: function(prop, value){
    if (value === undefined) {
        return this._meta[prop]
    } else {
        this._meta[prop] = value;
    }
  },
  url: function(){
    if (this.meta('friendID') !== null){
      return '/user_slyps?friend_id=' + this.meta('friendID')
    } else if (this.meta('recent')) {
      return '/user_slyps?recent=' + this.meta('recent')
    } else {
      return '/user_slyps'
    }
  },
  paginate: function(opts){
    var fetchOptions = opts || {}
    slypApp.state.toPaginate = true;
    slypApp.state.resettingFeed = true;
    var offset = fetchOptions.reset ? 0 : this.length;
    var step = 10;
    var paginateOptions = {
      remove: false,
      data: $.param({ offset: offset }),
      error: function(model, response, options){
        toastr['error']('Something went wrong, sorry :(');
      }
    }
    var options = $.extend(fetchOptions, paginateOptions);
    this.fetch(options).done(function(response){
      if (response.length < step){
        slypApp.state.toPaginate = false;
      }
      slypApp.state.resettingFeed = false;
   });
  },
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
  }
});
