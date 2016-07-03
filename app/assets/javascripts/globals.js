function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}

Object.defineProperty( String.prototype, 'http', {
    get: function () {
      var http = 'http';
      var startsWith = this.substring(0, http.length) == http;
      var includes = this.indexOf('://') > 3;
      return (startsWith && includes)
    }
});

String.prototype.pluralize = function(count, plural)
{
  if (plural == null)
    plural = this + 's';
  return (count == 1 ? count + ' ' + this : count + ' ' + plural)
}

String.prototype.trunc =
     function( n, useWordBoundary ){
         var isTooLong = this.length > n,
             s_ = isTooLong ? this.substr(0,n-1) : this;
         s_ = (useWordBoundary && isTooLong) ? s_.substr(0,s_.lastIndexOf(' ')) : s_;
         return  isTooLong ? s_ + '...' : s_;
      };

function validateEmail(email) {
  var re = /^(([^<>()\[\]\\.,;:\s@']+(\.[^<>()\[\]\\.,;:\s@']+)*)|('.+'))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(email);
}

function urlDomain(url) {
  var    a      = document.createElement('a');
         a.href = url;
  return a.hostname;
}

function generateFavicon(url) {
  return 'http://www.google.com/s2/favicons?domain=' + urlDomain(url)
}

function randomFromInterval(min,max)
{
    return Math.floor(Math.random()*(max-min+1)+min);
}

$.fn.exists = function () {
    return this.length !== 0;
}

var resizePopup = function(){
  $('.ui.popup').css('max-height', $(window).height()/1.5);
  $('.ui.popup').css('overflow-y', 'scroll');
};

$(window).resize(function(e){
  resizePopup();
});

var getScreenWidth = function(){
  return $(window).width()
}

var generateAvatarURL = function(value, fallback){
  var letter = typeof value == 'string' ? value[0] : (typeof fallback == 'string' ? fallback[0] : null)
  if (letter == null){
    return 'https://scontent.fmel1-1.fna.fbcdn.net/v/t1.0-1/c47.0.160.160/p160x160/10354686_10150004552801856_220367501106153455_n.jpg?oh=27badd77b946a9807aad0929dc4d3771&oe=57B8BF49'
  } else {
    return 'https://ssl.gstatic.com/bt/C3341AA7A1A076756462EE2E5CD71C11/avatars/avatar_tile_'+letter.toLowerCase()+'_28.png'
  }
}

var _toastr = function(type, message, options){
  message = typeof message !== 'undefined' ? message : 'Our robots cannot perform that action right now :(';
  type = typeof type !== 'undefined' ? type : 'success'; // Default to success toastr
  options = typeof options !== 'undefined' ? options : { 'positionClass': 'toast-top-center' };
  toastr.options = options;
  toastr[type](message);
}

var notImplemented = function(feature){
  if (typeof feature != 'string'){
    feature = '';
  } else {
    analytics.track('Feature Interest ' + feature);
  }

  _toastr('info', 'We\'ve logged your interest in our new ' + feature + ' feature. Coming soon <i class="smile icon"></i>');
}
