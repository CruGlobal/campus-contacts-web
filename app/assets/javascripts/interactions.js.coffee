$ ->
  $("#profile_feed #panel_nav li").live 'click', (e)->
    e.preventDefault()

    $("#profile_feed #panel_nav li").removeClass('current')
    $(this).addClass('current')
    $("#profile_feed .feed_content .tab_content").removeClass('current')
    $("#profile_feed .feed_content .tab_content.profile_" + $(this).attr('id')).addClass('current')