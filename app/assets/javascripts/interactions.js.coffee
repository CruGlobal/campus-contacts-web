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
    $('#profile_labels_dialog .label_checkbox').prop('checked',false).prop('disabled',false)
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
            label_box.prop('checked',true)
            label_box.prop('disabled',true)

      # Disable Checked Unassigned Labels
      checked_labels = $('#profile_labels_dialog .label_checkbox:checked').map ->
        return $(this).attr('value')
      $.each checked_labels, (index, value) ->
        if $.inArray(value, contact_labels) < 0
          $('#profile_labels_dialog .label_checkbox[value='+value+']').prop('disabled',true)

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

$ ->
  $(document).ready ->
    $.fn.tip()

  $(document).live 'click', (e)->
    $('.custom_dropdown').removeClass('active')

  $(":not(.tip)").live 'click', (e)->
    $('.qtip').hide()

  $('a').live 'click', (e)->
    $('.custom_dropdown').removeClass('active')

  # START - ACTION MENU
  $('li a#action_menu_record_interaction').live 'click', (e)->
    e.preventDefault()
    $('li#interactions').click()
    $('#interaction_new_record_button').click()

  $('li #action_menu_assign_profile').live 'click', (e)->
    e.preventDefault()
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

  $('#action_menu_labels').live 'click', (e)->
    e.preventDefault()
    $.fn.openLabelsDialog()

  $('li #action_menu_permissions').live 'click', (e)->
    e.preventDefault()
    $.fn.openPermissionsDialog()
  # END - ACTION MENU

  $('.arrow.down').live 'click', (e)->
    $('.custom_dropdown').removeClass('active')
    $(this).parents('.custom_dropdown').addClass('active')

  $('.arrow.up').live 'click', (e)->
    $(this).parents('.custom_dropdown').removeClass('active')

  $('#assign_popup_save_button').live 'click', (e)->
    e.preventDefault()
    $('.profile_checkbox').prop('checked',true)
    $('#assign_to_button').click()

  $('#assign_popup_cancel_button').live 'click', (e)->
    e.preventDefault()
    $.hideDialog($("#assign_search"))

  $('#msg_popup_save_button').live 'click', (e)->
    e.preventDefault()
    $('#bulk_send_msg_dialog').submitBulkSendTextDialog()

  $('#default_leader_options.edit .option.unassigned input').live 'change', (e)->
    $('#assigned_to_dropdown.edit .option input.leader_box').prop('checked',false)
    $('#assigned_to_dropdown.edit .option input.unassigned_box').prop('checked',true)
    $('#assigned_to_id').val("0")
    $('#assigned_to_dropdown.edit #selected').text("Unassigned")

  $('#default_leader_options.edit .option.leader input').live 'change', (e)->
    $('#default_leader_options.edit .option.unassigned input').prop('checked',false)
    checked = $('#assigned_to_dropdown.edit .option input.leader_box:checked')
    checkbox = checked.eq(0)
    checked_count = checked.size()
    if checked_count == 0
      $('#assigned_to_dropdown.edit .option input.unassigned_box').prop('checked',true)
      value = "0"
      selected_name = "Unassigned"
    else if checked_count > 1
      value = checked.map ->
        return $(this).attr('data-id')
      value = value.get().join()
      selected_name = checked_count + " people selected"
    else
      value = checkbox.attr('data-id')
      selected_name = checkbox.siblings('.leader_name').text()
    $('#assigned_to_id').val(value)
    $('#assigned_to_dropdown.edit #selected').text(selected_name)


  $('#search_leader_results.edit .option.leader input').live 'change', (e)->
    if $(this).is(':checked')
      data_id = $(this).attr('data-id')
      if $('#default_leader_options.edit .option.leader[data-id=' + data_id + ']').size() == 0
        $('#default_leader_options.edit').append($(this).parents('.option'))
      else
        $(this).parents('.option').remove()
    $('#default_leader_options.edit .option.unassigned input').prop('checked',false)
    checked = $('#assigned_to_dropdown.edit .option input.leader_box:checked')
    checkbox = checked.eq(0)
    checked_count = checked.size()
    if checked_count == 0
      $('#assigned_to_dropdown.edit .option input.leader_box.unassigned_box').prop('checked',true)
      value = "0"
      selected_name = "Unassigned"
    else if checked_count > 1
      value = checked.map ->
        return $(this).attr('data-id')
      value = value.get().join()
      selected_name = checked_count + " people selected"
    else
      value = checkbox.attr('data-id')
      selected_name = checkbox.siblings('.leader_name').text()
    $('#assigned_to_id').val(value)
    $('#assigned_to_dropdown.edit #selected').text(selected_name)

  $('#search_leader_field.edit').live 'keyup', (e)->
    e.preventDefault()
    if $(this).val() == ""
      $(this).removeClass("ui-autocomplete-input ui-autocomplete-loading")
    if $(this).val().length > 2
      $(this).addClass("ui-autocomplete-input ui-autocomplete-loading")
      ids = []
      $("#default_leader_options.edit .option.leader").each ->
        ids.push($(this).attr('data-id'))
      ids = ids.join(",")
      $.ajax
        type: 'GET',
        url: '/interactions/search_leaders?keyword=' + $(this).val() + '&person_id=' + $(this).attr('data-person-id') + '&except=' + ids

  $('#followup_status_dropdown.view .option').live 'click', (e)->
    selected_name = $(this).attr('data-name')
    selected_id = $(this).attr('data-id')
    $('.followup_status_field_edit').val(selected_id)
    $('.followup_status_field_edit').change()
    $('#followup_status_dropdown.edit').removeClass('active')
    $('#followup_status_dropdown.view').removeClass('active')
    $('#followup_status_dropdown.edit #selected').text(selected_name)
    $('#followup_status_dropdown.view #selected').text(selected_name)
    $('#info_edit_save_button').click()

  $('#followup_status_dropdown.edit .option').live 'click', (e)->
    selected_name = $(this).attr('data-name')
    selected_id = $(this).attr('data-id')
    $('#followup_status_dropdown.edit #selected').text(selected_name)
    $('.followup_status_field_edit').val(selected_id)
    $('.followup_status_field_edit').change()
    $('#followup_status_dropdown.edit').removeClass('active')



  $('#nationality_dropdown.edit .option').live 'click', (e)->
    selected_name = $(this).attr('data-name')
    $('#nationality_dropdown #selected').text(selected_name)
    $('.nationality_field_edit').val(selected_name)
    $('.nationality_field_edit').change()
    $('#nationality_dropdown.edit').removeClass('active')

  $('#groups_popup_save_button').live 'click', (e)->
    e.preventDefault()
    ids = []
    $('.group_checkbox:checked').each ->
      ids.push($(this).val())
    ids = ids.join(',')
    $.hideDialog($("#profile_groups_dialog"))
    if ids != $('#groups_save').attr('data-current-group-ids')
      $.toggleLoader('profile_group_header','Applying Changes...')
      $.ajax
        type: 'GET',
        url: "/interactions/set_groups?person_id=" + $(this).attr('data-person-id') + "&ids=" + ids

  $('#show_profile_groups_button').live 'click', (e)->
    e.preventDefault()
    $.showDialog($("#profile_groups_dialog"))

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
      type: 'GET',
      url: "/interactions/set_permissions?people_ids=" + people_ids + "&permission_id=" + checked_permission_id,
      complete: ->
        $.fn.listCheckboxes()

  $('#labels_popup_save_button').live 'click', (e)->
    e.preventDefault()

    checked_label_ids = $('.label_checkbox:checked:not(:disabled)').map ->
      return $(this).val()
    if checked_label_ids.size() > 1
      checked_label_ids = checked_label_ids.get().join(',')
    else
      checked_label_ids = checked_label_ids[0]

    unchecked_label_ids = $('.label_checkbox:not(:checked):not(:disabled)').map ->
      return $(this).val()
    if unchecked_label_ids.size() > 1
      unchecked_label_ids = unchecked_label_ids.get().join(',')
    else
      unchecked_label_ids = unchecked_label_ids[0]

    people_ids = $('.contact_checkbox:checked').map ->
      return $(this).attr('data-id')
    if people_ids.size() > 1
      people_ids = people_ids.get().join(',')
    else
      people_ids = people_ids[0]

    $.hideDialog($("#profile_labels_dialog"))
    $.toggleLoader('profile_name','Applying Changes...')
    $.toggleLoader('ac_button_bar','Applying Changes...')
    $.ajax
      type: 'GET',
      url: "/interactions/set_labels?people_ids=" + people_ids + "&label_ids=" + checked_label_ids + "&remove_label_ids=" + unchecked_label_ids
      complete: ->
        $.fn.listCheckboxes()

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

  $('#all_feeds_paging_link').live 'click', (e)->
    e.preventDefault()
    $('#all_feed_paging').html("")
    $.toggleLoader('all_feed_paging','Loading...')
    $.ajax
      type: 'GET',
      url: "/interactions/load_more_all_feeds?person_id=" + $(this).attr("data-person-id") + "&next_page=" + $(this).attr("data-next-page")

  $('#interaction_paging_link').live 'click', (e)->
    e.preventDefault()
    $('#interaction_paging').html("")
    $.toggleLoader('interaction_paging','Loading...')
    $.ajax
      type: 'GET',
      url: "/interactions/load_more_interactions?person_id=" + $(this).attr("data-person-id") + "&last_id=" + $(this).attr("data-last-id")

  $('#search_receiver_results .option.receiver input').live 'change', (e)->
    if $(this).is(':checked')
      data_id = $(this).attr('data-id')
      if $('#default_receiver_options .option.receiver[data-id=' + data_id + ']').size() == 0
        $('#default_receiver_options').append($(this).parents('.option'))
      else
        $(this).parents('.option').remove()

  $('#search_initiator_results .option.initiator input').live 'change', (e)->
    if $(this).is(':checked')
      data_id = $(this).attr('data-id')
      if $('#default_initiator_options .option.initiator[data-id=' + data_id + ']').size() == 0
        $('#default_initiator_options').append($(this).parents('.option'))
      else
        $(this).parents('.option').remove()

  $('#search_initiator_field').live 'keyup', (e)->
    e.preventDefault()
    if $(this).val() == ""
      $(this).removeClass("ui-autocomplete-input ui-autocomplete-loading")
    if $(this).val().length > 2
      $(this).addClass("ui-autocomplete-input ui-autocomplete-loading")
      ids = []
      $("#default_initiator_options .option.initiator").each ->
        ids.push($(this).attr('data-id'))
      ids = ids.join(",")
      $.ajax
        type: 'GET',
        url: '/interactions/search_initiators?keyword=' + $(this).val() + '&person_id=' + $(this).attr('data-person-id') + '&except=' + ids

  $('#search_receiver_field').live 'keyup', (e)->
    e.preventDefault()
    if $(this).val().length > 2
      $(this).addClass("ui-autocomplete-input ui-autocomplete-loading")
      ids = []
      $("#default_receiver_options .option.receiver").each ->
        ids.push($(this).attr('data-id'))
      ids = ids.join(",")
      $.ajax
        type: 'GET',
        url: '/interactions/search_receivers?keyword=' + $(this).val() + '&person_id=' + $(this).attr('data-person-id') + '&except=' + ids


  $('.feed_box .edit_feed_icon').live 'click', (e)->
    if $('.feed_content .tab_content.profile_interactions .edit_space').is(':visible')
      $('.interaction_new').removeClass('shouldReload')
      $('#interaction_save_cancel_button').click()
    $('li#interactions').click()
    $('#interaction_new_record_button').parents('.interaction_new_buttons').first().hide();
    $.toggleLoader('profile_name','Loading Interaction...')
    $.ajax
      type: 'GET',
      url: '/interactions/show_edit_interaction_form?id=' + $(this).attr('data-id') + '&person_id=' + $(this).attr('data-person-id')

  $('#interaction_save_delete_button').live 'click', (e)->
    e.preventDefault()
    $.toggleLoader('profile_name','Deleting Interaction...')
    $.blur('.feed_content .feed_box.interaction_new')

    $('.feed_content .tab_content.profile_interactions .edit_space').hide()
    $('#all_feeds_container #interaction_feed_' + $(this).attr('data-interaction_id')).remove()
    $('#interaction_feeds_container #interaction_feed_container_' + $(this).attr('data-interaction_id')).remove()
    $('.interaction_new').addClass('shouldReload')
    $('#interaction_save_cancel_button').click()

  $('#interaction_save_save_button').live 'click', (e)->
    e.preventDefault()
    if $('form #interaction_type_field').val() == "1" && $('form #interaction_comment').val() == ""
      $.a("You cannot save blank comment on Comment Only interaction.")
    else
      $.toggleLoader('profile_name','Saving Interaction...')
      $.blur('.feed_content .feed_box.interaction_new')
      $(document).click()
      $('form#new_interaction_form').submit()

  $('#privacy_setting_dropdown .option').live 'click', (e)->
    selected_name = $(this).attr('data-name')
    selected_id = $(this).attr('data-id')
    $('#privacy_setting_dropdown #selected').text(selected_name)
    $('#privacy_setting_field').val(selected_id)
    $('#privacy_setting_dropdown').removeClass('active')

  $('#initiator_dropdown .option.initiator').live 'click', (e)->
    checkbox = $(this).children('input.initiator_box')
    if checkbox.is(':checked')
      checkbox.prop('checked',false)
    else
      checkbox.prop('checked',true)
    if $('input.initiator_box:checked').size() == 0
      checkbox.prop('checked',true)
    checkbox.change()
    if $('input.initiator_box:checked').size() > 1
      $('#initiator_dropdown #selected').text($('input.initiator_box:checked').size() + " people selected")
    else
      selected_name = $('input.initiator_box:checked').siblings('.initiator_name').text()
      $('#initiator_dropdown #selected').text(selected_name)

  $('#initiator_dropdown input.initiator_box').live 'click', (e)->
    $(this).parents('.option.initiator').click()

  $('#interaction_type_dropdown .option').live 'click', (e)->
    selected_name = $(this).attr('data-name')
    selected_id = $(this).attr('data-id')
    $('#interaction_type_dropdown #selected').text(selected_name)
    $('#interaction_type_field').val(selected_id)
    $('#interaction_type_dropdown').removeClass('active')

  $('#receiver_id_dropdown .option').live 'click', (e)->
    $('input.receiver_box').prop('checked',false)
    checkbox = $(this).children('input.receiver_box').eq(0)
    checkbox.prop('checked',true)
    selected_name = checkbox.siblings('.receiver_name').text()
    checkbox.change()
    $('#receiver_field').val($(this).children('input.receiver_box').eq(0).val())
    $('#receiver_id_dropdown #selected').text(selected_name )
    $('#receiver_id_dropdown').removeClass('active')

  $('#receiver_id_dropdown input.receiver_box').live 'click', (e)->
    $('input.receiver_box').prop('checked',false)
    $(this).prop('checked',true)
    $('#receiver_field').val($(this).val())
    name = $(this).siblings('.receiver_name').text()
    $('#receiver_id_dropdown #selected').text(name)
    $('#receiver_id_dropdown').removeClass('active')

  $('#assigned_to_dropdown, #receiver_id_dropdown, #interaction_type_dropdown, #initiator_dropdown, #privacy_setting_dropdown').live 'click', (e)->
    e.stopPropagation()

  $('#selected').live 'click', (e)->
    e.stopPropagation()
    unless $(this).parents('.custom_dropdown').first().hasClass('active')
      $('.custom_dropdown').removeClass('active')
      $(this).parents('.custom_dropdown').first().addClass('active')
      if $(this).parents('.custom_dropdown').hasClass('assigned_to_dropdown')
        selected = $(this).parents('.custom_dropdown').attr("data-current-id").split(",")
        for id in selected
          $("#leader_" + id).prop('checked',true)

  $('.interaction_field.more_div .more_options_link').live 'click', (e)->
    e.preventDefault()
    if $(this).hasClass('shown')
      $(this).removeClass('shown')
      $('.interaction_field.more_option').fadeOut()
      $(this).html('More Options &#x25BC;')
    else
      $('.interaction_field.more_option').fadeIn()
      $(this).addClass('shown')
      $(this).html('Fewer Options &#x25B2;')

  $('#interaction_save_cancel_button').live 'click', (e)->
    e.preventDefault()
    $('.interaction_new_buttons').show()
    $('.custom_dropdown').css('position','relative')
    $('.feed_content .tab_content.profile_interactions .edit_space').slideUp 'fast', ->
      $('.custom_dropdown').css('position','absolute')
      if $('.interaction_new').hasClass('shouldReload')
        $.ajax
          type: 'GET',
          url: '/interactions/show_new_interaction_form?person_id=' + $('#interaction_save_cancel_button').attr('data-person-id')

  $('#interaction_new_record_button').live 'click', (e)->
    e.preventDefault()
    $(this).parents('.interaction_new_buttons').first().hide()
    $('.feed_content .tab_content.profile_interactions .edit_space .feed_slug').text("New")
    $('.custom_dropdown').css('position','relative')
    $('.feed_content .tab_content.profile_interactions .edit_space').slideDown 'fast', ->
      $('.custom_dropdown').css('position','absolute')
    $('.interaction_field.more_option').hide()
    $('.interaction_field.more_div .more_options_link').html('More Options &#x25BC;')
    $('.interaction_field.more_div .more_options_link').removeClass('shown')
    $('#interaction_save_delete_button').hide()
    $('#interaction_comment').focus()

    # set privacy
    if $('#privacy_setting_dropdown').attr('data-current-id') == ""
      first_option = $('#privacy_setting_dropdown #togglable').children('.option').eq(0)
      default_id = first_option.attr('data-id')
      default_name = first_option.attr('data-name')
      $('#privacy_setting_dropdown #selected').html(default_name)
      $('#privacy_setting_field').val(default_id)

    # set initiator
    if $('#initiator_dropdown').attr('data-current-ids') == "[]"
      default_initiator_name = $('#initiator_dropdown').attr('data-default-name')
      default_initiator_id = $('#initiator_dropdown').attr('data-default-id')
      $('#initiator_dropdown #selected').html(default_initiator_name)
      $('#initiator_dropdown input.initiator_box').prop('checked',false)
      $("#initiator_dropdown input.initiator_box[value=" + default_initiator_id + "]").prop('checked',true)

    # set interaction_type
    if $('#interaction_type_dropdown').attr('data-current-id') == ""
      first_option = $('#interaction_type_dropdown #togglable').children('.option').eq(0)
      default_interaction_type_id = first_option.attr('data-id')
      default_interaction_type_name = first_option.attr('data-name')
      $('#interaction_type_dropdown #selected').html(default_interaction_type_name)
      $('#new_interaction_type').val(default_interaction_type_id)

    # set receiver id
    if $('#receiver_id_dropdown').attr('data-current-id') == ""
      default_receiver_name = $('#receiver_id_dropdown').attr('data-default-name')
      $('#receiver_id_dropdown #selected').html(default_receiver_name)
      $('input.receiver_box').prop('checked',false)
      default_receiver_id = $('#receiver_id_dropdown').attr('data-default-id')
      $('#receiver_field').val(default_receiver_id)
      $("input.receiver_box[value=" + default_receiver_id  + "]").prop('checked',true)

    $('.interaction_new #interaction_comment').val('')
    $('.interaction_new #datepicker').val($('meta#wiser_date').attr('data-server-datetime'))
    $('.interaction_new #datepicker').datetimepicker
      dateFormat: 'yy-mm-dd'
      timeFormat: 'HH:mm:ss'
      showSecond: false

  $('input.primary').live 'click', (e)->
    group_name = $(this).parents('.sfield').attr("data-group")
    $('input.primary.' + group_name).prop('checked',false)
    $(this).prop('checked',true)

  $('#info_display_edit_button').live 'click', (e)->
    e.preventDefault()
    $('.feed_content .tab_content.profile_info .view_space').hide()
    $('.feed_content .tab_content.profile_info .edit_space').fadeIn()


  $('#info_edit_cancel_button').live 'click', (e)->
    e.preventDefault()
    if $('.feed_content .tab_content.profile_info .edit_space').is(':visible')
      $.ajax
        type: 'GET',
        url: '/interactions/reset_edit_form?person_id=' + $(this).attr('data-person-id')
      $('.feed_content .tab_content.profile_info .edit_space').hide()
      $('.feed_content .tab_content.profile_info .view_space').fadeIn()

  $('#info_edit_save_button').live 'click', (e)->
    e.preventDefault()
    $('body').addClass("reload_info")
    $.toggleLoader('profile_name','Applying Changes...')
    $.blur('.feed_content .tab_content.profile_info .edit_space')
    $.blur('.feed_content .tab_content.profile_info .view_space')
    $('form#edit_profile_form').submit()


  # $('#followup_status').live 'change', (e)->
  #   if $(this).hasClass("followup_status_field_view")
  #     div_kind = 'view'
  #   else
  #     div_kind = 'edit'
  #     $.toggleLoader('profile_name','Saving Status...')
  #   $.ajax
  #     type: 'GET',
  #     url: '/interactions/change_followup_status.js?status=' + $(this).val() + '&person_id=' + $(this).attr('data-person-id')

  $("#profile_name #edit_profile_name_button").live 'click', (e)->
    e.preventDefault()
    $("#profile_name").hide()
    $("#profile_name_edit").show()

  $("#profile_name_buttons #profile_name_edit_cancel_button").live 'click', (e)->
    e.preventDefault()
    $("#profile_name").show()
    $("#profile_name_edit").hide()

  $("#profile_name_buttons #profile_name_edit_save_button").live 'click', (e)->
    e.preventDefault()
    new_name = $.trim($("#person_first_name").val() + " " + $("#person_last_name").val())
    old_name = $.trim($("#profile_name span#name").text())
    unless old_name == new_name
      $.toggleLoader('profile_name','Applying Changes...')
      $('#profile_name_edit #profile_name_form').submit()
      $("#profile_name span#name").text(new_name)
    $("#profile_name").show()
    $("#profile_name_edit").hide()

  $("#profile_feed #panel_nav li").live 'click', (e)->
    e.preventDefault()
    # close current opened
    unless $(this).attr('id') == 'interactions'
      $('#interaction_save_cancel_button').click()
    unless $(this).attr('id') == 'info'
      $('#info_edit_cancel_button').click()
    $("#profile_feed #panel_nav li").removeClass('current')
    $(this).addClass('current')
    $("#profile_feed .feed_content .tab_content").removeClass('current')
    $("#profile_feed .feed_content .tab_content.profile_" + $(this).attr('id')).addClass('current')

  $('#edit_profile_add_email_button').live 'click', (e)->
    e.preventDefault()
    stamp = e.timeStamp
    $('#edit_profile_email_list').append("<div class=\"edit_email_fields sfield\" data-group=\"email\"> <input id=\"person_email_addresses_new_"+stamp+"_email\" name=\"person[email_addresses_attributes]["+stamp+"][email]\" size=\"30\" type=\"text\" value=\"\"> <br> <input name=\"person[email_addresses_attributes]["+stamp+"][primary]\" type=\"hidden\" value=\"0\"><input class=\"primary email\" id=\"person_email_addresses_"+stamp+"_primary\" name=\"person[email_addresses_attributes]["+stamp+"][primary]\" type=\"checkbox\" value=\"1\"> <label for=\"person_email_addresses_"+stamp+"_primary\">Primary</label> </div>")

  $('#edit_profile_add_phone_button').live 'click', (e)->
    e.preventDefault()
    stamp = e.timeStamp
    $('#edit_profile_phone_list').append("<div class=\"edit_phone_fields sfield\" data-group=\"phone\"><input id=\"person_phone_numbers_"+stamp+"_number\" name=\"person[phone_numbers_attributes]["+stamp+"][number]\" size=\"30\" type=\"text\" value=\"\"><input id=\"person_phone_numbers_"+stamp+"__destroy\" name=\"person[phone_numbers_attributes]["+stamp+"][_destroy]\" type=\"hidden\" value=\"false\"><a href=\"#\" class=\"remove_field\" style=\"\"> </a><br><select id=\"person_phone_numbers_"+stamp+"_location\" name=\"person[phone_numbers_attributes]["+stamp+"][location]\"><option value=\"mobile\" selected=\"selected\">Cell</option><option value=\"home\">Home</option><option value=\"work\">Work</option></select><input name=\"person[phone_numbers_attributes]["+stamp+"][primary]\" type=\"hidden\" value=\"0\"> <input class=\"primary phone\" id=\"person_phone_numbers_"+stamp+"_primary\" name=\"person[phone_numbers_attributes]["+stamp+"][primary]\" type=\"checkbox\" value=\"1\"> <label for=\"person_phone_numbers_"+stamp+"_primary\">Primary</label></div>")


  $('#edit_profile_add_address_button').live 'click', (e)->
    e.preventDefault()
    stamp = e.timeStamp
    $('#edit_profile_address_list').append("<div class=\"edit_address_fields sfield\" data-group=\"address\"> <select id=\"person_addresses_"+stamp+"_address_type\" name=\"person[addresses_attributes]["+stamp+"][address_type]\"><option value=\"current\" selected=\"selected\">Current</option> <option value=\"permanent\">Permanent</option> <option value=\"emergency1\">Emergency 1</option> <option value=\"emergency2\">Emergency 2</option></select> <input id=\"person_addresses_"+stamp+"__destroy\" name=\"person[addresses_attributes]["+stamp+"][_destroy]\" type=\"hidden\" value=\"false\"><a href=\"#\" class=\"remove_field\" style=\"\"> </a> <div class=\"multi_line\"> <input id=\"person_addresses_"+stamp+"_address1\" name=\"person[addresses_attributes]["+stamp+"][address1]\" placeholder=\"Address Line 1\" size=\"30\" type=\"text\" value=\"\"> </div> <div class=\"multi_line\"> <input id=\"person_addresses_"+stamp+"_address2\" name=\"person[addresses_attributes]["+stamp+"][address2]\" placeholder=\"Address Line 2\" size=\"30\" type=\"text\" value=\"\"> </div> <div class=\"multi_line\"> <input id=\"person_addresses_"+stamp+"_address3\" name=\"person[addresses_attributes]["+stamp+"][address3]\" placeholder=\"Address Line 3\" size=\"30\" type=\"text\" value=\"\"> </div> <div class=\"multi_line\"> <input id=\"person_addresses_"+stamp+"_address4\" name=\"person[addresses_attributes]["+stamp+"][address4]\" placeholder=\"Address Line 4\" size=\"30\" type=\"text\" value=\"\"> </div> <div class=\"city multi_line\"> <label for=\"person_addresses_"+stamp+"_city\">City</label>:<input id=\"person_addresses_"+stamp+"_city\" name=\"person[addresses_attributes]["+stamp+"][city]\" size=\"30\" type=\"text\" value=\"\"> </div> <div class=\"state multi_line\"> <label for=\"person_addresses_"+stamp+"_state\">State</label>: <select id=\"person_addresses_"+stamp+"_state\" name=\"person[addresses_attributes]["+stamp+"][state]\"><option value=\"\"></option> <option value=\"AL\">Alabama</option> <option value=\"AK\">Alaska</option> <option value=\"AZ\">Arizona</option> <option value=\"AR\">Arkansas</option> <option value=\"CA\">California</option> <option value=\"CO\">Colorado</option> <option value=\"CT\">Connecticut</option> <option value=\"DE\">Delaware</option> <option value=\"DC\">District Of Columbia</option> <option value=\"FL\">Florida</option> <option value=\"GA\">Georgia</option> <option value=\"HI\">Hawaii</option> <option value=\"ID\">Idaho</option> <option value=\"IL\">Illinois</option> <option value=\"IN\">Indiana</option> <option value=\"IA\">Iowa</option> <option value=\"KS\">Kansas</option> <option value=\"KY\">Kentucky</option> <option value=\"LA\">Louisiana</option> <option value=\"ME\">Maine</option> <option value=\"MD\">Maryland</option> <option value=\"MA\">Massachusetts</option> <option value=\"MI\">Michigan</option> <option value=\"MN\">Minnesota</option> <option value=\"MS\">Mississippi</option> <option value=\"MO\">Missouri</option> <option value=\"MT\">Montana</option> <option value=\"NE\">Nebraska</option> <option value=\"NV\">Nevada</option> <option value=\"NH\">New Hampshire</option> <option value=\"NJ\">New Jersey</option> <option value=\"NM\">New Mexico</option> <option value=\"NY\">New York</option> <option value=\"NC\">North Carolina</option> <option value=\"ND\">North Dakota</option> <option value=\"OH\">Ohio</option> <option value=\"OK\">Oklahoma</option> <option value=\"OR\">Oregon</option> <option value=\"PA\">Pennsylvania</option> <option value=\"RI\">Rhode Island</option> <option value=\"SC\">South Carolina</option> <option value=\"SD\">South Dakota</option> <option value=\"TN\">Tennessee</option> <option value=\"TX\">Texas</option> <option value=\"UT\">Utah</option> <option value=\"VT\">Vermont</option> <option value=\"VA\">Virginia</option> <option value=\"WA\">Washington</option> <option value=\"WV\">West Virginia</option> <option value=\"WI\">Wisconsin</option> <option value=\"WY\">Wyoming</option> <option value=\"AS\">American Samoa</option> <option value=\"FM\">Federated States of Micronesia</option> <option value=\"GU\">Guam</option> <option value=\"MH\">Marshall Islands</option> <option value=\"MP\">Northern Mariana Islands</option> <option value=\"PW\">Palau</option> <option value=\"PR\">Puerto Rico</option> <option value=\"VI\">Virgin Islands</option> <option value=\"AA\">Armed Forces Americas (except Canada)</option> <option value=\"AE\">Armed Forces Europe, Canada, Africa, or Middle East</option> <option value=\"AP\">Armed Forces Pacific</option></select> </div> <div class=\"zip multi_line\"> <label for=\"person_addresses_"+stamp+"_zip\">Zip</label>:<input class=\"field_zip\" id=\"person_addresses_"+stamp+"_zip\" name=\"person[addresses_attributes]["+stamp+"][zip]\" size=\"30\" type=\"text\" value=\"\"> </div> <div class=\"country multi_line\"> <label for=\"person_addresses_"+stamp+"_country\">Country</label>: <select id=\"person_addresses_"+stamp+"_country\" name=\"person[addresses_attributes]["+stamp+"][country]\"><option value=\"US\" selected=\"selected\">United States</option> <option value=\"CA\">Canada</option> <option value=\"AF\">Afghanistan</option> <option value=\"AX\">Aland Islands</option> <option value=\"AL\">Albania</option> <option value=\"DZ\">Algeria</option> <option value=\"AS\">American Samoa</option> <option value=\"AD\">Andorra</option> <option value=\"AO\">Angola</option> <option value=\"AI\">Anguilla</option> <option value=\"AQ\">Antarctica</option> <option value=\"AG\">Antigua and Barbuda</option> <option value=\"AR\">Argentina</option> <option value=\"AM\">Armenia</option> <option value=\"AW\">Aruba</option> <option value=\"AC\">Ascension Island</option> <option value=\"AU\">Australia</option> <option value=\"AT\">Austria</option> <option value=\"AZ\">Azerbaijan</option> <option value=\"BS\">Bahamas</option> <option value=\"BH\">Bahrain</option> <option value=\"BD\">Bangladesh</option> <option value=\"BB\">Barbados</option> <option value=\"BY\">Belarus</option> <option value=\"BE\">Belgium</option> <option value=\"BZ\">Belize</option> <option value=\"BJ\">Benin</option> <option value=\"BM\">Bermuda</option> <option value=\"BT\">Bhutan</option> <option value=\"BO\">Bolivia</option> <option value=\"BQ\">Bonaire, Sint Eustatius and Saba</option> <option value=\"BA\">Bosnia and Herzegovina</option> <option value=\"BW\">Botswana</option> <option value=\"BV\">Bouvet Island</option> <option value=\"BR\">Brazil</option> <option value=\"IO\">British Indian Ocean Territory</option> <option value=\"BN\">Brunei Darussalam</option> <option value=\"BG\">Bulgaria</option> <option value=\"BF\">Burkina Faso</option> <option value=\"BI\">Burundi</option> <option value=\"KH\">Cambodia</option> <option value=\"CM\">Cameroon</option> <option value=\"CA\">Canada</option> <option value=\"CV\">Cape Verde</option> <option value=\"KY\">Cayman Islands</option> <option value=\"CF\">Central African Republic</option> <option value=\"TD\">Chad</option> <option value=\"CL\">Chile</option> <option value=\"CN\">China</option> <option value=\"CX\">Christmas Island</option> <option value=\"CC\">Cocos (Keeling) Islands</option> <option value=\"CO\">Colombia</option> <option value=\"KM\">Comoros</option> <option value=\"CG\">Congo</option> <option value=\"CD\">Congo, the Democratic Republic of the</option> <option value=\"CK\">Cook Islands</option> <option value=\"CR\">Costa Rica</option> <option value=\"CI\">Côte d'Ivoire</option> <option value=\"HR\">Croatia</option> <option value=\"CU\">Cuba</option> <option value=\"CW\">Curaçao</option> <option value=\"CY\">Cyprus</option> <option value=\"CZ\">Czech Republic</option> <option value=\"DK\">Denmark</option> <option value=\"DJ\">Djibouti</option> <option value=\"DM\">Dominica</option> <option value=\"DO\">Dominican Republic</option> <option value=\"EC\">Ecuador</option> <option value=\"EG\">Egypt</option> <option value=\"SV\">El Salvador</option> <option value=\"GQ\">Equatorial Guinea</option> <option value=\"ER\">Eritrea</option> <option value=\"EE\">Estonia</option> <option value=\"ET\">Ethiopia</option> <option value=\"FK\">Falkland Islands (Malvinas)</option> <option value=\"FO\">Faroe Islands</option> <option value=\"FJ\">Fiji</option> <option value=\"FI\">Finland</option> <option value=\"FR\">France</option> <option value=\"GF\">French Guiana</option> <option value=\"PF\">French Polynesia</option> <option value=\"TF\">French Southern Territories</option> <option value=\"GA\">Gabon</option> <option value=\"GM\">Gambia</option> <option value=\"GE\">Georgia</option> <option value=\"DE\">Germany</option> <option value=\"GH\">Ghana</option> <option value=\"GI\">Gibraltar</option> <option value=\"GR\">Greece</option> <option value=\"GL\">Greenland</option> <option value=\"GD\">Grenada</option> <option value=\"GP\">Guadeloupe</option> <option value=\"GU\">Guam</option> <option value=\"GT\">Guatemala</option> <option value=\"GG\">Guernsey</option> <option value=\"GN\">Guinea</option> <option value=\"GW\">Guinea-Bissau</option> <option value=\"GY\">Guyana</option> <option value=\"HT\">Haiti</option> <option value=\"HM\">Heard Island and Mcdonald Islands</option> <option value=\"VA\">Holy See (Vatican City State)</option> <option value=\"HN\">Honduras</option> <option value=\"HK\">Hong Kong</option> <option value=\"HU\">Hungary</option> <option value=\"IS\">Iceland</option> <option value=\"IN\">India</option> <option value=\"ID\">Indonesia</option> <option value=\"IR\">Iran, Islamic Republic of</option> <option value=\"IQ\">Iraq</option> <option value=\"IE\">Ireland</option> <option value=\"IM\">Isle of Man</option> <option value=\"IL\">Israel</option> <option value=\"IT\">Italy</option> <option value=\"JM\">Jamaica</option> <option value=\"JP\">Japan</option> <option value=\"JE\">Jersey</option> <option value=\"JO\">Jordan</option> <option value=\"KZ\">Kazakhstan</option> <option value=\"KE\">Kenya</option> <option value=\"KI\">Kiribati</option> <option value=\"KP\">Korea, Democratic People's Republic of</option> <option value=\"KR\">Korea, Republic of</option> <option value=\"KV\">Kosovo</option> <option value=\"KW\">Kuwait</option> <option value=\"KG\">Kyrgyzstan</option> <option value=\"LA\">Lao People's Democratic Republic</option> <option value=\"LV\">Latvia</option> <option value=\"LB\">Lebanon</option> <option value=\"LS\">Lesotho</option> <option value=\"LR\">Liberia</option> <option value=\"LY\">Libya</option> <option value=\"LI\">Liechtenstein</option> <option value=\"LT\">Lithuania</option> <option value=\"LU\">Luxembourg</option> <option value=\"MO\">Macao</option> <option value=\"MK\">Macedonia, Republic of</option> <option value=\"MG\">Madagascar</option> <option value=\"MW\">Malawi</option> <option value=\"MY\">Malaysia</option> <option value=\"MV\">Maldives</option> <option value=\"ML\">Mali</option> <option value=\"MT\">Malta</option> <option value=\"MH\">Marshall Islands</option> <option value=\"MQ\">Martinique</option> <option value=\"MR\">Mauritania</option> <option value=\"MU\">Mauritius</option> <option value=\"YT\">Mayotte</option> <option value=\"MX\">Mexico</option> <option value=\"FM\">Micronesia, Federated States of</option> <option value=\"MD\">Moldova, Republic of</option> <option value=\"MC\">Monaco</option> <option value=\"MN\">Mongolia</option> <option value=\"ME\">Montenegro</option> <option value=\"MS\">Montserrat</option> <option value=\"MA\">Morocco</option> <option value=\"MZ\">Mozambique</option> <option value=\"MM\">Myanmar</option> <option value=\"NA\">Namibia</option> <option value=\"NR\">Nauru</option> <option value=\"NP\">Nepal</option> <option value=\"NL\">Netherlands</option> <option value=\"AN\">Netherlands Antilles</option> <option value=\"NC\">New Caledonia</option> <option value=\"NZ\">New Zealand</option> <option value=\"NI\">Nicaragua</option> <option value=\"NE\">Niger</option> <option value=\"NG\">Nigeria</option> <option value=\"NU\">Niue</option> <option value=\"NF\">Norfolk Island</option> <option value=\"MP\">Northern Mariana Islands</option> <option value=\"NO\">Norway</option> <option value=\"OM\">Oman</option> <option value=\"PK\">Pakistan</option> <option value=\"PW\">Palau</option> <option value=\"PS\">Palestinian Territory, Occupied</option> <option value=\"PA\">Panama</option> <option value=\"PG\">Papua New Guinea</option> <option value=\"PY\">Paraguay</option> <option value=\"PE\">Peru</option> <option value=\"PH\">Philippines</option> <option value=\"PN\">Pitcairn</option> <option value=\"PL\">Poland</option> <option value=\"PT\">Portugal</option> <option value=\"PR\">Puerto Rico</option> <option value=\"QA\">Qatar</option> <option value=\"RE\">Reunion</option> <option value=\"RO\">Romania</option> <option value=\"RU\">Russian Federation</option> <option value=\"RW\">Rwanda</option> <option value=\"BL\">Saint Barthelemy</option> <option value=\"SH\">Saint Helena</option> <option value=\"KN\">Saint Kitts and Nevis</option> <option value=\"LC\">Saint Lucia</option> <option value=\"MF\">Saint Martin (French Part)</option> <option value=\"PM\">Saint Pierre and Miquelon</option> <option value=\"VC\">Saint Vincent and the Grenadines</option> <option value=\"WS\">Samoa</option> <option value=\"SM\">San Marino</option> <option value=\"ST\">Sao Tome and Principe</option> <option value=\"SA\">Saudi Arabia</option> <option value=\"SN\">Senegal</option> <option value=\"RS\">Serbia</option> <option value=\"SC\">Seychelles</option> <option value=\"SL\">Sierra Leone</option> <option value=\"SG\">Singapore</option> <option value=\"SX\">Sint Maarten (Dutch part)</option> <option value=\"SK\">Slovakia</option> <option value=\"SI\">Slovenia</option> <option value=\"SB\">Solomon Islands</option> <option value=\"SO\">Somalia</option> <option value=\"ZA\">South Africa</option> <option value=\"GS\">South Georgia and the South Sandwich Islands</option> <option value=\"SS\">South Sudan, Republic of</option> <option value=\"ES\">Spain</option> <option value=\"LK\">Sri Lanka</option> <option value=\"SD\">Sudan</option> <option value=\"SR\">Suriname</option> <option value=\"SJ\">Svalbard and Jan Mayen</option> <option value=\"SZ\">Swaziland</option> <option value=\"SE\">Sweden</option> <option value=\"CH\">Switzerland</option> <option value=\"SY\">Syrian Arab Republic</option> <option value=\"TW\">Taiwan</option> <option value=\"TJ\">Tajikistan</option> <option value=\"TZ\">Tanzania, United Republic of</option> <option value=\"TH\">Thailand</option> <option value=\"TL\">Timor-Leste</option> <option value=\"TG\">Togo</option> <option value=\"TK\">Tokelau</option> <option value=\"TO\">Tonga</option> <option value=\"TT\">Trinidad and Tobago</option> <option value=\"TA\">Tristan da Cunha</option> <option value=\"TN\">Tunisia</option> <option value=\"TR\">Turkey</option> <option value=\"TM\">Turkmenistan</option> <option value=\"TC\">Turks and Caicos Islands</option> <option value=\"TV\">Tuvalu</option> <option value=\"UG\">Uganda</option> <option value=\"UA\">Ukraine</option> <option value=\"AE\">United Arab Emirates</option> <option value=\"GB\">United Kingdom</option> <option value=\"US\">United States</option> <option value=\"UM\">United States Minor Outlying Islands</option> <option value=\"UY\">Uruguay</option> <option value=\"UZ\">Uzbekistan</option> <option value=\"VU\">Vanuatu</option> <option value=\"VE\">Venezuela</option> <option value=\"VN\">Viet Nam</option> <option value=\"VG\">Virgin Islands, British</option> <option value=\"VI\">Virgin Islands, U.S.</option> <option value=\"WF\">Wallis and Futuna</option> <option value=\"EH\">Western Sahara</option> <option value=\"YE\">Yemen</option> <option value=\"ZM\">Zambia</option> <option value=\"ZW\">Zimbabwe</option></select> </div> </div>")

$.hideScroll = () ->
  $("body").css "overflow", "hidden"

$.showDialog = (selector) ->
  selector.show()
  $.hideScroll()

$.unhideScroll = () ->
  unless $(".custom_mh_popup_box").is(':visible')
    $("body").css "overflow", "auto"

$.hideDialog = (selector) ->
  selector.hide()
  $.unhideScroll()
