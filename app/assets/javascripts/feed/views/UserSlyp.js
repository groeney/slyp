slypApp.Views.UserSlyp = slypApp.Base.CompositeView.extend({
  template: '#js-slyp-card-tmpl',
  className: 'ui card',
  attributes: {
    'rv-fade-hide' : 'userSlyp.hideArchived < :archived',
    'rv-class-red' : 'userSlyp:unseen'
  },
  childView: slypApp.Views.Reslyp,
  childViewContainer: '.js-reslyps-container',
  initialize: function(options){
    this.collection = options.model.get('reslyps');
    var context = this;
    this.state = {
      canReslyp    : false,
      gotAttention : !this.model.hasConversations(),
      reslyping    : false,
      comment      : ''
    }
    this.state.hasComment = function(){
      return context.state.comment.length > 0;
    }
  },
  onRender: function(){
    this.binder = rivets.bind(this.$el, { userSlyp: this.model, state: this.state });
    var context = this;
    if (typeof this.model.get('url') !== 'undefined'){
      this.$('a[href^="' + this.model.get('url') + '"]').on('click', function(){
        if (context.model.get('unseen')){
          context.model.save({unseen: false});
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
  },
  onClose: function() {
    if (this.binder) this.binder.unbind();
  },
  events: {
    'click #reslyp-button'          : 'sendSlyp',
    'keypress #reslyp-comment'      : 'sendSlypIfValid',
    'click #archive-action'         : 'toggleArchive',
    'click #favorite-action'        : 'toggleStar',
    'mouseenterintent'              : 'giveAttention',
    'mouseleaveintent'              : 'takeAttention',
    'click #preview-button'         : 'showPreview',
    'click #send-button'            : 'reslypAttention',
    'click #comment-label'          : 'showConversations'
  },

  // Event functions
  sendSlyp: function(e){
    if (this.state.hasComment()){
      var emails = this.$('#recipient-emails').val().split(',');
      this.$('#reslyp-comment').val('');

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
  giveAttention: function(){
    this.state.gotAttention = true;
  },
  takeAttention: function(){
    if (!this.state.canReslyp){
      this.state.gotAttention = false;
    }
  },
  showPreview: function(e){
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

    if (this.model.get('unseen')){
      this.model.save({ unseen: false });
    }
  },
  reslypAttention: function(){
    this.$('.ui.multiple.selection.search.dropdown input.search').focus();
  },
  showConversations: function(){
    this.$('#conversations').popup('toggle');
  },

  // Helper functions
  reslyp: function(emails, comment){
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
        context.toastr('success', 'Reslyp successful :)');
        context.state.reslyping = false;
        context.state.canReslyp = true; // Until figure out communication with view from dropdown callbacks
        context.state.canReslyp = false;
        context.state.comment = '';
        context.model.fetch();
        context.removeRecipientsLabels();
      },
      error: function(status, err) {
        context.toastr('error', 'Couldn\'t add all OR some of those users :(');
        context.state.reslyping = false;
        context.state.canReslyp = true; // Until figure out communication with view from dropdown callbacks
        context.state.canReslyp = false;
        context.state.comment = '';
        context.model.fetch();
        context.removeRecipientsLabels();
      }
    });
  },
  removeRecipientsLabels: function(){
    this.$('.ui.dropdown a.label').remove();
  },
  filterFriends: function(users){
    var friends = _.pluck(this.model.get('friends'), 'email');
    return _.filter(users, function(val){ return friends.indexOf(val.email) < 0 })
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

    // Misc UI
    this.$('#conversations')
      .popup({
        on         : 'click',
        inline     : true,
        position   : 'right center',
        lastResort : 'bottom left',
        onShow     : function(module) {
          context.model.get('reslyps').fetch();
          resizePopup();
          if (context.model.get('unseen_activity')){
            context.model.save({ unseen_activity: false });
          }
        }
      });

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

    // Reslyp dropdown
    var dropdownSelector = '.ui.multiple.selection.search.dropdown';
    this.$(dropdownSelector)
      .dropdown({
        direction     : 'upward',
        allowAdditions: true,
        message       : {
          addResult : 'Invite <b style="font-weight: bold;">{term}</b>',
        },
        apiSettings   : {
          url    : '/search/users?q={query}',
          method : 'post',
          data   : {
            user_slyp_id: this.model.get('id')
          },
          onResponse: function(serverResponse){
            modResponse = context.filterFriends(_.values(serverResponse));
            modResponse = _.map(modResponse, function(val){
              return {
                name        : val.display_name,
                value       : val.email,
                description : val.email
              }
            });
            var response = {'success': true, 'results': modResponse}
            return response
          }
        }
      });

    this.$(dropdownSelector).dropdown('setting', 'onAdd', function(addedValue, addedText, addedChoice) {
      var friendExists = _.some(context.model.get('friends'), function(friend) {
        return friend.email == addedValue;
      });
      if (friendExists){
        context.toastr('error', 'You have already exchanged this slyp with ' + addedValue);
        return false
      } else {
        context.state.reslyping = false;
        context.state.canReslyp = true;
      }
      return true
    });

    this.$(dropdownSelector).dropdown('setting', 'onLabelCreate', function(value, text) {
      this.attr('data-content', value);
      this.popup({
        delay: {
          show: 500,
          hide: 0
        }
      })
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