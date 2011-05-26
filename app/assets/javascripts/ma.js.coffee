$ ->
	$('[data-method=delete]').live 'ajax:before', ->
		$(this).parent().fadeOut()
	
	$('#check_all').live 'click', ->
		$('input[type=checkbox]', $(this).closest('form')).prop('checked', $(this).prop('checked'))
		
