slypApp.Views.Sidebar = slypApp.Base.CompositeView.extend({
  template: '#js-sidebar-region-tmpl',
  childView: slypApp.Views.Reslyp,
  childViewContainer: '.js-reslyps-container',
  className: 'ui basic segment',
  initialize: function(options){
    var context = this;
    this.state = {
      loading  : true,
      expanded : false,
      gotAttention: true,
      reslyping: false,
      canReslyp: false,
      moreResults: false,
      comment: ''
    }
    this.state.hasComment = function(){
      return context.state.comment.length > 0;
    }
    this.collection = this.model.get('reslyps');
    if (this.collection != null){
      this.collection.fetch({
        reset: true,
        success: function(collection, response, options){
          context.state.loading = false;
        },
        error: function(collection, response, options){
          context.state.loading = false;
        }
      });
    }
  },
  onRender: function(){
    this.binder = rivets.bind(this.$el, {
      userSlyp: this.model,
      state: this.state,
      appState: slypApp.state
    });
  },
  onShow: function(){
    this.initializeSemanticElements();
  },
  events: {
    'click #expand-description'   : 'expandDescription',
    'click #collapse-description' : 'collapseDescription',
    'click #close-sidebar'        : 'closeSidebar',
    'click #sidebar-title'        : 'showPreview',
    'click #reslyp-button'        : 'sendSlyp',
    'keypress #reslyp-comment'    : 'sendSlypIfValid',
    'click #reslyp-dropdown'      : 'handleDropdownSelect',
    'click #see-more'             : 'seeMoreResults'
  },
  expandDescription: function(){
    this.state.expanded = true;
  },
  collapseDescription: function(){
    this.state.expanded = false;
  },
  closeSidebar: function(){
    $('.ui.right.sidebar').sidebar('toggle');
  },
  showPreview: function(){
    if (this.model.get('unseen')){
      this.model.save({ unseen: false });
    }
    if ($(window).width() > 768){
      this.showSidebarPreview();
    } else {
      this.showModalPreview();
    }
  },
  showSidebarPreview: function(){
    slypApp.previewSidebarRegion.show(new slypApp.Views.PreviewSidebar({ model: this.model }));
    $('#js-preview-sidebar-region').sidebar('toggle');
  },
  showModalPreview: function(){
    var modalEl = $('.ui.fullscreen.modal[data-user-slyp-id="' + this.model.get('id') + '"]');
    if (modalEl.exists()){
      $('.ui.right.sidebar').sidebar('toggle');
      modalEl.modal('show');
    } else {
      window.location.href = this.model.get('url');
    }
  },
  sendSlyp: function(e){
    if (this.state.hasComment()){
      var emails = this.$('#recipient-emails').val().split(',');

      if (emails.length > 0){
        var validatedEmails = _.filter(emails, function(email) { return validateEmail(email) });
        this.state.reslyping = true;
        var comment = this.state.comment;
        this.reslyp(validatedEmails, comment);
      } else {
        this.toastr('error', 'No valid emails.');
      }
    } else {
      this.toastr('error', 'Gotta add a comment before sending ;)');
    }
  },
  sendSlypIfValid: function(e){
    if (e.keyCode==13 && this.state.hasComment() && !e.shiftKey){
      e.preventDefault();
      this.$('#reslyp-button').click();
    }
  },
  handleDropdownSelect: function(){
    if (this.model.reslypableFriends().length == 0){
      this.state.moreResults = true;
      var context = this;
      setTimeout(function(){
        context.$('#reslyp-dropdown input.search').focus();
      }, 200);
    }
    // TODO: "Your friends" and "Other people" header is pushed out of view by dropdown default selection need to scroll up
  },
  seeMoreResults: function(){
    this.state.moreResults = true;
  },

  // Helper functions
  initializeSemanticElements: function(){
    var context = this;
    // Conversations sidebar
    $('.ui.right.sidebar').sidebar('setting', 'onShow', function(){
        slypApp.state.rightPaneActive = true;
    });

    $('.ui.right.sidebar').sidebar('setting', 'onHide', function(){
        slypApp.state.rightPaneActive = false;
    });

    // Reslyp dropdown
    this.$('#reslyp-dropdown')
      .dropdown({
        allowAdditions : true,
        message        : {
          addResult : 'Send to <b style="font-weight: bold;">{term}</b>',
        }
      });

    this.$('#reslyp-dropdown').dropdown('setting', 'onAdd', function(addedValue, addedText, addedChoice) {
      if (context.model.alreadyExchangedWith(addedValue)){
        context.toastr('error', 'You have already exchanged this slyp with ' + addedValue);
        return false
      } else {
        context.state.reslyping = false;
        context.state.canReslyp = true;
      }
      return true
    });

    this.$('#reslyp-dropdown').dropdown('setting', 'onLabelCreate', function(value, text) {
      $(this).find('span').detach();
      if (!validateEmail(value)){
        this.addClass('red');
      }
      return this
    });

    this.$('#reslyp-dropdown').dropdown('setting', 'onRemove', function(removedValue, removedText, removedChoice) {
      if (context.$el.find('#reslyp-dropdown a.label').length <= 1){
        context.state.reslyping = false;
        context.state.canReslyp = false;
      }
    });

    this.$('#reslyp-dropdown').dropdown('setting', 'onHide', function(){
      context.state.moreResults = false;
    });

    this.$('#reslyp-dropdown').dropdown('setting', 'onLabelRemove', function(value){
      this.popup('destroy');
    });

    this.$('#reslyp-dropdown').dropdown('save defaults');

  },
  reslyp: function(emails, comment){
    var comment = this.state.comment;
    this.state.comment = '';
    this.state.reslyping = true;

    var context = this;
    Backbone.ajax({
      url: '/reslyps',
      method: 'POST',
      accepts: {
        json: 'application/json'
      },
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify({
        emails: emails,
        slyp_id: this.model.get('slyp_id'),
        comment: comment
      }),
      success: function(response) {
        context.toastr('success', 'Started ' + emails.length + ' new conversations');
        context.refreshAfterReslyp();
      },
      error: function(status, err) {
        context.toastr('error', 'Couldn\'t send it to some of your friends');
        context.state.comment = comment;
        context.refreshAfterReslyp();
      }
    });
  },
  refreshAfterReslyp: function(){
    this.state.reslyping = false;
    this.state.canReslyp = false;
    this.model.fetch();
    slypApp.persons.fetch();
    this.refreshDropdown();
  },
  refreshDropdown: function(){
    this.$('#reslyp-dropdown').dropdown('restore defaults');
    this.$('#reslyp-dropdown .text').replaceWith('<div class="default text">send to friends</div>');
  }
});