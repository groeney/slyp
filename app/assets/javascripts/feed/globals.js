var openSettings = function(){
  setTimeout(function(){
    $('#goto-settings').click();
  }, 250);
}

var openEmailsSettings = function(){
  openSettings();
  setTimeout(function(){
    $('#emails').click()
  }, 500);
}

var openFriendsSettings = function(){
  openSettings();
  setTimeout(function(){
    $('#friends').click()
  }, 500);
}

Backbone.Collection.prototype.whereNot = function(options) {
  var key = Object.keys(options).pop();
  var value = options[key];
  return this.filter(function(model) {
    return model.get(key) !== value;
  });
}
