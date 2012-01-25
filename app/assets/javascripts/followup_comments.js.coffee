$ ->
  if $('#query')[0]
    if $('#query').val().length > 0
      $('#comment_search_box').show()
      false
      
  $('#filter_link').click ->
    $('#comment_search_box').toggle()
    false
    
  $('.comment_row td:not(.checkbox_cell)').live 'click', ->
    unless $('a', this)[0]?
      tr = $(this).parent()
      document.location = '/people/' + tr.attr('data-id')
