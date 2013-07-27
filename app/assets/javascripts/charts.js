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
$(document).ready(function() {
  $('select#gospel_exp_range').change(function(){
    $('div#snap_container1, div#snap_container2, div#snap_container3').hide();
    $('div#snap_spinner').show();
    $.ajax({
      url: "/charts/update_snapshot_range",
      type: "POST",
      data: {gospel_exp_range: $('select#gospel_exp_range option:selected').val()},
    })
  });
});
$(document).ready(function() {
  $('select#laborers_range').change(function(){
    $('div#snap_container1, div#snap_container2, div#snap_container3').hide();
    $('div#snap_spinner').show();
    $.ajax({
      url: "/charts/update_snapshot_range",
      type: "POST",
      data: {laborers_range: $('select#laborers_range option:selected').val()},
    })
  });
});