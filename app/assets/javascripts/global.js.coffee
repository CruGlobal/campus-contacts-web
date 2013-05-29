$ ->
  $(document).ready ->
    if $('div.carea div.flash_message').length > 0
      $('div.carea div.flash_message').delay(5000).hide(1)

    $('#send_email_to').tokenInput "/contacts/auto_suggest_send_email.json",
      theme: 'facebook'
      preventDuplicates: true
      minChars: 3
      resultsLimit: 10
      hintText: $('#send_email_to').attr("data-search-desc"),
      placeHolder: $('#send_email_to').attr("data-search-desc"),
      defaultWidth: 690

    $('#send_text_to').tokenInput "/contacts/auto_suggest_send_text.json",
      theme: 'facebook'
      preventDuplicates: true
      minChars: 3
      resultsLimit: 10
      hintText: $('#send_text_to').attr("data-search-desc"),
      placeHolder: $('#send_text_to').attr("data-search-desc"),
      defaultWidth: 690

    include_archived = $.url(window.location.href).param("include_archived")
    if include_archived
      sidebar_url = '/display_sidebar?include_archived=' + include_archived
    else
      sidebar_url = '/display_sidebar'
    if $('#sidebar_div').is(':visible')
      $.ajax
        type: 'GET',
        url: sidebar_url

  $('a#survey_keywords_mode_link').siblings('ul').width(300)

  $("#survey_updated_from").datepicker dateFormat: "mm/dd/yy"
  $("#survey_updated_to").datepicker dateFormat: "mm/dd/yy"
  $('#archive_contacts_before').datepicker dateFormat: "dd-mm-yy"

  $(".field_with_errors").each ->
    $(this).children().eq(0).blur()

  $("select, input[type=text], input[type=password], input[type=email]").live "keypress", (e) ->
    false if e.which is 13

  $('#bulk_send_msg_dialog').dialog
    resizable: false,
    height:444,
    width:730,
    modal: true,
    draggable: false,
    autoOpen: false,
    open: (event, ui) ->
      $.hideScroll()
    close: (event, ui) ->
      $.unhideScroll()
    buttons:
      Send: ->
        $(this).submitBulkSendTextDialog()
      Cancel: ->
        $(this).dialog('close')
