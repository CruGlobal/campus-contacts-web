$ -> 
    
  $('ul.sf-menu').superfish
    dropShadows: false,
    delay: 100
    
  $('.expandable').each (i)->
    e = $(this)
    if e.height() > Number(e.attr("data-height"))
      e.next('.moredown').show();
      e.attr("data-original-height", e.height())
      e.css({height: e.attr("data-height") + 'px', overflow: 'hidden'})
      
  $('a.moredown').click ->
    target = $($(this).attr('href'))
    target.toggleClass('showall')
    if target.hasClass('showall')
      target.attr('data-height', target.height())
      target.animate({height: target.attr("data-original-height")})
      $('span', this).html('<strong>+</strong> Show Less Leaders')
    else
      target.animate({height: target.attr("data-height")})
      $('span', this).html('<strong>+</strong> Show More Leaders')
    false
    
  $('a.disabled').live 'click', ->
    false
    
  $('[data-method=delete]').live 'ajax:before', ->
    $(this).parent().fadeOut()
    
  $('#check_all').live 'click', ->
    if $(this).attr('data-target')
      form = $($(this).attr('data-target'))
    else
      form = $(this).closest('form')
    $('input[type=checkbox]', form).prop('checked', $(this).prop('checked'))
    
  $('.drag').live 'click', ->
    false
    
  sortable_options = 
    axis:'y'
    dropOnEmpty:false
    update: (event, ui) -> 
      sortable = this
      $.ajax
        data:$(this).sortable('serialize',{key:sortable.id + '[]'})
        complete: (request) ->
          $(sortable).effect('highlight')
        success: (request) -> 
          $('#errors').html(request)
        type:'POST', 
        url: $(sortable).attr('data-sortable-url')
        
  $('[data-sortable]').sortable(sortable_options)
  
  $('.tipthis[title]').qtip()
  $('.tiplight').qtip()
  $('.tipit[title]').qtip
    position: 
      my: 'top right',  
      at: 'bottom left'
  
  $('[data-sortable][data-sortable-handle]').each ->
    handle = $(this).attr('data-sortable-handle');
    $(this).sortable("option", "handle", handle);
    