slypApp.Views.SettingsSidebar = Backbone.Marionette.LayoutView.extend({
  template: '#js-settings-sidebar-region-tmpl',
  className: 'ui basic right aligned segment',
  regions:{
    persons: '#persons'
  },
  initialize: function(options){
    this.state = {
      saving: false,
      profile: true,
      friends: false,
      emails: false,
      terms: false,
      privacy: false,
      editProfile: false,
      inviteEmail: '',
      personSearchTerm: '',
      searchingPersons: false,
      iphoneWhiteScreenBug: slypApp.state.isMobile()
    }
    var context = this;
    this.state.inviteEmailValid = function(){
      return validateEmail(context.state.inviteEmail);
    }
    this.state.personSearchTermValid = function(){
      return context.state.personSearchTerm.length > 0;
    }
  },
  onRender: function(){
    this.binder = rivets.bind(this.$el, {
      user: slypApp.user,
      state: this.state
    });
  },
  onShow: function(){
    this.initializeSemanticElements();
  },
  events: {
    'click #edit'                  : 'enterEditMode',
    'click #cancel'                : 'cancelEdit',
    'click #save'                  : 'saveChanges',
    'click #close-sidebar'         : 'closeSidebar',
    'click #profile'               : 'showProfile',
    'click #emails'                : 'showEmails',
    'click #terms'                 : 'showTerms',
    'click #privacy'               : 'showPrivacy',
    'click #friends'               : 'showFriends',
    'click #person-search .remove' : 'showFriends',
    'keyup #person-search input'   : 'searchPersonsIfValid',
    'click #person-search button'  : 'searchPersons',
    'keyup #invite-input'          : 'inviteByEmailIfValid',
    'click #invite-button'         : 'inviteByEmail',
    'click #update-password'       : function(){ notImplemented('Update Password'); }
  },

  // UI event functions
  enterEditMode: function(){
    if (this.state.profile){
      this.state.editProfile = true;
    }
  },
  cancelEdit: function(){
    this.model.fetch();
    this.exitEditMode();
  },
  saveChanges: function(){
    if (this.model.get('first_name') && this.model.get('last_name')){
      this.persist();
      this.exitEditMode();
    } else {
      toastr['error']('First and last names cannot be empty.');
      this.state.disabled = true;
      var context = this;
      this.model.fetch({
        success: function(){
          context.state.disabled = false;
        },
        error: function(){
          context.state.disabled = false;
        }
      });
    }
  },
  closeSidebar: function(){
    $('#js-settings-sidebar-region').sidebar('toggle');
  },
  showProfile: function(){
    this.changeMode('profile');
  },
  showFriends: function(){
    this.state.searchingPersons = false;
    this.state.personSearchTerm = '';
    var friendModels = slypApp.persons.whereNot({ friendship_id: null })
    var friendsCollection = new slypApp.Collections.Persons(friendModels)
    this.showChildView('persons', new slypApp.Views.Persons({
      collection: friendsCollection
    }));
    this.changeMode('friends');
  },
  searchPersonsIfValid: function(e){
    if (e.keyCode == 13){
      this.$('#person-search button').click();
    }
  },
  searchPersons: function(el){
    if (!$(el.target).hasClass('disabled')){
      this.state.searchingPersons = true;
      var searchModels = slypApp.persons.search(this.state.personSearchTerm);
      var searchCollection = new slypApp.Collections.Persons(searchModels);
      this.showChildView('persons', new slypApp.Views.Persons({
        collection: searchCollection
      }));
    }
  },
  showEmails: function(){
    this.changeMode('emails');
  },
  showTerms: function(){
    this.changeMode('terms');
  },
  showPrivacy: function(){
    this.changeMode('privacy');
  },
  inviteByEmailIfValid: function(e){
    if (e.keyCode == 13) {
      this.$('#invite-button').click();
    }
  },
  inviteByEmail: function(){
    if (validateEmail(this.state.inviteEmail)){
      var context = this;
      this.state.saving = true;
      Backbone.ajax({
        url: '/persons/invite',
        method: 'POST',
        accepts: {
          json: 'application/json'
        },
        contentType: 'application/json',
        dataType: 'json',
        data: JSON.stringify({
          email: this.state.inviteEmail
        }),
        success: function(response) {
          var newPerson = !(slypApp.persons.findWhere({ id: response.id }));
          var newFriendship = !(slypApp.persons.findWhere({ friendship_id: response.friendship_id }));
          slypApp.persons.add([response], { merge: true });
          context.state.saving = false;
          context.state.inviteEmail = '';
          if (newPerson){
            toastr['success']('Invitation email sent to ' + response.email + '. Celebration time!');
          } else if (newFriendship){
            toastr['success']('Added ' + response.display_name + ' to your friends list. #makingfriends');
          } else{
            toastr['success']('Doh! ' + response.display_name + ' is already a friend! #popular');
          }
        },
        error: function(a,b,c){
          context.state.saving = false;
          toastr['error']('Hmm looks like the email might not be valid :-(')
        }
      });
    } else {
      toastr['error']('That doesn\'t look like a valid email...');
    }
  },

  modelEvents: {
    'change:notify_reslyp'              : 'persist',
    'change:notify_activity'            : 'persist',
    'change:cc_on_reslyp_email_contact' : 'persist',
    'change:weekly_summary'             : 'persist',
    'change:searchable'                 : 'persist'
  },

  // Model event functions
  persist: function(){
    this.state.saving = true;
    var context = this;
    this.model.save(null, {
      success: function(model, response){
        context.doneSaving();
        toastr['success']('Settings saved!');
      },
      error: function(model, response){
        context.doneSaving();
        toastr['error'](response.responseJSON[0].message);
        context.model.fetch();
      }
    });
  },

  // Helper functions
  initializeSemanticElements: function(){
    this.$('.ui.checkbox').checkbox();
    var context = this;
    this.$('.inline.dropdown').dropdown({
      onChange: function(value, text, $choice){
        if (validateEmail(value) && context.model.get('send_reslyp_email_from') !== value){
          context.model.set('send_reslyp_email_from', value);
          context.persist();
        }
      }
    });
    $('.ui.accordion').accordion();

    $('#js-settings-sidebar-region').sidebar('setting', 'onShow', function(){
      $('#drift-widget-container').hide();
    });
    $('#js-settings-sidebar-region').sidebar('setting', 'onHide', function(){
      $('#drift-widget-container').show();
    });
    $('#js-settings-sidebar-region').sidebar('setting', 'transition', 'overlay');
  },
  changeMode: function(mode){
    this.state.profile = this.state.friends = this.state.emails = this.state.terms = this.state.privacy = false;
    this.state[mode] = true;
    if (this.state.iphoneWhiteScreenBug){
      $('#js-settings-sidebar-region').hide();
      setTimeout(function(){
        $('#js-settings-sidebar-region').show();
      }, 10);
      this.state.iphoneWhiteScreenBug = false;
    }
  },
  doneSaving: function(){
    this.state.saving = false;
  },
  exitEditMode: function(){
    if (this.state.profile){
      this.state.editProfile = false;
    }
  },
});
