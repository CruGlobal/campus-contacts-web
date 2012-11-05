var __NEW_QUESTION__ = 'Create new question';
var __NO_IMPORT__ = 'Do not import data';
var __PREDEFINED_SURVEY__ = 'Predefined Questions';

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

	// When survey item or no match is selected HTML is updated
	$('.surveyItem, .noMatch, .noImport').live('click', function(e) {
		e.preventDefault();
		
		var newElement = '';
		var newClass = '';
		var oldElement = '';
		
		var oldItem = '';
		var oldText = '';
		var oldInfo = '';
		var oldType = '';
		var oldSurvey = '';
		var oldQuestion = '';
		var oldCheck = '';
		
		var newItem = '';
		var newText = '';
		var newInfo = '';
		var newType = '';
		var newSurvey = '';
		var newQuestion = '';
		var newCheck = '';
		
		var userMatch = '';
		
		var newElement = $(e.target);
		var newClass = newElement.attr('class');
		var oldElement = newElement.parents('.matchSelect').find('.selectTitle').attr('id').split('_')[0];
		var userMatch = $(this).parents('.matchSelect').attr('id').split('_')[1];
		
		if (oldElement === 'match') {
			// Collect old element info
			var oldItem = $(this).parents('.matchSelect').find('.selectTitle');
			var oldText = oldItem.text();
			var oldInfo = oldItem.attr('id').split('_');
			var oldType = oldInfo[0];
			var oldSurvey = oldInfo[1];
			var oldQuestion = oldInfo[2];
			var oldCheck = oldInfo[3];
			
			// Set old element action to none
			mhubCollection[oldSurvey]['questions'][oldQuestion].action = 'NONE';
			mhubCollection[oldSurvey]['questions'][oldQuestion].match = 'NONE';
			
			if (newClass === 'surveyItem') {
				// Collect new element info
				var newItem = $(this);
				var newText = newItem.text();
				var newInfo = newItem.attr('id').split('_');
				var newType = newInfo[0];
				var newSurvey = newInfo[1];
				var newQuestion = newInfo[2];
				var newCheck = newInfo[3];
				
				// Set new element action to match
				mhubCollection[newSurvey]['questions'][newQuestion].action = 'MATCH';
				mhubCollection[newSurvey]['questions'][newQuestion].match = userQuestions[userMatch];
				userCollection[userMatch].action = 'MATCH';
				userCollection[userMatch]['match'].question = newQuestion;
				userCollection[userMatch]['match'].survey = newSurvey;
				userCollection[userMatch]['match'].text = newText;
				if (newCheck === 'true') {
					userCollection[userMatch]['match'].newquestion = true;
				}
				else {
					userCollection[userMatch]['match'].newquestion = false;
				}
			}
			else if (newClass === 'noMatch' || newClass === 'noImport') {
				// Set new element action to none
				userCollection[userMatch].action = 'NOIMPORT';
				userCollection[userMatch]['match'].text = 'NONE';
			}
		}
		else if (oldElement === 'new') {
			if (newClass === 'surveyItem') {
				// Collect new element info
				var newItem = $(this);
				var newText = newItem.text();
				var newInfo = newItem.attr('id').split('_');
				var newType = newInfo[0];
				var newSurvey = newInfo[1];
				var newQuestion = newInfo[2];
				
				// Set new element action to match
				mhubCollection[newSurvey]['questions'][newQuestion].action = 'MATCH';
				mhubCollection[newSurvey]['questions'][newQuestion].match = userQuestions[userMatch];
				userCollection[userMatch].action = 'MATCH';
				userCollection[userMatch]['match'].question = newQuestion;
				userCollection[userMatch]['match'].survey = newSurvey;
				userCollection[userMatch]['match'].text = newText;
			}
			else if (newClass === 'noMatch' || newClass === 'noImport') {
				// Set new element action to none
				userCollection[userMatch].action = 'NOIMPORT';
				userCollection[userMatch]['match'].text = 'NONE';
			}
		}
		else if (oldElement === 'noimport') {
			if (newClass === 'surveyItem') {
				// Collect new element info
				var newItem = $(this);
				var newText = newItem.text();
				var newInfo = newItem.attr('id').split('_');
				var newType = newInfo[0];
				var newSurvey = newInfo[1];
				var newQuestion = newInfo[2];
				
				// Set new element action to match
				mhubCollection[newSurvey]['questions'][newQuestion].action = 'MATCH';
				mhubCollection[newSurvey]['questions'][newQuestion].match = userQuestions[userMatch];
				userCollection[userMatch].action = 'MATCH';
				userCollection[userMatch]['match'].question = newQuestion;
				userCollection[userMatch]['match'].survey = newSurvey;
				userCollection[userMatch]['match'].text = newText;
			}
			else if (newClass === 'noMatch' || newClass === 'noImport') {
				// No task
			}
		}
		
		// Generate HTML matches & list
		generateMatches(userCollection);
		generateList(mhubCollection);
		
		$('.selectQuestions').hide();
	});
	
	$('.newQuestion, .editMatch').live('click', function(e) {
		e.preventDefault();
		
		resetForm('#new_question_form');
		
		var targetElement = $(e.target);
		var targetClass = targetElement.attr('class');
		
		if (targetClass === 'editMatch') {
			var questionId = $(this).attr('id').split('_')[1];
			var questionAction = $(this).parents('.matchEdit').siblings('.matchSelect').find('.selectTitle').attr('id').split('_')[0];
			console.log(questionAction);
		}
		else {
			var questionId = $(this).parents('.matchSelect').attr('id').split('_')[1];
		}
		
		$('#new_question_div').dialog({
			resizable: false,
			height: 444,
			width: 600,
			modal: true,
			buttons: [
			{
				text: 'Done',
				click: function() {
					var newForm = $('#new_question_form');
					
					var newSurveyCheck = '';
					var newSurveyName = '';
					var newQuestionType = '';
					var newShort = '';
					var newMultiple = '';
					var newMultipleOptions = '';
					
					var oldSurveyName = '';
					
					var newSurveyCheck = newForm.find('#create_new');
					
					if (newSurveyCheck.is(':checked')) {
						newSurveyName = newForm.find('#survey_name').val();
						surveyTitles.push(newSurveyName);
						if (newSurveyName === '') {
							alert('Please enter a survey name');
							newForm.find('#survey_name').focus();
						}
						else {
							newQuestionType = newForm.find('#question_type').find(':selected').val();
							if (newQuestionType === '') {
								alert('Please select a question type');
								newForm.find('#question_type').focus();
							}
							else if (newQuestionType === 'text_field_short') {
								newShort = newForm.find('#short_answer_question').val();
								if (newShort === '') {
									alert('Please enter a question');
									newForm.find('#short_answer_question').focus();
								}
								else {
									var mhubObjectLocation = '';
									var mhubObjectQuestion = new Object();
									var mhubObjectHolder = new Object();
									
									var userObjectLocation = '';
									var userObjectMatch = new Object();
									var userObjectHolder = new Object();
									
									mhubObjectLocation = collectionSize(mhubCollection);
									
									mhubObjectQuestion.action = 'MATCH';
									mhubObjectQuestion.match = userQuestions[questionId];
									mhubObjectQuestion.text = newShort;
									mhubObjectQuestion.newquestion = true;
									mhubObjectQuestion.type = 'SHORT';
									mhubObjectHolder.action = 'NEW';
									mhubObjectHolder.title = newSurveyName;
									mhubObjectHolder.questions = new Object();
									mhubObjectHolder.questions[0] = mhubObjectQuestion;
									
									mhubCollection[mhubObjectLocation] = mhubObjectHolder;
									
									userObjectLocation = collectionSize(userCollection);
									
									userObjectMatch.question = 0;
									userObjectMatch.survey = mhubObjectLocation;
									userObjectMatch.text = newShort;
									userObjectMatch.newquestion = true;
									
									userObjectHolder.text = userQuestions[questionId];
									userObjectHolder.action = 'MATCH';
									userObjectHolder.match = userObjectMatch;
									
									userCollection[questionId] = userObjectHolder;
									
									// Generate HTML matches & list
									generateMatches(userCollection);
									generateList(mhubCollection);
									
									$(this).dialog('destroy');
								}
							}
							else {
								newMultiple = newForm.find('#multiple_choice_question').val();
								if (newMultiple === '') {
									alert('Please enter a question');
									newForm.find('#multiple_choice_question').focus();
								}
								else {
									newMultipleOptions = newForm.find('#multiple_choice_options').val();
									if (newMultipleOptions === '') {
										alert('Please enter at least one option');
										newForm.find('#multiple_choice_options').focus();
									}
									else {
										var mhubObjectLocation = '';
										var mhubObjectQuestion = new Object();
										var mhubObjectHolder = new Object();
										
										var userObjectLocation = '';
										var userObjectMatch = new Object();
										var userObjectHolder = new Object();
										
										mhubObjectLocation = collectionSize(mhubCollection);
										
										mhubObjectQuestion.action = 'MATCH';
										mhubObjectQuestion.match = userQuestions[questionId];
										mhubObjectQuestion.text = newMultiple;
										mhubObjectQuestion.newquestion = true;
										if (newQuestionType === 'choice_field_radio') {
											mhubObjectQuestion.type = 'RADIO';
										}
										else if (newQuestionType === 'choice_field_checkbox') {
											mhubObjectQuestion.type = 'CHECKBOX';
										}
										else if (newQuestionType === 'choice_field_dropdown') {
											mhubObjectQuestion.type = 'DROPDOWN';
										}
										mhubObjectQuestion.options = newMultipleOptions;
										
										mhubObjectHolder.action = 'NEW';
										mhubObjectHolder.title = newSurveyName;
										mhubObjectHolder.questions = new Object();
										mhubObjectHolder.questions[0] = mhubObjectQuestion;
										
										mhubCollection[mhubObjectLocation] = mhubObjectHolder;
										
										userObjectLocation = collectionSize(userCollection);
										
										userObjectMatch.question = 0;
										userObjectMatch.survey = mhubObjectLocation;
										userObjectMatch.text = newMultiple;
										userObjectMatch.newquestion = true;
										userObjectHolder.text = userQuestions[questionId];
										userObjectHolder.action = 'MATCH';
										userObjectHolder.match = userObjectMatch;
										
										userCollection[questionId] = userObjectHolder;
										
										// Generate HTML matches & list
										generateMatches(userCollection);
										generateList(mhubCollection);
										
										$(this).dialog('destroy');
									}
								}
							}
						}
					}
					else {
						oldSurveyName = newForm.find('#select_survey').find(':selected').text();
						if (oldSurveyName === '') {
							alert('Please select a survey');
							newForm.find('#select_survey').focus();
						}
						else {
							newQuestionType = newForm.find('#question_type').find(':selected').val();
							if (newQuestionType === '') {
								alert('Please select a question type');
								newForm.find('#question_type').focus();
							}
							else if (newQuestionType === 'text_field_short') {
								newShort = newForm.find('#short_answer_question').val();
								if (newShort === '') {
									alert('Please enter a question');
									newForm.find('#short_answer_question').focus();
								}
								else {
									var mhubObjectSurvey = '';
									var mhubObjectLocation = '';
									var mhubObjectQuestion = new Object();
									var mhubObjectHolder = new Object();
									
									var userObjectLocation = '';
									var userObjectMatch = new Object();
									var userObjectHolder = new Object();
									
									mhubObjectSurvey = findSurvey(mhubCollection, oldSurveyName);
									mhubObjectLocation = collectionSize(mhubCollection[mhubObjectSurvey]['questions']);
									
									mhubObjectQuestion.action = 'MATCH';
									mhubObjectQuestion.match = userQuestions[questionId];
									mhubObjectQuestion.text = newShort;
									mhubObjectQuestion.newquestion = true;
									mhubObjectQuestion.type = 'SHORT';
									
									mhubCollection[mhubObjectSurvey]['questions'][mhubObjectLocation] = mhubObjectQuestion;
									
									userObjectLocation = collectionSize(userCollection);
									
									userObjectMatch.question = mhubObjectLocation;
									userObjectMatch.survey = mhubObjectSurvey;
									userObjectMatch.text = newShort;
									userObjectMatch.newquestion = true;
									
									userObjectHolder.text = userQuestions[questionId];
									userObjectHolder.action = 'MATCH';
									userObjectHolder.match = userObjectMatch;
									
									userCollection[questionId] = userObjectHolder;
									
									// Generate HTML matches & list
									generateMatches(userCollection);
									generateList(mhubCollection);
									
									$(this).dialog('destroy');
								}
							}
							else {
								newMultiple = newForm.find('#multiple_choice_question').val();
								if (newMultiple === '') {
									alert('Please enter a question');
									newForm.find('#multiple_choice_question').focus();
								}
								else {
									newMultipleOptions = newForm.find('#multiple_choice_options').val();
									if (newMultipleOptions === '') {
										alert('Please enter at least one option');
										newForm.find('#multiple_choice_options').focus();
									}
									else {
										var mhubObjectSurvey = '';
										var mhubObjectLocation = '';
										var mhubObjectQuestion = new Object();
										var mhubObjectHolder = new Object();
										
										var userObjectLocation = '';
										var userObjectMatch = new Object();
										var userObjectHolder = new Object();
										
										mhubObjectSurvey = findSurvey(mhubCollection, oldSurveyName);
										mhubObjectLocation = collectionSize(mhubCollection[mhubObjectSurvey]['questions']);
										
										mhubObjectQuestion.action = 'MATCH';
										mhubObjectQuestion.match = userQuestions[questionId];
										mhubObjectQuestion.text = newMultiple;
										mhubObjectQuestion.newquestion = true;
										if (newQuestionType === 'choice_field_radio') {
											mhubObjectQuestion.type = 'RADIO';
										}
										else if (newQuestionType === 'choice_field_checkbox') {
											mhubObjectQuestion.type = 'CHECKBOX';
										}
										else if (newQuestionType === 'choice_field_dropdown') {
											mhubObjectQuestion.type = 'DROPDOWN';
										}
										mhubObjectQuestion.options = newMultipleOptions;
										
										mhubCollection[mhubObjectSurvey]['questions'][mhubObjectLocation] = mhubObjectQuestion;
										
										userObjectLocation = collectionSize(userCollection);
										
										userObjectMatch.question = mhubObjectLocation;
										userObjectMatch.survey = mhubObjectSurvey;
										userObjectMatch.text = newMultiple;
										userObjectMatch.newquestion = true;
										
										userObjectHolder.text = userQuestions[questionId];
										userObjectHolder.action = 'MATCH';
										userObjectHolder.match = userObjectMatch;
										
										userCollection[questionId] = userObjectHolder;
										
										// Generate HTML matches & list
										generateMatches(userCollection);
										generateList(mhubCollection);
										
										$(this).dialog('destroy');
									}
								}
							}
						}
					}
				}
			}, {
				text: 'Cancel',
				click: function() {
					resetForm('#new_question_form');
					$(this).dialog('destroy');
				}
			}
			]
		});
		false;
	});
	
	// New question form scripts
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
				if (surveyTitles[i] !== __PREDEFINED_SURVEY__) {
					var survey_options = survey_options + '<option value="survey_' + i + '">' + surveyTitles[i] + '</option>';
				}
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

// -------------------------------------------------------------------------------------

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
								htmlResults = htmlResults + '<li class="surveyItem" id="none_' + key + '_' + prop2 + '_' + obj3['newquestion'] + '">' + obj3['text'] + '</li>';
							}
							else if (obj3[prop3] === 'MATCH') {
								// Do nothing
							}
							else if (obj3[prop3] === 'NEW') {
								htmlResults = htmlResults + '<li class="surveyItem" id="new_' + key + '_' + prop2 + '_' + obj3['newquestion'] + '">' + obj3['text'] + '</li>';
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
				if (obj2 === 'NOIMPORT') {
					newText = __NO_IMPORT__;
					newId = 'noimport_' + key;
					checkAction = newId.split('_')[0];
					checkNew = obj1['match'].newquestion;
					break;
				}
				if (obj2 === 'MATCH') {
					newText = obj1['match'].text;
					newId = 'match_' + obj1['match'].survey + '_' + obj1['match'].question + '_' + obj1['match'].newquestion;
					checkAction = newId.split('_')[0];
					checkNew = obj1['match'].newquestion;
					break;
				}
				else if (obj2 === 'NEW') {
					newText = __NEW_QUESTION__;
					newId = 'new_' + key;
					checkAction = newId.split('_')[0];
					checkNew = obj1['match'].newquestion;
					break;
				}
			}
		}
		newData.push([newText, newId, checkAction, checkNew]);
	}
	
	$('.selectTitle').each(function(index) {
		$(this).text(newData[index][0]);
		$(this).attr('id', newData[index][1]);
		if (newData[index][2] === 'new') {
			$(this).parents('.matchSelect').siblings('.matchEdit').show();
		}
		else if (newData[index][2] === 'match' && newData[index][3] === true) {
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
			survey.action = "NONE";
			questionGroup = {};
			for (var ii = 0; ii < surveyData[i + 1].length; ii++) {
				question = {};
				var currentQuestion = surveyData[i + 1][ii];
				question.text = currentQuestion;
				question.newquestion = false;
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
			matchInfo.newquestion = false;
			question.match = matchInfo;
		}
		else {
			question.action = 'NEW';
			matchInfo.survey = 'NONE';
			matchInfo.question = 'NONE';
			matchInfo.text = 'NONE';
			matchInfo.newquestion = false;
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

// Function:	findSurvey
// Definition:	Locates info about survey in object
var findSurvey = function(data, survey) {
	var itemResults = new Array();
	
	for (var key in data) {
		var obj1 = data[key];
		for (var prop1 in obj1) {
			if (prop1 === "title") {
				if (obj1[prop1] === survey) {
					var surveyLocation = key;
					break;
				}
			}
		}
	}
	return surveyLocation;
}

// Function:	collectionSize
// Definition:	Returns size of object
var collectionSize = function(obj) {
	var size = 0;
	var key = '';
	for (key in obj) {
		if (obj.hasOwnProperty(key)) {
			size++;
		}
	}
	return size;
}

// Function:	resetForm
// Definition:	Set form elements back to original state
var resetForm = function (formId) {
	$(formId).find('#create_new').attr('checked','checked');
	$(formId).find('#survey_new').show();
	$(formId).find('#survey_old').hide();
	$(formId).find('#question_short_answer').hide();
	$(formId).find('#question_multiple_choice').hide();
	$(formId).find('input:text, select, textarea').val('');
}