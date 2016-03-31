slypApp.Views.UserSlyp = slypApp.Views.Base.extend({
  template: '#js-slyp-card-tmpl',
  className: 'ui card',
  events: {
    'click .ui.action.input .button': 'sendSlyp',
    'keypress input'                : 'sendSlypIfEnter',
    'click .archive.icon'           : 'toggleArchive',
    'click .star.icon'              : 'toggleStar',
    'mouseenterintent'              : 'giveAttention',
    'mouseleaveintent'              : 'takeAttention'
  },
  modelEvents:{
    'change' : 'renderAvatars'
  },
  attributes: {
    'rv-fade-hide': 'model.hideArchived < :archived'
  },
  renderAvatars: function(){
    window.LetterAvatar.transform_el(this.el);
  },
  giveAttention: function(){
    this.state.gotAttention = true;
  },
  takeAttention: function(){
    if (!this.state.canReslyp){
      this.state.gotAttention = false;
    }
  },
  onClose: function() {
    if (this.binder) this.binder.unbind();
  },
  onRender: function(){
    this.state = {
      canReslyp      : false,
      gotAttention   : false,
      reslyping      : false,
      comment        : ''
    }

    this.binder = rivets.bind(this.$el, { model: this.model, state: this.state })

    this.$('.ui.dropdown')
      .dropdown({
        direction     : 'upward',
        allowAdditions: true,
        apiSettings: {
          url: '/search/users?q={query}',
          method: 'post',
          data: {
            user_slyp_id: this.model.get('id')
          },
          onResponse: function(serverResponse){
            var response = {'success': true, 'results': serverResponse}
            return response
          }
        }
      });

    this.$('.ui.dropdown').dropdown('setting', 'onAdd', (addedValue, addedText, addedChoice) => {
      var friendExists = _.some(this.model.get('friends'), function(friend) {
        return friend.email == addedValue;
      });

      if (friendExists){
        this.toastr('error', 'You have already exchanged this slyp with ' + addedValue);
        return false
      } else {
        this.state.reslyping = false;
        this.state.canReslyp = true;
        // var elm = $(this.parentElement).find('.action.input');
        // if (elm.is(':hidden')){
        //   elm.find('button').removeClass('loading');
        //   elm.show();
        // }
      }
      return true
    });

    this.$('.ui.dropdown').dropdown('setting', 'onLabelCreate', function(value, text) {
      if (!validateEmail(value)){
        this.addClass('red');
      }
      return this
    });

    this.$('.ui.dropdown').dropdown('setting', 'onRemove', (removedValue, removedText, removedChoice) => {
      if (this.$el.find('.ui.dropdown a.label').length <= 1){
        this.state.reslyping = false;
        this.state.canReslyp = false;
      }
    });

    this.$('.ui.dropdown').dropdown('setting', 'onLabelRemove', function(value){
      this.popup('destroy');
    });

    this.$('.ui.dropdown').dropdown('save defaults');

    this.$('.summary.front-display')
      .popup({
        on        : 'click',
        inline    : true,
        hoverable : true,
        position  : 'right center',
        lastResort: 'bottom left',
        onShow    : (module) => {
          resizePopup();
          return this.model.get('reslyps').length > 0
        },
        delay    :{
          show: 1000,
          hide: 300
        }
      });

    this.$('#friends')
      .popup({
        onShow: (module) => {
          resizePopup();
          return this.model.get('friends').length > 0
        },
        delay: {
          hide: 500
        },
        hoverable: true
      });

    this.$('.avatar')
      .popup({
        delay :{
          show: 100,
          hide: 200
        }
      });

    window.LetterAvatar.transform_el(this.el);
  },
  onShow: function(){
    this.$('img.display')
      .visibility({
        'type': 'image',
        'transition': 'fade in',
        'duration': 750
    });
  },
  sendSlypIfEnter: function(e){
    if (e.keyCode==13){
      this.$('.action.input .button').click();
    }
  },
  sendSlyp: function(e){
    var emails = this.$('#recipient-emails').val().split(',');
    this.$('.ui.dropdown').dropdown('restore defaults');
    this.$('.ui.dropdown').dropdown('set text', 'send to friends'); // ^ 'restore defaults' not setting text
    this.$('#reslyp-comment').val('');

    if (emails.length > 0){
      var validatedEmails = _.filter(emails, function(email) { return validateEmail(email) });
      this.state.reslyping = true;
      var comment = this.state.comment;
      this.reslyp(validatedEmails, comment);
    } else {
      this.toastr('error', 'No valid emails.');
    }
  },
  reslyp: function(emails, comment){
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
      success: (response) => {
        this.toastr('success', 'Reslyp successful :)');
        this.state.reslyping = false;
        this.state.canReslyp = true; // Until figure out communication with view from dropdown callbacks
        this.state.canReslyp = false;
        this.model.fetch();
        this.removeRecipientsLabels();
      },
      error: (status, err) => {
        this.toastr('error', 'Couldn\'t add all OR some of those users :(');
        this.state.reslyping = false;
        this.state.canReslyp = true; // Until figure out communication with view from dropdown callbacks
        this.state.canReslyp = false;
        this.model.fetch();
        this.removeRecipientsLabels();
      }
    });
  },
  toggleStar: function(e){
    this.model.save({ favourite: !this.model.get('favourite') },
    {
      error: this.error('error')
    });
  },
  toggleArchive: function(e){

    this.model.save({archived: !this.model.get('archived')},
    {
      success: () => {
        var self = this; // Makes *view* accessible in onclick, as this
        var toastrOptions = {
          'positionClass': 'toast-bottom-left',
          'onclick': () => {
            this.model.save({archived: !this.model.get('archived')})
          },
          'fadeIn': 300,
          'fadeOut': 1000,
          'timeOut': 5000,
          'extendedTimeOut': 1000
        }
        this.toastr('success', 'Slyp archived. Click to undo.', toastrOptions);
      },
      error: () => { this.toastr('error') }
    });
  },
  removeRecipientsLabels: function(){
    this.$('.ui.dropdown a.label').remove();
  }
});

slypApp.Views.UserSlyps = Backbone.Marionette.CollectionView.extend({
  childView: slypApp.Views.UserSlyp,
  className: 'ui three doubling stackable cards'
})
