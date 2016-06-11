slypApp.Views.SettingsSidebar = Backbone.Marionette.LayoutView.extend({
  template: '#js-settings-sidebar-region-tmpl',
  className: 'ui basic right aligned segment',
  regions: {
    menu: '#menu',
    content: '#content'
  },
  initialize: function(options){
    this.state = {
      saving: false,
      profile: true,
      emails: false,
      terms: false,
      privacy: false,
      editProfile: false
    }
  },
  onRender: function(){
    this.binder = rivets.bind(this.$el, { user: slypApp.user, state: this.state });
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
    })
  },
  events: {
    'click #edit'            : 'enterEditMode',
    'click #cancel'          : 'cancelEdit',
    'click #save'            : 'saveChanges',
    'click #close-sidebar'   : 'closeSidebar',
    'click #profile'         : 'showProfile',
    'click #emails'          : 'showEmails',
    'click #terms'           : 'showTerms',
    'click #privacy'         : 'showPrivacy',
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
  showEmails: function(){
    this.changeMode('emails');
  },
  showTerms: function(){
    this.changeMode('terms');
  },
  showPrivacy: function(){
    this.changeMode('privacy');
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
    this.state.profile = this.state.emails = this.state.terms = this.state.privacy = false;
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
