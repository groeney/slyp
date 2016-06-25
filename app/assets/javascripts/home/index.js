$('#beta-success').modal({
  selector : { close: '.close, .actions .button'}
});

$('#beta-error').modal({
  selector : { close: '.close, .actions .button'}
});

$('#login').click(function(){
  $('#login-modal').modal('show');
});

$.fn.api.settings.api = {
  'create beta': '/users/beta_request'
};

$('#beta-request').api({
  action        : 'create beta',
  method        : 'POST',
  serializeForm : true,
  onSuccess     : function(response, element, xhr) {
    $('#beta-success').find('.content span').text('#' + response.priority);
    $('#beta-success').modal('show');
  },
  onError       : function(errorMessage, element, xhr) {
    if (xhr.status == 400){
      $('#beta-error .content').html("It seems like you are already a user with us. Find the login button at the top right or look for an invitation email from us!");
      $('#beta-error').modal('show');
    } else {
      $('#beta-error').modal('show');
    }
  },
  onFailure       : function(response, element) {
    $('#beta-error').modal('show');
  }
});

$('#beta-request [name=email]').val(getParameterByName('email'));