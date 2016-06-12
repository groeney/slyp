slypApp.Base.CompositeView = Backbone.Marionette.CompositeView.extend({
  toastr: function(type, message, options){
    message = typeof message !== 'undefined' ? message : 'Our robots cannot perform that action right now :(';
    type = typeof type !== 'undefined' ? type : 'success'; // Default to success toastr
    options = typeof options !== 'undefined' ? options : { 'positionClass': 'toast-top-center' };
    toastr.options = options;
    toastr[type](message);
  },
  notImplemented: function(){
    this.toastr('info', 'We\'ve logged your interest. Coming soon :)');
  }
});