slypApp.Views.NavBar = slypApp.Views.Base.extend({
  template: '#js-nav-bar-tmpl',
  className: 'ui top fixed borderless stackable large menu',
  events:{
    'keypress #creator input'     : 'createSlypIfEnter',
    'click .circle.add.link.icon' : 'createSlyp',
    'focusin #searcher input'    : 'enterSearchMode',
    'keypress #searcher input'    : 'searchingIfEnter',
    'click #back-button'          : 'exitSearchMode',
    'focusout #searcher'          : 'doneSearching',
    'click .left.secondary.menu .mobile.only' : 'toggleActions'
  },
  toggleActions: function(){
    this.$('#right-menu').toggleClass('hide');
    this.$('#right-menu').toggleClass('right');
  },
  enterSearchMode: function(){
    slypApp.state.searchMode = true;
  },
  doneSearching: function(){
    if (this.state.searchTerm === ''){
      this.exitSearchMode();
    }
  },
  exitSearchMode: function(){
    slypApp.state.resettingFeed = true;
    var context = this;
    slypApp.userSlyps.fetch({
      success: function(collection, response, options) {
        slypApp.state.searchMode = false;
        context.state.searchTerm = '';
        slypApp.state.resettingFeed = false;
      }
    });
  },
  onRender: function(){
    this.state = {
      slypURL      : '',
      searchTerm   : '',
      creatingSlyp : false
    }
    this.binder = rivets.bind(this.$el, { state: this.state, appState: slypApp.state })

    this.$('#user-actions').dropdown({
      on: 'hover'
    });
    this.$('#display-name').popup({
      position: 'left center',
      delay   : {
        show: 1000,
        hide: 0
        }
      });
    $.fn.search.settings.templates = {
      message: function(message, type) {
        return ''
      }
    }
    this.$('.ui.search')
      .search({
        cache: false,
        apiSettings: {
          url: '/search/user_slyps?q={query}',
          onResponse: function(serverResponse){
            serverResponse = _.map(serverResponse, function(value, index) {
               return value;
            });
            slypApp.userSlyps.reset(serverResponse);
            serverResponse = {};
            return {'success': true, 'results': serverResponse }
          }
        },
        minCharacters : 3,
      });
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
      var context = this;
      Backbone.ajax({
        url: '/user_slyps',
        method: 'POST',
        accepts: {
          json: 'application/json'
        },
        contentType: 'application/json',
        dataType: 'json',
        data: JSON.stringify({
          url: context.state.slypURL
        }),
        success: function(response) {
          var contains = (slypApp.userSlyps.get(response.id) != null);
          slypApp.userSlyps.add(response, { merge: true });
          var userSlyp = slypApp.userSlyps.get(response.id);
          if (userSlyp.get('archived')){
            userSlyp.save({ archived: false });
            context.toastr('info', 'We took this slyp out of your archive for you :)');
          } else if (contains) {
            context.toastr('info', 'We just moved this slyp to the front for you :)');
          } else {
            context.toastr('success', 'Added slyp! :)');
          }
          userSlyp.moveToFront();
          context.state.slypURL = '';
          context.state.creatingSlyp = false;
        },
        error: function(status, err) {
          if (context.state.slypURL.http){
            context.toastr('error', 'URL invalid :(. Please use a valid URL starting with http:// or https://');
          } else {
            context.toastr('error');
          }
          context.state.creatingSlyp = false;
        }
      });
    } else {
      context.toastr('error', 'URL invalid :(. Please use a valid URL starting with http:// or https://')
    }
  }
});

