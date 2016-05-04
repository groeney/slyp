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