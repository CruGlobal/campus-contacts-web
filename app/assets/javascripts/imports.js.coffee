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
        Cancel: ->
          $(this).dialog('close')
      
  $('.column_edit_link').live 'click', (e)->
    e.preventDefault()
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
    if questionType is "TextField"
      $("#survey_question_set").show()
      $('#import_survey_question_options_set').hide()
      $('#length_counter').text(countCharacters('TextField'))
    else if questionType is "ChoiceField"
      $("#survey_question_set").show()
      $('#import_survey_question_options_set').show()
    else
      $("#survey_question_set").hide()

  $('#question_field, #question_options_field').live 'keyup', ->
    $('#length_counter').text(countCharacters($("#question_category").val()))
    $('#question_preview').html($('#question_field').val() + "<br/>" + $('#question_options_field').val())
  
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
    
countCharacters = (type) ->
  if type is 'TextField'
    return $('#question_field').val().length
  else
    total = $('#question_field').val().length + $('#question_options_field').val().length
    total += 1 if $('#question_options_field').val().length > 0
    return total

  