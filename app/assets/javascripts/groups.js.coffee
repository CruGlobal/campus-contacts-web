$ ->
  $('#group_table .controls a.delete').live 'click', (e)->
    $(this).closest('tr').fadeOut()
    
  if $('#group_meeting_day')?
    $('#group_meeting_day').val($('#day_of_week').val())
  $('#group_meets').live 'change', ->
    meets = $(this).val()
    switch meets
      when "weekly"
        $('.regular').show()
        $('.day_of_month_div').hide()
        $('.day_of_week_div').show()
        $('#group_meeting_day').val($('#day_of_week').val())
      when "monthly"
        $('.regular').show()
        $('.day_of_week_div').hide()
        $('.day_of_month_div').show()
        $('#group_meeting_day').val($('#day_of_month').val())
      when 'sporadically'
        $('.regular').hide()
        $('#group_meeting_day').val('')
  
  $('#day_of_week').live 'change', ->
    $('#group_meeting_day').val($(this).val())
    
  $('#day_of_month').live 'change', ->
    $('#group_meeting_day').val($(this).val())
        
  $('#group_list_publicly').live 'change', ->
    if $('#group_list_publicly').prop('checked')
      $('.approve_join').show()
    else
      $('.approve_join').hide()

  $("a.add-member").live 'click', ->
    $('#role').val('member')
    $('#member_search').attr('title', $('#add_member_prompt').text())
    $.fn.showSearchBox()
    false
    
  $("a.add-leader").live 'click', ->
    $('#role').val('leader')
    $('#member_search').attr('title', $('#add_leader_prompt').text())
    $.fn.showSearchBox()
    false
    
  $('#member_search_name').autocomplete
    source: (request, response)->
      form = $('#member_search_form')
      $('#spinner_member_search').show()
      $.ajax
        url: form.attr('action'), 
        data: form.serialize(), 
        type: 'GET',
        success: (data)->
          $('#member_search_results').html(data)
          $("#member_search_results").show()
        complete: ->
          $('#spinner_member_search').hide()
        error: (xhr, status, error)->
          alert(error)
      response([]);

  $('#add_new_person_group_button').live 'click', ->
    $('#member_search .explain').hide()
    $('#member_search_form').hide()
    $('#member_search_results').hide()
    $('#add_person_group_div').show()
    $('#new_member_form').show()
    false

  $('#add_person_group_div .save').live 'click', ->
    form = $(this).closest('form')
    if $('#person_firstName', form).val() == '' #or ($('#person_email_address_email', form).val() == '' &&$('#person_phone_number_number', form).val() == '')
      alert('At a minimum you need to provide a first name.')
      return false

    add_another = false      
    if $(this).hasClass('save_and_more')
      add_another = true
    params = form.serialize() + '&add_to_group=y'
    url = form.prop('action')
    $.post url, params, (data) ->
      group_id = 1
      personId = data.person.personID
      $('<a href="/groups/' + group_id  + '/group_memberships?person_id=' + personId + '&role=member&add_another=' + add_another + '"data-method="post" data-remote="true"></a>')
      .appendTo(body)
      .click()
      .remove()
    , 'json'
    $.fn.showSearchBox()
    $('#new_person')[0].reset()
    false
      
      
$.fn.showSearchBox = ->
  $('#member_search .explain').show()
  $('#add_member_form').hide()
  $('#member_search_form').show()
  $('#member_search_name').val('')
  $("#member_search_results").hide()
  $('#new_member_form').hide();
  el = $('#member_search')
  el.dialog
    resizable: false,
    height:650,
    width:600,
    modal: true,
    buttons: 
      Cancel: ->
        $(this).dialog('destroy')
  false
