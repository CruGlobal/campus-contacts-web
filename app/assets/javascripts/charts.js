$(document).ready(function() {
  $('input#snap_all_true, input#snap_all_false').bind('click', function () {
    if ($('input#snap_all_true').prop('checked')) {
      $('input.snap_movement').prop({
        disabled: true
      });
    } else if ($('input#snap_all_false').prop('checked')) {
      $('input.snap_movement').prop({
        disabled: false
      });
    }
  });
});