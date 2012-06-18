clientSideValidations.callbacks.element.fail = function(element, message, callback) {
	if(element.parent().hasClass('field')){
		parent = element.parent();
	}else if(element.parent().parent().hasClass('field')){
		parent = element.parent().parent();
	}
	
	element_id = element.attr('id');
	message = message[0].toUpperCase() + message.substr(1).toLowerCase();
	
	message_span = "<span class='message_msg'>"+message+"</span>"
	message_box = "<div class='error_space' id='error_"+element_id+"'>"+message_span+"</div>"
	
	element.css('border','1px solid #C00');
	parent.html(element);
	
	if(parent.children('.error_space').size() > 0){
		parent.children('.message_msg').html(message);
	}else{
		element.parent().append(message_box);
	}
}

clientSideValidations.callbacks.element.pass = function(element, callback) {
	parent = element.parent();
	element.css('border','');
	parent.html(element);
}