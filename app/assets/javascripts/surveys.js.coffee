$ ->
  $('#survey_background_color, #survey_text_color').excolor({root_path: '/assets/'})
  false

  $('#show_advanced_survey_option').live 'click', ()->
  	$('#advanced_survey_option').toggle()
  	if($('#advanced_survey_option').is(":visible"))
  		$(this).html($(this).html().replace("Show","Hide"))
  	else
  		$(this).html($(this).html().replace("Hide","Show"))
  	end

  $('#transfer_survey_div').dialog
    resizable: false,
    height: 400,
    width: 550,
    title: "Copy Survey to another Organization",
    autoOpen: false,
    draggable: true,
    modal: true,
    open: (event, ui) ->
      $("body").css({ overflow: 'hidden' })
      $('.ui-widget-overlay').width('100%');
    close: (event, ui) ->
      $("body").css({ overflow: 'inherit' })
    buttons:
      Close: ->
        $(this).dialog('close')

  $('#transfer_survey_content #other_orgs_list .other_org').live 'click', ->
    org_id = $(this).attr('data-org-id')
    org_name = $(this).attr('data-org-name')
    survey_id = $('#transfer_survey_div').attr('data-survey-id')
    survey_name = $('#transfer_survey_div').attr('data-survey-name')
    if(confirm('Are you sure you want to copy ' + survey_name + ' to ' + org_name + ' organization?'))
      $('#transfer_survey_div #transfer_survey_processing #org_name').text(org_name)
      $('#transfer_survey_div #transfer_survey_content').hide()
      $('#transfer_survey_div #transfer_survey_error').hide()
      $('#transfer_survey_div #transfer_survey_processing').show()
      $.ajax
        type: 'GET',
        url: '/copy_survey?survey_id=' + survey_id + '&organization_id=' + org_id

  $('a.transfer_survey').live 'click', (e)->
    e.preventDefault()
    survey_id = $(this).attr('data-id')
    survey_name = $(this).attr('data-name')
    $('#transfer_survey_div #transfer_survey_guide #survey_name').text($(this).attr('data-name'))
    $('#transfer_survey_div').attr('data-survey-id',survey_id)
    $('#transfer_survey_div').attr('data-survey-name',survey_name)
    $('#transfer_survey_div').dialog('open')
    $('#transfer_survey_div #transfer_survey_processing').hide()
    $('#transfer_survey_div #transfer_survey_error').hide()
    $('#transfer_survey_div #transfer_survey_content').show()
    $("#other_orgs_filter_keyword").removeClass("ui-autocomplete-loading")
    $("#other_orgs_filter_keyword").val("")
    $("#other_orgs_filter_keyword").focus()
    $(".other_org").remove()

  $('#other_orgs_filter_keyword').live 'keyup', ->
    $('#transfer_survey_div #transfer_survey_processing').hide()
    $('#transfer_survey_div #transfer_survey_error').hide()

    keyword = $(this).val().toLowerCase()
    if keyword.length >= 3
      $(this).addClass("ui-autocomplete-loading")
      window.setTimeout (->
        $.ajax
          type: 'GET',
          url: '/show_other_orgs?keyword=' + encodeURIComponent(keyword)
      ), 1000
    else if keyword.length == 0
      $(".other_org").remove()
      $(this).removeClass("ui-autocomplete-loading")