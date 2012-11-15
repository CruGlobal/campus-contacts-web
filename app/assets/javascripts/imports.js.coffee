$ ->
  $(document).ready ->
    $('.import_column_survey_select').each ->
      $('#column_edit_' + $(this).attr('data_id')).show() if $(this).val() == ''
      
    $('#import_column_question tr:not(:first)').each ->
      select_field = $(this).find('.import_column_survey_select')
      header = $.trim(parseCamelCase($(this).children('.column_header').text().replace(/_|-|:/g,' ')).toLowerCase())
      header_words = header.split(' ')
      select_field.find('option:not(:first)').each ->
        match_question = true
        for word in header_words
          match_question = false if match_question && word.length > 2 && $(this).text().toLowerCase().search(word) == -1
        if match_question
          select_field.val($(this).val()) unless $(this).is(':disabled')
      select_field.trigger('change')
          
        
  
  $('.import_column_survey_select').live 'change', ->
    if $(this).val() == ''
      $('#column_edit_' + $(this).attr('data_id')).show() 
    else
      $('#column_edit_' + $(this).attr('data_id')).hide() 
    $(".import_column_survey_select option").removeAttr('disabled')
    $(".import_column_survey_select").each ->
      value = $(this).val().toString()
      $(".import_column_survey_select option[value=" + value + "]").attr('disabled','disabled') if value != ''
      $(this).find("option[value=" + $(this).val().toString() + "]").removeAttr('disabled')
    
  
parseCamelCase = (val) ->
  val.replace /[a-z][A-Z]/g, (str, offset) ->
    str[0] + " " + str[1].toLowerCase()

  