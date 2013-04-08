$('.rule_form .title').live('click', function(){
  $(this).parents('.rule_form').children('.settings').slideToggle();
});

$('#add_suvey_question_link').live('click', function(){
  $('#question_form').hide();
  $('#saving').hide();
  $('#loading').slideDown();
});
$('.edit_question_show_loading').live('click',function(){
  $('#create_question_form').hide();
  $('#question_form').hide();
  $('#saving').hide();
  $('#loading').slideDown();
});

$('#cancel_edit_survey_question').live('click',function(){
  $('#create_question_form').slideUp();
  $('#question_form').slideUp();
  $('#loading').hide();
  $('#saving').hide();
});

$('#save_edit_survey_question').live('click',function(){
  $('#create_question_form').hide();
  $('#question_form').hide();
  $('#loading').hide();
  $('#saving').slideDown();
});

$(".assign_to_radio").live('click',function(){
  $("#autoassign_suggestion").find("label").html("Search " + $(this).val() + ": ");
	$("#autoassign_suggestion").attr("data-type",$(this).val());
});

$('.assign_to_radio').live('change',function(){
	$("#autoassign_selected_id").val("");
	$('#autoassign_autosuggest').tokenInput("clear");
});

function autoassign_search(id, name){
	id = typeof id !== 'undefined' ? id : "";
	name = typeof name !== 'undefined' ? name : "";
  
	$('#autoassign_autosuggest').off();
	if(id != "" && name != ""){
		$('#autoassign_autosuggest').tokenInput(function() {
			return autoassign_search_url();
		}, {
			theme: 'facebook',
			preventDuplicates: true,
			minChars: 1,
			resultsLimit: 10,
			tokenLimit: 1,
			animateDropdown: false,
			defaultWidth: 420,
			propertyToSearch: "label",
      tokenValue: "label",
	    onAdd: function (item) {
				$("#autoassign_selected_id").val(item.id);
	    },
	    onDelete: function (item) {
				$("#autoassign_selected_id").val("");
	    },
			prePopulate: [
        {id: id, label: name}
      ]
		});
	}else{
		$('#autoassign_autosuggest').tokenInput(function() {
			return autoassign_search_url();
		}, {
			theme: 'facebook',
			preventDuplicates: true,
			minChars: 1,
			resultsLimit: 10,
			tokenLimit: 1,
			animateDropdown: false,
			defaultWidth: 420,
			propertyToSearch: "label" ,
      tokenValue: "label",
	    onAdd: function (item) {
				$("#autoassign_selected_id").val(item.id);
	    },
	    onDelete: function (item) {
				$("#autoassign_selected_id").val("");
	    }
		});
	}
}

function autoassign_search_url(){
	return "/autoassign_suggest.json?q&survey_id="+$("#autoassign_autosuggest").attr("data-survey-id")+"&type="+$(".assign_to_radio:checked").val();
}