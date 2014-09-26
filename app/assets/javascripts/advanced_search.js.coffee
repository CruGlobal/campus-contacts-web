$ ->

  $('#search_people_filters_reset_all_button').live 'click', (e)->
    $.fn.filterLoader('show')

  $(document).ready ->
    $.fn.filterLoader('hide')

    $(".field_option.datefield").each ->
      if !$(this).hasClass("with_month")
        $(this).children("select").first().after("&nbsp;Month:")
      $(this).addClass("with_month")

  $(document).on 'change', ".datefield_option_select", (e)->
    if $(this).val() == "match"
      $(this).parents(".field_option").siblings(".datefield_end_select").hide()
    else
      $(this).parents(".field_option").siblings(".datefield_end_select").show()

  $(document).on 'click', "a.reset_search", (e)->
    el = $(this)
    values = el.attr('data-value').split(",")
    if el.hasClass "group_search"
      # Group Search
      $('.search_group_checkbox').prop('checked', false)
      for value in values
        $(".search_group_checkbox#search_group_#{value}").prop('checked', true)
      if el.attr('data-filter') == "all"
        $("#group_filter_all").prop('checked', true)
      else
        $("#group_filter_any").prop('checked', true)
    else if el.hasClass "label_search"
      # Label Search
      $('.search_label_checkbox').prop('checked', false)
      for value in values
        $(".search_label_checkbox#search_label_#{value}").prop('checked', true)
      if el.attr('data-filter') == "all"
        $("#label_filter_all").prop('checked', true)
      else
        $("#label_filter_any").prop('checked', true)
    else if el.hasClass "checkbox_search"
      id = el.attr("data-id")
      $(".#{id}_checkbox").prop('checked', false)
      for value in values
        $(".#{id}_checkbox:data[value=#{value}]").prop('checked', true)
      if el.hasClass "survey_scope"
        survey_ids = []
        $('input.search_survey_checkbox.survey_item:checked').each ->
          survey_ids.push($(this).attr("value"))
        $('.advanced_search_survey_update_loader').css("display","inline-block");
        $.ajax
          type: 'GET',
          url: '/contacts/update_advanced_search_surveys?survey_ids=' + survey_ids
    else if el.hasClass "survey_range_search"
      $(".survey_range_toggle").prop('checked', el.attr("data-toggle") == "on")
      $(".date_field.survey_range_start").val(values[0])
      $(".date_field.survey_range_stop").val(values[1])
    else if el.hasClass "textbox_search"
      $("##{el.attr('data-id')}_textbox_option").val(el.attr('data-option'))
      $("##{el.attr('data-id')}_textbox_answer").val(values)

  $(document).on 'click', "input#search_survey_all", (e)->
    $('input.search_survey_checkbox.survey_item').prop('checked', $(this).is(':checked'))

  $(document).on 'click', "input.search_survey_checkbox", (e)->
    survey_ids = []
    $('input.search_survey_checkbox.survey_item:checked').each ->
      survey_ids.push($(this).attr("value"))
    $('.advanced_search_survey_update_loader').css("display","inline-block");
    $.fn.filterLoader('show')
    $.ajax
      type: 'GET',
      url: '/contacts/update_advanced_search_surveys?survey_ids=' + survey_ids

  $(document).on 'click', ".search_category .field_title", (e)->
    e.preventDefault()
    element = $(this).siblings(".field_element").first()
    if element.is(":visible")
      $(this).children(".arrow").html("&#x25B6;")
      $(this).parents(".field").children(".search_filter_options").fadeOut "fast", ->
        element.slideUp("fast")
    else
      $(this).children(".arrow").html("&#x25BC;")
      element.slideDown "fast", ->
        $(this).parents(".field").children(".search_filter_options").fadeIn("fast")

$.fn.filterLoader = (action, msg) ->
  msg ||= "Loading Contacts"
  $(".filter_loader .msg").text(msg)
  count = $(".filter_loader").data("count") || 0
  if action == 'show'
    count += 1
    $(".filter_loader").data("count", count)
    $(".filter_loader").fadeIn()
    $('#all_contacts_list.scroll_table').css('opacity','0.5')
  else if action == 'force'
    $(".filter_loader").data("count", 0)
    $(".filter_loader").fadeOut()
    $('#all_contacts_list.scroll_table').css('opacity','1')
  else
    count -= 1 if count > 0
    $(".filter_loader").data("count", count)
    if count <= 0
      $(".filter_loader").fadeOut()
      $('#all_contacts_list.scroll_table').css('opacity','1')