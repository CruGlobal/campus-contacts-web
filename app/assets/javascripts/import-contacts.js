var __NEW_QUESTION__ = "Create new question";

$(document).ready(function() {
	// Data arrays created in script in views/imports/edit.html.erb
	// surveyTitles - Contains the titles of each survey
	// surveyLengths - Contains length of each survey
	// mhubQuestions - Contains the questions of all MissionHub surveys
	// userQuestions - Contains the questions of the imported data
	// surveyData - Contains the survey titles and questions
	// surveys - Collects survey questions
	
	var matchFound = '';
	
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
			matchQuestions.push(__NEW_QUESTION__);
		}
	}
	
//	console.log(matchQuestions);
	
	refreshData(matchQuestions, surveyData);
	
	htmlResults = generateHtml(surveyData);
	
	$(".surveyContainer").html(htmlResults);
  
	$(".selectTitle").each(function(index) {
		$(this).text(matchQuestions[index]);
		if ($(this).text() === __NEW_QUESTION__) {
			$(this).parents(".matchSelect").siblings(".matchEdit").css("display", "block");
		}
	});
  
	$(".selectTitleBg").live("click", function(e) {
		e.preventDefault();
		
		$(this).siblings(".selectQuestions").toggle().scrollTop(0);
	});
	
	$(".surveyItem, .noMatch").live("click", function(e) {
		e.preventDefault();
		
		var originalData = origData(surveyTitles, surveyLengths, mhubQuestions);
		console.log(originalData);
		var selectedItem = '';
		var previousItem = '';
		var htmlResults = '';
		newMatches = new Array();
		
		selectedItem = $(this).text();
		previousItem = $(this).parents(".matchSelect").find(".selectTitle").text();
		$(this).parents(".matchSelect").find(".selectTitle").text(selectedItem);
		$('.selectTitle').each(function(i) {
			newMatches.push($(this).text());
		});
		console.log(newMatches);
		refreshData(newMatches, originalData);
		htmlResults = generateHtml(originalData);
		$(".surveyContainer").html(htmlResults);
		
		$(".selectQuestions").hide();
	});
  
	$("html").click(function(e) {
		if (!$(e.target).is(".selectTitleBg, .selectTitle")) {
			$(".selectQuestions").hide();
		}
	});
	
	$('.newQuestion').live('click', function(e) {
		e.preventDefault();
		
		var clickedElement = '';
		
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

constructArray = function(string) {
	results = new Array();
	
	string = string.toLowerCase();
	string = string.replace(/[^a-zA-Z0-9 ]+/g, "").replace("/ {2,}/", " ");
	string = string.split(" ");
	
	for (a = 0; a < string.length; a++) {
		results = results.concat(string[a].split("_"));
	}
	
	return results;
};

compare = function(userString, mhubString, matchQuestions) {
	var firstMatch = '';
	var secondMatch = '';
	var mhubCheck = '';
	var matchCheck = '';
	
	matchArray = new Array();
	
	userArray = constructArray(userString);
	mhubArray = constructArray(mhubString);
	matchArray = _.intersection(userArray, mhubArray);
	firstMatch = matchArray.length / mhubArray.length;
	
	if (firstMatch >= 0.75) {
		return true;
	}
	else {
		for (b = 0; b < userArray.length; b++) {
			secondMatch = false;
    		for (bb = 0; bb < mhubArray.length; bb++) {
    			mhubCheck = mhubArray[bb].indexOf(userArray[b]);
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

refreshData = function(matchOrig, surveyOrig) {
	for (c = 0; c < matchOrig.length; c++) {
		if (matchOrig[c] !== "Create new question") {
			for (cc = 0; cc < surveyOrig.length; cc++) {
				if (surveyOrig[cc] instanceof Array === true) {
					for (ccc = 0; ccc < surveyOrig[cc].length; ccc++) {
						index = surveyOrig[cc][ccc].indexOf(matchOrig[c]);
						if (index !== -1) {
							itemLocation = surveyOrig[cc].indexOf(matchOrig[c]);
							surveyOrig[cc].splice(itemLocation,1);
							break;
						}
					}
				}
			}
		}
	}
}

generateHtml = function (data) {
	var htmlResults = '';
	for (d = 0; d < data.length; d++) {
		if (data[d] instanceof Array === false) {
			htmlResults = htmlResults + '<ul class="surveyQuestions"><span class="surveyHeader">' + data[d] + '</span>';
		}
		else {
			for (dd = 0; dd < data[d].length; dd++) {
				htmlResults = htmlResults + '<li class="surveyItem">' + data[d][dd] + '</li>';
			}
		}
		if (data[d] instanceof Array === true) {
			htmlResults = htmlResults + '</ul>';
		}
	}
	return htmlResults;
}

origData = function (titles, lengths, questions) {
	data = new Array();
	holder = new Array();
	questionPosition = 0;
	for (e = 0; e < titles.length; e++) {
		data.push(titles[e]);
		for (ee = 0; ee < lengths[e]; ee++) {
			holder.push(questions[ee + questionPosition]);
		}
		data.push(holder);
		questionPosition += holder.length;
		holder = [];
	}
	return data;
}