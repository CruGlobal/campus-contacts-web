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
$(document).ready(function() {
  $('div#snapshot_movements_submit input.large_gray').bind('click', function () {
    $('div#snap_container1, div#snap_container2, div#snap_container3').hide();
    $('div#snap_spinner').show();
  });
});