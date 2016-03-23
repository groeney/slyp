slypApp.Collections.UserSlyps = Backbone.Collection.extend({
  model: slypApp.Models.UserSlyp,
  url: "/user_slyps"
})
