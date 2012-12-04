$ ->
  $(document).ready ->
    $('.import_column_survey_select').each ->
      $('#column_edit_' + $(this).attr('data_id')).show() if $(this).val() == ''
      $(this).children(':first').after("<option value='do_not_import'>Do Not Import</option>")
      
    $('#import_column_question tr:not(:first)').each ->
      select_field = $(this).find('.import_column_survey_select')
      header = $.trim(parseCamelCase($(this).children('.column_header').text().replace(/_|-|:/g,' ')).toLowerCase())
      header_words = header.split(' ')
      if select_field.attr('saved_value') == ''
        select_field.find('option:not(:first))').each ->
          match_question = true
          for word in header_words
            match_question = false if match_question && word.length > 2 && $(this).text().toLowerCase().search(word) == -1
          if match_question
            select_field.val($(this).val()) unless $(this).is(':disabled')
        select_field.trigger('change')
      else
        select_field.val(select_field.attr('saved_value'))
        select_field.trigger('change')
      $('#create_question_dialog').dialog('close')
      
  	$('#create_question_dialog').dialog
  		resizable: false,
  		height: 444,
  		width: 600,
  		modal: true,
  		autoOpen: false,
      open: (event, ui) ->
        $("body").css("overflow", "hidden")
        $('.ui-widget-overlay').width($('body').width())
      close: (event, ui) ->
        $("body").css("overflow", "auto")
      buttons: 
        Save: ->
          $('#import_survey_form').submit()
        Cancel: ->
          $(this).dialog('close')
      
  $('#use_labels').live 'change', ->
    if $(this).is(':checked') 
      $('.label_space').show()
    else
      $('.label_space').hide()
  
  $('.column_edit_link').live 'click', (e)->
    e.preventDefault()
    current_value = $("#import_column_survey_select_"+$(this).attr('data_id')).val()
    $('#question_id_field').val(current_value)
    if current_value is ""
      $('#create_survey_toggle').attr('checked','checked')
      $('#survey_content #new_survey').show()
      $('#survey_content #old_survey').hide()
      $('#survey_question_set').hide()
      $('#survey_name_field').val('')
      $('#select_survey_field').val('')
      $('#question_field').val('')
      $('#question_category').val('')
      $('#question_options_field').val('')
      $('#create_survey_toggle').removeAttr('disabled')
      $('#select_survey_field').removeAttr('disabled')
      $('#question_category').removeAttr('disabled')
      $('#length_counter').text('0')
      $('#question_preview').html('')
      $('#import_error_message').html('')
    else
      selected_question = $("#import_column_survey_select_"+$(this).attr('data_id')).val()
      survey_title = $("#import_column_survey_select_"+$(this).attr('data_id')+" option[value="+selected_question+"]").parents('optgroup').attr('label')
      selected_option = $("#import_column_survey_select_"+$(this).attr('data_id')).children().find("option[value="+selected_question+"]")
      $('#create_survey_toggle').removeAttr('checked')
      $('#survey_content #new_survey').hide()
      $('#survey_content #old_survey').show()
      $('#survey_question_set').show()
      $('#select_survey_field option').each ->
        $('#select_survey_field').val($(this).attr('value')) if $(this).text() == survey_title
      $('#question_category').val(selected_option.attr('question_type'))
      $("#question_category").trigger('change')
      $('#create_survey_toggle').attr('disabled','disabled')
      $('#question_category').attr('disabled','disabled')
      $('#select_survey_field').attr('disabled','disabled')
      $('#question_field').val(selected_option.text())
      $('#question_options_field').val(selected_option.attr('question_content'))
      $('#question_field').trigger('keyup')
      
    $('#create_question_dialog').attr('data_id', $(this).attr('data_id'))
    $('#create_question_dialog').dialog('option', 'position', 'center');
    $('#create_question_dialog').dialog('open')
          
  $('#create_survey_toggle').live 'change', ->
    if $(this).is(':checked')
      $('#survey_content #new_survey').show()
      $('#survey_content #old_survey').hide()
    else
      $('#survey_content #new_survey').hide()
      $('#survey_content #old_survey').show()
      
  $("#question_category").live 'change', ->
    questionType = $(this).val()
    $('#length_counter').text(countCharacters(questionType))
    if questionType.indexOf("TextField") is 0
      $("#survey_question_set").show()
      $('#import_survey_question_options_set').hide()
      $('#length_counter').text(countCharacters('TextField'))
    else if questionType.indexOf("ChoiceField") is 0
      $("#survey_question_set").show()
      $('#import_survey_question_options_set').show()
    else
      $("#survey_question_set").hide()

  $('#question_field, #question_options_field').live 'keyup', ->
    $('#length_counter').text(countCharacters($("#question_category").val()))
    $('#question_preview').html($('#question_field').val() + "<br/>" + $('#question_options_field').val())
  
  $('.import_column_survey_select').live 'change', ->
    selected_option = $(this).children().find("option[value="+$(this).val()+"]")
    if $(this).val() == ""
      $('#column_edit_' + $(this).attr('data_id')).show().click()
    else if selected_option.attr('new') == 'true'
      $('#column_edit_' + $(this).attr('data_id')).show()
    else
      $('#column_edit_' + $(this).attr('data_id')).hide() 
    $(".import_column_survey_select option").removeAttr('disabled')
    $(".import_column_survey_select").each ->
      value = $(this).val().toString()
      $(".import_column_survey_select option[value=" + value + "]").attr('disabled','disabled') if value != '' && value != 'do_not_import'
      $(this).find("option[value=" + $(this).val().toString() + "]").removeAttr('disabled')
    
  
parseCamelCase = (val) ->
  val.replace /[a-z][A-Z]/g, (str, offset) ->
    str[0] + " " + str[1].toLowerCase()
    
countCharacters = (type) ->
  if type is 'TextField'
    return $('#question_field').val().length
  else
    total = $('#question_field').val().length + $('#question_options_field').val().length
    total += 1 if $('#question_options_field').val().length > 0
    return total

  