$ ->
  $("#person_updated_from").datepicker dateFormat: "dd-mm-yy"
  $("#person_updated_to").datepicker dateFormat: "dd-mm-yy"
  $('#archive_contacts_before').datepicker dateFormat: "dd-mm-yy"

  $(".field_with_errors").each ->
    $(this).children().eq(0).blur()

  $("select, input[type=text], input[type=password], input[type=email]").live "keypress", (e) ->
    false if e.which is 13