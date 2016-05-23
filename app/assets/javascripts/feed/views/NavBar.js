slypApp.Views.NavBar = slypApp.Base.CompositeView.extend({
  template: '#js-nav-bar-tmpl',
  onRender: function(){
    this.state = {
      slypURL      : '',
      searchTerm   : '',
      creatingSlyp : false
    }
    this.binder = rivets.bind(this.$el, { state: this.state, appState: slypApp.state })
  },
  onShow: function(){
    this.initializeSemanticElements();
  },
  events: {
    'click #refresh'                          : 'refreshFeed',
    'click #back-button'                      : 'refreshFeed',
    'click #create-popup button'              : 'createSlyp',
    'keypress #create-popup input'            : 'createSlypIfEnter',
    'focusin #searcher input'                 : 'enterSearchMode',
    'focusout #searcher'                      : 'doneSearching',
    'click .right.secondary.menu.mobile.only' : 'toggleActions'
  },

  // Event functions
  refreshFeed: function(){
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
  createSlyp: function(){
    var context = this;
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
          context.$('#create-popup').popup('hide');
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
  },
  createSlypIfEnter: function(e){
    if (e.keyCode==13){
      this.createSlyp();
    }
  },
  enterSearchMode: function(){
    slypApp.state.searchMode = true;
  },
  doneSearching: function(){
    if (this.state.searchTerm === ''){
      this.refreshFeed();
    }
  },
  toggleActions: function(){
    this.$('#right-menu').toggleClass('hide');
    this.$('#right-menu').toggleClass('right');
    slypApp.state.actionsMode = !slypApp.state.actionsMode
  },

  // Helper functions
  initializeSemanticElements: function(){
    var context = this;
    // Misc UI
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

    // Search
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

    // Create
    this.$('#create-button').popup({
      on       : 'click',
      position : 'left center',
      popup    : '#create-popup',
      onShow   : function(){
        resizePopup();
        setTimeout(function() { context.$('#create-popup input').focus() }, 100);
      }
    });
  }
});