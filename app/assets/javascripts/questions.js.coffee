$ ->
  # update sms length
  $('.label, .content').live 'keyup', (event)->
    return false if $('#web_only_' + $(this).closest('.inlineform').attr('data-elem-id')).prop("checked")
    letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
    parent = $(this).closest('.inlineform')
    sms = $('.label', parent).val()
    if $('.content', parent)[0]? and $('.content', parent).val().trim() != ''
      $.each $('.content', parent).val().split("\n"), (i, option) ->
        sms += ' ' + letters[i] + ')' + option;
    if sms.length == 141
      inp = String.fromCharCode event.which
      if /[a-zA-Z0-9-_ ]/.test(inp)
        alert(t('application.messages.question_too_long'))
        # if $('.content', parent)[0]? and $('.content', parent).val().trim() != ''
        #   $('.content', parent).val($('.content', parent).val().substr(0,$('.content', parent).val().length - 1))
        # else
        #   $('.label', parent).val($('.label', parent).val().substr(0,140))
        return false
    $('.sms_length', parent).html(sms.length)
    $('.sms_preview').html(sms)
  
  $('#add_question_link').live 'click', ->
    $('.inlineform').hide()
    $('#new_question_form').closest('.inlineform').show()
    $('#create_question_form').slideDown()
    $('.advanced_options').hide()
    $('.sms_length').html(0)
    $('.sms_preview').html('')
    false
    
  $('#add_old_question_link').live 'click', ->
    $('#previously_used').dialog
      resizable: false,
      height: 700,
      width: 800,
      modal: true,
      buttons: 
        Close: ->
          $(this).dialog('destroy')
    false
    
  $('.use_question, .remove_question').live 'click', ->
  	$(this).closest('tr').fadeOut()
  	$(this).closest('tr').remove()
  	false
  	
  $('.question_type').live 'change', ->
	  form = $(this).closest('form')
	  switch $(this).val()
	    when ''
        $('.right_col').hide()
        $('.multiple_choice_form', form).hide()
        $('.short_answer_form', form).hide()
        $('.submit_button', form).hide()
      when 'TextField:short'
        $('.multiple_choice_form', form).hide()
      else
        $('.multiple_choice_form', form).show()
    false
    if $(this).val() != ''
      if $('#web_only_' + $(this).closest('.inlineform').attr('data-elem-id')).prop("checked")
        $('.right_col').hide()
      else
        $('.right_col').show()
      $('.short_answer_form', form).show()
      $('.submit_button', form).show()
    
  $('.web_only').live 'click', ->
    if $(this).prop('checked')
      $(this).closest('.inlineform').find('.right_col').hide()
    else
      wrapper = $(this).closest('.inlineform')
      wrapper.find('.label').keyup()
      wrapper.find('.right_col').show()
      
  $('.question_form').submit ->
    $('#question_form').slideUp 2000
  .bind 'ajax:complete', ->
    $('.question_form')[0].reset()
    $('#question_type').change()
    
  $('#advanced_toggle').live 'click', (e) ->
    e.preventDefault()
    $('.advanced_options').slideToggle()
    if $('.advanced_options').is(':visible')
      $(this).text(t('surveys.questions.form.hide_advanced_options'))
    else
      $(this).text(t('surveys.questions.form.show_advanced_options'))

  $('#notify_advanced_toggle').live 'click', (e) ->
    e.preventDefault()
    $('.notify_advanced_options').toggle()
    if $('.notify_advanced_options').is(':visible')
      $(this).text(t('surveys.questions.form.hide_notification_options'))
    else
      $(this).text(t('surveys.questions.form.show_notification_options'))

  $('#assignment_advanced_toggle').live 'click', (e) ->
    e.preventDefault()
    $('.assignment_advanced_options').toggle()
    if $('.assignment_advanced_options').is(':visible')
      $(this).text(t('surveys.questions.form.hide_assignment_options'))
    else
      $(this).text(t('surveys.questions.form.show_assignment_options'))
	
  $('#cancel_survey_question').live 'click', (e)->
    e.preventDefault()
    $('.inlineform').show()
    $('#new_question_form').closest('.inlineform').hide()
    $('.question_form')[0].reset()
    $('.question_form')[1].reset()
    $('#question_form').slideUp()
    false
    
  $('#move_right').live 'click', ->
   alert $('#leaders_').html()
   alert $('#current_leaders_').html()
   $('#leaders_').children().clone(true).appendTo('#current_leaders_').selectmenu('refresh')
