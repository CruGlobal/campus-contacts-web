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
    $.fn.showSearchBox()
    
  $("a.add-leader").live 'click', ->
    $('#role').val('leader')
    $.fn.showSearchBox()
    
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
      
$.fn.showSearchBox = ->
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
  
$.fn.activateGroupLabelDroppable = () ->
  $('#groups_controller.index .leftmenu .label').droppable 
    activeClass: 'ui-state-highlight'
    drop: (event, ui) ->
      label = $(this)
      label.effect('highlight', {}, 'slow')
      $('#assign_to').val(label.attr('data-id'))
      # $.fn.assignTo(leader)