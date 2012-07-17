$ ->

  $('.id_checkbox, .check_all, .check_all_contacts, .check_all_mine').live 'click', ->
    toggle_contacts_control()
    
  $("#person_updated_from").datepicker dateFormat: "dd-mm-yy"
  $("#person_updated_to").datepicker dateFormat: "dd-mm-yy"

  $(".field_with_errors").each ->
    $(this).children().eq(0).blur()

  $("select, input[type=text], input[type=password], input[type=email]").live "keypress", (e) ->
    false if e.which is 13

  toggle_contacts_control()
  
  
toggle_contacts_control = ->
  if $(".id_checkbox").is(":checked")
    $(".control_toggle").show()
  else
    $(".control_toggle").hide()