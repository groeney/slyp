slypApp.Collections.Persons = Backbone.Collection.extend({
  model: slypApp.Models.Person,
  url: '/persons',
  search: function(term){
    return this.filter(function(model) {
      var re = new RegExp('^' + term, 'i');
      return re.test(model.get('first_name')) ||
             re.test(model.get('last_name')) || re.test(model.get('email'));
    });
  }
});