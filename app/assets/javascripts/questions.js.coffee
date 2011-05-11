$ ->
	$('.use_question, .remove_question').live 'click', ->
		$(this).closest('tr').fadeOut()
		false
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
