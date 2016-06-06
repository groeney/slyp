slypApp.Views.SettingsSidebar = Backbone.Marionette.LayoutView.extend({
  template: '#js-settings-sidebar-region-tmpl',
  className: 'ui basic right aligned segment',
  attributes: {
    'rv-class-loading' : 'state.saving'
  },
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
      saving: false
    }
  },
  onRender: function(){
    this.binder = rivets.bind(this.$el, { user: slypApp.user, state: this.state });
  },
  onShow: function(){
    this.$('.ui.checkbox').checkbox();
  },
  events: {
    'click #close-sidebar' : 'closeSidebar'
  },
  modelEvents: {
    'change:notify_reslyp'         : 'persist',
    'change:notify_friend_joined'  : 'persist',
    'change:notify_replies'        : 'persist',
    'change:weekly_summary' : 'persist'
  },
  closeSidebar: function(){
    $('#js-settings-sidebar-region').sidebar('toggle');
  },
  persist: function(e){
    this.state.saving = true;
    var context = this;
    this.model.save(null, {
      success: function(){
        context.state.saving = false;
        toastr['success']('Settings saved!');
      },
      error: function(){
        context.state.saving = false;
        toastr['error']('Something went wrong when saving those settings :(');
      }
    });
  }
});
