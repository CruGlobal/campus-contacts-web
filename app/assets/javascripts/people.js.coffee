$ ->
  if $('#people_controller.confirm_merge input[type=submit]')[0]
    $('#people_controller.confirm_merge input[type=submit]')[0].focus() 
  $('#user_merge_form input.person').observe_field 0.75, ->
    $(this).triggerPersonLookup()
          
  $('#user_merge_form input.name').observe_field 1, ->
    $(this).triggerPersonSearch()

  $('#user_merge_form input.person').triggerPersonLookup()
  $('#user_merge_form input.name').triggerPersonSearch()
  
  true
  
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
    return false
  $('.to_list').html('')
  ids = []
  no_emails = []
  
  $('.id_checkbox:checked').each ->
    id = $(this).val()
    tr = $(this).parent().parent();
    name = tr.find('.first_name').html() + ' ' + tr.find('.last_name').html()
    email = tr.find('.email').text().length
    if email > 0
      ids.push(id)    
      $('.to_list').append('<li data-id="'+id + '">'+ name + ' <a href="" class="delete">x</a></li>')
    else
      no_emails.push(name)
      
  if($('#all_selected_text').is(':visible'))    
    $('.all_row').each ->
      id = $(this).attr('data-id')
      name = $(this).attr('data-name')
      email = $(this).attr('data-email').length
      if email > 0
        ids.push(id)      
        $('.to_list').append('<li data-id="'+id + '">'+ name + ' <a href="" class="delete">x</a></li>')    
      else
        no_emails.push(name)
        
  if ids.length == 0
    alert("Your selection didn't contain any person with a an email.")
    return false
        
  $('#bulk_send_dialog .subject').show()
  /* disable char counter */
  $('#char_counter').hide()
  $('#body').unbind('keyup')
  $('#body').unbind('paste')  
  nicEdit = null
  $('#bulk_send_dialog').dialog
    resizable: false,
    height:444,
    width:600,
    modal: true,
    title: 'Bulk Send Email Message',
    open: (event, ui) ->

      if no_emails.length > 0
        html = '<p>The following people are missing email addresses and will not be contacted:<br/>'
        for name in no_emails
          html += '&middot; ' + name + '<br/>'
        html += '</p>'
        $('#bulk_send_dialog_message').show().find('.notice').html(html)
      else
        $('#bulk_send_dialog_message').hide()
        
      nicEdit = new nicEditor({fullPanel : true}).panelInstance('body');  
      $(this).find('form').attr('action', '/people/bulk_email')
    close: (event, ui) ->
      nicEdit.removeInstance('body');
    buttons: 
      Send: ->
        $(this).submitBulkSendDialog()
        $.n('Bulk email message sent')
      Cancel: ->
        nicEdit.removeInstance('body');      
        $(this).dialog('destroy')
  false        
  
$('#send_bulksms_link').live 'click', -> 
  if $('.id_checkbox:checked').length == 0
    alert("You didn't select any people to text")
    return false
  $('.to_list').html('')
  ids = []
  no_numbers = []
  
  $('.id_checkbox:checked').each ->
    id = $(this).val()
    tr = $(this).parent().parent();
    name = tr.find('.first_name').html() + ' ' + tr.find('.last_name').html()
    number = tr.find('.phone_number').text().length
    if number > 0
      ids.push(id)    
      $('.to_list').append('<li data-id="'+id + '">'+ name + ' <a href="" class="delete">x</a></li>')
    else
      no_numbers.push(name)

  if($('#all_selected_text').is(':visible'))    
    $('.all_row').each ->
      id = $(this).attr('data-id')
      name = $(this).attr('data-name')
      number = $(this).attr('data-phone-number').length
      if number > 0
        ids.push(id)      
        $('.to_list').append('<li data-id="'+id + '">'+ name + ' <a href="" class="delete">x</a></li>')    
      else
        no_numbers.push(name)

  if ids.length == 0
    alert("Your selection didn't contain any person with a phone number.")
    return false

  $('#bulk_send_dialog .subject').hide()
  $('#char_counter').show()
  $('#body').simplyCountable( { maxCount: 140 } )
  $('#bulk_send_dialog').dialog
    resizable: false,
    height:444,
    width:600,
    modal: true,
    title: 'Bulk Send Sms Message',
    open: (event, ui) ->
      if no_numbers.length > 0
        html = '<p>The following people are missing phone numbers and will not be contacted:<br/>'
        for name in no_numbers
          html += '&middot; ' + name + '<br/>'
        html += '</p>'
        $('#bulk_send_dialog_message').show().find('.notice').html(html)
      else
        $('#bulk_send_dialog_message').hide()
    
      $(this).find('form').attr('action', '/people/bulk_sms')
    close: (event, ui) ->
    buttons: 
      Send: ->
        $(this).submitBulkSendDialog()
        $.n('Bulk sms message sent')        
      Cancel: ->
        $(this).dialog('destroy')
  false        
  
  
$('#bulk_send_dialog form').live 'submit', ->
  false

$('#check_all').live 'click', ->
  text = $('#contacts_table').find('tr:first').text()
  if text.indexOf('Fetching') == 0
    return false
    
  checked = $(this).prop('checked')
  params = $(this).attr('data-params')  
  $('input.id_checkbox').prop('checked', checked)  
  if(checked)    
    $('#contacts_table').prepend('<tr><td colspan="8" align="center">Fetching information...</td></tr>') 
    $.get '/people/all?' + params, (html) ->
      $('#contacts_table').find('tr:first').remove()
      $('#contacts_table').prepend(html)     
    
  else
    $('#contacts_table').find('tr:first').remove()

