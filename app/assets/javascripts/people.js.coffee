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
        
$('#send_bulkemail_link').live 'click', -> 
  $('.to_list').html('')
  ids = []
  $('.id_checkbox:checked').each ->
    id = $(this).val()
    ids.push(id)
    $('.to_list').append('<li data-id="'+id + '">'+$(this).parent().next().html() + ' <a href="" class="delete">x</a></li>')
  $('#bulk_send_dialog').dialog
    resizable: false,
    height:444,
    width:600,
    modal: true,
    buttons: 
      Cancel: ->
        $(this).dialog('destroy')
  false        
  
$('#bulk_send_dialog form').live 'submit', ->
  ids = []
  $('.to_list li').each ->
    id = $(this).attr('data-id')
    ids.push(id)
  $('#to').val(ids.join(','))
  $('#bulk_send_dialog').dialog('destroy')
  $.rails.handleRemote($(this))
  false