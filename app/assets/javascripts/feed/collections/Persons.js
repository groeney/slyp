slypApp.Collections.Persons = Backbone.Collection.extend({
  model: slypApp.Models.Person,
  url: '/persons'
});