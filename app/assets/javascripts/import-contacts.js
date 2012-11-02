var __NEW_QUESTION__ = 'Create new question';
var __NO_IMPORT__ = 'Do not import data';

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
	
	// Construct mhub & user objects with all data
	mhubCollection = constructMhubObject(userQuestions, mhubQuestions, surveyTitles, surveyLengths, matchQuestions);
	userCollection = constructUserObject(userQuestions, mhubCollection, matchQuestions);
	
	// Generate HTML matches & list
	generateMatches(userCollection);
	generateList(mhubCollection);
	
	// When select box is clicked options are set to show at top position
	$('.selectTitleBg').live('click', function(e) {
		e.preventDefault();
		
		$(this).siblings('.selectQuestions').toggle().scrollTop(0);
	});
	
	// Hides all select data when anywhere else is clicked
	$('html').click(function(e) {
		if (!$(e.target).is('.selectTitleBg, .selectTitle')) {
			$('.selectQuestions').hide();
		}
	});

	$('.surveyItem').live('click', function(e) {
		e.preventDefault();
		
		var oldItem = '';
		var oldText = '';
		var oldInfo = '';
		var oldSurvey = '';
		var oldQuestion = '';
		
		var newItem = '';
		var newText = '';
		var newInfo = '';
		var newSurvey = '';
		var newQuestion = '';
		
		var userMatch = '';
		
		var oldItem = $(this).parents('.matchSelect').find('.selectTitle');
		var oldText = oldItem.text();
		var oldInfo = oldItem.attr('id').split('_');
		var oldSurvey = oldInfo[1];
		var oldQuestion = oldInfo[3];
		
		var newItem = $(this);
		var newText = newItem.text();
		var newInfo = newItem.attr('id').split('_');
		var newSurvey = newInfo[1];
		var newQuestion = newInfo[3];
		
		var userMatch = $(this).parents('.matchSelect').attr('id').split('_')[1];
		
		mhubCollection[oldSurvey]['questions'][oldQuestion].action = 'NONE';
		mhubCollection[oldSurvey]['questions'][oldQuestion].match = 'NONE';
		
		mhubCollection[newSurvey]['questions'][newQuestion].action = 'MATCH';
		mhubCollection[newSurvey]['questions'][newQuestion].match = userQuestions[userMatch];
		
		userCollection[userMatch]['match'].survey = newSurvey;
		userCollection[userMatch]['match'].question = newQuestion;
		userCollection[userMatch]['match'].text = newText;
		
		// Generate HTML matches & list
		generateMatches(userCollection);
		generateList(mhubCollection);
		
		$('.selectQuestions').hide();
	});
	
	$('.noMatch').live('click', function(e) {
		e.preventDefault();
		
		var oldItem = '';
		var oldText = '';
		var oldInfo = '';
		var oldSurvey = '';
		var oldQuestion = '';
		
		var userMatch = '';
		
		var oldItem = $(this).parents('.matchSelect').find('.selectTitle');
		var oldText = oldItem.text();
		var oldInfo = oldItem.attr('id').split('_');
		var oldSurvey = oldInfo[1];
		var oldQuestion = oldInfo[3];
		
		var userMatch = $(this).parents('.matchSelect').attr('id').split('_')[1];
		
		mhubCollection[oldSurvey]['questions'][oldQuestion].action = 'NONE';
		mhubCollection[oldSurvey]['questions'][oldQuestion].match = 'NONE';
		
		userCollection[userMatch].action = 'NONE';
		userCollection[userMatch]['match'].survey = 'NONE';
		userCollection[userMatch]['match'].question = 'NONE';
		userCollection[userMatch]['match'].text = 'NONE';
		
		// Generate HTML matches & list
		generateMatches(userCollection);
		generateList(mhubCollection);
		
		$('.selectQuestions').hide();
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
// Definition:	Builds HTML string for select list
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
	// return htmlResults;
	
	$('.surveyContainer').html(htmlResults);
}

// Function:	generateMatches
// Definition:	Builds & populates HTML for select matches
var generateMatches = function (data) {
	var newText = '';
	var newId = '';
	var checkAction = '';
	var newData = new Array();
	
	for (var key in data) {
		var obj1 = data[key];
		for (var prop1 in obj1) {
			newText = '';
			newId = '';
			if (prop1 === 'action') {
				var obj2 = obj1[prop1];
				if (obj2 === 'MATCH') {
					newText = obj1['match'].text;
					newId = 'survey_' + obj1['match'].survey + '_question_' + obj1['match'].question;
					checkAction = 'match';
					break;
				}
				else if (obj2 === 'NEW') {
					newText = __NEW_QUESTION__;
					newId = 'new_' + key;
					checkAction = 'new';
					break;
				}
				else if (obj2 === 'NONE') {
					newText = __NO_IMPORT__;
					newId = 'none_' + key;
					checkAction = 'none';
					break;
				}
			}
		}
		newData.push([newText, newId, checkAction]);
	}
	
	$('.selectTitle').each(function(index) {
		$(this).text(newData[index][0]);
		$(this).attr('id', newData[index][1]);
		if (newData[index][2] === 'new') {
			$(this).parents('.matchSelect').siblings('.matchEdit').show();
		}
		else {
			$(this).parents('.matchSelect').siblings('.matchEdit').hide();
		}
		
	});
}

// Function:	constructMhubObject
// Definition:	Creates object containing all mhub survey question data
var constructMhubObject = function (userData, mhubData, surveys, lengths, matches) {

	var question = new Object();
	var questionGroup = new Object();
	var survey = new Object();
	var surveyGroup = new Object();
	
	surveyData = origData(surveys, lengths, mhubData);
	
	for (var i = 0; i < surveyData.length; i++) {
		survey = {};
		if (surveyData[i] instanceof Array === false) {
			survey.title = surveyData[i];
			questionGroup = {};
			for (var ii = 0; ii < surveyData[i + 1].length; ii++) {
				question = {};
				var currentQuestion = surveyData[i + 1][ii];
				question.text = currentQuestion;
				for (var iii = 0; iii < matches.length; iii++) {
					var matchCheck = currentQuestion.indexOf(matches[iii]);
					if (matchCheck !== -1) {
						question.action = "MATCH";
						question.match = userData[iii];
						break;
					}
				}
				if (!question.action) {
					question.action = "NONE";
					question.match = "NONE";
				}
				questionGroup[ii] = question;
			}
			survey.questions = questionGroup;
			if (i === 0) {
				surveyGroup[i] = survey;
			}
			else {
				surveyGroup[(i/2)] = survey;
			}
		}
	}
	
	return surveyGroup;
}

// Function:	origData	
// Definition:	Creates an array of all original survey data
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

// Function:	constructUserObject
// Definition:	Creates object containing all imported user header data
var constructUserObject = function (userData, mhubCollection, matches) {

	var question = new Object();
	var questionGroup = new Object();
	var questionInfo = new Array();
	var matchInfo = new Object();
	
	for (var i = 0; i < userData.length; i++) {
		question = {};
		matchInfo = {};
		question.text = userData[i];
		questionInfo = findItem(mhubCollection, userData[i], 'match', 'text');

		if (matches[i] !== __NEW_QUESTION__) {
			question.action = 'MATCH';
			matchInfo.survey = questionInfo[0];
			matchInfo.question = questionInfo[1];
			matchInfo.text = questionInfo[2];
			question.match = matchInfo;
		}
		else {
			question.action = 'NEW';
			matchInfo.survey = 'NONE';
			matchInfo.question = 'NONE';
			matchInfo.text = 'NONE';
			question.match = matchInfo;
		}
		questionGroup[i] = question;
	}
	
	return questionGroup;
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












var resetForm = function (formId) {
	$(formId).find('#create_new').attr('checked','checked');
	$(formId).find('#survey_new').show();
	$(formId).find('#survey_old').hide();
	$(formId).find('#question_short_answer').hide();
	$(formId).find('#question_multiple_choice').hide();
	$(formId).find('input:text, select, textarea').val('');
}