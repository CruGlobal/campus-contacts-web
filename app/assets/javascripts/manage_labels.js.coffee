$ ->
  $('#add_orgnizational_label_button').live 'click', (e)->
    e.preventDefault()
    $("#org_title_dialog").html(t('manage_labels.add_title'))
    $.showDialog($("#add_label_div"))
    $("#add_label_save_button").show()
    $("#edit_label_save_button").hide()
    $('#label_name').focus()
    $('#label_name').val("")

  $(".edit_orgnizational_label_button").live "click", (e)->
    e.preventDefault()
    name = $(this).attr("data-name")
    id = $(this).attr("data-id")
    $("#org_title_dialog").html(t('manage_labels.edit_title'))
    $.showDialog($("#add_label_div"))
    $("#add_label_save_button").hide()
    $("#edit_label_save_button").show()
    $("#label_name").val(name)
    $("#edit_label_save_button").attr("data-id", id)
    $('#label_name').focus()
    false

  $('#add_label_save_button').live 'click', (e)->
    e.preventDefault()
    $("#org_title_dialog").html(t('manage_labels.add_title'))
    name = $('#label_name').val()
    loader = $("#add_label_loader")
    fields = $(".add_label_content")
    loader.show()
    fields.hide()
    if name == ''
      $.a(t('manage_labels.name_is_required'))
      loader.hide()
      fields.show()
    else
      $.ajax
        type: 'POST',
        url: '/labels/add_label',
        data: 'name='+name,
        success: () ->
          loader.hide()
          fields.show()


  $('#edit_label_save_button').live 'click', (e)->
    e.preventDefault()
    $("#org_title_dialog").html(t('manage_labels.edit_title'))
    name = $('#label_name').val()
    id = $(this).attr("data-id")
    loader = $("#add_label_loader")
    fields = $(".add_label_content")
    loader.show()
    fields.hide()
    if name == ''
      $.a(t('manage_labels.name_is_required'))
      loader.hide()
      fields.show()
    else
      $.ajax
        type: 'POST',
        url: '/labels/edit_label',
        data: 'name='+name+'&id='+id,
        success: () ->
          loader.hide()
          fields.show()
