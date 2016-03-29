slypApp.Views.NavBar = slypApp.Views.Base.extend({
  template: '#js-nav-bar-tmpl',
  className: 'ui stackable top fixed four item menu navbar',
  events:{
    'keypress input'              : 'createSlypIfEnter',
    'paste input'                 : 'quietlyCreateSlyp',
    'click .circle.add.link.icon' : 'createSlyp'
  },
  onRender: function(){
    this.state = {
      slypURL:''
    }
    this.binder = rivets.bind(this.$el, { state: this.state })
  },
  quietlyCreateSlyp: function(e){
    setTimeout( () => {
      Backbone.ajax({
        url: '/slyps',
        method: 'POST',
        accepts: {
          json: 'application/json'
        },
        contentType: 'application/json',
        dataType: 'json',
        data: JSON.stringify({
          url: this.state.slypURL
        }),
        success: (response) => {
          console.debug('Quietly created slyp ' + this.state.slypURL)
        }
      });
    }, 10);
  },
  createSlypIfEnter: function(e){
    if (e.keyCode==13){
      this.createSlyp();
    }
  },
  createSlyp: function(){
    if (this.state.slypURL.http){
      console.debug('Creating ' + this.state.slypURL + '...');
      Backbone.ajax({
        url: '/user_slyps',
        method: 'POST',
        accepts: {
          json: 'application/json'
        },
        contentType: 'application/json',
        dataType: 'json',
        data: JSON.stringify({
          url: this.state.slypURL
        }),
        success: (response) => {
          slypApp.userSlyps.add(response, { merge: true });
          var userSlyp = slypApp.userSlyps.get(response.id);
          if (userSlyp.get('archived')){
            userSlyp.set('archived', false);
            this.toastr('info', 'You already had this slyp, so we just removed it from your archive :)');
          } else {
            this.toastr('success', 'Added slyp! :)');
          }
          userSlyp.moveToFront();
          this.state.slypURL = '';
        },
        error: (status, err) => {
          if (this.state.slypURL.http){
            this.toastr('error', 'URL invalid :(. Please use a valid URL starting with http:// or https://');
          } else {
            this.toastr('error');
          }
        }
      });
    }
  }
});

