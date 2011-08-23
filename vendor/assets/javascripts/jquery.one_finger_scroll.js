jQuery.fn.oneFingerScroll = function() {
  var scrollStartPos = 0;
  $(this).bind('touchstart', function(event) {
      // jQuery clones events, but only with a limited number of properties for perf reasons. Need the original event to get 'touches'
      var e = event.originalEvent;
      scrollStartPos = $(this).scrollTop() + e.touches[0].pageY;
      e.preventDefault();
  });
  $(this).bind('touchmove', function(event) {
      var e = event.originalEvent;
      $(this).scrollTop(scrollStartPos - e.touches[0].pageY);
      e.preventDefault();
  });
  return this;
};