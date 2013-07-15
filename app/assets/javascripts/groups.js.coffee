$ ->
  $('#check_all_groups').live 'click', (e)->
    $('.id_checkbox.group_checkbox').prop('checked',$(this).is(':checked'))
    $('.id_checkbox.group_checkbox').each ->
      group_class = $(this).attr('id')
      $('.id_checkbox.contact_checkbox.'+group_class).prop('checked',$(this).is(':checked'))

  $('.id_checkbox.group_checkbox').live 'click', (e)->
    group_class = $(this).attr('id')
    $('.id_checkbox.contact_checkbox.'+group_class).prop('checked',$(this).is(':checked'))

  $('#group_table .controls a.delete').live 'click', (e)->
    $(this).closest('tr').fadeOut()

  if $('#group_meeting_day')?
    $('#group_meeting_day').val($('#day_of_week').val())
  $('#group_meets').live 'change', ->
    meets = $(this).val()
    switch meets
      when "weekly"
        $('.regular').show()
        $('.day_of_month_div').hide()
        $('.day_of_week_div').show()
        $('#group_meeting_day').val($('#day_of_week').val())
      when "monthly"
        $('.regular').show()
        $('.day_of_week_div').hide()
        $('.day_of_month_div').show()
        $('#group_meeting_day').val($('#day_of_month').val())
      when 'sporadically'
        $('.regular').hide()
        $('#group_meeting_day').val('')

  $('#day_of_week').live 'change', ->
    $('#group_meeting_day').val($(this).val())

  $('#day_of_month').live 'change', ->
    $('#group_meeting_day').val($(this).val())

  $('#group_list_publicly').live 'change', ->
    if $('#group_list_publicly').prop('checked')
      $('.approve_join').show()
    else
      $('.approve_join').hide()

  $(".add_group_member, .add_group_leader").live "click", ->
    $("#role").val($(this).attr("data-role"))
    $('#member_search_title').html($(this).attr("data-desc"))
    $.showDialog($("#member_search_div"))
    $("#member_search_name").focus()
    $("#member_search_name").val("")
    #clear the search form group members
    $("#member_search_results").html("")
    false

  $('#member_search_name').autocomplete
    source: (request, response)->
      form = $('#member_search_form')
      $('#spinner_member_search').show()
      $.ajax
        url: form.attr('action'),
        data: form.serialize(),
        type: 'GET',
        success: (data)->
          $('#member_search_results').html(data) if $("#member_search_form").is(":visible")
          $("#member_search_results").show()
        complete: ->
          $('#spinner_member_search').hide()
        error: (xhr, status, error)->
          alert(error)
      response([])

  $('#add_new_person_group_button').live 'click', ->
    $.fn.show_add_contact()
    $(".remove_add_new_person_to_group, .explain").hide()
    name = $('#member_search_name').val().split(' ')
    $('#person_first_name').val(name[0])
    $('#person_last_name').val(name[1])
    false

$.mh.addNewGroupMemberContact = (add_more) ->
  form = $('#new_person')
  $("#add_person_group_div .explain").show()
  $("#add_contact_form").hide()
  if $('#person_first_name', form).val() == ''
    $.a(t('contacts.index.no_name_message'))
    return false
  $("#add_another").val(add_more)
  $("#add_to_group_tag").val(1)
  $("#add_to_group").val($("#add_to_group_id").val())
  $.rails.handleRemote(form)
  false

$.fn.showSearchBox = ->
  $("#member_search .explain_search, #member_search_form").show()
  $("#add_member_form, #member_search_results, #new_member_form").hide()
  $("#member_search_name").val("")
  $("#member_search").dialog
    resizable: false,
    height:488,
    width:600,
    modal: true,
    close: (event, ui) ->
      $("#add_contact_div").dialog("destroy")
    buttons: [
      text: t("application.add_contact.save_and_close"),
      "class": "add_new_person_group_member_butons hidden",
      click: ->
        $.mh.saveContact(false)
    ,
      text: t("application.add_contact.save_and_add"),
      "class": "add_new_person_group_member_butons hidden",
      click: ->
        $.mh.saveContact(true)
    ,
    text: "Cancel",
    click: ->
      $(this).dialog("destroy")
    ]
  false
