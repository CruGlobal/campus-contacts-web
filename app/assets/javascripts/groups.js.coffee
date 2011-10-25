$ ->
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
      