$ ->
  $(document).on "click", ".remove_address_field", (e) ->
    e.preventDefault()
    parent = $(this).parents(".edit_address_fields")
    person_id = parent.parents("#edit_profile_address_list").attr("data-person-id")
    address_type_selection = parent.find(".selection_address_type")
    $("##{address_type_selection.attr('id').replace('address_type', 'id')}").remove()
    parent.remove()
    $.ensure_uniq_address_type()
    $.ajax
      type: 'GET',
      url: "/interactions/remove_address?address_type=#{address_type_selection.val()}&person_id=#{person_id}"

  $(document).on "change", ".selection_address_type", () ->
    $.ensure_uniq_address_type()

  $(document).on "click", "#add_address_button", (e) ->
    e.preventDefault()
    parent = $("#edit_profile_address_list")
    if parent.find(".selection_address_type").length >= 4
      $.a(t('interactions.addresses_limit'))
    else
      clone_address = parent.find(".edit_address_fields:last").clone()
      clone_address.find(":input").each ->
        @name = @name.replace(/\[(\d+)\]/, (str, p1) ->
          "[" + (parseInt(p1, 10) + 1) + "]"
        )
        @id = @id.replace(/\_(\d+)\_/, (str, p1) ->
          "[" + (parseInt(p1, 10) + 1) + "]"
        )
      parent.append(clone_address)
      $.clear_form_elements(clone_address)
      $.ensure_uniq_address_type()

  $(document).ready ->
    $.fn.tip()
    $.ensure_uniq_address_type()

  $('html').live 'click', (e)->
    $('.custom_dropdown').removeClass('active')

  $(":not(.tip)").live 'click', (e)->
    $('.qtip').hide()

  $('a').live 'click', (e)->
    $('.custom_dropdown').removeClass('active')

  $('.arrow.down').live 'click', (e)->
    e.stopPropagation()
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

  $('.custom_dropdown.select_one .option').live 'click', (e)->
    selected_name = $(this).attr('data-name')
    selected_id = $(this).attr('data-id')
    dropdown = $(this).parents('.custom_dropdown')
    dropdown.children('#selected').text(selected_name)
    dropdown.prev('input').val(selected_id)
    dropdown.removeClass('active')

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

  $(document).on 'click', '#interaction_new_record_button', (e)->
    e.preventDefault()
    $(this).parents('.interaction_new_buttons').first().hide()
    $('.feed_content .tab_content.profile_interactions .edit_space .feed_slug').text("New")
    $('.custom_dropdown').css('position','relative')
    $('.feed_content .tab_content.profile_interactions .edit_space').slideDown 'fast', ->
      $('.custom_dropdown').css('position','absolute')
    $('.interaction_field.more_option').hide()
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

$.hideScroll = () ->
  $("body").css "overflow", "hidden"

$.showDialog = (selector) ->
  selector.show()
  $.autoAdjustDialog(selector)
  $.hideScroll()

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


$.unhideScroll = () ->
  unless $(".custom_mh_popup_box").is(':visible')
    $("body").css "overflow", "auto"

$.hideDialog = (selector) ->
  selector.hide()
  $.unhideScroll()

$.ensure_uniq_address_type = () ->
  parent = $("#edit_profile_address_list")
  if parent.length > 0
    selected_types = []
    parent.find(".selection_address_type").each ->
      select = $(this)
      select_value = select.val()

      # form builder generating selected attribute, we should disregard it
      select.find("option").each ->
        $(this).removeAttr("selected")

      if jQuery.inArray(select_value, selected_types) < 0
        select.val(select_value)
        selected_types.push(select_value)
      else
        select.find("option").each ->
          option_value = $(this).val()
          if jQuery.inArray(option_value, selected_types) < 0
            select.val(option_value)
            selected_types.push(option_value)
            return false

    parent.find(".selection_address_type").each ->
      $(this).find("option").removeAttr("disabled")
    $.each selected_types, (index, value) ->
      parent.find(".selection_address_type option[value=" + value + "]").attr('disabled', 'disabled')
      return

$.clear_form_elements = (parent) ->
  $(parent).find(":input").each ->
    switch @type
      when "password", "text", "textarea", "file", "select-one", "select-multiple"
        $(this).val ""
      when "checkbox", "radio"
        @checked = false
    return
  return
