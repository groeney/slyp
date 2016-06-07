slypApp.Views.UserSlyp = slypApp.Base.CompositeView.extend({
  template: '#js-slyp-card-tmpl',
  className: 'ui card',
  attributes: {
    'rv-fade-hide' : 'userSlyp.hideArchived < :archived',
    'rv-class-red' : 'userSlyp:unseen',
    'rv-class-red' : 'userSlyp.hasLove < :unseen_replies :unseen_activity',
    'style'        : 'background-color:white;'
  },
  initialize: function(options){
    var context = this;
    this.state = {
      canReslyp         : false,
      gotAttention      : !this.model.hasConversations() || slypApp.state.isMobile(),
      reslyping         : false,
      comment           : '',
      moreResults       : null,
      intendingToReply  : false,
      quickReplyText    : '',
      loadingQuickReply : false,
      scrubbedFriends   : this.getPotentialFriends()
    }
    this.state.hasComment = function(){
      return context.state.comment.length > 0;
    }
    this.state.hasQuickReplyText = function(){
      return context.state.quickReplyText.length > 0
    }
  },
  onRender: function(){
    this.binder = rivets.bind(this.$el, {
      userSlyp        : this.model,
      state           : this.state
    });
    var context = this;
    if (typeof this.model.get('url') !== 'undefined'){
      this.$('a[href^="' + this.model.get('url') + '"]').on('click', function(){
        if (context.model.get('unseen')){
          context.model.save({ unseen: false });
        }
      });
    }
  },
  onShow: function(){
    this.initializeSemanticElements();
    this.$('.video_frame').first().addClass('ui').addClass('embed');
    this.$('img.avatar').popup();

    this.$('textarea').each(function () {
      this.setAttribute('style', 'height:' + (this.scrollHeight+50) + 'px;overflow-y:hidden;');
    }).on('input', function () {
      this.style.height = 'auto';
      this.style.height = (this.scrollHeight) + 'px';
    });

    var hotPreviewId = getParameterByName('preview_user_slyp_id');
    if (hotPreviewId != null && hotPreviewId == this.model.get('id')){
      window.history.pushState({}, document.title, window.location.pathname); // requires HTML5
      this.showPreview();
    }
  },
  onDestroy: function(){
    if (this.binder) this.binder.unbind();
  },
  events: {
    'click #conversations'        : 'showConversationsSidebar',
    'click #reslyp-button'        : 'sendSlyp',
    'keypress #reslyp-comment'    : 'sendSlypIfValid',
    'click #archive-action'       : 'toggleArchive',
    'click #favorite-action'      : 'toggleStar',
    'mouseleaveintent'            : 'takeAttention',
    'click #preview-button'       : 'showPreview',
    'click #title'                : 'showPreview',
    'click #send-button'          : 'reslypAttention',
    'click #comment-label'        : 'intendToReply',
    'click .dropdown.search'      : 'handleDropdownSelect',
    'click #see-more'             : 'seeMoreResults',
    'focusout #quick-reply-input' : 'noReply',
    'keypress #quick-reply-input' : 'sendQuickReplyIfValid',
    'click #quick-reply-button'   : 'sendQuickReply',
    'click #explore-us'           : 'notImplemented'
  },

  // Event functions
  showConversationsSidebar: function(){
    this.model.save({ unseen_activity: false });
    slypApp.sidebarRegion.show(new slypApp.Views.Sidebar({ model: this.model }));
    $('.ui.right.sidebar').sidebar('toggle');
  },
  sendSlyp: function(e){
    if (this.state.hasComment()){
      var emails = this.$('#recipient-emails').val().split(',');

      if (emails.length > 0){
        var validatedEmails = _.filter(emails, function(email) { return validateEmail(email) });
        this.reslyp(validatedEmails);
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
  toggleArchive: function(e){
    var context = this;
    this.model.save({ archived: !this.model.get('archived') },
    {
      success: function() {
        var toastrOptions = {
          'positionClass': 'toast-bottom-left',
          'onclick': function() {
            context.model.save({archived: !context.model.get('archived')});
          },
          'fadeIn': 300,
          'fadeOut': 1000,
          'timeOut': 5000,
          'extendedTimeOut': 1000
        }
        if (context.model.get('archived')){
          context.toastr('success', 'Marked as done. Click to Undo.', toastrOptions);
        } else {
          context.toastr('success', 'Moved to reading list. Click to Undo.', toastrOptions);
        }
      },
      error: function() { context.toastr('error') }
    });
  },
  toggleStar: function(e){
    var context = this;
    this.model.save({ favourite: !this.model.get('favourite') },
    {
      error: function() { context.toastr('error') }
    });
  },
  takeAttention: function(){
    if (!this.state.canReslyp){
      this.state.gotAttention = false;
    }
  },
  showPreview: function(){
    if (slypApp.state.isMobile()){
      this.showModalPreview();
    } else {
      this.showSidebarPreview();
    }

    if (this.model.get('unseen')){
      this.model.save({ unseen: false });
    }
  },
  reslypAttention: function(){
    this.giveAttention();
    this.$('.search.dropdown').click();
  },
  intendToReply: function(){
    if (this.state.intendingToReply){
      this.state.intendingToReply = false;
      this.showConversationsSidebar();
    } else {
      this.state.intendingToReply = true;
      this.$('#quick-reply-input').focus();
    }
  },
  handleDropdownSelect: function(){
    if (this.getPotentialFriends().length == 0){
      this.seeMoreResults();
      var context = this;
      setTimeout(function(){
        context.$('.dropdown.search input.search').focus();
      }, 200);
    }
    // TODO: "Your friends" and "Other people" header is pushed out of view by dropdown default selection need to scroll up
  },
  seeMoreResults: function(){
    var context = this;
    var query = this.$('.dropdown.search input.search').val();
    Backbone.ajax({
      url: '/search/users?q=' + query,
      method: 'GET',
      accepts: {
        json: 'application/json'
      },
      contentType: 'application/json',
      dataType: 'json',
      success: function(response) {
        context.state.moreResults = slypApp.user.scrubFriends(response);
      }
    });
  },
  noReply: function(){
    var context = this;
    setTimeout(function(){ // Gives time to click quick-reply-button event, if applicable.
      context.state.intendingToReply = false;
    }, 200);
  },
  sendQuickReplyIfValid: function(e){
    if (e.keyCode == 13 && this.state.hasQuickReplyText()){
      e.preventDefault();
      this.$('#quick-reply-button').click();
    }
  },
  sendQuickReply: function(){
    var quickReplyText = this.state.quickReplyText;
    this.state.quickReplyText = '';
    this.state.loadingQuickReply = true;
    var context = this;
    Backbone.ajax({
      url: '/replies',
      method: 'POST',
      accepts: {
        json: 'application/json'
      },
      contentType: 'application/json',
      dataType: 'json',
      data: JSON.stringify({
        reslyp_id: context.model.get('latest_conversation').reslyp_id,
        text: quickReplyText
      }),
      success: function(response) {
        context.state.intendingToReply = false;
        context.state.loadingQuickReply = false;
        context.model.fetch();
      },
      error: function(status, err) {
        context.state.quickReplyText = quickReplyText;
        context.state.intendingToReply = true;
        context.state.loadingQuickReply = false;
        context.toastr('error', 'Couldn\'t add that reply for some reason :(')
      }
    });
  },

  // Helper functions
  giveAttention: function(){
    this.state.gotAttention = true;
  },
  showModalPreview: function(){
    var modalSelector = this.$('.ui.modal').first();
    if (modalSelector.length === 0){
      modalSelector = $('div[data-user-slyp-id=' + this.model.get('id') + '].ui.modal').first();
    }
    modalSelector.modal({
      onHidden: function() { // Buggy if more than one video
        iframe = $(this).find('.ui.embed iframe').first();
        iframe.attr('src', iframe.attr('src'));
      }
    }).modal('show');
  },
  showSidebarPreview: function(){
    slypApp.previewSidebarRegion.show(new slypApp.Views.PreviewSidebar({ model: this.model }));
    $('#js-preview-sidebar-region').sidebar('toggle');
  },
  reslyp: function(emails){
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
        context.toastr('success', 'Started ' + 'conversation'.pluralize(emails.length));
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
    var context = this;
    this.model.fetch({
      success: function(){
        context.state.scrubbedFriends = context.getPotentialFriends();
      },
      error: function(){
        context.state.scrubbedFriends = context.getPotentialFriends();
      }
    });
    this.refreshDropdown();
  },
  refreshDropdown: function(){
    this.$('.ui.dropdown').dropdown('restore defaults');
    this.$('.ui.dropdown .text').replaceWith('<div class="default text">send to friends</div>');
  },
  getPotentialFriends: function(){
    return this.model.scrubFriends(slypApp.user.get('friends')) || [];
  },
  initializeSemanticElements: function(){
    var context = this;
    // User actions
    this.$('#archive-action').popup({
      position: 'bottom left',
      delay: {
        show: 500,
        hide: 0
      }
    });

    this.$('#favorite-action').popup({
      position: 'bottom left',
      delay: {
        show: 500,
        hide: 0
      }
    });

    this.$('#explore-us').popup({
      position: 'bottom left',
      delay: {
        show: 500,
        hide: 0
      }
    });

    // Misc UI
    this.$('img').error(function () {
        $(this).attr('src', '/assets/blank-image.png');
    });

    this.$('.image').dimmer({
      on: 'hover'
    });

    this.$('img.display')
      .visibility({
        'type': 'image',
        'transition': 'fade in',
        'duration': 750
    });

    // Preview modal
    this.$('.ui.fullscreen.modal').modal('setting', 'onShow', function(){
      slypApp.state.previewingSlyp = true;
    });

    this.$('.ui.fullscreen.modal').modal('setting', 'onHide', function(){
      slypApp.state.previewingSlyp = false;
    });

    // Reslyp dropdown
    var dropdownSelector = '.ui.multiple.selection.search.dropdown';
    this.$(dropdownSelector)
      .dropdown({
        allowAdditions: true,
        message       : {
          addResult : 'Invite <b style="font-weight: bold;">{term}</b>',
        }
      });

    this.$(dropdownSelector).dropdown('setting', 'onAdd', function(addedValue, addedText, addedChoice) {
      if (context.model.alreadyExchangedWith(addedValue)){
        context.toastr('error', 'You have already exchanged this slyp with ' + addedValue);
        return false
      } else {
        context.state.reslyping = false;
        context.state.canReslyp = true;
      }
      return true
    });

    this.$(dropdownSelector).dropdown('setting', 'onLabelCreate', function(value, text) {
      $(this).find('span').detach();
      if (!validateEmail(value)){
        this.addClass('red');
      }
      return this
    });

    this.$(dropdownSelector).dropdown('setting', 'onRemove', function(removedValue, removedText, removedChoice) {
      if (context.$el.find('.ui.dropdown a.label').length <= 1){
        context.state.reslyping = false;
        context.state.canReslyp = false;
      }
    });

    this.$(dropdownSelector).dropdown('setting', 'onHide', function(){
      context.state.moreResults = null;
    });

    this.$(dropdownSelector).dropdown('setting', 'onLabelRemove', function(value){
      this.popup('destroy');
    });

    this.$(dropdownSelector).dropdown('save defaults');
  }
});

slypApp.Views.UserSlyps = Backbone.Marionette.CollectionView.extend({
  childView: slypApp.Views.UserSlyp,
  className: 'ui three doubling stackable cards'
});