$ ->   
  $('.fingerme').oneFingerScroll();
  
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
  $('.tipit2[title]').qtip
    position: 
      my: 'top right',  
      at: 'top left'
  
  $('[data-sortable][data-sortable-handle]').each ->
    handle = $(this).attr('data-sortable-handle');
    $(this).sortable("option", "handle", handle);
    
  $('.handle').draggable 
    revert: true
    start: (event, ui) ->
      # If this row isn't checked, store the previously checked rows and check this row '
      unless $(this).next('input').prop('checked') 
        $(this).data 'checked', $('.id_checkbox:checked').map ->
          return $(this).val()
        $('.id_checkbox:checked').prop('checked', false) 
        $(this).next('input').prop('checked', true) 
    stop: (event, ui) ->
      if $(this).data('checked')?
        $(this).next('input').prop('checked', false)
        $.each $(this).data('checked'), (i, id) ->
          $('.id_checkbox[value=' + id + ']').prop('checked', true)
      $(this).data('checked', null)
    helper: (event) ->
      length = if $(this).next('input').prop('checked') then $('.id_checkbox:checked').length else 1
      if length == 1
        helper_text = $('#drag_helper_text_one').html()
      else
        helper_text = $('#drag_helper_text_other').html().replace('0', length)
      $('<div class="drag-contact">' + helper_text + '</div>').appendTo($('body'));     
      
window.t = (s) -> I18n.translate(s)    

$.a = (msg, title) -> 
  unless $('#alert_dialog')[0]?
    $('body').append('<div id="alert_dialog" title="' + t('general.alert') + '"></div>')
  if title?
    $('#alert_dialog').attr('title', title)
  $('#alert_dialog').html(msg)
  $('#alert_dialog').dialog
    resizable: false,
    height: 200,
    width: 400,
    modal: true,
    buttons: 
      Ok: ->
        $(this).dialog('destroy')