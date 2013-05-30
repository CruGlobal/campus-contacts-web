$ ->
  
  $(document).live 'click', (e)->
    $('#receiver_id_dropdown, #interaction_type_dropdown, #initiator_dropdown, #privacy_setting_dropdown, #followup_status_dropdown.edit, #followup_status_dropdown.view, #assigned_to_dropdown').removeClass('active')
    
  $('a').live 'click', (e)->
    $('#receiver_id_dropdown, #interaction_type_dropdown, #initiator_dropdown, #privacy_setting_dropdown, #followup_status_dropdown.edit, #followup_status_dropdown.view, #assigned_to_dropdown').removeClass('active')
    
  # START - ACTION MENU
  $('li a#action_menu_record_interaction').live 'click', (e)->
    e.preventDefault()
    $('li#interactions').click()
    $('#interaction_new_record_button').click()

  $('li #action_menu_assign').live 'click', (e)->
    e.preventDefault()
    if $('.id_checkbox:checked').length > 0
      $('#keep_contact').attr checked: true
      $('#assign_to_me').click()
      el = $('#assign_search')
      el.dialog
        resizable: false,
        height:500,
        width:450,
        modal: true,
        open: (event, ui) ->
          $.hideScroll()
        close: (event, ui) ->
          $.unhideScroll()
        buttons:
          Cancel: ->
            $(this).dialog('close')
            $(this).dialog('destroy')
    else
      $.a(t('contacts.index.none_checked'))
    
  $('li #action_menu_labels').live 'click', (e)->
    e.preventDefault()
    $.showDialog($("#profile_labels_dialog"))
    
  $('li #action_menu_roles').live 'click', (e)->
    e.preventDefault()
    $.showDialog($("#profile_roles_dialog"))
  # END - ACTION MENU
  
  $('#assigned_to_dropdown .option').live 'click', (e)->
    $('input.leader_box').prop('checked',false)
    checkbox = $(this).children('input.leader_box').eq(0)
    checkbox.prop('checked',true)
    selected_name = checkbox.siblings('.leader_name').text()
    checkbox.change()
    $('#assigned_to_id').val(checkbox.attr('data-id'))
    $('#assigned_to_dropdown #selected').text(selected_name)
    $('#assigned_to_dropdown').removeClass('active')

  $('#search_leader_results .option.leader input').live 'change', (e)->
    if $(this).is(':checked')
      data_id = $(this).attr('data-id')
      if $('#default_leader_options .option.receiver[data-id=' + data_id + ']').size() == 0
        $('#default_leader_options').append($(this).parents('.option'))
      else
        $(this).parents('.option').remove()

  $('#search_leader_field').live 'keyup', (e)->
    e.preventDefault()
    if $(this).val() == ""
      $(this).removeClass("ui-autocomplete-input ui-autocomplete-loading")
    if $(this).val().length > 2
      $(this).addClass("ui-autocomplete-input ui-autocomplete-loading")
      ids = []
      $("#default_leader_options .option.leader").each ->
        ids.push($(this).attr('data-id'))
      ids = ids.join(",")
      $.ajax
        type: 'GET',
        url: '/interactions/search_leaders?keyword=' + $(this).val() + '&person_id=' + $(this).attr('data-person-id') + '&except=' + ids
  
  $('#followup_status_dropdown.edit .option').live 'click', (e)->
    selected_name = $(this).attr('data-name')
    selected_id = $(this).attr('data-id')
    $('#followup_status_dropdown.edit #selected').text(selected_name)
    $('.followup_status_field_edit').val(selected_id)
    $('.followup_status_field_edit').change()
    $('#followup_status_dropdown.edit').removeClass('active')
  
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
    
  $('#groups_popup_cancel_button').live 'click', (e)->
    e.preventDefault()
    $.hideDialog($("#profile_groups_dialog"))
  
  $('#show_profile_groups_button').live 'click', (e)->
    e.preventDefault()
    $.showDialog($("#profile_groups_dialog"))
  
  $('#roles_popup_save_button').live 'click', (e)->
    e.preventDefault()
    ids = []
    $('.role_checkbox:checked').each ->
      ids.push($(this).val())
    ids = ids.join(',')
    $.hideDialog($("#profile_roles_dialog"))
    if ids != $('#roles_save').attr('data-current-role-ids')
      $.toggleLoader('profile_name','Applying Changes...')
      $.ajax
        type: 'GET',
        url: "/interactions/set_roles?person_id=" + $(this).attr('data-person-id') + "&ids=" + ids
  
  $('#roles_popup_cancel_button').live 'click', (e)->
    e.preventDefault()
    $.hideDialog($("#profile_roles_dialog"))
  
  $('#labels_popup_save_button').live 'click', (e)->
    e.preventDefault()
    ids = []
    $('.label_checkbox:checked').each ->
      ids.push($(this).val())
    ids = ids.join(',')
    $.hideDialog($("#profile_labels_dialog"))
    if ids != $('#labels_save').attr('data-current-label-ids')
      $.toggleLoader('profile_label_header','Applying Changes...')
      $.ajax
        type: 'GET',
        url: "/interactions/set_labels?person_id=" + $(this).attr('data-person-id') + "&ids=" + ids
    
  
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
  
  $('#labels_popup_cancel_button').live 'click', (e)->
    e.preventDefault()
    $.hideDialog($("#profile_labels_dialog"))
    
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
    $.toggleLoader('profile_name','Loading Selected Interaction...')
    $.ajax
      type: 'GET',
      url: '/interactions/show_edit_interaction_form?id=' + $(this).attr('data-id') + '&person_id=' + $(this).attr('data-person-id')    
  
  $('#interaction_save_save_button').live 'click', (e)->
    e.preventDefault()
    $.toggleLoader('profile_name','Saving Interaction...')
    $.blur('.feed_content .feed_box.interaction_new')
    $('form#new_interaction_form').submit()
  
  $('#privacy_setting_dropdown .option').live 'click', (e)->
    selected_name = $(this).attr('data-name')
    selected_id = $(this).attr('data-id')
    $('#privacy_setting_dropdown #selected').text(selected_name)
    $('#privacy_setting_field').val(selected_id)
    $('#privacy_setting_dropdown').removeClass('active')
  
  $('#initiator_dropdown .option').live 'click', (e)->
    checkbox = $(this).children('input.initiator_box').eq(0)
    if checkbox.is(':checked')
      if $('input.initiator_box:checked').size() > 1
        checkbox.prop('checked',false)
      else
        checkbox.prop('checked',true)
    else
      checkbox.prop('checked',true)
    checkbox.change()
    selected_name = $(this).children('input.initiator_box').eq(0).siblings('.initiator_name').text()
    if $('input.initiator_box:checked').size() > 1
      $('#initiator_dropdown #selected').text($('input.initiator_box:checked').size() + " people selected")
    else
      $('#initiator_dropdown #selected').text(selected_name)
      
  
  $('#initiator_dropdown input.initiator_box').live 'click', (e)->
    if $(this).is(':checked')
      if $('input.initiator_box:checked').size() > 1
        $(this).prop('checked',false)
      else
        $(this).prop('checked',true)
    else
      $(this).prop('checked',true)
    selected_name = $(this).siblings('.initiator_name').text()
    if $('input.initiator_box:checked').size() > 1
      $('#initiator_dropdown #selected').text($('input.initiator_box:checked').size() + " people selected")
    else
      $('#initiator_dropdown #selected').text(selected_name)
  
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
  
  $('.arrow').live 'click', (e)->
    e.preventDefault()
    $(this).siblings('#selected').click()
  
  $('#selected').live 'click', (e)->
    e.stopPropagation()
    unless $(this).parents('.custom_dropdown').first().hasClass('active')
      $('.custom_dropdown').removeClass('active')
      $(this).parents('.custom_dropdown').first().addClass('active')
  
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
    assigned_to_id = $('#assigned_to_dropdown').attr('data-current-id')
    $(".option.leader[data-id=" + assigned_to_id  + "]").click()
    
  
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
  if $(document).height() > $(window).height() 
    if $('html').scrollTop()
      scrollTop = $('html').scrollTop()
    else
      scrollTop = $('body').scrollTop()
    $('html').addClass('noscroll').css('top',-scrollTop)
  
$.showDialog = (selector) ->
  $.hideScroll()
  selector.show()
  
$.unhideScroll = () ->
  scrollTop = parseInt($('html').css('top'))
  $('html').removeClass('noscroll');
  $('html,body').scrollTop(-scrollTop);
  
$.hideDialog = (selector) ->
  $.unhideScroll()
  selector.hide()