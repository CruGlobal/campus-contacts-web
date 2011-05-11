$ ->
	$('.use_question').live 'click', ->
		$(this).closest('tr').fadeOut()
		false
