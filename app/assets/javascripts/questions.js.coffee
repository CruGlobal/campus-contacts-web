$ ->
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
	      $('.multiple_choice_form', form).hide()
	      $('.short_answer_form', form).hide()
	      $('.submit_button', form).hide()
	    when 'TextField:short'
	      $('.multiple_choice_form', form).hide()
	      $('.short_answer_form', form).show()
	      $('.submit_button', form).show()
	    else
	      $('.short_answer_form', form).show()
	      $('.multiple_choice_form', form).show()
	      $('.submit_button', form).show()
    false
    
  $('.question_form').submit ->
    $('#question_form').slideUp 2000
  .bind 'ajax:complete', ->
    $('.question_form')[0].reset()
    $('#question_type').change()
