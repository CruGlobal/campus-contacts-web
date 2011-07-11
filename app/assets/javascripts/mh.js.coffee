$ ->
	$('#change_org').live 'click', ->
		$('#other_orgs').toggle()
		$('#change_org').toggleClass("on")
		false
		
	$('[data-method=delete]').live 'ajax:before', ->
		$(this).parent().fadeOut()
	
	$('#check_all').live 'click', ->
		if $(this).attr('data-target')
			form = $($(this).attr('data-target'))
		else
			form = $(this).closest('form')
		$('input[type=checkbox]', form).prop('checked', $(this).prop('checked'))
		
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
	
	$('.tipthis[title]').qtip()
	
	$('[data-sortable][data-sortable-handle]').each ->
		handle = $(this).attr('data-sortable-handle');
		$(this).sortable("option", "handle", handle);
		
