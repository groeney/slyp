slypApp.Collections.UserSlyps = Backbone.Collection.extend({
  model: slypApp.Models.UserSlyp,
  url: '/user_slyps',
  initialize: function(){
    this.fetch();
    var context = this;
    window.setInterval(function(){
      if (!slypApp.state.searchMode && !slypApp.state.resettingFeed && !slypApp.state.addMode){
        context.fetch();
      }
    }, 30000);
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
