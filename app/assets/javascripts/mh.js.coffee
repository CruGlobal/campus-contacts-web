$ ->
	$('.expandable').each (i)->
		e = $(this)
		if e.height() > e.attr("data-height")
			e.next('.moredown').show();
			e.attr("data-original-height", e.height())
			e.css({height: e.attr("data-height") + 'px', overflow: 'hidden'})
			
	$('a.moredown').click ->
		target = $($(this).attr('href'))
		target.toggleClass('showall')
		if target.hasClass('showall')
			target.attr('data-height', target.height())
			target.animate({height: target.attr("data-original-height")})
			$('span', this).html('<strong>+</strong> Show Less Leaders')
		else
			target.animate({height: target.attr("data-height")})
			$('span', this).html('<strong>+</strong> Show More Leaders')
		false
			
	$('#change_org').live 'click', ->
	  # hide other menu
		$('#show_survey_keywords_menu').hide()
		$('#survey_keywords_mode_link').removeClass("on")
		
		$('#other_orgs').toggle()
		$('#change_org').toggleClass("on")
		false
		
	$('#survey_keywords_mode_link').live 'click', ->
	  # hide other menu
	  $('#other_orgs').hide()
	  $('#change_org').removeClass("on")
	  
	  $('#show_survey_keywords_menu').toggle()
	  $('#survey_keywords_mode_link').toggleClass("on")
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
		
