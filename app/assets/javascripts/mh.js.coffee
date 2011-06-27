$ ->
	$('#change_org').live 'click', ->
		$('#other_orgs').toggle()
		false
		
	$('[data-method=delete]').live 'ajax:before', ->
		$(this).parent().fadeOut()
	
	$('#check_all').live 'click', ->
		$('input[type=checkbox]', $(this).closest('form')).prop('checked', $(this).prop('checked'))
		
	$('.drag').live 'click', -> 
		false
	
	sortable_options = 
		axis:'y'
		dropOnEmpty:false
		update: (event, ui) -> 
			sortable = this
			$.ajax({
				data:$(this).sortable('serialize',{key:sortable.id + '[]'})
				complete: (request) ->
					$(sortable).effect('highlight')
				success: (request) -> 
					$('#errors').html(request)
				type:'POST', 
				url: $(sortable).attr('data-sortable-url')
			})
	
	$('[data-sortable]').sortable(sortable_options)
	
	$('[data-sortable][data-sortable-handle]').each ->
		handle = $(this).attr('data-sortable-handle');
		$(this).sortable("option", "handle", handle);
		
