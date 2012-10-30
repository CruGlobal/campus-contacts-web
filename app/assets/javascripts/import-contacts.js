var __NEW_QUESTION__ = "Create new question";

$(document).ready(function() {
	// Data arrays created in script in views/imports/edit.html.erb
	// - surveyTitles:	Contains the titles of each survey
	// - surveyLengths:	Contains length of each survey
	// - mhubQuestions:	Contains the questions of all MissionHub surveys
	// - userQuestions: Contains the questions of the imported data
	// - surveyData:	Contains the survey titles and questions
	// - surveys:		Collects survey questions
	
	var i = '';
	var ii = '';
	var matchFound = '';
	var htmlResults = '';
	var matchQuestions = new Array();
	var dataToBackend = new Object();
	
	
// 	var newfunction = function (userData, mhubData, surveys, lengths, matches) {
// 		var question = new Object();
// 		var Questions = new Object();
// 		var survey = new Object();
// 		var Surveys = new Object();
// 		
// 		
// 	}
	
	
	
	
	for (i = 0; i < userQuestions.length; i++) {
		var matchFound = false;
		
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
	
	dataToBackend = constructObject(userQuestions, mhubQuestions, surveyTitles, surveyLengths, matchQuestions);
	
	refreshData(matchQuestions, surveyData);
	
	$(".surveyContainer").html(generateHtml(surveyData));
  
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
		var selectedItem = '';
		var previousItem = '';
		var newMatches = new Array();
		
		selectedItem = $(this).text();
		previousItem = $(this).parents(".matchSelect").find(".selectTitle").text();
		$(this).parents(".matchSelect").find(".selectTitle").text(selectedItem);
		$('.selectTitle').each(function(i) {
			newMatches.push($(this).text());
		});
		refreshData(newMatches, originalData);
		$(".surveyContainer").html(generateHtml(originalData));
		
		$(".selectQuestions").hide();
	});
  
	$("html").click(function(e) {
		if (!$(e.target).is(".selectTitleBg, .selectTitle")) {
			$(".selectQuestions").hide();
		}
	});
	
	$('.newQuestion').live('click', function(e) {
		e.preventDefault();
		
		resetForm('#new_question_form');
		
		var questionId = $(this).parents('.matchSelect').attr('id').split('_')[1];
		
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
		
		resetForm('#new_question_form');
		
		var questionId = $(this).attr('id').split('_')[1];
		
		$('#new_question_div').dialog({
			resizable: false,
			height: 444,
			width: 600,
			modal: true,
			buttons: [
			{
				text: 'Done',
				click: function() {
					if ($('#create_new').attr('checked')) {
						var new_survey_name = $('#survey_name').val();
						surveyTitles.push(new_survey_name);
						surveyLengths[surveyTitles.length - 1] = 1;
						console.log(surveyLengths);
					}
					else {
						var old_survey_name = $('#select_survey').find(':selected').text();
						var index = surveyTitles.indexOf(old_survey_name);
					}
					var question_type = $('#question_type').find(':selected').val();
					if (question_type !== '') {
						if (question_type === 'text_field_short') {
							var short_answer_question = $('#short_answer_question').val();
							$('#select_' + questionId).find('.selectTitle').text(short_answer_question);
						}
						else {
							var multiple_choice_question = $('#multiple_choice_question').val();
							var multiple_choice_options = $('#multiple_choice_options').val();
							$('#select_' + questionId).find('.selectTitle').text(multiple_choice_question);
						}
					}
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
	
	// ----- Create new question form scripts ----- //
	$('#short_answer_question').simplyCountable({
		counter:		'#short_counter',
		countDirection:	'up'
	});
	$('#multiple_choice_question').simplyCountable({
		counter:		'#choice_counter',
		countDirection:	'up'
	});
	$('#create_new').click(function() {
		if ($('#create_new').attr('checked')) {
			$('#survey_new').show();
			$('#survey_old').hide();
		}
		else {
			var i = '';
			var survey_options = '<option value=""></option>';
			for (i = 0; i < surveyTitles.length; i++) {
				var survey_options = survey_options + '<option value="survey_' + i + '">' + surveyTitles[i] + '</option>';
			}
			$('#survey_old').show();
			$('#survey_old select').html(survey_options);
			$('#survey_new').hide();
		}
	});
	$('#question_type').change(function() {
		var questionType = $(this).val();
		if (questionType === "text_field_short") {
			$('#question_short_answer').show();
			$('#preview_short').show();
			$('#question_multiple_choice').hide();
			$('#preview_multiple').hide();
		}
		else {
			$('#question_multiple_choice').show();
			$('#preview_multiple').show();
			$('#question_short_answer').hide();
			$('#preview_short').hide();
		}
	});
	$('#short_answer_question').keyup(function() {
		$('#short_answer_preview').text($(this).val());
	});
	$('#multiple_choice_question').keyup(function() {
		$('#multiple_choice_preview').text($(this).val());
	});
});

constructArray = function(string) {
	var i = '';
	var results = new Array();
	
	string = string.toLowerCase();
	string = string.replace(/[^a-zA-Z0-9 ]+/g, "").replace("/ {2,}/", " ");
	string = string.split(" ");
	
	for (i = 0; i < string.length; i++) {
		results = results.concat(string[i].split("_"));
	}
	
	return results;
};

var compare = function(userString, mhubString, matchQuestions) {
	var i = '';
	var ii = '';
	var firstMatch = '';
	var secondMatch = '';
	var mhubCheck = '';
	var matchCheck = '';
	var userArray = new Array();
	var mhubArray = new Array();
	var matchArray = new Array();
	
	userArray = constructArray(userString);
	mhubArray = constructArray(mhubString);
	matchArray = _.intersection(userArray, mhubArray);
	firstMatch = matchArray.length / mhubArray.length;
	
	if (firstMatch >= 0.75) {
		return true;
	}
	else {
		for (i = 0; i < userArray.length; i++) {
			secondMatch = false;
    		for (ii = 0; ii < mhubArray.length; ii++) {
    			mhubCheck = mhubArray[ii].indexOf(userArray[i]);
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

var refreshData = function(matches, surveys) {
	var i = '';
	var ii = '';
	var iii = '';
	var itemLocation = '';
	
	for (i = 0; i < matches.length; i++) {
		if (matches[i] !== __NEW_QUESTION__) {
			for (ii = 0; ii < surveys.length; ii++) {
				if (surveys[ii] instanceof Array === true) {
					for (iii = 0; iii < surveys[ii].length; iii++) {
						index = surveys[ii][iii].indexOf(matches[i]);
						if (index !== -1) {
							itemLocation = surveys[ii].indexOf(matches[i]);
							surveys[ii].splice(itemLocation,1);
							break;
						}
					}
				}
			}
		}
	}
}

var generateHtml = function (data) {
	var i = '';
	var ii = '';
	var htmlResults = '';
	
	for (i = 0; i < data.length; i++) {
		if (data[i] instanceof Array === false) {
			htmlResults = htmlResults + '<ul class="surveyQuestions"><span class="surveyHeader">' + data[i] + '</span>';
		}
		else {
			for (ii = 0; ii < data[i].length; ii++) {
				htmlResults = htmlResults + '<li class="surveyItem">' + data[i][ii] + '</li>';
			}
		}
		if (data[i] instanceof Array === true) {
			htmlResults = htmlResults + '</ul>';
		}
	}
	return htmlResults;
}

var origData = function (titles, lengths, questions) {
	var i = '';
	var ii = '';
	var questionPosition = 0;
	var data = new Array();
	var holder = new Array();
	
	for (i = 0; i < titles.length; i++) {
		data.push(titles[i]);
		for (ii = 0; ii < lengths[i]; ii++) {
			holder.push(questions[ii + questionPosition]);
		}
		data.push(holder);
		questionPosition += holder.length;
		holder = [];
	}
	return data;
}

var resetForm = function (formId) {
	$(formId).find('#create_new').attr('checked','checked');
	$(formId).find('#survey_new').show();
	$(formId).find('#survey_old').hide();
	$(formId).find('#question_short_answer').hide();
	$(formId).find('#question_multiple_choice').hide();
	$(formId).find('input:text, select, textarea').val('');
}

var constructObject = function (userData, mhubData, surveys, lengths, matches) {
	var i = '';
	var ii = '';
	var ii = '';
	var index = '';
	var holder = new Object();
	var surveyData = new Array();
	var questions = new Object();
	var results = new Object();

	console.log(matches);

	var question = new Object();
	var questionGroup = new Object();
	var survey = new Object();
	var surveyGroup = new Object();
	
	surveyData = origData(surveys, lengths, mhubData);
	
	for (var x = 0; x < surveyData.length; x++) {
		survey = {};
		if (surveyData[x] instanceof Array === false) {
			survey.title = surveyData[x];
			questionGroup = {};
			for (var xx = 0; xx < surveyData[x + 1].length; xx++) {
				question = {};
				var currentQuestion = surveyData[x + 1][xx];
				question.text = currentQuestion;
				for (var xxx = 0; xxx < matches.length; xxx++) {
					var matchCheck = currentQuestion.indexOf(matches[xxx]);
					if (matchCheck !== -1) {
						question.action = "MATCH";
						question.match = userData[xxx];
						break;
					}
				}
				if (!question.action) {
					question.action = "NEW";
				}
				questionGroup[xx] = question;
			}
			survey.questions = questionGroup;
			if (x === 0) {
				surveyGroup[x] = survey;
			}
			else {
				surveyGroup[x - 1] = survey;
			}
		}
	}
	
	console.log(surveyGroup);
	
	
	
	
	
// 	console.log(userData);
// 	console.log(mhubData);
// 	console.log(surveys);
// 	console.log(lengths);
// 	console.log(matches);
// 	console.log(surveyData);
	
	for (i = 0; i < userData.length; i++) {
		holder = {};
		holder.userquestion = userData[i];
		if (matches[i] !== __NEW_QUESTION__) {
			holder.mhubquestion = matches[i];
		}
		else {
			holder.action = "NEW";
		}
		for (ii = 0; ii < surveyData.length; ii++) {
			if (surveyData[ii] instanceof Array === true) {
				for (iii = 0; iii < surveyData[ii].length; iii++) {
					index = surveyData[ii][iii].indexOf(matches[i]);
					if (index !== -1) {
						holder.action = "MATCH";
						holder.survey = surveyData[ii - 1];
						break;
					}
				}
				if (holder.action === "Match") {
					break;
				}
			}
		}
		results[i] = holder;
	}
	
	//console.log(results);
	
	return results;
}

















































