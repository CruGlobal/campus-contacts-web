$ ->
  $("#person_updated_from").datepicker dateFormat: "dd-mm-yy"
  $("#person_updated_to").datepicker dateFormat: "dd-mm-yy"
  $('#archive_contacts_before').datepicker dateFormat: "dd-mm-yy"

  $(".field_with_errors").each ->
    $(this).children().eq(0).blur()

  $("select, input[type=text], input[type=password], input[type=email]").live "keypress", (e) ->
    false if e.which is 13
    
  $('#bulk_send_text_dialog .multiselect').chosen()
  $('#bulk_send_text_dialog').dialog
    resizable: false,
    height:444,
    width:730,
    modal: true,
    autoOpen: false,
    title: 'Send Text Message',
    open: (event, ui) ->
      $("body").css("overflow", "hidden")
      $(this).find('form').attr('action', '/people/bulk_sms')
    close: (event, ui) ->
      $("body").css("overflow", "auto")
      $('#bulk_sms_message').val($('#bulk_send_body').val())            
    buttons: 
      Send: ->
        $(this).submitBulkSendTextDialog()      
      Cancel: ->
        $(this).dialog('close')
      

