(function(w, d) {

  function LetterAvatar(name, size) {

    name = name || '';
    size = size || 60;

      var nameSplit = String(name).toUpperCase().split(' '),
      initials, charIndex, canvas, context, dataURI;

    if (nameSplit.length == 1) {
      initials = nameSplit[0] ? nameSplit[0].charAt(0) : '?';
    } else {
      initials = nameSplit[0].charAt(0) + nameSplit[1].charAt(0);
    }

    if (w.devicePixelRatio) {
      size = (size * w.devicePixelRatio);
    }

    canvas = d.createElement('canvas');
    canvas.width = size;
    canvas.height = size;
    context = canvas.getContext("2d");

    context.fillStyle = "#FFF";
    context.fillRect(0, 0, canvas.width, canvas.height);
    context.font = Math.round(canvas.width / 2) + "px Arial";
    context.textAlign = "center";
    context.fillStyle = "#000";
    context.fillText(initials, size / 2, size / 1.5);

    dataURI = canvas.toDataURL();
    canvas = null;

    return dataURI;
  }

  LetterAvatar.transform = function(el) {
    if (el !== undefined){
      Array.prototype.forEach.call(el.querySelectorAll('img[avatar]'), function(img, name) {
        name = img.getAttribute('avatar');
        img.src = LetterAvatar(name, img.getAttribute('width'));
        img.removeAttribute('avatar');
        img.setAttribute('alt', name);
      });
    }

  };

  LetterAvatar.transform_el = function(el) {
    this.transform(el);
  };

  LetterAvatar.transform_document = function() {
    this.transform(d);
  };

  // AMD support
  if (typeof define === 'function' && define.amd) {

    define(function() {
      return LetterAvatar;
    });

    // CommonJS and Node.js module support.
  } else if (typeof exports !== 'undefined') {

    // Support Node.js specific `module.exports` (which can be a function)
    if (typeof module != 'undefined' && module.exports) {
      exports = module.exports = LetterAvatar;
    }

    // But always support CommonJS module 1.1.1 spec (`exports` cannot be a function)
    exports.LetterAvatar = LetterAvatar;

  } else {

    w.LetterAvatar = LetterAvatar;

    d.addEventListener('DOMContentLoaded', function(event) {
      LetterAvatar.transform();
    });
  }

})(window, document);

String.prototype.trunc =
     function( n, useWordBoundary ){
         var isTooLong = this.length > n,
             s_ = isTooLong ? this.substr(0,n-1) : this;
         s_ = (useWordBoundary && isTooLong) ? s_.substr(0,s_.lastIndexOf(' ')) : s_;
         return  isTooLong ? s_ + '&hellip;' : s_;
      };

String.prototype.pluralize = function(count, plural)
{
  if (plural == null)
    plural = this + 's';
  return (count == 1 ? count + ' ' + this : count + ' ' + plural)
}

var resizePopup = function(){$('.ui.popup').css('max-height', $(window).height());};
$(window).resize(function(e){
    resizePopup();
});

function validateEmail(email) {
    var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(email);
}