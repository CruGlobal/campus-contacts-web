$ ->
  $.fn.activateGroupLabelDroppable()
  $('#groups_controller.index td.labels a.delete').live 'click', ->
    row = $(this).closest('tr')
    li = $(this).closest('li')
    li.fadeOut()
    $.ajax
      url: '/groups/' + row.attr('data-id') + '/group_labelings/' + li.attr('data-id')
      type: 'DELETE'
    false
    
  $('#groups_controller.index #labels a.delete_label').live 'click', ->
    li = $(this).closest('li')
    li.fadeOut()
    $.ajax
      url: '/group_labels/' + li.attr('data-id')
      type: 'DELETE'
    false
    
  $('#groups_controller.index a.add-label').live 'click', ->
    el = $('#new_label')
    el.dialog
      resizable: false,
      height:250,
      width:400,
      modal: true,
      buttons: 
        Create: ->
          $('form', el).submit()
        Cancel: ->
          $(this).dialog('destroy')
    
  $('#new_label form').live 'submit', ->
    $('#spinner_new_label').show()
    
$.fn.activateGroupLabelDroppable = () ->
  $('#groups_controller.index .leftmenu .label').droppable 
    activeClass: 'ui-state-highlight'
    drop: (event, ui) ->
      label = $(this)
      label.effect('highlight', {}, 'slow')
      $.fn.applyGroupLabel(label)
      
$.fn.applyGroupLabel = (label) ->
  label_name = $('.name a', label).text()
  $('.id_checkbox:checked').each ->
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
