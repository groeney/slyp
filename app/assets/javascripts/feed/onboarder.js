// Tour
var shepherd = new Shepherd.Tour({
  defaults: {
    classes: 'shepherd-element shepherd-open shepherd-theme-square-dark',
    showCancelLink: true
  }
});

// Steps and triggers
shepherd.addStep('1 add', {
  title: 'Add slyps',
  text: 'Click on the <i class="plus icon"></i> icon to create a new slyp',
  attachTo: '#add-button bottom',
  buttons: false
});

// trigger
// Find in ./views/NavBar.js:154

shepherd.addStep('2 create', {
  title: 'Create',
  text: 'Nice. We found a link for you, try adding it!',
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
// Find in ./views/NavBar.js:126

shepherd.addStep('3 select', {
  title: 'Select friends',
  text: ['Well done!', 'Hint: you can send to yourself and include a personal note for later.'],
  attachTo: '#card-0 #reslyp-dropdown right',
  buttons: false,
  when: {
    'before-show' : function(){
      $('#send-button').first().click();
      $('html, body').animate({ scrollTop: '200px' });
    }
  }
});

// trigger
// Find in ./views/UserSlyp.js:364

shepherd.addStep('4 send', {
  title: 'Add comment and send',
  text: ['Suggestion: "good #weekendread, related to #work"', 'You\'ll be able to search over this later.'],
  attachTo: '#card-0 #reslyp-comment right',
  buttons: false
});

// trigger
// Find in ./views/UserSlyp.js:268

shepherd.addStep('5 label', {
  title: 'At a glance',
  text: ['Nice job! This is your most recent conversation at a glance.', 'Click it once to reply quickly.', 'Click it twice to view your conversations.'],
  attachTo: '#card-0 #comment-label right',
  buttons: [
    {
      text: 'Nice',
      action: shepherd.next,
      classes: 'shepherd-button-example-primary'
    }
  ],
  when: {
    'before-show' : function(){
      $('html, body').animate({ scrollTop: '0px' });
    }
  }
});

// trigger
// Find inside step->buttons:action

shepherd.addStep('6 actions', {
  title: 'The fun part',
  text: ['Use <i class="send icon"></i> to send to friends (you\'ve done that!).', 'Use <i class="search icon"></i> to view the content and <i class="comment outline icon"></i> to view your conversations.'],
  attachTo: '#card-0 #slyp-actions right',
  buttons: [
    {
      text: 'Got it, thanks',
      action: function(e){
        $('.blurring.image img').first().trigger('mouseleave');
        shepherd.next();
      },
      classes: 'shepherd-button-example-primary'
    }
  ],
  when: {
    'before-show': function(){
      $('.blurring.image img').first().trigger('mouseenter');
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
  ]
});

shepherd.addStep('8 simultaneous', {
  title: 'Engage',
  text: ['These are your "engagement panels", where you can read and discuss with friends.', 'You can also send this article to friends via Facebook Messenger or post to Twitter.'],
  attachTo: '#js-sidebar-region right',
  buttons: [
    {
      text: 'Great',
      action: shepherd.next,
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
    return this.currentStep.isOpen();
}