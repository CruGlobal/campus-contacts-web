$('.rule_form .title').live('click', function(){
  $(this).parents('.rule_form').children('.settings').slideToggle();
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
$('.assign_to_radio').live('click',function(){
  type = $(this).val();
  $(this).parent().siblings('#autoassign_suggestion').children().find('label').html("Search " + type + ": ");
  $(this).parent().siblings('#autoassign_suggestion').attr('data-type', type);
});
 
$('.assign_to_radio').live('change',function(){
  $("#autoassign_selected_id, #autoassign_autosuggest").val("");
});

$(document).ready(function() {
	ele = $('#autoassign_autosuggest');
	keyword = ele.val();
	type = ele.parent().parent().parent().children().find('input[name=assign_contact_to]:checked').val();
	survey_id = ele.attr('data-survey-id');
	ele.autocomplete({
		source: "/autoassign_suggest?survey_id="+survey_id+"&type="+type+"&keyword="+keyword,
		select: function(event, ui){
		  $('#autoassign_selected_id').val(ui.item.id);
		}
	});
	ele.live('keyup', function(){
		keyword = ele.val();
		type = ele.parent().parent().parent().children().find('input[name=assign_contact_to]:checked').val();
		survey_id = ele.attr('data-survey-id');
		ele.autocomplete({
			source: "/autoassign_suggest?survey_id="+survey_id+"&type="+type+"&keyword="+keyword,
			select: function(event, ui){
			  $('#autoassign_selected_id').val(ui.item.id);
			}
		});
	});
});