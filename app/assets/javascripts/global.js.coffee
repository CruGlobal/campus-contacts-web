$ ->
  $(document).ready ->
    if $('div.carea div.flash_message').length > 0
      $('div.carea div.flash_message').delay(5000).hide(1)

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

    get_url = $.url(window.location.href)
    assigned_to = get_url.param("assigned_to")
    label = get_url.param("label")
    permission = get_url.param("permission")
    archived = get_url.param("archived")
    dnc = get_url.param("dnc")
    include_archived_interactions = get_url.param("include_archived_interactions")
    include_archived_labels = get_url.param("include_archived_labels")

    if $('#sidebar_div').is(':visible')
      $.ajax
        type: 'GET',
        url: '/display_sidebar'
    else if $('#ac_sidebar').is(':visible')
      $.ajax
        type: 'GET',
        url: '/display_new_sidebar',
        data:
          assigned_to: assigned_to
          label: label
          permission: permission
          archived: archived
          dnc: dnc
          include_archived_interactions: include_archived_interactions
          include_archived_labels: include_archived_labels

  $('a#survey_keywords_mode_link').siblings('ul').width(300)

  $("#survey_updated_from").datepicker dateFormat: "mm/dd/yy"
  $("#survey_updated_to").datepicker dateFormat: "mm/dd/yy"
  $('#archive_contacts_before').datepicker dateFormat: "dd-mm-yy"

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
