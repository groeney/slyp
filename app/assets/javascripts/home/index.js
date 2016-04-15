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
    'create beta': '/beta_request'
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
      $('#beta-error').modal('show');
    },
    onFailure       : function(response, element) {
      $('#beta-error').modal('show');
    }
  });

