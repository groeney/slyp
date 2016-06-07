slypApp.Views.SettingsSidebar = Backbone.Marionette.LayoutView.extend({
  template: '#js-settings-sidebar-region-tmpl',
  className: 'ui basic right aligned segment',
  regions: {
    menu: '#menu',
    content: '#content'
  },
  initialize: function(options){
    this.state = {
      reslypFrequency: [
                          { value: 'notify_reslyp_immediately', text: 'Immediately' },
                          { value: 'notify_reslyp_daily', text: 'Daily' },
                          { value: 'notify_reslyp_weekly', text: 'Weekly' },
                          { value: 'notify_reslyp_never', text: 'Never' }
                       ],
      friendJoinedFrequency: [
                          { value: 'notify_friend_joined_immediately', text: 'Immediately' },
                          { value: 'notify_friend_joined_daily', text: 'Daily' },
                          { value: 'notify_friend_joined_weekly', text: 'Weekly' },
                          { value: 'notify_friend_joined_never', text: 'Never' }
                       ],
      repliesFrequency: [
                          { value: 'notify_replies_daily', text: 'Daily' },
                          { value: 'notify_replies_weekly', text: 'Weekly' },
                          { value: 'notify_replies_never', text: 'Never' }
                       ],
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
    'change:notify_friend_joined'  : 'persist',
    'change:notify_replies'        : 'persist',
    'change:weekly_summary'        : 'persist'
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
