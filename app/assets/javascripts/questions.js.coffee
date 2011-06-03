$ ->
	$('.use_question, .remove_question').live 'click', ->
		$(this).closest('tr').fadeOut()
		$(this).closest('tr').remove()
		false
	
	$('#question_type').change ->
		switch $(this).val()
			when ''
				$('#multiple_choice_form').hide()
				$('#short_answer_form').hide()
			when 'TextField:short'
				$('#multiple_choice_form').hide()
				$('#short_answer_form').show()
			else
				$('#short_answer_form').show()
				$('#multiple_choice_form').show()
	
	$('#question_form_form').submit ->
		$('#question_form').slideUp 2000
	.bind 'ajax:complete', ->
		$('#question_form_form')[0].reset()
		$('#question_type').change()
