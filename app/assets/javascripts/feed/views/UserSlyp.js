slypApp.Views.UserSlyp = Backbone.Marionette.ItemView.extend({
  template: "#js-slyp-card-tmpl",
  className: "ui card",
  events: {
    "click button.send"             : "sendSlyp",
    "keypress input"                : "sendSlypIfEnter",
    "mouseover .content.friend-data": "mOver",
  },
  modelEvents: {
    "change": "render"
  },
  mOver: function(){
    var menu = this.$('div.menu');
    if (menu.children().length == 0){
      menu.append(this.model.dropdownHTML())
      window.LetterAvatar.transform_el(this.el);
    }
  },
  onRender: function(){
    this.$('.summary.front-display')
      .popup({
        on        : 'click',
        inline    : true,
        hoverable : true,
        position  : 'bottom left',
        lastResort: 'bottom left',
        onShow    : function(){
            resizePopup();
        },
        delay    :{
          show: 1000,
          hide: 300
        }
      });

    this.$('.avatar')
      .popup({
        delay :{
          show: 100,
          hide: 200
        }
      });

    this.$('.ui.dropdown')
      .dropdown({
        direction     : 'upward',
        allowAdditions: true,
        onLabelCreate: function(label){
          // this.find('span').remove();
          this.addClass('mini');
          if (!validateEmail(label)){
            this.addClass('red')
          }
          return this
        },
        onAdd: function(addedValue, addedText, addedChoice){
          var elm = $(this.parentElement).find('button.send');
          if (elm.is(":hidden")){
            elm.show();
          }
        },
        onRemove: function(removedValue, removedText, removedChoice){
          if ($(this).find('a.label').length <= 1){
            $(this.parentElement).find('button.send').hide();
          }
        }
      });
    window.LetterAvatar.transform_el(this.el);
  },
  onShow: function(){
    this.$('img.display')
      .visibility({
        type       : 'image',
        transition : 'fade in',
        duration   : 1000
      });
  },
  sendSlyp: function(e){
    var recipients_labels = this.$('.ui.dropdown a.label').not('.red');
    if (recipients_labels.length > 0){
      var recipients_emails = recipients_labels
        .map(function(){return this.getAttribute("data-value");}).get();
      $(e.toElement).addClass('loading');
      this.reslyp(recipients_emails, "this is a comment");
    } else {
      toastr.error('No valid emails.');
    }
  },
  sendSlypIfEnter: function(e){
    if (e.keyCode==13){
      this.$('button.send').click();
    }
  },
  reslyp: function(emails, comment){
    var self = this;
    Backbone.ajax({
      url: '/reslyps',
      method: 'POST',
      accepts: {
        json: "application/json"
      },
      contentType: "application/json",
      dataType: "json",
      data: JSON.stringify({
        emails: emails,
        slyp_id: self.model.get('slyp_id'),
        comment: comment
      }),
      success: function(response){
        toastr.success('Successfully sent.');
        self.$('button.send').removeClass('loading');
        self.model.fetch();
      },
      error: function(status, response){
        responseText = JSON.parse(status.responseText);
        toastr.error(responseText[0].message);
        self.$('button.send').removeClass('loading');
        self.model.fetch();
      }
    });
  }
});

slypApp.Views.UserSlyps = Backbone.Marionette.CollectionView.extend({
  childView: slypApp.Views.UserSlyp,
  className: "ui three doubling stackable cards"
  })
