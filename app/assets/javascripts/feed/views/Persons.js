slypApp.Views.Persons = Backbone.Marionette.CollectionView.extend({
  className : 'ui middle aligned divided list',
  childView : slypApp.Views.Person,
  initialize: function(options){
    this.collection = new slypApp.Collections.Persons(options.models);
    this.state = {
      showEmail: options.showEmail
    }
  },
  childViewOptions: function(model, index) {
    return {
      showEmail: this.state.showEmail
    }
  }
});