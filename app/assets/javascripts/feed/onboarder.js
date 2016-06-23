// Tour
var shepherd = new Shepherd.Tour({
  defaults: {
    classes: 'shepherd-element shepherd-open shepherd-theme-arrows',
    showCancelLink: true
  }
});

// Steps and triggers
shepherd.addStep('1 add', {
  title: 'Add slyps',
  text: 'Click on the icon to create a new slyp',
  attachTo: '#add-button bottom',
  buttons: false
});

// trigger
// Find in ./views/NavBar.js:154

shepherd.addStep('2 create', {
  title: 'Create',
  text: 'Nice. We\'ve pre-populated a link for you, try adding it!',
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
  text: ['Well done! Now select a friend to send to.', 'Hint: you can send to yourself and include a personal note.'],
  attachTo: '#reslyp-dropdown bottom',
  buttons: false,
  when: {
    'before-show' : function(){
      $('html, body').animate({ scrollTop: '200px' });
      $('#send-button').first().click();
    }
  }
});

// trigger
// Find in ./views/UserSlyp.js:350

shepherd.addStep('4 send', {
  title: 'Add comment and send',
  text: ['Now tell them why this slyp is shareworthy and send it!'],
  attachTo: '#reslyp-comment right',
  buttons: false
});

// trigger
// Find in ./views/UserSlyp.js:260

shepherd.addStep('5 label', {
  title: 'At a glance',
  text: ['Nice job! This is your most recent conversation at a glance. Click it to reply quickly. Double click it to open your conversations.'],
  attachTo: '#comment-label right',
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
  text: ['Use <i class="send icon"></i> to send to friends (you\'ve done that!).', 'Use <i class="search icon"></i> to see the content and <i class="comment outline icon"></i> to view your conversations.'],
  attachTo: '#slyp-actions bottom',
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
  title: 'Magic',
  text: 'We want to show you something cool. Do you want to see?',
  attachTo: '.blurring.image bottom',
  buttons: [
    {
      text: 'Yes, please!',
      action: function(e){
        $('#preview-button').first().click();
        setTimeout(function(){
          $('#open-conversations').click();
          shepherd.next();
        },100);
      },
      classes: 'shepherd-button-example-primary'
    },
    {
      text: 'Nope, good for now',
      classes: 'shepherd-button-secondary',
      action: shepherd.complete
    }
  ]
});

shepherd.addStep('8 simultaneous', {
  title: 'Engage',
  text: ['These are your engagement panels. You can read and talk about this article with friends at the same time.', 'You can also send this article to friends via Messenger or post it to Twitter with the appropriate buttons.'],
  attachTo: '#close-left-pane left',
  buttons: [
    {
      text: 'Great',
      action: shepherd.next,
      classes: 'shepherd-button-example-primary'
    }
  ]
});

shepherd.on('complete', function(){
  toastr['success']('You\'re all set. Plenty more features to discover along the way, holla if you need a hand!')
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
        setTimeout(function(){
          shepherd.show(id);
        }, 500);
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
