$(document).ready(function() {

	$(".selectTitle").live("click", function(e) {
		e.preventDefault();
		$(this).siblings(".selectQuestions").toggle();
	});
	
	$("li").live("click", function(e) {
		e.preventDefault();
		var selectedItem = $(this).text();
		$(this).parents(".matchSelect").find(".selectTitle").text(selectedItem);
		$(".selectQuestions").hide();
	});
	
	$("html").click(function(e) {
 		if (! $(e.target).hasClass("selectTitle")) {
	 		$(".selectQuestions").hide();
	 	}
	});
	
	/*
	$("a").live("click", function(e) {
		e.preventDefault();
		alert("Create new question");
	});
	*/

});