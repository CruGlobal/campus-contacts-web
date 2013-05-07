$ ->
  $('#info_display_edit_button').live 'click', (e)->
    e.preventDefault()
    $('.feed_content .tab_content.profile_info .view_space').hide()
    $('.feed_content .tab_content.profile_info .edit_space').fadeIn()
  
  $('#info_edit_cancel_button').live 'click', (e)->
    e.preventDefault()
    $('.feed_content .tab_content.profile_info .edit_space').hide()
    $('.feed_content .tab_content.profile_info .view_space').fadeIn()
    
  $('#info_edit_save_button').live 'click', (e)->
    e.preventDefault()
    $('body').addClass("reload_info")
    $.toggleLoader('profile_name','Applying Changes...')
    $('.feed_content .tab_content.profile_info .edit_space').hide()
    $('.feed_content .tab_content.profile_info .view_space').fadeIn()
    $('form#edit_profile_form').submit()
    
  
  $('#followup_status').live 'change', (e)->
    $.toggleLoader('followup_status_div','Applying...')
    $.ajax
      type: 'GET',
      url: '/interactions/change_followup_status?status=' + $(this).val() + '&person_id=' + $(this).attr('data-person-id')
  
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
    $("#profile_feed #panel_nav li").removeClass('current')
    $(this).addClass('current')
    $("#profile_feed .feed_content .tab_content").removeClass('current')
    $("#profile_feed .feed_content .tab_content.profile_" + $(this).attr('id')).addClass('current')
