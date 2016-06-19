slypApp.Views.SettingsSidebar = Backbone.Marionette.LayoutView.extend({
  template: '#js-settings-sidebar-region-tmpl',
  className: 'ui basic right aligned segment',
  regions:{
    friendships: '#friendships',
    others: '#others'
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
      showOthers: false,
      inviteEmail: ''
    }
  },
  onRender: function(){
    this.binder = rivets.bind(this.$el, {
      user: slypApp.user,
      state: this.state
    });
    this.listenTo(slypApp.persons, 'change:friendship_id update', this.showFriends, this);
  },
  onShow: function(){
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
  },
  events: {
    'click #edit'            : 'enterEditMode',
    'click #cancel'          : 'cancelEdit',
    'click #save'            : 'saveChanges',
    'click #close-sidebar'   : 'closeSidebar',
    'click #profile'         : 'showProfile',
    'click #friends'         : 'showFriends',
    'click #emails'          : 'showEmails',
    'click #terms'           : 'showTerms',
    'click #privacy'         : 'showPrivacy',
    'click #show-others'     : 'showOthers',
    'click #invite-button'    : 'inviteByEmail',
    'keypress #invite-input'    : 'inviteByEmailIfValid',
    'click #update-password' : 'notImplemented'
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
    var friends = slypApp.persons.whereNot({ friendship_id: null })
    this.showChildView('friendships', new slypApp.Views.Persons({ models: friends, showEmail: true }));
    this.changeMode('friends');
    if (this.state.showOthers){
      var others = slypApp.persons.where({ friendship_id: null });
      this.showChildView('others', new slypApp.Views.Persons({ models: others, showEmail: false }));
    }
  },
  showOthers: function(){
    this.state.showOthers = !(this.state.showOthers);
    if (this.state.showOthers){
      var others = slypApp.persons.where({ friendship_id: null });
      this.showChildView('others', new slypApp.Views.Persons({ models: others, showEmail: false }));
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
      toastr['error']('Need a valid email!');
    }
  },
  notImplemented: function(){
    toastr['info']('We\'ve logged your interest. Coming soon :)');
  },

  modelEvents: {
    'change:notify_reslyp'         : 'persist',
    'change:notify_activity'       : 'persist',
    'change:cc_me_on_email_reslyp' : 'persist',
    'change:weekly_summary'        : 'persist',
    'change:searchable'            : 'persist'
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
  changeMode: function(mode){
    this.state.profile = this.state.friends = this.state.emails = this.state.terms = this.state.privacy = false;
    this.state[mode] = true;
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
