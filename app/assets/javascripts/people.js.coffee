$ ->
  $('#apply_roles_spinner').hide()
  $("#apply_roles_successful").hide()

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
    name = tr.attr('data-name')
    email = tr.find('.email').text().length
    if email > 0
      ids.push(id)    
      $('.to_list').append('<li data-id="'+id + '">'+ name + ' <a href="" class="delete">x</a></li>')
    else
      no_emails.push($.trim(name))
      
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
  
  $('#bulk_send_dialog form').addClass('bulk-email')
  $('#bulk_send_dialog form').removeClass('bulk-sms')
  $('#bulk_send_dialog .subject').show()
  /* disable char counter */
  $('#char_counter').hide()
  $('#body').unbind('keyup')
  $('#body').unbind('paste')  
  $('#body').val($('#bulk_email_message').val())
  nicEdit = null
  $('#bulk_send_dialog').dialog
    resizable: false,
    height:644,
    width:600,
    modal: true,
    title: 'Send Email Message',
    open: (event, ui) ->

      if no_emails.length > 0
        html = '<p>The following people are missing email addresses and will not be contacted:<br/>'
        html += no_emails.join(', ')
        html += '</p></div>'
        $('#bulk_send_dialog_message').show().find('.notice').html(html)
      else
        $('#bulk_send_dialog_message').hide()
        
      nicEdit = new nicEditor({fullPanel : true}).panelInstance('body');  
      $(this).find('form').attr('action', '/people/bulk_email')
    close: (event, ui) ->
      nicEdit.removeInstance('body');
      $('#bulk_email_message').val($('#body').val())      
    buttons: 
      Send: ->
        nicEdit.removeInstance('body');        
        $(this).submitBulkSendDialog()
        $('#bulk_email_message').val($('#body').val())              
        $.n('Email message sent')
      Cancel: ->
        nicEdit.removeInstance('body');      
        $('#bulk_email_message').val($('#body').val())              
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
    name = tr.attr('data-name')
    number = tr.find('.phone_number').text().length
    if number > 0
      ids.push(id)    
      $('.to_list').append('<li data-id="'+id + '">'+ name + ' <a href="" class="delete">x</a></li>')
    else
      no_numbers.push($.trim(name))

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

  $('#bulk_send_dialog form').removeClass('bulk-email')
  $('#bulk_send_dialog form').addClass('bulk-sms')
  $('#bulk_send_dialog .subject').hide()
  $('#char_counter').show()
  $('#body').simplyCountable( { maxCount: 125 } )
  $('#body').val($('#bulk_sms_message').val())  
  $('#bulk_send_dialog').dialog
    resizable: false,
    height:444,
    width:600,
    modal: true,
    title: 'Send Text Message',
    open: (event, ui) ->
      if no_numbers.length > 0
        html = '<div class="missing"><p>The following people are missing phone numbers and will not be contacted:<br/>'
        html += no_numbers.join(', ')
        html += '</p></div>'
        $('#bulk_send_dialog_message').show().find('.notice').html(html)
      else
        $('#bulk_send_dialog_message').hide()
    
      $(this).find('form').attr('action', '/people/bulk_sms')
    close: (event, ui) ->
      $('#bulk_sms_message').val($('#body').val())            
    buttons: 
      Send: ->
        $(this).submitBulkSendDialog()
        $('#bulk_sms_message').val($('#body').val())                
        $.n('Text message sent')        
      Cancel: ->
        $('#bulk_sms_message').val($('#body').val())        
        $(this).dialog('destroy')
  false        
  
$('#bulk_send_dialog form').live 'submit', ->
  false

$('#check_all').live 'click', ->
  text = $('#contacts_table').find('tr:first').text()
  if text.indexOf('Fetching') == 0
    return false
    
  checked = $(this).prop('checked')
  change_all_role_checkboxes(false) if !checked
  params = $(this).attr('data-params')  
  $('input.id_checkbox').prop('checked', checked)  
  change_all_role_checkboxes(true) if checked
  
  /* only show option to select more if there are more than 1 page */
  if $('.pagination').length
    if checked    
      $('#contacts_table').prepend('<tr><td colspan="8" align="center" style="background:none;">Fetching information...</td></tr>') 
      $.get '/people/all?' + params, (html) ->
        $('#contacts_table').find('tr:first').remove()
        $('#contacts_table').prepend(html)     
    else
      $('#contacts_table').find('tr:first').remove()

$('#roles_menu_div').live 'click', ->
  role_div = $(this).parent().find('.dropdown_1column')

  if $(role_div).attr('style')
    role_div.attr('style', '')
    $(this).attr('style', '')
  else
    role_div.css('left', '44.8em')
    $(this).attr('style', 'background: url("/assets/pillbg_over.png") repeat-x')
   
$('#apply_roles').live 'click', -> 
  role_ids = []

  if $('.role_id_checkbox:checked').length == 0
    alert("You didn't select any roles to apply.")
    return false
  
  if $('.id_checkbox:checked').length == 0
    alert("You didn't select any people to update roles.")
    return false

  $('.role_id_checkbox:checked').each ->
    role_id = $(this).val()
    role_ids.push(role_id)    

  $('#apply_roles_spinner').show()
  checked_elements = $('.id_checkbox:checked')

  $(checked_elements).each ->
    person = $(this)
 
    $.ajax
      type: 'POST',
      url: '/people/update_roles',
      data: 'role_ids='+role_ids+'&person_id='+person.val(),
      complete: ->
        if checked_elements.last().val() == person.val()
          console.log "KARREN" 
          $("#apply_roles_spinner").hide()
          $("#apply_roles_successful").show()
          $("#apply_roles_successful").html("Roles have been applied.")

$('.id_checkbox').live 'click', ->
  mark_as_checked = $(this).is ':checked'
  role_labels = get_role_labels($(this))
  change_role_checkboxes(role_labels, mark_as_checked)
  change_all_role_checkboxes(true) if !mark_as_checked  

get_role_labels = (obj) ->   
  firstname_div = $(obj).parent().next()
  role_labels = $(firstname_div).find('span.role_label')
  role_labels

change_role_checkboxes = (role_labels, check) ->
  role_labels.each ->
    role = $(this).attr('id').split('_')
    checkbox = '#role_ids_' + role[1] 
    $(checkbox).attr checked: check 

change_all_role_checkboxes = (check) ->
  $('input.id_checkbox:checked').each ->
    role_labels = get_role_labels($(this))
    change_role_checkboxes(role_labels, check) 
