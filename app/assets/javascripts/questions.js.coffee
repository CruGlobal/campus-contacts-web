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
    if sms.length >= 141
      inp = String.fromCharCode event.which
      if /[a-zA-Z0-9-_ ]/.test(inp)
        alert('Due to restrctions on text message lengths, the total length of your question can\'t be more than 140 characters.')
        if $('.content', parent)[0]? and $('.content', parent).val().trim() != ''
          $('.content', parent).val($('.content', parent).val().substr(0,$('.content', parent).val().length - 1))
        else
          $('.label', parent).val($('.label', parent).val().substr(0,140))
        return false
    $('.sms_length', parent).html(sms.length)
    $('.sms_preview').html(sms)
  
  $('#add_question_link').live 'click', ->
    $('.inlineform').hide()
    $('#new_question_form').closest('.inlineform').show()
    $('#question_form').slideDown()
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
    if $(this).val()
      $(this).closest('.inlineform').find('.right_col').hide()
    else
      $(this).closest('.inlineform').find('.right_col').show()    
      
  $('.question_form').submit ->
    $('#question_form').slideUp 2000
  .bind 'ajax:complete', ->
    $('.question_form')[0].reset()
    $('#question_type').change()
