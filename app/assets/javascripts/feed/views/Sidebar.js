var NoReslypsMessage = Backbone.Marionette.ItemView.extend({
  template: '#js-no-reslyps-message-tmpl'
});

slypApp.Views.Sidebar = Backbone.Marionette.CompositeView.extend({
  template: '#js-sidebar-region-tmpl',
  childView: slypApp.Views.Reslyp,
  childViewContainer: '.js-reslyps-container',
  className: 'ui basic segment',
  emptyView: NoReslypsMessage,
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
    this.model.touch();
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
    if (this.model.get('unseen')){
      var context = this;
      setTimeout(function(){
        context.$('#sidebar-title').click();
      }, 500);
    }
  },
  events: {
    'click #expand-description'   : 'expandDescription',
    'click #collapse-description' : 'collapseDescription',
    'click #close-sidebar'        : 'closeSidebar',
    'click #sidebar-title'        : 'showPreview',
    'click #reslyp-button'        : 'sendSlyp',
    'keypress #reslyp-comment'    : 'sendSlypIfValid',
    'click #reslyp-dropdown'      : 'handleDropdownSelect',
    'click #see-more'             : 'seeMoreResults',
    'click .fb-share-button'      : 'fbShareAttempt',
    'click .twitter-share-button' : 'twitterShareAttempt',
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
    if (this.model.get('html') == null){
      var context = this;
      this.model.fetch().done(function(){
        slypApp.modalsRegion.show(new slypApp.Views.PreviewModal({ model: context.model }));
      });
    } else {
      slypApp.modalsRegion.show(new slypApp.Views.PreviewModal({ model: this.model }));
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
    var scrollTop     = $(window).scrollTop(),
        elementOffset = this.$('#reslyp-dropdown').offset().top,
        distance      = (elementOffset - scrollTop);
    this.$('#reslyp-dropdown .menu').css('max-height', distance).css('min-height', distance);
    this.$('.menu').first().animate({ scrollTop: '0px' });
  },
  seeMoreResults: function(){
    this.state.moreResults = true;
  },
  fbShareAttempt: function(){
    // Analytics
    analytics.track('FB Share', {
      slyp_id: this.model.get('slyp_id'),
      slyp_title: this.model.get('title'),
      slyp_url: this.model.get('url')
    });
  },
  twitterShareAttempt: function(){
    // Analytics
    analytics.track('Twitter Share', {
      slyp_id: this.model.get('slyp_id'),
      slyp_title: this.model.get('title'),
      slyp_url: this.model.get('url')
    });
  },

  // Helper functions
  initializeSemanticElements: function(){
    var context = this;
    // Conversations sidebar
    $('.ui.right.sidebar').sidebar('setting', 'onShow', function(){
      slypApp.state.rightPaneActive = true;
      $('#drift-widget-container').hide();
    });

    $('.ui.right.sidebar').sidebar('setting', 'onHide', function(){
      slypApp.state.rightPaneActive = false;
      var previewVisible = $('#js-preview-sidebar-region').sidebar('is visible');
      if (!previewVisible){
        $('#drift-widget-container').show();
      }
    });

    $('.ui.right.sidebar').sidebar('setting', 'transition', 'overlay');

    // Reslyp dropdown
    this.$('#reslyp-dropdown')
      .dropdown({
        direction: 'upward',
        allowAdditions : true,
        message        : {
          addResult : 'Send to <b style="font-weight: bold;">{term}</b>',
        }
      });

    this.$('#reslyp-dropdown').dropdown('setting', 'onAdd', function(addedValue, addedText, addedChoice) {
      if (context.model.alreadyExchangedWith(addedValue)){
        _toastr('error', 'You have already exchanged this slyp with ' + addedValue);
        return false
      } else {
        context.state.reslyping = false;
        context.state.canReslyp = true;
        if (context.$('#reslyp-dropdown').dropdown('get value') == ''){
          setTimeout(function(){
            context.$('#reslyp-comment').focus();
          }, 100);
        }
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
        _toastr('success', 'Started ' + emails.length + ' new conversations');
        context.refreshAfterReslyp();

        // Analytics
        analytics.track('Reslyp', {
          num_emails: emails.length,
          slyp_id: context.model.get('slyp_id'),
          slyp_title: context.model.get('title'),
          slyp_url: context.model.get('url')
        });
      },
      error: function(status, err) {
        _toastr('error', 'Couldn\'t send it to some of your friends');
        context.state.comment = comment;
        context.refreshAfterReslyp();
      }
    });
  },
  refreshAfterReslyp: function(){
    this.state.reslyping = false;
    this.state.canReslyp = false;
    this.model.fetch();
    this.model.get('reslyps').fetch();
    slypApp.persons.fetch();
    this.refreshDropdown();
  },
  refreshDropdown: function(){
    this.$('#reslyp-dropdown').dropdown('restore defaults');
    this.$('#reslyp-dropdown .text').replaceWith('<div class="default text">send to friends</div>');
  }
});