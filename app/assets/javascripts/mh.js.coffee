$ ->
	$('#change_org').live 'click', ->
		$('#other_orgs').toggle()
		$('#change_org').toggleClass("on")
		$('#show_survey_keywords_menu').hide()
		$('#survey_keywords_mode_link').removeClass("on")
		false
		
	$('#survey_keywords_mode_link').live 'click', ->
		$('#show_survey_keywords_menu').toggle()
		$('#survey_keywords_mode_link').toggleClass("on")
		x = $('#change_org').width() + 85
		$("#show_survey_keywords_menu").css('right', x)
		
		$('#other_orgs').hide()
		$('#change_org').removeClass("on")
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
	
	$('.tipthis[title]').qtip()
	
	$('[data-sortable][data-sortable-handle]').each ->
		handle = $(this).attr('data-sortable-handle');
		$(this).sortable("option", "handle", handle);
		
