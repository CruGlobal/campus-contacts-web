$(function() {
  var api_key = $('#api_key').text();
  var question_title, survey_title, last_updated;
  var total_responses = 0;

  $.getJSON("/apis/v3/surveys?secret="+api_key,
  function(returned_data)
  {
    var surveys = returned_data['surveys'];
    for (var i = 0; i < surveys.length; i++) {
      $('#upper').append('<div id="'+surveys[i]["id"]+'" class="leftMenuItem upper"><div class="upper-check"></div>'+surveys[i]['title']+'</div>');
    }
    //survey_title = surveys[0]['label'];
  });

  $('#header-button').click(function(){
    if($('.leftMenu').hasClass('visible')){
      $('.leftMenu').animate({"left": "-=300px"}, "slow").removeClass("visible");
      $('#question-title').animate({"margin-left": "-=300px"}, "slow");
    }
    else{
      $('.leftMenu').animate({"left": "+=300px"}, "slow").addClass("visible");
      $('#question-title').animate({"margin-left": "+=300px"}, "slow");
    }
  });

  $(document).on('click','.lower', function(){
    if(!($(this).find('.lower-check').hasClass('checked'))){
      $('.lower-check').each(function(){
        $(this).removeClass('checked');
      });
      $(this).find('.lower-check').addClass('checked').delay(2000);
      setTimeout(function(){
        $('.leftMenu').animate({"left": "-=300px"}, "slow").removeClass("visible");
        $('#question-title').animate({"margin-left": "-=300px"}, "slow");
      }, 300);
      
      question_id = $(this).attr('id');
      question_title = $(this).text();
      $('#question-title').text(question_title.toUpperCase());
      $('#total-responses-container').show("slow");
      get_answers(question_id);
    }
  });

  $(document).on('click','.upper', function(){
    if(!($(this).find('.upper-check').hasClass('checked'))){
      $('.upper-check').each(function(){
        $(this).removeClass('checked');
      });
      $(this).find('.upper-check').addClass('checked');
      
      $('#lower').html("");
      $('#scroller').html("");
      total_responses = 0;
      $('#total-responses-container').hide();
      
      survey_id = $(this).attr('id');
      get_questions(survey_id);
    }
  });

  function get_answers(id){
    $.getJSON("/apis/v3/answers?question_ids="+id+"&secret="+api_key+"&order=created_at%20desc",
    function(returned_data)
    {
      var answers = returned_data['answers'];
      total_responses = answers.length;
      $('#total_responses').text(total_responses);
      for (var i = 0; i < answers.length; i++) {
        if(i < 7){
          $('#scroller').append("<tr><td>"+answers[i]['value']+"</td></tr>");
        }
      }
    });
    
    last_updated = Math.floor(new Date() / 1000);
    var tid = setInterval(function() {update(id)}, 3000);
  }

  update = function(id){
    $.getJSON("/apis/v3/answers?question_ids="+id+"&secret="+api_key+"&since="+last_updated,
    function(returned_data)
    {
      var answers = returned_data['answers'];
      total_responses += answers.length;
      $('#total_responses').text(total_responses);
      for (var i = 0; i < answers.length; i++) {
        var first = 0;
        var speed = 2000;
        var pause = 4000;
        $('#scroller').prepend('<tr><td>'+answers[i]['value']+'</td></tr>');
        $('#scroller tr:first').css('opacity', 0).slideDown(speed).animate({ opacity: 1 },{ queue: false, duration: 'slow' });
        $('#scroller tr:last').animate({opacity: 0}, speed).fadeOut('slow', function() {$(this).remove();});
        last_updated = Math.floor(new Date() / 1000);
      }
    });
  }

  function get_questions(id){
    $.getJSON("/apis/v3/questions?survey_id="+id+"&secret="+api_key,
    function(returned_data)
    {
      var questions = returned_data['questions'];
      for (var i = 0; i < questions.length; i++) {
        $('#lower').append('<div id="'+questions[i]["id"]+'" class="leftMenuItem lower"><div class="lower-check"></div>'+questions[i]['label']+'</div>');
      }
    });
  }
});
