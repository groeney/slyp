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