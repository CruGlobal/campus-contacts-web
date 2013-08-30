$ ->
  $(document).ready ->
    $('#send_email_to').tokenInput "/contacts/auto_suggest_send_email.json",
      theme: 'facebook'
      preventDuplicates: true
      minChars: 3
      resultsLimit: 10
      hintText: "",
      placeHolder: $('#send_email_to').attr("data-search-desc"),
      defaultWidth: 690

    $('#send_text_to').tokenInput "/contacts/auto_suggest_send_text.json",
      theme: 'facebook'
      preventDuplicates: true
      minChars: 3
      resultsLimit: 10
      hintText: "",
      placeHolder: $('#send_text_to').attr("data-search-desc"),
      defaultWidth: 690

  $('a#survey_keywords_mode_link').siblings('ul').width(300)

  $("#survey_updated_from").datepicker dateFormat: "mm/dd/yy"
  $("#survey_updated_to").datepicker dateFormat: "mm/dd/yy"
  $("#archive_contacts_before").datepicker dateFormat: "yy-mm-dd"
  $("#date_leaders_not_logged_in_after").datepicker dateFormat: "yy-mm-dd"

  $(".field_with_errors").each ->
    $(this).children().eq(0).blur()

  $("select, input[type=text], input[type=password], input[type=email]").live "keypress", (e) ->
    false if e.which is 13

  $('#token-input-send_email_to').live 'blur', ->
    $(this).width(675)

  $('#token-input-send_email_to').live 'focus', ->
    if $(this).val() == ""
      $(this).width(675)

  $('#token-input-send_text_to').live 'blur', ->
    $(this).width(675)

  $('#token-input-send_text_to').live 'focus', ->
    if $(this).val() == ""
      $(this).width(675)

$.fn.cleanURL = (url)->
  values = url.split('?')
  url = values[0]
  if values.length > 1
    url += '?' + values[1].split('&').filter(String).join('&')
  return url

