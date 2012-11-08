// Data arrays created in script in views/imports/edit.html.erb
// - surveyTitles:	Contains the titles of each survey
// - surveyLengths:	Contains length of each survey
// - surveyGroups:	Contains the survey questions
// - mhubQuestions:	Contains the questions of all MissionHub surveys
// - userQuestions: Contains the questions of the imported data
// - surveyData:	Contains all of the survey titles and questions

// Define global variables
var __NEW_QUESTION__ = 'Create new question';
var __NO_IMPORT__ = 'Do not import data';
var __PREDEFINED_SURVEY__ = 'Predefined Questions';

// Main function ran on document ready
$(document).ready(function() {
	// Initialize variables
	var matchQuestions = new Array();
	
	// Perform comparison of User & MHub data & generate array of matches
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
		$('.selectQuestions').hide();
		$(this).siblings('.selectQuestions').toggle().scrollTop(0);
		var checkAction = $(this).find('.selectTitle').attr('id').split('_')[3];
 		if (checkAction === 'true') {
 			$(this).siblings('.selectQuestions').find('.newQuestion').hide();
 		}
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
		
		// Initialize variables
		var newElement = '';
		var newClass = '';
		var oldElement = '';
		var userMatch = '';
		
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
		
		newElement = $(e.target);
		newClass = newElement.attr('class');
		oldElement = newElement.parents('.matchSelect').find('.selectTitle').attr('id').split('_')[0];
		userMatch = $(this).parents('.matchSelect').attr('id').split('_')[1];
		
		if (oldElement === 'match') {
			// Collect old element info
			oldItem = $(this).parents('.matchSelect').find('.selectTitle');
			oldText = oldItem.text();
			oldInfo = oldItem.attr('id').split('_');
			oldType = oldInfo[0];
			oldSurvey = oldInfo[1];
			oldQuestion = oldInfo[2];
			oldCheck = oldInfo[3];
			
			// Set old element action to none
			mhubCollection[oldSurvey]['questions'][oldQuestion].action = 'NONE';
			mhubCollection[oldSurvey]['questions'][oldQuestion].match = 'NONE';
			
			if (newClass === 'surveyItem') {
				// Collect new element info
				newItem = $(this);
				newText = newItem.text();
				newInfo = newItem.attr('id').split('_');
				newType = newInfo[0];
				newSurvey = newInfo[1];
				newQuestion = newInfo[2];
				newCheck = newInfo[3];
				
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
				newItem = $(this);
				newText = newItem.text();
				newInfo = newItem.attr('id').split('_');
				newType = newInfo[0];
				newSurvey = newInfo[1];
				newQuestion = newInfo[2];
				
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
				newItem = $(this);
				newText = newItem.text();
				newInfo = newItem.attr('id').split('_');
				newType = newInfo[0];
				newSurvey = newInfo[1];
				newQuestion = newInfo[2];
				
				// Set new element action to match
				mhubCollection[newSurvey]['questions'][newQuestion].action = 'MATCH';
				mhubCollection[newSurvey]['questions'][newQuestion].match = userQuestions[userMatch];
				userCollection[userMatch].action = 'MATCH';
				userCollection[userMatch]['match'].question = newQuestion;
				userCollection[userMatch]['match'].survey = newSurvey;
				userCollection[userMatch]['match'].text = newText;
			}
		}
		
		// Generate HTML matches & list
		generateMatches(userCollection);
		generateList(mhubCollection);
		
		// Hide the select dropdown box
		$('.selectQuestions').hide();
	});
	
	$('.newQuestion, .editMatch').live('click', function(e) {
		e.preventDefault();
		
		// Reset the dialog form fields
		resetForm('#new_question_form');
		
		// Initialize variables
		var targetElement = '';
		var targetClass = '';
		
		var questionId = '';
		var questionAction = '';
		
		var prevSurvey = '';
		var prevQuestion = '';
		var prevText = '';
		var prevTitle = '';
		var prevAction = '';
		var prevType = '';
		var prevOptions = '';
		
		var newSurvey = '';
		var newQuestion = '';
		var newText = '';
		var newTitle = '';
		var newAction = '';
		var newType = '';
		var newOptions = '';
		
		var newForm = '';
		var newSurveyCheck = '';
		
		// Set clicked element information
		targetElement = $(e.target);
		targetClass = targetElement.attr('class');
		
		if (targetClass === 'editMatch') {
			questionId = $(this).attr('id').split('_')[1];
			questionAction = $(this).parents('.matchEdit').siblings('.matchSelect').find('.selectTitle').attr('id').split('_')[0];
		}
		else {
			questionId = $(this).parents('.matchSelect').attr('id').split('_')[1];
		}
		if (questionAction === 'match') {
			// Collect previous new survey/question information
			prevSurvey = userCollection[questionId]['match'].survey;
			prevQuestion = userCollection[questionId]['match'].question;
			prevText = userCollection[questionId]['match'].text;
			prevTitle = mhubCollection[prevSurvey].title;
			prevAction = mhubCollection[prevSurvey].action;
			prevType = mhubCollection[prevSurvey].questions[prevQuestion].type;
			
			if (prevType !== 'SHORT') {
				prevOptions = mhubCollection[prevSurvey].questions[prevQuestion].options;
			}
			
			// Populate the form with previous new question information
			populateForm('#new_question_form', prevSurvey, prevQuestion, prevText, prevTitle, prevAction, prevType, prevOptions);
			
			// Open dialog box with new survey/question form
			$('#new_question_div').dialog({
				resizable: false,
				height: 444,
				width: 600,
				modal: true,
				buttons: [
				{
					text: 'Done',
					click: function() {
						newForm = $('#new_question_form');					
						newSurveyCheck = newForm.find('#create_new');
						
						// Determine question action
						if (newSurveyCheck.is(':checked')) {
							newAction = 'NEW';
						}
						else {
							newAction = 'NONE';
						}
						
						// New survey check
						if (prevAction === 'NEW') {
							// Check if new action is same as previous action
							if (prevAction === newAction) {
								var newCheck = true;
							
								// Collect new survey/question information
								newTitle = newForm.find('#survey_name').val();
								newType = newForm.find('#question_type').val();
								if (newType === 'text_field_short') {
									newType = 'SHORT';
									newText = newForm.find('#short_answer_question').val();
								}
								else {
									if (newType === 'choice_field_radio') {
										newType = 'RADIO';
									}
									else if (newType === 'choice_field_checkbox') {
										newType = 'CHECKBOXES';
									}
									else if (newType === 'choice_field_dropdown') {
										newType = 'DROPDOWN';
									}
									newText = newForm.find('#multiple_choice_question').val();
									newOptions = newForm.find('#multiple_choice_options').val();
								}
								
								// Validate form
								var errorCheck = formValidation(newForm, newCheck, newTitle, newType, newText, newOptions);
								if (errorCheck[0] !== '') {
									alert(errorCheck[0]);
									newForm.find(errorCheck[1]).focus();
								}
								else {
									// Update data collections
									userCollection[questionId]['match'].text = newText;
									mhubCollection[prevSurvey].title = newTitle;
									mhubCollection[prevSurvey].questions[prevQuestion].text = newText;
									mhubCollection[prevSurvey].questions[prevQuestion].type = newType;
									mhubCollection[prevSurvey].questions[prevQuestion].options = newOptions;
									
									// Update surveyTitles array with new survey title
									surveyTitles[prevSurvey] = newTitle;
									
									// Generate HTML matches & list
									generateMatches(userCollection);
									generateList(mhubCollection);
									
									// Destroy the dialog
									$(this).dialog('destroy');
								}
								
							}
							// If new action is not the same as previous action
							else {
								var newCheck = false;
								
								// Delete the previously created survey from data collection
								delete mhubCollection[prevSurvey];
								
								// Collect new survey/question information
								newTitle = newForm.find('#select_survey').find(':selected').text();
								if (newTitle === prevTitle) {
									alert('I thought you wanted to select an existing survey. Please select a pre-existing survey or click on the new survey box.');
									$('#select_survey').focus();
								}
								else {								
									newType = newForm.find('#question_type').val();
									if (newType === 'text_field_short') {
										newType = 'SHORT';
										newText = newForm.find('#short_answer_question').val();
									}
									else {
										if (newType === 'choice_field_radio') {
											newType = 'RADIO';
										}
										else if (newType === 'choice_field_checkbox') {
											newType = 'CHECKBOXES';
										}
										else if (newType === 'choice_field_dropdown') {
											newType = 'DROPDOWN';
										}
										
										newText = newForm.find('#multiple_choice_question').val();
										newOptions = newForm.find('#multiple_choice_options').val();
									}
									
									// Validate form
									var errorCheck = formValidation(newForm, newCheck, newTitle, newType, newText, newOptions);
									if (errorCheck[0] !== '') {
										alert(errorCheck[0]);
										newForm.find(errorCheck[1]).focus();
									}
									else {								
										// Collect new survey/question information
										newSurvey = findSurvey(mhubCollection, newTitle);
										newQuestion = collectionSize(mhubCollection[newSurvey]['questions']);
										
										// Update data collections
										var mhubObjectQuestion = new Object();
										var userObjectMatch = new Object();
										var userObjectHolder = new Object();
										
										mhubObjectQuestion.action = 'MATCH';
										mhubObjectQuestion.match = userQuestions[questionId];
										mhubObjectQuestion.text = newText;
										mhubObjectQuestion.options = newOptions;
										mhubObjectQuestion.newquestion = true;
										mhubObjectQuestion.type = newType;
										
										mhubCollection[newSurvey]['questions'][newQuestion] = mhubObjectQuestion;
										
										userObjectMatch.question = newQuestion;
										userObjectMatch.survey = newSurvey;
										userObjectMatch.text = newText;
										userObjectMatch.newquestion = true;
										
										userObjectHolder.text = userQuestions[questionId];
										userObjectHolder.action = 'MATCH';
										userObjectHolder.match = userObjectMatch;
										
										userCollection[questionId] = userObjectHolder;
										
										// Update surveyTitles array with new survey title
										for (var i = 0; i < surveyTitles.length; i++) {
											var index = surveyTitles[i].indexOf(prevTitle);
											if (index !== -1) {
												surveyTitles.splice(i, 1);
												break;
											}
										}
										
										// Generate HTML matches & list
										generateMatches(userCollection);
										generateList(mhubCollection);
										
										// Destroy the dialog
										$(this).dialog('destroy');
									}
								}
							}
						}
						else {
							// Previous action is NONE & previous action is the same as new action
							if (prevAction === newAction) {
								var newCheck = false;
								
								// Collect new survey/question information
								newTitle = newForm.find('#select_survey').find(':selected').text();
								newType = newForm.find('#question_type').val();
								if (newType === 'text_field_short') {
									newType = 'SHORT';
									newText = newForm.find('#short_answer_question').val();
								}
								else {
									if (newType === 'choice_field_radio') {
										newType = 'RADIO';
									}
									else if (newType === 'choice_field_checkbox') {
										newType = 'CHECKBOXES';
									}
									else if (newType === 'choice_field_dropdown') {
										newType = 'DROPDOWN';
									}
									
									newText = newForm.find('#multiple_choice_question').val();
									newOptions = newForm.find('#multiple_choice_options').val();
								}
								
								// Validate form
								var errorCheck = formValidation(newForm, newCheck, newTitle, newType, newText, newOptions);
								if (errorCheck[0] !== '') {
									alert(errorCheck[0]);
									newForm.find(errorCheck[1]).focus();
								}
								else {						
									// Collect new survey/question information
									newSurvey = findSurvey(mhubCollection, newTitle);
									
									// Check if new survey is the same as old survey
									if (newSurvey === prevSurvey) {
										// Update data collections
										userCollection[questionId]['match'].text = newText;								
										mhubCollection[prevSurvey].questions[prevQuestion].text = newText;
										mhubCollection[prevSurvey].questions[prevQuestion].type = newType;
										mhubCollection[prevSurvey].questions[prevQuestion].options = newOptions;	
									}
									else {
										// Collect new survey/question information
										newQuestion = collectionSize(mhubCollection[newSurvey]['questions']);
										
										// Delete the previously created survey from data collection																
										delete mhubCollection[prevSurvey].questions[prevQuestion];
										
										// Update data collections
										var mhubObjectQuestion = new Object();
										
										userCollection[questionId]['match'].text = newText;
										userCollection[questionId]['match'].survey = newSurvey;
										userCollection[questionId]['match'].question = newQuestion;
										
										mhubObjectQuestion.action = 'MATCH';
										mhubObjectQuestion.match = userQuestions[questionId];
										mhubObjectQuestion.text = newText;
										mhubObjectQuestion.newquestion = true;
										mhubObjectQuestion.type = newType;
										mhubObjectQuestion.options = newOptions;
										
										mhubCollection[newSurvey].questions[newQuestion] = mhubObjectQuestion;
									}
									
									// Generate HTML matches & list
									generateMatches(userCollection);
									generateList(mhubCollection);
									
									// Destroy the dialog
									$(this).dialog('destroy');
								}
							}
							// Previous action is NONE & previous action is not the same as new action
							else {
								var newCheck = true;
								
								// Collect new survey/question information
								newTitle = newForm.find('#survey_name').val();
								newType = newForm.find('#question_type').val();
								if (newType === 'text_field_short') {
									newType = 'SHORT';
									newText = newForm.find('#short_answer_question').val();
								}
								else {
									if (newType === 'choice_field_radio') {
										newType = 'RADIO';
									}
									else if (newType === 'choice_field_checkbox') {
										newType = 'CHECKBOXES';
									}
									else if (newType === 'choice_field_dropdown') {
										newType = 'DROPDOWN';
									}
									newText = newForm.find('#multiple_choice_question').val();
									newOptions = newForm.find('#multiple_choice_options').val();
								}
								
								// Validate form
								var errorCheck = formValidation(newForm, newCheck, newTitle, newType, newText, newOptions);
								if (errorCheck[0] !== '') {
									alert(errorCheck[0]);
									newForm.find(errorCheck[1]).focus();
								}
								else {							
									// Delete the previously created survey from data collection
									delete mhubCollection[prevSurvey].questions[prevQuestion];
									
									// Collect new survey/question information
									newSurvey = collectionSize(mhubCollection);
									newQuestion = 0;
									
									// Update data collections
									var mhubObjectQuestion = new Object();
									var mhubObjectHolder = new Object();
									
									userCollection[questionId]['match'].text = newText;
									userCollection[questionId]['match'].survey = newSurvey;
									userCollection[questionId]['match'].question = newQuestion;
									
									mhubObjectQuestion.action = 'MATCH';
									mhubObjectQuestion.match = userQuestions[questionId];
									mhubObjectQuestion.text = newText;
									mhubObjectQuestion.newquestion = true;
									mhubObjectQuestion.type = newType;
									
									mhubObjectHolder.action = 'NEW';
									mhubObjectHolder.title = newTitle;
									mhubObjectHolder.questions = new Object();
									mhubObjectHolder.questions[0] = mhubObjectQuestion;
									
									mhubCollection[newSurvey] = mhubObjectHolder;
									
									// Update surveyTitles array with new survey title
									surveyTitles.push(newTitle);
									
									// Generate HTML matches & list
									generateMatches(userCollection);
									generateList(mhubCollection);
									
									// Destroy the dialog
									$(this).dialog('destroy');
								}
							}
						}
					},
				}, {
					text: 'Cancel',
					click: function() {
						resetForm('#new_question_form');
						$(this).dialog('destroy');
					}
				}
				]
			});
		}
		else {
			// Open dialog box with new survey/question form
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
						var newSurveyCheck = newForm.find('#create_new');
						
						// Check if new survey
						if (newSurveyCheck.is(':checked')) {
							var newCheck = true;
						
							// Collect new survey/question information
							newTitle = newForm.find('#survey_name').val();
							newType = newForm.find('#question_type').find(':selected').val();
							
							if (newType === 'text_field_short') {
								newType = 'SHORT';
								newText = newForm.find('#short_answer_question').val();
							}
							else {
								if (newType === 'choice_field_radio') {
									newType = 'RADIO';
								}
								else if (newType === 'choice_field_checkbox') {
									newType = 'CHECKBOXES';
								}
								else if (newType === 'choice_field_dropdown') {
									newType = 'DROPDOWN';
								}
								newText = newForm.find('#multiple_choice_question').val();
								newOptions = newForm.find('#multiple_choice_options').val();
							}
							
							// Validate form
							var errorCheck = formValidation(newForm, newCheck, newTitle, newType, newText, newOptions);
							if (errorCheck[0] !== '') {
								alert(errorCheck[0]);
								newForm.find(errorCheck[1]).focus();
							}
							else {						
								newSurvey = collectionSize(mhubCollection);
								newQuestion = 0;
								
								// Update data collections
								var mhubObjectQuestion = new Object();
								var mhubObjectHolder = new Object();
								var userObjectMatch = new Object();
								var userObjectHolder = new Object();
								
								userObjectMatch.question = newQuestion;
								userObjectMatch.survey = newSurvey;
								userObjectMatch.text = newText;
								userObjectMatch.newquestion = true;
								userObjectHolder.text = userQuestions[questionId];
								userObjectHolder.action = 'MATCH';
								userObjectHolder.match = userObjectMatch;
								userCollection[questionId] = userObjectHolder;
								
								mhubObjectQuestion.action = 'MATCH';
								mhubObjectQuestion.match = userQuestions[questionId];
								mhubObjectQuestion.text = newText;
								mhubObjectQuestion.newquestion = true;
								mhubObjectQuestion.type = newType;
								mhubObjectQuestion.options = newOptions;
								
								mhubObjectHolder.action = 'NEW';
								mhubObjectHolder.title = newTitle;
								mhubObjectHolder.questions = new Object();
								mhubObjectHolder.questions[0] = mhubObjectQuestion;
								
								mhubCollection[newSurvey] = mhubObjectHolder;
								
								// Update surveyTitles array with new survey title
								surveyTitles.push(newTitle);
								
								// Generate HTML matches & list
								generateMatches(userCollection);
								generateList(mhubCollection);
								
								// Destroy the dialog
								$(this).dialog('destroy');
							}
						}
						else {						
							var newCheck = false;
							
							// Collect old survey/new question information
							prevTitle = newForm.find('#select_survey').find(':selected').text();
							newType = newForm.find('#question_type').find(':selected').val();
							
							if (newType === 'text_field_short') {
								newType = 'SHORT';
								newText = newForm.find('#short_answer_question').val();
							}
							else {
								if (newType === 'choice_field_radio') {
									newType = 'RADIO';
								}
								else if (newType === 'choice_field_checkbox') {
									newType = 'CHECKBOXES';
								}
								else if (newType === 'choice_field_dropdown') {
									newType = 'DROPDOWN';
								}
								newText = newForm.find('#multiple_choice_question').val();
								newOptions = newForm.find('#multiple_choice_options').val();
							}
							
							// Validate form
							var errorCheck = formValidation(newForm, newCheck, prevTitle, newType, newText, newOptions);
							if (errorCheck[0] !== '') {
								alert(errorCheck[0]);
								newForm.find(errorCheck[1]).focus();
							}
							else {
								prevSurvey = findSurvey(mhubCollection, prevTitle);
								newQuestion = collectionSize(mhubCollection[prevSurvey]['questions']);
								
								// Update data collections
								var mhubObjectQuestion = new Object();
								var mhubObjectHolder = new Object();
								var userObjectMatch = new Object();
								var userObjectHolder = new Object();
								
								userObjectMatch.question = newQuestion;
								userObjectMatch.survey = prevSurvey;
								userObjectMatch.newquestion = true;
								userObjectMatch.text = newText;
								userObjectHolder.text = userQuestions[questionId];
								userObjectHolder.action = 'MATCH';
								userObjectHolder.match = userObjectMatch;
								userCollection[questionId] = userObjectHolder;
								
								mhubObjectQuestion.action = 'MATCH';
								mhubObjectQuestion.match = userQuestions[questionId];
								mhubObjectQuestion.text = newText;
								mhubObjectQuestion.newquestion = true;
								mhubObjectQuestion.type = newType;
								mhubObjectQuestion.options = newOptions;
								mhubCollection[prevSurvey]['questions'][newQuestion] = mhubObjectQuestion;
								
								// Generate HTML matches & list
								generateMatches(userCollection);
								generateList(mhubCollection);
								
								// Destroy the dialog
								$(this).dialog('destroy');
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
		}
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
			$('#survey_old').show();
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
		else if (questionType !== "text_field_short" && questionType !== '') {
			$('#question_multiple_choice').show();
			$('#preview_multiple').show();
			$('#question_short_answer').hide();
			$('#preview_short').hide();
		}
		else {
			$('#question_short_answer').hide();
			$('#preview_short').hide();
			$('#question_multiple_choice').hide();
			$('#preview_multiple').hide();
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
	return Number(surveyLocation);
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
	resetSurveyOptions(formId, surveyTitles);
	$(formId).find('#create_new').attr('checked', true);
	$(formId).find('#survey_new').show();
	$(formId).find('#survey_old').hide();
	$(formId).find('#question_short_answer').hide();
	$(formId).find('#question_multiple_choice').hide();
	$(formId).find('input:text, select, textarea').val('');
}

// Function:	resetSurveyOptions
// Definition:	Set survey select options
var resetSurveyOptions = function(formId, surveyTitles) {
	var survey_options = '<option value=""></option>';
	for (i = 0; i < surveyTitles.length; i++) {
		if (surveyTitles[i] !== __PREDEFINED_SURVEY__) {
			var survey_options = survey_options + '<option value="survey_' + i + '">' + surveyTitles[i] + '</option>';
		}
	}
	$(formId).find('#survey_old select').html(survey_options);
}

// Function:	populateForm
// Definition:	Set form elements to include previous data
var populateForm = function (formId, prevSurvey, prevQuestion, prevText, prevTitle, prevAction, prevType, prevOptions) {
	if (prevAction === 'NEW') {
		$(formId).find('#create_new').attr('checked', true);
		$(formId).find('#survey_new').show();
		$(formId).find('#survey_old').hide();
		$(formId).find('#survey_name').val(prevTitle);
		if (prevType === 'SHORT') {
			$(formId).find('#question_type').val('text_field_short');
			$(formId).find('#question_short_answer').show();
			$(formId).find('#question_multiple_choice').hide();
			$(formId).find('#short_answer_question').val(prevText);
		}
		else {
			if (prevType === 'RADIO') {
				$(formId).find('#question_type').val('choice_field_radio');
			}
			else if (prevType === 'CHECKBOXES') {
				$(formId).find('#question_type').val('choice_field_checkbox');
			}
			else if (prevType === 'DROPDOWN') {
				$(formId).find('#question_type').val('choice_field_dropdown');
			}
			$(formId).find('#question_short_answer').hide();
			$(formId).find('#question_multiple_choice').show();
			$(formId).find('#multiple_choice_question').val(prevText);
			$(formId).find('#multiple_choice_options').val(prevOptions);
		}
	}
	else if (prevAction === 'NONE') {
		$(formId).find('#create_new').attr('checked', false);
		$(formId).find('#survey_new').hide();
		$(formId).find('#survey_old').show();
		$(formId).find('#select_survey').val('survey_' + prevSurvey);
		if (prevType === 'SHORT') {
			$(formId).find('#question_type').val('text_field_short');
			$(formId).find('#question_short_answer').show();
			$(formId).find('#question_multiple_choice').hide();
			$(formId).find('#short_answer_question').val(prevText);
		}
		else {
			if (prevType === 'RADIO') {
				$(formId).find('#question_type').val('choice_field_radio');
			}
			else if (prevType === 'CHECKBOXES') {
				$(formId).find('#question_type').val('choice_field_checkbox');
			}
			else if (prevType === 'DROPDOWN') {
				$(formId).find('#question_type').val('choice_field_dropdown');
			}
			$(formId).find('#question_short_answer').hide();
			$(formId).find('#question_multiple_choice').show();
			$(formId).find('#multiple_choice_question').val(prevText);
			$(formId).find('#multiple_choice_options').val(prevOptions);
		}
	}
}
// Function:	formValidation
// Definition:	Verifies that all form fields are populated
var formValidation = function(form, check, title, type, text, options) {
	// Initialize variables
	var errorMsg = '';
	var errorField = '';
	var errorInfo = new Array();
	
	var formType = form.find('#create_new');
	
	if (check === true) {
	// Form is for new survey
		if (title === '') {
			errorMsg = 'Please enter a survey name.';
			errorField = '#survey_name';
		}
		else {
			if (type === '') {
				errorMsg = 'Please select a question type.';
				errorField = '#question_type';
			}
			else {
				if (type === 'SHORT' && text === '') {
					errorMsg = 'Please enter a question.';
					errorField = '#short_answer_question';
				}
				else if (type !== 'SHORT' && text === '') {
					errorMsg = 'Please enter a question.';
					errorField = '#multiple_choice_question';
				}
				else if (type !== 'SHORT' && options === '') {
					errorMsg = 'Please enter at least one option.';
					errorField = '#multiple_choice_options.';
				}
			}
		}
	}
	else {
	// Form is for existing survey
		if (title === '') {
			errorMsg = 'Please select a survey name.';
			errorField = '#select_survey';
		}
		else {
			if (type === '') {
				errorMsg = 'Please select a question type.';
				errorField = '#question_type';
			}
			else {
				if (type === 'SHORT' && text === '') {
					errorMsg = 'Please enter a question.';
					errorField = '#short_answer_question';
				}
				else if (type !== 'SHORT' && text === '') {
					errorMsg = 'Please enter a question.';
					errorField = '#multiple_choice_question';
				}
				else if (type !== 'SHORT' && options === '') {
					errorMsg = 'Please enter at least one option.';
					errorField = '#multiple_choice_options.';
				}
			}
		}
	}
	errorInfo.push(errorMsg, errorField);
	return errorInfo;
}