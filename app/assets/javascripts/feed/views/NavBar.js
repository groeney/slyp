slypApp.Views.NavBar = Backbone.Marionette.CompositeView.extend({
  template: '#js-nav-bar-tmpl',
  onRender: function(){
    this.state = {
      searchTerm     : '',
      creatingSlyp   : false,
      searchType     : 'user_slyps'
    }
    this.binder = rivets.bind(this.$el, {
      state: this.state,
      appState: slypApp.state,
      user: slypApp.user
    })
    var context = this;
    $(document).keydown(function(e){
      if( e.target.nodeName == 'INPUT' || e.target.nodeName == 'TEXTAREA' ) return;
      if (e.shiftKey && e.keyCode == 187){
        e.preventDefault();
        context.$('#add-button').click();
      }
    });

    this.hideShowOnScroll();
  },
  onShow: function(){
    this.initializeSemanticElements();
    var onboarded = ($.cookie('_onboard_tour') == 'true');
    if (!onboarded){
      var context = this;
      setTimeout(function(){
        context.$('#goto-help').click();
      }, 1500);
    }
  },
  events: {
    'click #home'                             : 'forceRefresh',
    'click #back-button'                      : 'exitSearchMode',
    'click #create-button'                    : 'createSlyp',
    'keypress #create-input'                  : 'createSlypIfEnter',
    'click #add-button'                       : 'enterAddMode',
    'keyup #searcher input'                   : 'setAppropriateSearch',
    'keydown #searcher input'                 : 'handleSearchInput',
    'focusout #searcher'                      : 'focusOutSearch',
    'focusout #create-input'                  : 'doneAdding',
    'click #search-button'                    : 'enterSearchMode',
    'click #explore-button'                   : function(){ notImplemented('Explore'); },
    'click #goto-settings'                    : 'goToSettings',
    'click #goto-help'                        : 'showHelp'
  },

  // Event functions
  exitSearchMode: function(){
    slypApp.state.searchMode = false;
    this.refreshFeed();
  },
  forceRefresh: function(){
    $('#filter-dropdown').dropdown('set selected', 'all');
  },
  refreshFeed: function(){
    this.state.searchTerm = '';
    if ($('#filter-dropdown').dropdown('get value') !== 'all'){
      $('#filter-dropdown').dropdown('set selected', 'all');
    }
  },
  createSlyp: function(){
    var context = this;
    if (slypApp.state.slypURL == ''){
      this.$('#create-input').trigger('keypress');
    }
    if (slypApp.state.slypURL.http){
      slypApp.state.resettingFeed = true;
      Backbone.ajax({
        url: '/user_slyps',
        method: 'POST',
        accepts: {
          json: 'application/json'
        },
        contentType: 'application/json',
        dataType: 'json',
        data: JSON.stringify({
          url: slypApp.state.slypURL
        }),
        success: function(response) {
          var exists = (slypApp.userSlyps.get(response.id) != null);
          slypApp.userSlyps.add(response, { merge: true });
          var userSlyp = slypApp.userSlyps.get(response.id);
          if (userSlyp.get('archived')){
            userSlyp.save({ archived: false });
            _toastr('info', 'We found this slyp already in your feed!');
          } else if (exists) {
            _toastr('info', 'We found this slyp already in your feed!');
          } else {
            _toastr('success', 'Created a slyp!');

            // Analytics
            analytics.track('Created New Slyp', {
              slyp_title: response.title,
              total_reslyps: response.total_reslyps,
              slyp_id: response.slyp_id,
              slyp_url: response.url
            });
          }
          userSlyp.moveToFront();
          slypApp.state.slypURL = '';
          slypApp.state.resettingFeed = false;
          $('#card-0 #send-button').click();

          // Onboarder
          shepherdMediator.trigger('proceedTo', '3 select');
        },
        error: function(status, err) {
          if (slypApp.state.slypURL.http){
            _toastr('error', 'URL invalid :(. Please use a valid URL starting with http:// or https://');
          } else {
            _toastr('error');
          }
          slypApp.state.resettingFeed = false;
        }
      });
    } else {
      _toastr('error', 'URL invalid :(. Please use a valid URL starting with http:// or https://')
    }
  },
  createSlypIfEnter: function(e){
    if (e.keyCode==13){
      if (slypApp.state.slypURL.http){
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

    // Onboarder
    shepherdMediator.trigger('proceedTo', '2 create');
  },
  enterSearchMode: function(){
    if ($('#filter-dropdown').dropdown('get value') !== 'search'){
      $('#filter-dropdown').dropdown('set selected', 'search');
    }
  },
  setAppropriateSearch: function(){
    var leadingChar = this.state.searchTerm[0] || ''
    if (leadingChar == '@'){
      if (this.state.searchType !== 'friends'){
        this.state.searchType = 'friends';
        this.setFriendsSearch();
        this.$('.ui.search').search('cancel query');
        this.$('.ui.search').search('search remote', this.state.searchTerm);
      }

    } else {
        if (this.state.searchType !== 'user_slyps'){
          this.state.searchType = 'user_slyps';
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
      this.exitSearchMode();
    }
  },
  focusOutSearch: function(){
    if (this.state.searchTerm == ''){
      this.exitSearchMode();
    }
  },
  doneAdding: function(){
    setTimeout(function(){
      slypApp.state.addMode = false;
    }, 200);
  },
  goToSettings: function(){
    slypApp.settingsSidebarRegion.show(new slypApp.Views.SettingsSidebar({ model: slypApp.user }));
    $('#js-settings-sidebar-region').sidebar('toggle');
  },
  showHelp: function(){
    shepherdMediator.trigger('start-onboarding');
  },

  // Helper functions
  hideShowOnScroll: function(){
    var lastScrollTop = 0, delta = 5;
    var context = this;
    $(window).scroll(function(){
      var nowScrollTop = $(this).scrollTop();
      if(Math.abs(lastScrollTop - nowScrollTop) >= delta){
        var fadeTime = 750;
        if (nowScrollTop > lastScrollTop){
          $(context.$el).fadeOut(fadeTime);
          $('#filter-dropdown').fadeOut(fadeTime);
        } else {
          $(context.$el).fadeIn(fadeTime);
          $('#filter-dropdown').fadeIn(fadeTime);
        }
        lastScrollTop = nowScrollTop;
      }
    });
  },
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
          slypApp.userSlyps.meta('friendID', result.id)
          slypApp.userSlyps.paginate({ reset: true });
        },
        minCharacters : 1
      });
  },
  setUserSlypsSearch: function(){
    var context = this;
    var noResults = 'noResults';
    $.fn.search.settings.templates.message = function(message, type) {
      return ''
    }
    this.$('.ui.search')
        .search({
          cache: false,
          searchDelay: 350,
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
              if (serverResponse.length == 0){
                _toastr('error', 'No slyps found for that search.')
              }
              serverResponse = {};
              slypApp.state.resettingFeed = false;
              return { 'success': true, 'results': serverResponse }
            }
          },
          minCharacters : 3,
        });
  }
});