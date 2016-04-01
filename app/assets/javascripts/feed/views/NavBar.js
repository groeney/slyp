slypApp.Views.NavBar = slypApp.Views.Base.extend({
  template: '#js-nav-bar-tmpl',
  className: 'ui top fixed borderless menu',
  attributes: {
    'rv-class-inverted' : 'appState.searchMode',
    'rv-class-grey'     : 'appState.searchMode'
  },
  events:{
    'keypress #creator input'     : 'createSlypIfEnter',
    'paste #creator input'        : 'quietlyCreateSlyp',
    'click .circle.add.link.icon' : 'createSlyp',
    'focusout #searcher input'    : 'resetFeed',
    'focusin #searcher input'    : 'enterSearchMode',
    'keypress #searcher input'    : 'searchingIfEnter',
    'click #back-button'          : 'exitSearchMode'
  },
  enterSearchMode: function(){
    slypApp.state.searchMode = true;
  },
  exitSearchMode: function(){
    slypApp.state.searchMode = false;
    this.state.searchTerm = '';
    slypApp.userSlyps.fetch();
  },
  searchingIfEnter: function(e){
    if (e.keyCode == 13){
      // slypApp.state.searching = true;
    }
  },
  resetFeed: function(){
    // this.state.searchTerm = '';
    // slypApp.userSlyps.fetch();
  },
  onRender: function(){
    this.state = {
      slypURL      : '',
      searchTerm   : '',
      creatingSlyp : false
    }
    this.binder = rivets.bind(this.$el, { state: this.state, appState: slypApp.state })

    this.$('#user-actions').dropdown();

    this.$('.ui.search')
      .search({
        cache: false,
        apiSettings: {
          url: '/search/user_slyps?q={query}',
          onResponse: function(serverResponse){
            slypApp.state.searching = false;
            serverResponse = _.map(serverResponse, function(value, index) {
               return value;
            });
            slypApp.userSlyps.reset(serverResponse);

            serverResponse.forEach(function(result, index, serverResponse) {
              serverResponse[index].image = result.display_url
              serverResponse[index].description = result.author
            });
            return {'success': true, 'results': serverResponse}
          }
        },
        fields: {
        },
        minCharacters : 3,
      });
  },
  quietlyCreateSlyp: function(e){
    setTimeout( () => {
      if (this.state.slypURL.http){
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
            console.debug('Quietly created slyp ' + this.state.slypURL);
          }
        });
      }
    }, 50);
  },
  createSlypIfEnter: function(e){
    if (e.keyCode==13){
      this.createSlyp();
    }
  },
  createSlyp: function(){
    if (this.state.slypURL.http){
      console.debug('Creating ' + this.state.slypURL + '...');
      this.state.creatingSlyp = true;
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
          this.state.creatingSlyp = false;
        },
        error: (status, err) => {
          if (this.state.slypURL.http){
            this.toastr('error', 'URL invalid :(. Please use a valid URL starting with http:// or https://');
          } else {
            this.toastr('error');
          }
          this.state.creatingSlyp = false;
        }
      });
    } else {
      this.toastr('error', 'URL invalid :(. Please use a valid URL starting with http:// or https://')
    }
  }
});

