$ ->
  # START - ACTION MENU
  $('li a#action_menu_back').live 'click', (e)->
    e.preventDefault()
    window.history.back()

  $('li a#action_menu_record_interaction').live 'click', (e)->
    e.preventDefault()
    $('#panel_nav li#interactions').click()
    $('#interaction_new_record_button').click()

  $('li #action_menu_assign_profile').live 'click', (e)->
    e.preventDefault()
    $('#panel_nav li#info').click()
    $("#info_display_edit_button").click()

  $('li #action_menu_assign').live 'click', (e)->
    e.preventDefault()
    $('.profile_checkbox').prop('checked',true)
    if $('.id_checkbox:checked').length > 0
      $('#keep_contact').attr checked: true
      $('#assign_to_me').click()
      if $("#assign_search").hasClass('should_reload')
        $("#assign_search #assign_search_loader").show()
        $("#assign_search #mh_popup_box_content").hide()
        $("#assign_search #assign_save").hide()
        $.ajax
          type: 'GET',
          url: '/show_assign_search'
      $.showDialog($("#assign_search"))
    else
      $.a(t('contacts.index.none_checked'))

  $('#action_menu_change').live 'click', (e)->
    e.preventDefault()
    if $('.id_checkbox:checked').length > 0
      selected_ids = $(".id_checkbox:checked").map ->
        return $(this).data('id')
      .get().join(",")
      $('#bulk_change_form #people_ids').val(selected_ids)
      $.showDialog($("#bulk_change_info_dialog"))
      $('.custom_dropdown').each ->
        selected = $(this).data('default') || 'Select Status'
        $(this).find('#selected').text(selected)
        $(this).find('.custom_dropdown_value').val('')
      $('#bulk_change_form').find('input[type=radio], input[type=checkbox]').prop('checked',false)
    else
      $.a(t('contacts.index.none_checked'))

  $('#action_menu_labels').live 'click', (e)->
    e.preventDefault()
    $.fn.openLabelsDialog()

  $('li #action_menu_permissions').live 'click', (e)->
    e.preventDefault()
    $.fn.openPermissionsDialog()

  # END - ACTION MENU

  $('#permissions_popup_save_button').live 'click', (e)->
    e.preventDefault()
    checked_permission_id = $('.permissions_chooser_box .permission_checkbox:checked').val()
    people_ids = $('.contact_checkbox:checked').map ->
      return $(this).attr('data-id')
    if people_ids.size() > 1
      people_ids = people_ids.get().join(',')
    else
      people_ids = people_ids[0]

    $.hideDialog($("#profile_permissions_dialog"))
    $.toggleLoader('profile_name','Applying Changes...')
    $.toggleLoader('ac_button_bar','Applying Changes...')
    $.ajax
      type: 'POST',
      url: "/contacts/set_permissions?people_ids=" + people_ids + "&permission_id=" + checked_permission_id,
      complete: ->
        $.fn.listCheckboxes()

  $('#labels_popup_save_button').live 'click', (e)->
    e.preventDefault()

    arr_checked_label_ids = $('.label_checkbox:checked:not(:disabled)').map ->
      return $(this).val()
    checked_label_ids = arr_checked_label_ids.get().join(',')

    arr_unchecked_label_ids = $('.label_checkbox:not(:checked):not(:disabled)').map ->
      return $(this).val()
    unchecked_label_ids = arr_unchecked_label_ids.get().join(',')

    arr_unchanged_label_ids = $('.label_checkbox:indeterminate').map ->
      return $(this).val()
    unchanged_label_ids = arr_unchanged_label_ids.get().join(',')

    arr_people_ids = $('.contact_checkbox:checked').map ->
      return $(this).attr('data-id')
#    people_ids = arr_people_ids.get().join(',')

    $.hideDialog($("#profile_labels_dialog"))
    from_all_contacts = $(".contact_listing").length
    if from_all_contacts > 0
      $.fn.filterLoader("show", "Saving changes")
    else
      $.toggleLoader('profile_name','Applying Changes...')

    labels_processed = 0
    people_sent = 0
    per_loop = 400
    add_labels_error = false
    while people_sent < arr_people_ids.length
      $.ajax(
        type: "POST"
        url: "/contacts/set_labels"
        data:
          people_ids: arr_people_ids.slice(people_sent, people_sent + per_loop).get().join(',')
          label_ids: checked_label_ids
          remove_label_ids: unchecked_label_ids
          unchanged_label_ids: unchanged_label_ids
          from_all_contacts: from_all_contacts
      ).success (data) ->
        labels_processed += per_loop
        return if add_labels_error
        if arr_people_ids.length <= labels_processed
          $.fn.filterLoader("force")
          $.fn.listCheckboxes()
        else
          $.fn.filterLoader("show", "Labels: #{labels_processed} out of #{arr_people_ids.length} contacts were updated.")
      .error (xhr, textStatus, error) ->
        add_labels_error = true
        $.fn.filterLoader("show", "Error saving contact, please refresh the page and try again.")
      people_sent += per_loop

  $('#labels_add_new_button').live 'click', (e)->
    e.preventDefault()
    new_label_name = $.trim($('#labels_new_input').val())
    if new_label_name  != ""
      $('#labels_notice').text("")
      $.toggleLoader('labels_notice','Adding Label...')
      $.ajax
        type: 'GET',
        url: "/interactions/create_label?name=" + escape(new_label_name )
    else
      $.toggleLoader('labels_notice','')

  $('#show_profile_labels_button').live 'click', (e)->
    e.preventDefault()
    $.showDialog($("#profile_labels_dialog"))

$.fn.tip = () ->
  $('.tip').qtip({position: {my: 'bottom center', at: 'top center'}, style: {classes: 'qtip-blue qtip-shadow'}})
  $('.tipitleft').qtip({position: {my: 'center right', at: 'center left'}, style: {classes: 'qtip-blue qtip-shadow'}})
  $('.tipitright').qtip({position: {my: 'top left', at: 'bottom right'}, style: {classes: 'qtip-blue qtip-shadow'}})

$.fn.openLabelsDialog = () ->
  $('.contact_checkbox.profile_checkbox').prop('checked',true)
  if $('.contact_checkbox:checked').size() == 0
    $.a(t('contacts.index.none_checked'))
  else
    if $('.contact_checkbox:checked').size() == 1
      displayed_text = $('.contact_checkbox:checked').first().attr('data-name')
    else
      displayed_text = $('.contact_checkbox:checked').size() + " selected people"
    $('#profile_labels_dialog .selected_contacts_name').text(displayed_text)
    $('#labels_chooser_box').scrollTop(0)
    $('#profile_labels_dialog .label_checkbox').prop('checked',false).prop('disabled',false).prop('indeterminate',false)
    contact_ctr = 0
    $('.contact_checkbox:checked').each ->
      contact_ctr += 1
      contact_labels = $(this).attr('data-labels').split(',')

      # Check Assigned Labels
      $.each contact_labels, (index, value) ->
        label_box = $('#profile_labels_dialog .label_checkbox[value='+value+']')
        if contact_ctr == 1
          label_box.prop('checked',true)
        else
          unless label_box.is(':checked')
            label_box.prop('indeterminate',true)

      # Disable Checked Unassigned Labels
      checked_labels = $('#profile_labels_dialog .label_checkbox:checked').map ->
        return $(this).attr('value')
      $.each checked_labels, (index, value) ->
        if $.inArray(value, contact_labels) < 0
          $('#profile_labels_dialog .label_checkbox[value='+value+']').prop('indeterminate',true)

    $.showDialog($("#profile_labels_dialog"))

$.fn.openPermissionsDialog = () ->
  $('.contact_checkbox.profile_checkbox').prop('checked',true)
  valid_leader = true
  $('.contact_checkbox:checked').each ->
    valid_leader = false if $(this).attr('data-email') == ""
  if $('.contact_checkbox:checked').size() == 0
    $.a(t('contacts.index.none_checked'))
  else
    if !valid_leader
      $.a(t('contacts.index.not_valid_leader_selected'))
      $('input#permissions_ids__4, input#permissions_ids__1').prop('disabled',true)
      $('input#permissions_ids__4, input#permissions_ids__1').prop('checked',false)
    else
      $('input#permissions_ids__4, input#permissions_ids__1').prop('disabled',false)
    $('#profile_permissions_dialog .permission_checkbox').prop('checked',false)
    if $('.contact_checkbox:checked').size() == 1
      displayed_text = $('.contact_checkbox:checked').first().attr('data-name')
    else
      displayed_text = $('.contact_checkbox:checked').size() + " selected people"
    $('#profile_permissions_dialog .selected_contacts_name').text(displayed_text)

    contact_ctr = 0
    $('.contact_checkbox:checked').each ->
      contact_ctr += 1
      contact_permission_id = $(this).attr('data-permissions').toString()

      permission_box = $('#profile_permissions_dialog .permission_checkbox[value='+contact_permission_id+']')
      if contact_ctr == 1
        permission_box.prop('checked',true)
      else
        unless permission_box.is(':checked')
          $('#profile_permissions_dialog .permission_checkbox').prop('checked',false)

    $.showDialog($("#profile_permissions_dialog"))

