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

function randomFromInterval(min,max)
{
    return Math.floor(Math.random()*(max-min+1)+min);
}