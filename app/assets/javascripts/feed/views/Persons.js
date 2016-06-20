var NoPersonsMessage = Backbone.Marionette.ItemView.extend({
  template: '#js-no-persons-message-tmpl'
})

slypApp.Views.Persons = Backbone.Marionette.CollectionView.extend({
  className : 'ui middle aligned divided list',
  childView : slypApp.Views.Person,
  emptyView : NoPersonsMessage
});