$ ->
  $('#survey_background_color, #survey_text_color').excolor({root_path: '/assets/'})
  false
  
  $('#show_advanced_survey_option').live 'click', ()->
  	$('#advanced_survey_option').toggle()
  	if($('#advanced_survey_option').is(":visible"))
  		$(this).html($(this).html().replace("Show","Hide"))
  	else
  		$(this).html($(this).html().replace("Hide","Show")) 	
  	end
