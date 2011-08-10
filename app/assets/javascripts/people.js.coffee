$ ->
  $('#user_merge_form input').observe_field 1, ->
    css_class = $(this).attr('id')
    id = $(this).val()
    return false unless Number(id) > 0
    $("#spinner_" + css_class).show()
    $.ajax
      url: '/people/' + id + '/merge_preview?class=' + css_class
      type: 'GET',
      complete: ->
        $('.merge.' + css_class).show()
        $("#spinner_" + css_class).hide()
