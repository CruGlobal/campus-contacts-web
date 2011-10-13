$ ->
  if $('#people_controller.confirm_merge input[type=submit]')[0]
    $('#people_controller.confirm_merge input[type=submit]')[0].focus() 
  $('#user_merge_form input.person').observe_field 0.75, ->
    $(this).triggerPersonLookup()
          
  $('#user_merge_form input.name').observe_field 1, ->
    $(this).triggerPersonSearch()

  
  $('#user_merge_form input.person').triggerPersonLookup()
  $('#user_merge_form input.name').triggerPersonSearch()
  
$.fn.triggerPersonSearch = ->
  this.each ->
    name = $(this).val()
    $('#person_ids').hide()
    $('input.person').val('')
    $('.merge.person.preview').hide()
    return false if $.trim(name) == ''
    $("#spinner_name").show()
    $.ajax
      url: '/people/search_ids.json?q=' + name
      type: 'GET',
      success: (data)->
        $('#ids').html('<strong>' + name + '</strong>: ' + data.join(', '))
        $('#person_ids').show()
        $.each data, (i, val)->
          field = $('#person'+(i+1))
          if field[0]
            field.val(val)
      complete: ->
        $("#spinner_name").hide()
        
$.fn.triggerPersonLookup = ->
  this.each ->
    css_class = $(this).attr('id')
    id = $(this).val()
    unless Number(id) > 0
      $('.merge.' + css_class).hide()
      return false 
    $("#spinner_" + css_class).show()
    $.ajax
      url: '/people/' + id + '/merge_preview?class=' + css_class
      type: 'GET',
      complete: ->
        $('.merge.' + css_class).show()
        $("#spinner_" + css_class).hide()
        
$.fn.submitBulkSendDialog = ->
  ids = []
  $('.to_list li').each ->
    id = $(this).attr('data-id')
    ids.push(id)
  $('#to').val(ids.join(','))
  $('#bulk_send_dialog').dialog('destroy')
  $.rails.handleRemote($("#bulk_send_dialog form"))
        
        
$('#send_bulkemail_link').live 'click', -> 
  if $('.id_checkbox:checked').length == 0
    alert("You didn't select any people to email")
    return
  $('.to_list').html('')
  ids = []
  $('.id_checkbox:checked').each ->
    id = $(this).val()
    ids.push(id)
    tr = $(this).parent().parent();
    name = tr.find('.first_name').html() + ' ' + tr.find('.last_name').html()
    $('.to_list').append('<li data-id="'+id + '">'+ name + ' <a href="" class="delete">x</a></li>')
  $('#bulk_send_dialog .subject').show()
  $('#bulk_send_dialog').dialog
    resizable: false,
    height:444,
    width:600,
    modal: true,
    title: 'Bulk Send Email Message',
    open: (event, ui)->
      no_emails = []
      $('.id_checkbox:checked').each ->
         tr = $(this).parent().parent();
         name = tr.find('.first_name').html() + ' ' + tr.find('.last_name').html()
         email = tr.find('.email').text().length
         if email == 0
           no_emails.push(name)
      if no_emails.length > 0
        html = '<p>The following people are missing email addresses and will not be contacted:<br/>'
        for name in no_emails
          html += '&middot; ' + name + '<br/>'
        html += '</p>'
        $("#bulk_send_dialog_message .notice").html(html).show()
      else
        $("#bulk_send_dialog_message").hide()
        
      $(this).find('form').attr("action", '/people/bulk_email')
    buttons: 
      Send: ->
        $(this).submitBulkSendDialog()
      Cancel: ->
        $(this).dialog('destroy')
  false        
  
$('#send_bulksms_link').live 'click', -> 
  if $('.id_checkbox:checked').length == 0
    alert("You didn't select any people to text")
    return
  $('.to_list').html('')
  ids = []
  $('.id_checkbox:checked').each ->
    id = $(this).val()
    ids.push(id)
    tr = $(this).parent().parent();
    name = tr.find('.first_name').html() + ' ' + tr.find('.last_name').html()
    $('.to_list').append('<li data-id="'+id + '">'+ name + ' <a href="" class="delete">x</a></li>')
  $('#bulk_send_dialog .subject').hide()
  $('#bulk_send_dialog').dialog
    resizable: false,
    height:444,
    width:600,
    modal: true,
    title: 'Bulk Send Sms Message',
    open: (event, ui)->
      no_numbers = []
      $('.id_checkbox:checked').each ->
         tr = $(this).parent().parent();
         name = tr.find('.first_name').html() + ' ' + tr.find('.last_name').html()
         number = tr.find('.phone_number').text().length
         if number == 0
           no_numbers.push(name)
      if no_numbers.length > 0
        html = '<p>The following people are missing phone numbers and will not be contacted:<br/>'
        for name in no_numbers
          html += '&middot; ' + name + '<br/>'
        html += '</p>'
        $("#bulk_send_dialog_message .notice").html(html).show()
      else
        $("#bulk_send_dialog_message").hide()
    
      $(this).find('form').attr("action", '/people/bulk_sms')
    buttons: 
      Send: ->
        $(this).submitBulkSendDialog()
      Cancel: ->
        $(this).dialog('destroy')
  false        
  
  
$('#bulk_send_dialog form').live 'submit', ->
  false