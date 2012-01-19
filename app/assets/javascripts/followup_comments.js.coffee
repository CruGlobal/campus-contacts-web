$ ->
  if $('#query')[0]
    if $('#query').val().length > 0
      $('#comment_search_box').show()
      false
      
  $('#filter_link').click ->
    $('#comment_search_box').toggle()
    false
