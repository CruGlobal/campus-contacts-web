$ ->
  $("#sms_keyword_post_survey_message, #sms_keyword_initial_response").counter
    goal: 140,
    count: 'up'

  $('#sms_keyword_form input[type=submit]').click ->
    unless $('#sms_keyword_initial_response').val().search(/\{\{\s*link\s*\}\}/) >= 0
      return false unless confirm("Warning! If you want people to enter your survey you MUST add {{ link }} to your message. Currently, {{ link }} is not in your message.")
    $('#sms_keyword_form')[0].submit()