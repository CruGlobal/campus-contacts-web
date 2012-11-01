var __NEW_QUESTION__ = "Create new question";
var __NO_IMPORT__ = "Do not import data";

$(document).ready(function() {
	// Data arrays created in script in views/imports/edit.html.erb
	// - surveyTitles:	Contains the titles of each survey
	// - surveyLengths:	Contains length of each survey
	// - mhubQuestions:	Contains the questions of all MissionHub surveys
	// - userQuestions: Contains the questions of the imported data
	// - surveyData:	Contains the survey titles and questions
	// - surveys:		Collects survey questions
	
	// Initialize variables
	var htmlResults = '';
	var matchQuestions = new Array();
	var dataCollection = new Object();
	
	// Perform comparison of User & MHub data & generate array of matches
	// Functions: compare(userString, mhubString, matchQuestions)
	for (var i = 0; i < userQuestions.length; i++) {
		var matchFound = false;
		for (var ii = 0; ii < mhubQuestions.length; ii++) {
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
	
	// Construct object with all data
	dataCollection = constructObject(userQuestions, mhubQuestions, surveyTitles, surveyLengths, matchQuestions);
	
	foobar = dataCollection;
	// console.log(dataCollection);
	
	// Generate HTML list & matches
	regenerate(dataCollection, '');
	

	
	// When select box is clicked options are set to show
	$(".selectTitleBg").live("click", function(e) {
		e.preventDefault();
		
		$(this).siblings(".selectQuestions").toggle().scrollTop(0);
	});
	
	// --------------------------------------------------	
	
	refreshData(matchQuestions, surveyData);
	
	// $(".surveyContainer").html(generateHtml(surveyData));
	
	$(".surveyItem, .noMatch").live("click", function(e) {
		e.preventDefault();
		
		var oldItem = $(this).parents(".matchSelect").find(".selectTitle");
		var oldText = oldItem.text();
		var oldInfo = oldItem.attr("id").split("_");
		var oldSurvey = oldInfo[1];
		var oldQuestion = oldInfo[3];
		
		dataCollection[oldSurvey]["questions"][oldQuestion].action = "NONE";
		dataCollection[oldSurvey]["questions"][oldQuestion].match = "NONE";
		
		var newItem = $(this);
		var newText = newItem.text();
		if (newText !== __NO_IMPORT__) {
			var newInfo = newItem.attr("id").split("_");
			var newSurvey = newInfo[1];
			var newQuestion = newInfo[3];
			var newMatch = $(this).parents('.matchSelect').attr('id').split('_')[1];
			
			dataCollection[newSurvey]["questions"][newQuestion].action = "MATCH";
			dataCollection[newSurvey]["questions"][newQuestion].match = userQuestions[newMatch];
		}
		
		// Generate HTML list & matches
		regenerate(dataCollection, newText);
		
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
						// console.log(surveyLengths);
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

// Function:	compare
// Definition:	Compares userString & mhubString & generates array of matches
// Uses:		constructArray
var compare = function(userString, mhubString, matchQuestions) {
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
		for (var i = 0; i < userArray.length; i++) {
			secondMatch = false;
    		for (var ii = 0; ii < mhubArray.length; ii++) {
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

// Function:	constructArray
// Definition:	Builds array from string input
constructArray = function(string) {
	var results = new Array();
	
	string = string.toLowerCase();
	string = string.replace(/[^a-zA-Z0-9 ]+/g, "").replace("/ {2,}/", " ");
	string = string.split(" ");
	
	for (var i = 0; i < string.length; i++) {
		results = results.concat(string[i].split("_"));
	}
	
	return results;
};

// Function:	generateList
// Definition:	Builds html string for select list
var generateList = function(data) {
	var htmlResults = '';
	
	for (var key in data) {
		var obj1 = data[key];
		for (var prop1 in obj1) {
			if (prop1 === 'title') {
				htmlResults = htmlResults + '<ul class="surveyQuestions"><span class="surveyHeader">' + obj1[prop1] + '</span>';
			}
			else if (prop1 === 'questions') {
				var obj2 = obj1[prop1];
				for (var prop2 in obj2) {
					var obj3 = obj2[prop2];
					for (var prop3 in obj3) {
						if (prop3 === 'action') {
							if (obj3[prop3] === 'NONE') {
								htmlResults = htmlResults + '<li class="surveyItem" id="survey_' + key + '_question_' + prop2 + '">' + obj3['text'] + '</li>';
							}
						}
					}
				}
				htmlResults = htmlResults + '</ul>';
			}
		}
	}
	return htmlResults;
}

// Function:	findItem
// Definition:	Locates info about item in object
var findItem = function(data, item, type, output) {
	var itemResults = new Array();
	
	for (var key in data) {
		var obj1 = data[key];
		for (var prop1 in obj1) {
			if (prop1 === "questions") {
				var obj2 = obj1[prop1];
				for (var prop2 in obj2) {
					var obj3 = obj2[prop2];
					for (var prop3 in obj3) {
						if (prop3 === type) {
							if (obj3[prop3] === item) {
								itemResults = [key, prop2, obj3[output]];
							}
						}
					}
				}
			}
		}
	}
	return itemResults;
}

// Function:	regenerate
// Definition:	Regenerate HTML & update matches

var regenerate = function (data, checkImport) {
	// Generate HTML list
	$(".surveyContainer").html(generateList(data));
	
	// Set the text & id of the matched elements
	$(".selectTitle").each(function(index) {
		var question = userQuestions[index];
		var questionInfo = findItem(data, question, "match", "text");
		
		if (questionInfo[2]) {
			$(this).text(questionInfo[2]);
			$(this).attr("id", "survey_" + questionInfo[0] + "_question_" + questionInfo[1]);
		}
		else if (checkImport === __NO_IMPORT__) {
			$(this).text(__NO_IMPORT__);
		}
		else {
			$(this).text(__NEW_QUESTION__);
			$(this).parents(".matchSelect").siblings(".matchEdit").css("display", "block");
		}
	});
}

var generateHtml = function (data) {
	var htmlResults = '';
	
	for (var i = 0; i < data.length; i++) {
		if (data[i] instanceof Array === false) {
			htmlResults = htmlResults + '<ul class="surveyQuestions"><span class="surveyHeader">' + data[i] + '</span>';
		}
		else {
			for (var ii = 0; ii < data[i].length; ii++) {
				htmlResults = htmlResults + '<li class="surveyItem">' + data[i][ii] + '</li>';
			}
		}
		if (data[i] instanceof Array === true) {
			htmlResults = htmlResults + '</ul>';
		}
	}
	return htmlResults;
}

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

	// console.log(matches);

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
					question.action = "NONE";
					question.match = "NONE";
				}
				questionGroup[xx] = question;
			}
			survey.questions = questionGroup;
			if (x === 0) {
				surveyGroup[x] = survey;
			}
			else {
				surveyGroup[(x/2)] = survey;
			}
		}
	}
	
	
	
	
	
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
	
	return surveyGroup;
}