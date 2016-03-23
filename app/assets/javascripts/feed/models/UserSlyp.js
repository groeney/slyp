slypApp.Models.UserSlyp = Backbone.Model.extend({
  dropdownHTML: function(){
    var users = slypApp.users.models;
    reslypedUsers = this.get('reslyps')
      .map(function(el){ return el.user.id });
    var html = '';
    for (var i = 0; i < users.length; i++){
      var user = users[i];
      var is_disabled =
        (reslypedUsers.indexOf(user.id) > -1)
        ? ' disabled' : ''
      var avatar = (user.get('first_name').length) ?
        user.get('first_name') : user.get('email');
      var display_name = (user.get('full_name').length) ?
        user.get('full_name') : user.get('email');
      html +=
        '<div class="item' + is_disabled + '" data-value="'
        + user.get('email') + '"><img class="round ui avatar right spaced image" avatar="'
        + avatar + '"><span>' + display_name
        + '</span></div>'
    }
    return html
  }
})