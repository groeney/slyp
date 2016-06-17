slypApp.Views.Person = Backbone.Marionette.ItemView.extend({
  template: '#js-person-tmpl',
  className: 'item',
  attributes: {
    'rv-data-person-id' : 'person:id',
    'style'             : 'padding:1em;'
  },
  onRender: function(){
    this.binder = rivets.bind(this.$el, {
      person: this.model
    });
  },
  events: {
    'click button.ui.icon' : 'toggleFriendship'
  },
  toggleFriendship: function(){
    this.model.toggleFriendship();
  }
})