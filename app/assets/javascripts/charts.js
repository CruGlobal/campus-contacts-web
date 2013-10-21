$(document).ready(function() {
  $('button#uncheck_all_movements').bind('click', function () {
    $('#snapshot_movements input.snap_movement').prop({
      disabled: false,
      checked: false
    });
    $('input#snap_all_false').prop('checked',true);
  });
  $('input#snap_all_true').bind('click', function () {
    $('input.snap_movement').prop({
      disabled: true
    });
  });
  $('input#snap_all_false').bind('click', function () {
    $('input.snap_movement').prop({
      disabled: false
    });
  });

  $('div#snapshot_movements_submit input.large_gray').bind('click', function () {
    $('div#snap_container1, div#snap_container2, div#snap_container3, div#snap_numbers').hide();
    $('div#snap_spinner').show();
  });
  $('select#gospel_exp_range').change(function(){
    $('div#snap_container1, div#snap_container2, div#snap_container3, div#snap_numbers').hide();
    $('div#snap_spinner').show();
    $.ajax({
      url: "/charts/update_snapshot_range",
      type: "POST",
      data: {gospel_exp_range: $('select#gospel_exp_range option:selected').val()}
    })
  });
  $('select#laborers_range').change(function(){
    $('div#snap_container1, div#snap_container2, div#snap_container3, div#snap_numbers').hide();
    $('div#snap_spinner').show();
    $.ajax({
      url: "/charts/update_snapshot_range",
      type: "POST",
      data: {laborers_range: $('select#laborers_range option:selected').val()}
    })
  });
  $('select#goal_org_select').change(function(){
    $('div#goal_container, div#goal_box').hide();
    $('div#goal_spinner, div#goal_box_spinner').show();
    $.ajax({
      url: "/charts/update_goal_org",
      type: "POST",
      data: {org_id: $('select#goal_org_select option:selected').val()}
    })
  });
  $('select#goal_criteria_select').change(function(){
    $('div#goal_container, div#goal_box').hide();
    $('div#goal_spinner, div#goal_box_spinner').show();
    $.ajax({
      url: "/charts/update_goal_criteria",
      type: "POST",
      data: {criteria: $('select#goal_criteria_select option:selected').val()}
    })
  });
});