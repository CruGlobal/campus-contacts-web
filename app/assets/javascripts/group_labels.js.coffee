$ ->
  $.fn.activateGroupLabelDroppable()
  $('#groups_controller.index td.labels a.delete').live 'click', ->
    row = $(this).closest('tr')
    li = $(this).closest('li')
    li.fadeOut()
    $.ajax
      url: '/groups/' + row.attr('data-id') + '/group_labelings/' + li.attr('data-id')
      type: 'DELETE'
    li.remove()
    false

  $('#group_labels a.delete_label').live 'click', ->
    li = $(this).closest('li')
    li.fadeOut()
    $.ajax
      url: '/group_labels/' + li.attr('data-id')
      type: 'DELETE'
    false

  $('#add_group_label_button').live 'click', ->
    $.showDialog($("#add_group_label_div"))


  $('#add_group_label_save_button').live 'click', (e)->
    e.preventDefault()
    group_label_name = $('#group_label_name').val()
    loader = $("#add_group_label_loader")
    fields = $(".add_group_label_content")
    loader.show()
    fields.hide()
    if group_label_name == ''
      $.a(t('groups.label_name_is_required'))
      loader.hide()
      fields.show()
    else
      $.ajax
        type: 'POST',
        url: '/group_labels',
        data: 'group_label_name='+group_label_name,
        success: () ->
          loader.hide()
          fields.show()

$.fn.activateGroupLabelDroppable = () ->
  $('#groups_controller.index .leftmenu .label').droppable
    activeClass: 'ui-state-highlight'
    drop: (event, ui) ->
      label = $(this)
      label.effect('highlight', {}, 'slow')
      $.fn.applyGroupLabel(label)

$.fn.applyGroupLabel = (label) ->
  label_name = $('a', label).text()
  $('.id_checkbox.group_checkbox:checked').each ->
    row = $('tr[data-id=' + $(this).val() + ']')
    labels = $('td.labels span.name', row).map ->
      return $(this).text()
    .get()
    unless $.inArray(label_name, labels) > -1
      $('td.labels ul',row).append('<li data-id="'+label.attr("data-id")+'"><span class="name">'+label_name+'</span><a class="delete" href="#">x</a></li>')
      $.ajax
        url: '/groups/' + $(this).val() + '/group_labelings'
        data: {group_label_id: label.attr("data-id")},
        type: 'POST'
