$ ->
  $(".my_completed, .my_in_progress").droppable
    activeClass: 'ui-state-active'
    hoverClass: 'ui-state-hover'
    accept: ".handle"
    drop: (event, ui) ->
      li = $(this)
      li.effect "highlight", {}, "slow"
      if $(this).hasClass("my_completed")
        $.fn.move_my_contacts_to_completed_or_in_progress "my_completed", "my_in_progress"
      else
        $.fn.move_my_contacts_to_completed_or_in_progress "my_in_progress", "my_completed"


$.fn.move_my_contacts_to_completed_or_in_progress = (add_class, subtract_class) ->
  $('.id_checkbox:checked').each ->
    unless $("."+add_class).hasClass("selected_class")
      if id = $(this).attr("data-id")
        $.toggleLoader "ac_button_bar", "Loading..."

        if add_class == "my_in_progress"
          get_status = "contacted"
        else
          get_status = "completed"

        $.ajax
          type: "POST",
          url: "/people/update_permission_status",
          data: {person_id: id , status: get_status}
          success: (resp) ->
            $.toggleLoader "ac_button_bar", ""
            if resp
              #remove row if successfully updated the status
              $("#person_"+id).remove()

              #Add counter in sidebar
              add_count = $("."+add_class+" .count")
              add_count.text(parseInt(add_count.text()) + 1)

              #Subtract counter in sidebar
              subtract_count = $("."+subtract_class+" .count")
              subtract_count.text(parseInt(subtract_count.text()) - 1)
