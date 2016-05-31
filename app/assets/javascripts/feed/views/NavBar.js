slypApp.Views.NavBar = slypApp.Base.CompositeView.extend({
  template: '#js-nav-bar-tmpl',
  onRender: function(){
    this.state = {
      slypURL        : '',
      searchTerm     : '',
      creatingSlyp   : false,
      searchType     : 'user_slyps'
    }
    this.binder = rivets.bind(this.$el, { state: this.state, appState: slypApp.state, user: slypApp.user })
  },
  onShow: function(){
    this.initializeSemanticElements();
    this.$('#filter-dropdown').dropdown({
      onChange: function(value, text, selectedItem) {
        switch(value){
          case "reading list":
            slypApp.state.resettingFeed = true;
            slypApp.userSlyps.fetch({
              success: function(collection, response, options) {
                slypApp.state.searchMode = false;
                slypApp.state.showArchived = false;
                slypApp.state.resettingFeed = false;
              }
            });
            break;
          case "done":
            slypApp.state.showArchived = true;
            slypApp.userSlyps.fetchArchived();
            break;
          case "search":
            slypApp.state.searchMode = true;
            slypApp.state.showArchived = true;
            $('#searcher input').focus();
            break;
          default:
            if (!isNaN(value)){
              slypApp.state.showArchived = true;
              slypApp.userSlyps.fetchMutualUserSlyps(value);
            } else{
              toastr['error']('Our robots cannot perform that action right now :(');
            }
            break;
        }
      }
    });
    this.$('#filter-dropdown').dropdown('set selected', 'reading list'); // Performs initial fetch!
  },
  events: {
    'click #back-button'                      : 'exitSearchMode',
    'click #create-button'                    : 'createSlyp',
    'keypress #create-input'                  : 'createSlypIfEnter',
    'click #add-button'                       : 'enterAddMode',
    'keyup #searcher input'                   : 'setAppropriateSearch',
    'keydown #searcher input'                 : 'handleSearchInput',
    'focusout #searcher'                      : 'focusOutSearch',
    'focusout #create-input'                  : 'doneAdding',
    'click .right.secondary.menu.mobile.only' : 'toggleActions',
    'click #search-button'                    : 'enterSearchMode'
  },

  // Event functions
  exitSearchMode: function(){
    slypApp.state.searchMode = false;
    this.refreshFeed();
  },
  refreshFeed: function(){
    this.state.searchTerm = '';
    if ($('#filter-dropdown').dropdown('get value') !== 'reading list'){
      $('#filter-dropdown').dropdown('set selected', 'reading list');
    }
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
      if (this.state.slypURL.http){
        this.doneAdding();
        this.createSlyp();
      } else {
        this.toastr('error', 'URL invalid :(. Please use a valid URL starting with http:// or https://');
      }
    }
  },
  enterAddMode: function(){
    slypApp.state.addMode = true;
    this.$('#create-input').focus();
  },
  enterSearchMode: function(){
    if ($('#filter-dropdown').dropdown('get value') !== 'search'){
      $('#filter-dropdown').dropdown('set selected', 'search');
    }
  },
  setAppropriateSearch: function(){
    var leadingChar = this.state.searchTerm[0] || ''
    if (leadingChar == '@'){
      if (this.state.searchType == 'user_slyps'){
        this.state.searchType = 'friends'
        this.setFriendsSearch();
        this.$('.ui.search').search('cancel query');
        this.$('.ui.search').search('search remote', this.state.searchTerm);
      }

    } else {
        if (this.state.searchType == 'friends'){
          this.state.searchType = 'user_slyps'
          this.setUserSlypsSearch();
          this.$('.ui.search').search('cancel query');
          if (this.state.searchTerm.length >= 2){
            this.$('.ui.search').search('search remote', this.state.searchTerm);
          }
        }
    }
  },
  handleSearchInput: function(e){
    if (e.keyCode == 27){
      this.refreshFeed();
    }
  },
  focusOutSearch: function(){
    if (this.state.searchTerm == ''){
      slypApp.state.searchMode = false;
      this.refreshFeed();
    }
  },
  doneAdding: function(){
    setTimeout(function(){
      slypApp.state.addMode = false;
    }, 200)
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
    this.initializeSearchBar();
  },
  initializeSearchBar: function(){
    if (this.state.searchType == 'friends'){
      this.setFriendsSearch();
    } else if (this.state.searchType == 'user_slyps'){
      this.setUserSlypsSearch();
    }
  },
  setFriendsSearch: function(){
    var context = this;
    this.$('.ui.search')
      .search({
        cache: false,
        apiSettings: {
          url: '/search/friends?q={query}',
          onResponse: function(serverResponse){
            serverResponse = _.map(serverResponse, function(value, index) {
              var _nv =
              {
                title: value.display_name,
                description: value.email,
                image: generateAvatarURL(value.display_name),
                id: value.id
              }
              return _nv
            });
            return { 'success': true, 'results': serverResponse }
          }
        },
        onSelect: function(result, response){
          slypApp.userSlyps.fetchMutualUserSlyps(result.id);
        },
        minCharacters : 1
      });
  },
  setUserSlypsSearch: function(){
    $.fn.search.settings.templates.message = function(message, type) {
        return ''
    }
    this.$('.ui.search')
      .search({
        cache: false,
        apiSettings: {
          url: '/search/user_slyps?q={query}',
          beforeSend: function(settings){
            slypApp.state.resettingFeed = true;
            return settings
          },
          onResponse: function(serverResponse){
            serverResponse = _.map(serverResponse, function(value, index) {
               return value;
            });
            slypApp.userSlyps.reset(serverResponse);
            serverResponse = {};
            slypApp.state.resettingFeed = false;
            return { 'success': true, 'results': serverResponse }
          }
        },
        minCharacters : 3,
      });
  }
});