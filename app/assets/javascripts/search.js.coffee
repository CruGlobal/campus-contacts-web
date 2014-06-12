$ ->
  $(document).ready ->

    # Display clear button for active filters
    $("#search_survey_filters .side-search-option").each ->
      if $(this).data('type') == "TextField"
        if $(this).data('option') != 'any'
          $(this).find(".clear_filter").show()
      else if $(this).data('type') == "ChoiceField"
        if $(this).find("input[type='checkbox']:checked").size() > 0
          $(this).find(".clear_filter").show()

    $.fn.handleSearchOptions()
    if $("#contacts_table .id_checkbox").size() > 0
      $('.save-search-option').show()
    else
      $('.save-search-option').hide()

    $(document).on 'change', ".pagination_space select#per_page", (e)->
      $(document).scrollTop(0)
      $.fn.filterLoader('show')
      $("#pagination_limit_select").submit()
      $(".pagination_space #per_page").attr("disabled", true)

    # Search trigger
    $(document).on 'click', '#search_any_button', (e)->
      stamp = $.now()
      $('#search_stamp').val(stamp)
      $("#ac_sidebar #sidebar_lists").data('stamp',stamp)
      $.fn.handleSearchOptions()
      $.fn.filterLoader('show')

    # Delete Saved Search
    $(document).on "click", ".side-search#saved_search .option.link .delete a", (e)->
      $(this).parents(".side-search-option").fadeOut()

    # Filter Archived Contacts
    $(document).on 'click', '#contacts_controller #include_archived', (e)->
      $('#search_any_button').click()

    # Filter Friends Contacts
    $(document).on 'click', '#contacts_controller #friends_only', (e)->
      $('#search_any_button').click()

    # Show clear button for active filters
    $("#search_standard_filters .side-search-option").each ->
      if $(this).find(".fields").children(".option.active").size() > 0
        $(this).find(".clear_filter").show()

    # Radio
    $("#search_standard_filters input[type='radio'], #search_survey_filters input[type='radio']").live 'change', (e)->
      if ['contains','is_exactly','does_not_contain'].indexOf($(this).val()) >= 0
        if $.trim($(this).parents(".options").siblings(".fields").find("input").val()) != ""
          $('#search_any_button').click()
      else
        $('#search_any_button').click()

    # Checkbox
    $("#search_standard_filters input[type='checkbox'], #search_survey_filters input[type='checkbox']").live 'change', (e)->
      option = $(this).parents(".option.checkbox")
      parent = option.parents(".side-search-option")


      if $(this).is(":checked")
        option.addClass("active")
      else
        option.removeClass("active")
        unless parent.hasClass('active')
          option.hide()

      # Reposition option
      # if $(this).is(":checked")
      #   option.appendTo(parent.find(".fields_active"))
      # else
      #   option.prependTo(parent.find(".fields"))

      # Hide or display clear button
      if parent.find(".fields").children(".option.checkbox.active").size() > 0
        parent.find(".clear_filter").show()
      else
        parent.find(".clear_filter").hide()

      $('#search_any_button').click()

    $(document).on "keypress", ".side-search-option input[type='text'], input#search_any", (e)->
    	if e.which == 13
        $('#search_any_button').click()

    # DateField triggers
    $(document).on "change", ".field.date_field .dateselect select", (e)->
      date_fields = $(this).parents(".dateselect")
      date_day = date_fields.find("select.select_day")
      date_month= date_fields.find("select.select_month")
      date_year= date_fields.find("select.select_year")

      if $(this).hasClass("select_day") || $(this).hasClass("select_month")
        if date_day.val() != "" && date_month.val() != ""
          $('#search_any_button').click()
      else if $(this).hasClass("select_year")
        if date_day.val() != "" && date_month.val() != ""
          $('#search_any_button').click()
      else
        if date_day.val() != "" && date_month.val() != "" && date_year.val() != ""
          $('#search_any_button').click()


    $(document).on "click", ".side-search-option .toggler", (e)->
      fields = $(this).siblings(".fields")
      inactive = fields.find(".option.checkbox:not(.active)")
      parent = $(this).parents(".side-search-option")
      options = parent.find(".options")
      selected_option = parent.data("option")

      if $(this).hasClass("active")
        if parent.data('type') == "TextField"
          if selected_option == 'any'
            $(this).removeClass("active")
            parent.removeClass("active")
            options.removeClass("active")
            fields.find(".text_field").hide()
          else
            $(this).removeClass("active")
            parent.removeClass("active")
        else if parent.data('type') == "DateField"
          $(this).removeClass("active")
          parent.removeClass("active")
          options.removeClass("active")
          fields.hide()
          fields.find(".field").hide()
        else
          $(this).removeClass("active")
          parent.removeClass("active")
          inactive.hide()
          if fields.find(".option.checkbox:visible").size() == 0
            options.removeClass("active")
      else
        if parent.data('type') == "TextField"
          if selected_option == 'any'
            $(this).addClass("active")
            parent.addClass("active")
            options.addClass("active")
          else
            $(this).addClass("active")
            parent.addClass("active")
            options.addClass("active")
            fields.find(".text_field").show()
        else if parent.data('type') == "DateField"
          $(this).addClass("active")
          parent.addClass("active")
          options.addClass("active")
          fields.show()
          fields.find(".field").show()
        else
          $(this).addClass("active")
          parent.addClass("active")
          options.addClass("active")
          inactive.show()






      # if $(this).hasClass("active")
      #   if parent.data('type') == "TextField"
      #     if selected_option == 'any'
      #
      #       parent.removeClass("active")
      #       options.removeClass("active")
      #       inactive.hide()
      #   else
      #     $(this).removeClass("active")
      #     parent.removeClass("active")
      #     options.removeClass("active")
      #     inactive.hide()
      # else
      #   if parent.data('type') == "TextField"
      #     if selected_option == 'any'
      #       $(this).addClass("active")
      #       parent.addClass("active")
      #       options.addClass("active")
      #       inactive.hide()
      #     else
      #       $(this).addClass("active")
      #       parent.addClass("active")
      #       options.addClass("active")
      #       inactive.show()
      #   else
      #     $(this).addClass("active")
      #     parent.addClass("active")
      #     options.addClass("active")
      #     inactive.show()


    $(document).on "click", ".side-search-option .title", (e)->
      $(this).siblings(".toggler").click()

    $(document).on "click", ".side-search .side-search-toggler", (e)->
      toggler= $(this)
      fields = toggler.siblings(".side-search-options")
      if fields.is(":visible")
        toggler.removeClass("active")
        fields.slideUp "fast"
      else
        toggler.addClass("active")
        fields.slideDown "fast"

    # Show apply button for standard filter (active)
    # $(document).on "click", ".side-search-option .fields_active .checkbox input[type='checkbox']", (e)->
    #   apply = $(this).parents(".fields_active").siblings(".fields")
    #   apply.find(".actions .apply").show()
    #   apply.find(".actions .clear").hide()
    #   unless apply.is(":visible")
    #     parent = apply.parents(".side-search-option")
    #     toggler = parent.find(".toggler")
    #     toggler.addClass("active")
    #     parent.addClass("active")
    #     apply.slideDown("fast")

    # Show apply button for standard filter
    # $(document).on "click", ".side-search-option .fields .checkbox input[type='checkbox']", (e)->
    #   apply = $(this).parents(".fields")
    #   apply.find(".actions .apply").show()
    #   apply.find(".actions .clear").hide()


    # Clear filter
    $(document).on "click", ".side-search-option .clear_filter", (e)->
      e.preventDefault()
      $(this).hide()
      parent = $(this).parents(".side-search-option")
      # Values
      type = parent.data("type")
      # Elements
      actions = $(this).parents(".actions")

      if parent.parents("#search_survey_filters").size() == 1
        parent.siblings(".side-search-surveys").html("")

      if type == "TextField"
        parent.removeClass("active")
        parent.data('option-title',"Any Response")
        parent.data('option','any')
        parent.find(".toggler").removeClass("active")
        options = parent.find(".options")
        options.find(".text_option.any").children("input").prop("checked", true)
        options.find(".choices").slideUp()
        options.find(".selected").text("Any Response")
        options.find(".selected").show()
        options.removeClass("active")
        field = parent.find(".field")
        field.removeClass("active").hide()
        field.find("input").val("")
      else if type == "ChoiceField"
        parent.removeClass("active")
        parent.find(".toggler").removeClass("active")
        options = parent.find(".options")
        options.find(".text_option").first().children("input").prop("checked", true)
        options.find(".choices").slideUp()
        options.find(".selected").text("Match Any")
        options.find(".selected").show()
        options.removeClass("active")
        fields = parent.find(".fields")
        fields.find("input").prop("checked", false)
        fields.find(".option.checkbox").removeClass("active").hide()
      else if type == "DateField"
        options = actions.siblings(".options")
        options.find(".text_option.any").children("input").prop("checked", true)
        options.find(".choices").slideUp()
        options.find(".selected").text("Exact")
        options.find(".selected").show()
        fields = parent.find(".dateselect select")
        fields.each ->
          $(this).val($(this).data("null"))
      else if type == "Standard"
        parent.removeClass("active")
        parent.find(".toggler").removeClass("active")
        options = parent.find(".options")
        options.find(".text_option").first().children("input").prop("checked", true)
        options.find(".choices").slideUp()
        options.find(".selected").text("Match Any")
        options.find(".selected").show()
        options.removeClass("active")
        fields = parent.find(".fields")
        fields.find("input").prop("checked", false)
        fields.find(".option.checkbox").removeClass("active").hide()

      $('#search_any_button').click()

    # Reset filter
    # $(document).on "click", ".side-search-option .reset_filter", (e)->
    #   e.preventDefault()
    #   parent = $(this).parents(".side-search-option")
    #   # Values
    #   type = parent.data("type")
    #   value = parent.data("value")
    #   option = parent.data("option")
    #   option_title = parent.data("option-title")
    #   # Elements
    #   field = parent.find(".field input")
    #   actions = $(this).parents(".actions")
    #
    #   if type == "TextField"
    #     options = actions.parents(".fields").siblings(".options")
    #     options.find(".text_option." + option + " input").prop("checked", true)
    #     options.find(".choices").slideUp()
    #     options.find(".selected").text(option_title)
    #     options.find(".selected").show()
    #     field.val(value)
    #     field.keyup()
    #   else if type == "ChoiceField"
    #     options = actions.parents(".fields").siblings(".options")
    #     options.find(".text_option." + option + " input").prop("checked", true)
    #     options.find(".choices").slideUp()
    #     options.find(".selected").text(option_title)
    #     options.find(".selected").show()
    #
    #     fields = parent.find(".option.checkbox")
    #     checkboxes = fields.find("input[type='checkbox']")
    #     checkboxes.prop("checked", false)
    #     for val in value
    #       fields.find("input[type='checkbox'][value='" + val + "']").prop("checked", true)
    #   else if type == "DateField"
    #     options = actions.parents(".fields").siblings(".options")
    #     options.find(".text_option." + option + " input").prop("checked", true)
    #     options.find(".choices").slideUp()
    #     options.find(".selected").text(option_title)
    #     options.find(".selected").show()
    #
    #     fields = parent.find(".dateselect select")
    #     fields.each ->
    #       $(this).val($(this).data("value"))
    #   else if type == "Standard"
    #     options = actions.parents(".fields").siblings(".options")
    #     options.find(".text_option." + option + " input").prop("checked", true)
    #     options.find(".choices").slideUp()
    #     options.find(".selected").text(option_title)
    #     options.find(".selected").show()
    #
    #     actions.parents(".fields").find(".option.checkbox input").prop("checked", false)
    #     actions.parents(".fields").siblings(".fields_active").find(".option.checkbox input").prop("checked", true)
    #
    #   if parent.data("set") == false
    #     parent.find(".options").removeClass("active")
    #   parent.find(".fields").slideUp("fast")
    #   parent.find(".toggler").removeClass("active")
    #   parent.removeClass("active")
    #
    #   parent.find(".actions .apply").hide()
    #   parent.find(".actions .clear").show() if value != ""

    # Show apply button for dateselect fields
    $(document).on "change", ".side-search-option .dateselect select", (e)->
      apply = $(this).parents(".side-search-option").find(".actions")
      apply.find(".apply").show()
      apply.find(".clear").hide()



    # Toggle option if the parent is clicked
    $(document).on "click", ".options .selected", (e)->
      $(this).hide()
      $(this).siblings(".choices").slideDown()


    # Show options when the selected option is clicked
    $(document).on "click", ".options .choices .text_option", (e)->
      input = $(this).children('input')
      unless input.is(":disabled")
        input.prop("checked", true)
        parent = input.parents(".side-search-option")
        options = parent.find(".options")

        if parent.data("type") == "TextField"
          selected = $.trim($(this).text())
          options.find(".selected").text(selected).show()
          options.find(".choices").hide()
          parent.data('option-title',selected)
          parent.data('option',input.val())

          # Hide or show text field
          text_field = parent.find(".fields .text_field")
          if ['contains','is_exactly','does_not_contain'].indexOf(input.val()) >= 0
            text_field.show()
          else
            text_field.hide()

          # Hide or show clear button
          if input.val() == 'any'
            parent.find(".clear_filter").hide()
          else
            parent.find(".clear_filter").show()

        else if parent.data("type") == "ChoiceField"
          selected = $.trim($(this).text())
          options.find(".selected").text(selected).show()
          options.find(".choices").hide()
          parent.data('option-title',selected)
          parent.data('option',input.val())

        else if parent.data("type") == "Standard"
          selected = $.trim($(this).text())
          options.find(".selected").text(selected).show()
          options.find(".choices").hide()
          parent.data('option-title',selected)
          parent.data('option',input.val())

        else if parent.data("type") == "DateField"
          selected = $.trim($(this).text())
          options.find(".selected").text(selected).show()
          options.find(".choices").hide()
          parent.data('option-title',selected)
          parent.data('option',input.val())

          if input.val() == "match"
            parent.find(".field .dateselect.end .dateselect_intro").addClass("inactive")
            parent.find(".field .dateselect.end .dateselect_label").addClass("inactive")
            parent.find(".field .dateselect.end select").prop("disabled", true)
          else
            parent.find(".field .dateselect.end .dateselect_intro").removeClass("inactive")
            parent.find(".field .dateselect.end .dateselect_label").removeClass("inactive")
            parent.find(".field .dateselect.end select").prop("disabled", false)

    # Disable some options when no keyword is defined
    $(document).on "keyup", ".field .textfield", (e)->
      parent = $(this).parents(".side-search-option")
      options = parent.find(".options")
      contains = options.children(".choices").children(".text_option.contains").children("input")
      is_exactly = options.children(".choices").children(".text_option.is_exactly").children("input")
      does_not_contain = options.children(".choices").children(".text_option.does_not_contain").children("input")
      is_blank = options.children(".choices").children(".text_option.is_blank").children("input")
      any = options.children(".choices").children(".text_option.any").children("input")

      # unless parent.find(".fields").is(":visible")
      #   parent.find(".toggler").click()
      #
      # if $(this).val() == ""
      #   if contains.is(":checked") || is_exactly.is(":checked") || does_not_contain.is(":checked")
      #     any.prop("checked", true)
      #     options.find(".selected").text("Any Response")
      #   contains.prop("disabled", true)
      #   is_exactly.prop("disabled", true)
      #   does_not_contain.prop("disabled", true)
      # else
      #   if is_blank.is(":checked") || any.is(":checked")
      #     contains.prop("checked", true)
      #     options.find(".selected").text("Contains")
      #   contains.prop("disabled", false)
      #   is_exactly.prop("disabled", false)
      #   does_not_contain.prop("disabled", false)

$.fn.handleSearchOptions = ()->
  active = false
  $("#search_survey_filters .side-search-option").each ->
    if $(this).data('type') == "TextField"
      if $(this).data('option') != 'any'
        active = true
    else if $(this).data('type') == "ChoiceField"
      if $(this).find("input[type='checkbox']:checked").size() > 0
        active = true

  $("#search_standard_filters .side-search-option").each ->
    if $(this).find(".fields").children(".option.active").size() > 0
      active = true

  if active
    $("#search-sidebar .side-search-links").show()
  else if $.trim($("#search-sidebar #search_any").val()) != ""
    $("#search-sidebar .side-search-links").show()
  else if $("#search-sidebar #include_archived").is(":checked")
    $("#search-sidebar .side-search-links").show()
  else if $("#search-sidebar #friends_only").is(":checked")
    $("#search-sidebar .side-search-links").show()
  else
    $("#search-sidebar .side-search-links").hide()
  $('.save-search-option').hide()