$ ->
  $('#user_merge_form input.person').observe_field 0.75, ->
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
          
  $('#user_merge_form input.name').observe_field 0.75, ->
    name = $(this).val()
    $('#person_ids').hide()
    return false if $.trim(name) == ''
    $("#spinner_name").show()
    $.ajax
      url: '/people/search_ids.json?q=' + name
      type: 'GET',
      success: (data)->
        $('#ids').html('<strong>' + name + '</strong>: ' + data.join(', '))
        $('#person_ids').show()
        $.each data, (i, val)->
          field = $('#person'+(i+1))
          if field[0]
            field.val(val)
      complete: ->
        $("#spinner_name").hide()
