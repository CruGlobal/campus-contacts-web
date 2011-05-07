$.jQTouch({});
$(function() {
  $('a[rel=external]').click(function() {
    $(location).attr('href',this.href);
  });

});
