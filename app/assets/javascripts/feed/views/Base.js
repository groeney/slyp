slypApp.Base.CompositeView = Backbone.Marionette.CompositeView.extend({
  toastr: function(type, message, options){
    message = typeof message !== 'undefined' ? message : 'Our robots cannot perform that action right now :(';
    type = typeof type !== 'undefined' ? type : 'success'; // Default to success toastr
    options = typeof options !== 'undefined' ? options : {};
    toastr.options = options;
    toastr[type](message);
  },
  toastrFeatNotImplemented: function(){
    this.toastr('info', 'Thanks for your interest in this feature. Coming soon :)')
  }
});