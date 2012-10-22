constructArray = function(string) {
	var string
	
	results = new Array();
	
	string = string.toLowerCase();
	string = string.replace(/[^a-zA-Z0-9 ]+/g, "").replace("/ {2,}/", " ");
	string = string.split(" ");
	
	for (x = 0; x < string.length; x++) {
		results = results.concat(string[x].split("_"));
	}
	
	return results;
};

compare = function(userString, mhubString, matchQuestions) {
	var firstMatch;
	var secondMatch;
	var mhubCheck;
	var matchCheck;
	
	matchArray = new Array();
	
	userArray = constructArray(userString);
	mhubArray = constructArray(mhubString);
	matchArray = _.intersection(userArray, mhubArray);
	firstMatch = matchArray.length / mhubArray.length;
	
	if (firstMatch >= 0.75) {
		return true;
	}
	else {
		for (y = 0; y < userArray.length; y++) {
			secondMatch = false;
    		for (z = 0; z < mhubArray.length; z++) {
    			mhubCheck = mhubArray[z].indexOf(userArray[y]);
	    		matchCheck = matchQuestions.indexOf(mhubString);
    			if (mhubCheck !== -1 && matchCheck === -1) {
        			secondMatch = true;
        			break;
        		}
    		}
		}
		return secondMatch;
	}
};

$(document).ready(function() {
	// surveyTitles, mhubQuestions, userQuestions arrays created in views/imports/edit.html.erb
	console.log(surveyTitles);
	console.log(mhubQuestions);
	console.log(userQuestions);
	
	var matchFound;
	
	matchQuestions = new Array();
	
	for (i = 0; i < userQuestions.length; i++) {
		matchFound = false;
		
		for (ii = 0; ii < mhubQuestions.length; ii++) {
			if (compare(userQuestions[i], mhubQuestions[ii], matchQuestions) === true) {
				matchFound = true;
				break;
			}
		}
		if (matchFound === true) {
			matchQuestions.push(mhubQuestions[ii]);
		}
		else {
			matchQuestions.push("Create new question");
		}
	}
  
	$(".selectTitle").each(function(index) {
		$(this).text(matchQuestions[index]);
		if ($(this).text() === "Create new question") {
			$(this).parents(".matchSelect").siblings(".matchEdit").css("display", "block");
		}
	});
  
	$(".selectTitleBg").live("click", function(e) {
		e.preventDefault();
		$(this).siblings(".selectQuestions").toggle().scrollTop(0);
	});
	
	$(".surveyItem, .noMatch").live("click", function(e) {
		var selectedItem;
		
		e.preventDefault();
		selectedItem = $(this).text();
		$(this).parents(".matchSelect").find(".selectTitle").text(selectedItem);
		$(".selectQuestions").hide();
	});
  
	$("html").click(function(e) {
		if (!$(e.target).is(".selectTitleBg, .selectTitle")) {
			$(".selectQuestions").hide();
		}
	});
	
	$('.newQuestion').live('click', function(e) {
		var clickedElement;
		e.preventDefault();
		clickedElement = $(this).parents(".matchSelect").attr("id");
		$('#new_question_div').dialog({
			resizable: false,
			height: 444,
			width: 600,
			modal: true,
			buttons: [
			{
				text: 'Done',
				click: function() {
					$("#" + clickedElement).siblings(".matchEdit").css("display", "block");
					$(this).dialog('destroy');
				}
			}, {
				text: 'Cancel',
				click: function() {
					$(this).dialog('destroy');
				}
			}
			]
		});
		false;
	});
	
	$('.editMatch').live('click', function(e) {
		e.preventDefault();
		$('#new_question_div').dialog({
			resizable: false,
			height: 444,
			width: 600,
			modal: true,
			buttons: [
			{
				text: 'Done',
				click: function() {
					$(this).dialog('destroy');
				}
			}, {
				text: 'Cancel',
				click: function() {
					$(this).dialog('destroy');
				}
			}
			]
		});
		false;
	});
});