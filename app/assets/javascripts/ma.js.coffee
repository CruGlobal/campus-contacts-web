$ ->
	$('[data-method=delete]').live 'ajax:before', ->
		$(this).parent().fadeOut()
		
