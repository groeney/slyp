slypApp.Views.Persons = Backbone.Marionette.CollectionView.extend({
  className : 'ui middle aligned divided list',
  childView : slypApp.Views.Person,
  initialize: function(options){
    this.collection = new slypApp.Collections.Persons(options.models);
  }
});