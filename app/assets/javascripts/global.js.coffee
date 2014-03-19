$ ->
  $(window).resize ->
    active_dialog = $(".mh_popup_box:visible")
    $.autoAdjustDialog(active_dialog.first().parents(".custom_mh_popup_box"))

  $(document).ready ->
    $(".mh_popup_box").each ->
      $.autoAdjustDialog($(this))

    $('#send_email_to').tokenInput "/contacts/auto_suggest_send_email.json",
      theme: 'facebook'
      preventDuplicates: true
      minChars: 3
      resultsLimit: 10
      hintText: "",
      placeHolder: $('#send_email_to').attr("data-search-desc")

    $('#send_text_to').tokenInput "/contacts/auto_suggest_send_text.json",
      theme: 'facebook'
      preventDuplicates: true
      minChars: 3
      resultsLimit: 10
      hintText: "",
      placeHolder: $('#send_text_to').attr("data-search-desc")

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


$.unhideScroll = () ->
  unless $(".custom_mh_popup_box").is(':visible')
    $("body").css "overflow", "auto"

$.hideScroll = () ->
  $("body").css "overflow", "hidden"

$.showDialog = (selector) ->
  selector.show()
  $.autoAdjustDialog(selector)
  $.hideScroll()

$.hideDialog = (selector) ->
  selector.hide()
  $.unhideScroll()

$.autoAdjustDialog = (selector) ->
  default_width = selector.data('width') || 500
  box = selector.find(".mh_popup_box")
  box.width(default_width)
  if box.width() >= $(window).width()
    new_width = $(window).width() - 20
  else
    new_width = default_width
  box.width(new_width)

  box.css({"margin": "10px auto"})
  box.find("input").each ->
    parent_width = box.find(".mh_popup_box_scroller").width()
    $(this).width(parent_width - $(this).css("padding-left"))
  box.find(".mh_popup_buttons").width(new_width - 10)
  box.find(".assign_save").width(new_width - 10)


  token_inputs = box.find(".token-input-list-facebook")
  if token_inputs.size() > 0
    token_inputs.each ->
      if $(this).is(":visible")
        $(this).width("100%")
        new_width = $(this).width()
        $(this).find(".token-input-input-token-facebook").width(new_width)
        $(".token-input-dropdown-facebook").width(new_width)