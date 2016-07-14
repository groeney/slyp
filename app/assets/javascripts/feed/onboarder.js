// Tour
var shepherd = new Shepherd.Tour({
  defaults: {
    classes: 'shepherd-element shepherd-open shepherd-theme-square-dark',
    showCancelLink: true
  }
});

// Steps and triggers
shepherd.addStep('1 add', {
  title: 'Create slyps',
  text: 'Click on the <i class="plus icon"></i> icon to create a new slyp',
  attachTo: '#add-button bottom',
  buttons: false
});

// trigger
// Find in ./views/NavBar.js:133

shepherd.addStep('2 create', {
  title: 'Create',
  text: 'Nice. We found a link for you, try creating it!',
  attachTo: '#create-input bottom',
  buttons: false,
  when: {
    hide: function(){
      slypApp.state.slypURL = '';
    },
    show: function(){
      slypApp.state.slypURL = 'https://newrepublic.com/article/133876/pulp-friction';
    }
  }
});

// trigger
// Find in ./views/NavBar.js:103

shepherd.addStep('3 select', {
  title: 'Send to email',
  text: ['Paste an email address or select a friend.'],
  attachTo: '#card-0 #reslyp-dropdown right',
  buttons: false,
  when: {
    'before-show' : function(){
      $('html, body').animate({ scrollTop: '350px' });
    }
  }
});

// trigger
// Find in ./views/UserSlyp.js:395

shepherd.addStep('4 send', {
  title: 'Add comment and send',
  text: ['Protip: you will be able to search your conversations later.'],
  attachTo: '#card-0 #reslyp-comment right',
  buttons: false
});

// trigger
// Find in ./views/UserSlyp.js:296

shepherd.addStep('5 label', {
  title: 'At a glance',
  text: ['This is your most recent conversation at a glance.', 'Click once: reply.', 'Click twice: view conversation.'],
  attachTo: '#card-0 #comment-label right',
  buttons: [
    {
      text: 'Nice',
      action: function(){
        $('#close-left-pane').click();
        setTimeout(function(){
          $('#close-sidebar').click();
        }, 150);
        shepherd.next();
      },
      classes: 'shepherd-button-example-primary'
    }
  ],
  when: {
    'show' : function(){
      $('html, body').animate({ scrollTop: '300px' });
    }
  }
});

// trigger
// Find inside step->buttons:action

shepherd.addStep('6 actions', {
  title: 'Action station',
  text: ['Click text to view more.', 'Click <i class="send icon"></i> to send (we\'ve done that!).', 'Click <i class="search icon"></i> to read and <i class="talk outline icon"></i> to view conversations.'],
  attachTo: '#card-0 #card-image right',
  buttons: [
    {
      text: 'Got it, thanks',
      action: function(e){
        $('#close-left-pane').click();
        setTimeout(function(){
          $('#close-sidebar').click();
        }, 150);
        setTimeout(function(){
          shepherd.next();
        }, 200);
      },
      classes: 'shepherd-button-example-primary'
    }
  ],
  when: {
    show: function(){
      $('.blurring.image img').first().trigger('mouseenter');
      $('html, body').animate({ scrollTop: '100px' });
      $('#card-0 .blurring.image').on('mouseout', function(){
        $('#card-0 .blurring.image').trigger('mouseenter');
      });
    },
    hide: function(){
      $('#card-0 .blurring.image').off('mouseout');
      $('#card-0 .blurring.image').trigger('mouseout');
    }
  }
});

// trigger
// Find inside step->buttons:action

shepherd.addStep('7 magic', {
  title: 'Grand finale',
  text: 'This is our favourite part of the tour <i class="smile icon"></i>',
  attachTo: '#js-nav-bar-region bottom',
  buttons: [
    {
      text: 'Let\'s go!',
      action: function(e){
        $('#preview-button').first().click();
        setTimeout(function(){
          $('#open-conversations').click();
          shepherd.currentStep.hide();
        }, 50);
        setTimeout(function(){
          shepherd.next();
        }, 2000)
      },
      classes: 'shepherd-button-example-primary'
    }
  ],
  when: {
    show: function(){
      $('html, body').animate({ scrollTop: '0px' });
    }
  }
});

shepherd.addStep('8 simultaneous', {
  title: 'Engage',
  text: ['We love this simultaneous view.', 'Also send this article via <i class="facebook icon"></i> or post to <i class="twitter icon"></i>.'],
  attachTo: '#js-sidebar-region right',
  buttons: [
    {
      text: 'Great',
      action: function(e){
        $('#close-sidebar').click();
        setTimeout(function(){
          $('#close-left-pane').click();
        }, 250);
        setTimeout(function(){
          shepherd.next();
        }, 500);
      },
      classes: 'shepherd-button-example-primary'
    }
  ]
});

shepherd.addStep('9 chat', {
  title: 'Chat with us',
  text: ['How did you find that tour?', '1) Super nice!', '2) Kinda nice', '3) Could be betterrrr'],
  attachTo: '#drift-widget top',
  buttons: [
    {
      text: 'Start chat',
      action: function(){
        $('#drift-widget').contents().find('body button').click();
        shepherd.next();
      },
      classes: 'shepherd-button-example-primary'
    }
  ]
});

shepherd.on('complete', function(){
  toastr['success']('You\'re all set. Plenty more features to discover along the way, holla if you need a hand!');
  $.cookie('_onboard_tour', true);
});

// Events
var mediator = new Shepherd.Evented;

mediator.on('start-onboarding', function(){
  slypApp.modalsRegion.show(new slypApp.Views.OnboardModal({ model: slypApp.user }));
});

mediator.on('proceedTo', function(id){
  if (shepherd.currentStep && shepherd.currentStep.isOpen()){
    var fromId = shepherd.currentStep.id;
    var idStepNum = id.split(' ')[0];
    var fromIdStepNum = fromId.split(' ')[0];
    if ((idStepNum - fromIdStepNum) !== 1){
      return
    }

    switch(id){
      case '2 create':
        shepherd.next();
        break;
      case '3 select':
        shepherd.show(id);
        break;
      case '4 send':
        shepherd.show(id);
        break;
      case '5 label':
        shepherd.show(id);
        break;
      default:
        shepherd.next();
    }
  }
});

window.shepherdMediator = mediator;
window.shepherd = shepherd;

// Helper methods
shepherd.isActive = function(){
  var curStep = (this.getCurrentStep() || {});
  return (curStep.isOpen || noop)();
}