$ ->

  $('.org_control').not('.tree_no_child').each ->
    if $("." + $(this).attr('id')).not('.tree_no_child').size() > 1
      $("." + $(this).attr('id')).not('.tree_no_child').last().addClass('tree_no_child')

  $('.org_control').live 'click', ->
    child_div = $('#' + $(this).attr('child_div'))
    child_div.toggle()
    if child_div.is(':visible')
      $(this).addClass('tree_open')
    else
      $(this).removeClass('tree_open')
  $('.org_star').live 'click', ->
    document.location = $(this).attr('url')

  $('.import .manage_labels #use_labels').live 'click', ->
    if $(this).is(':checked')
      $(this).siblings('.label_space').slideDown()
    else
      $(this).siblings('.label_space').slideUp()

  $('#new_label_button').live 'click', ->
    if $.trim($(this).siblings('#new_label_field').val()) != ""
      $(this).attr('disabled',true)
      $(this).siblings('#new_label_field').addClass('loading')
      $.ajax
        type: 'POST',
        dataType: 'script',
        url: '/labels/create_now',
        data: 'name='+$(this).siblings('#new_label_field').val()
    false

  $('.action_dropdown').live 'click', ->
    link = $(this)
    link.toggleClass('active')
    link.next('ul').toggle()
    link.parent().mouseleave ->
      link.removeClass('active')
      link.next('ul').hide()
    false

  $('input[type=checkbox].primary').live 'click', ->
    fieldset = $(this).closest('.fieldset')
    $('input[type=checkbox].primary', fieldset).prop('checked', false)
    $(this).prop('checked', true)

  $('a.remove_field').live 'click', (e)->
    e.preventDefault()
    group_name = $(this).parents('.sfield').attr("data-group")
    if group_name == 'address' || $(".sfield[data-group=" + group_name + "]:visible").size() > 1
      link = this
      $(link).prev("input[type=hidden]").val("1")
      $(link).closest(".sfield").hide()
      fieldset = $(link).closest('.fieldset')
      if $('.sfield:visible', fieldset).length <= 2
        $('.remove_field', fieldset).hide()
    else
      $(this).hide()

  if $.fn.oneFingerScroll?
    $('.fingerme').oneFingerScroll()

  $('.expandable').each (i)->
    e = $(this)
    if e.height() > Number(e.attr("data-height"))
      e.next('.moredown').show()
      e.attr("data-original-height", e.height())
      e.css({height: e.attr("data-height") + 'px', overflow: 'hidden'})

  $('a.moredown').click ->
    target = $($(this).attr('href'))
    target.toggleClass('showall')
    if target.hasClass('showall')
      target.attr('data-height', target.height())
      target.animate({height: target.attr("data-original-height")})
      $('span', this).html('<strong>-</strong> Show Less')
    else
      target.animate({height: target.attr("data-height")})
      $('span', this).html('<strong>+</strong> Show More')
    false

  $('a.disabled').live 'click', ->
    false

  $('[data-method=delete]:not(.dont_hide)').live 'ajax:before', ->
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

  if $.fn.sortable?
    $('[data-sortable]').sortable(sortable_options)

  if $.fn.qtip?
    $('.tipthis[title]').qtip()
    $('.tiplight').qtip()
    $('.tipit[title]').qtip
      position:
        my: 'top right',
        at: 'bottom left'
    $('.tipitright[title]').qtip
      position:
        my: 'top left',
        at: 'bottom right'
    $('.tipitmiddle[title]').qtip
      position:
        my: 'top middle',
        at: 'bottom middle'
    $('.tipit2[title]').qtip
      position:
        my: 'top right',
        at: 'top left'

  $('[data-sortable][data-sortable-handle]').each ->
    handle = $(this).attr('data-sortable-handle')
    $(this).sortable("option", "handle", handle)

  if $.fn.draggable?
    $('.handle').draggable
      revert: true
      start: (event, ui) ->
        # to show group label list if the side list in groups page is hidden
        unless $(".sidebar_group_labels").is(":visible")
          $(".sidebar_group_labels_toggle").click()

        # If this row isn't checked, store the previously checked rows and check this row '
        unless $(this).parent().next().find('input').prop('checked')
          $(this).data 'checked', $('.id_checkbox:checked').map ->
            return $(this).val()
          $('.id_checkbox:checked').prop('checked', false)
          $(this).parent().next().find('input').prop('checked', true)
      stop: (event, ui) ->
        if $(this).data('checked')?
          $(this).parent().next().find('input').prop('checked', false)
          $.each $(this).data('checked'), (i, id) ->
            $('.id_checkbox[value=' + id + ']').prop('checked', true)
        $(this).data('checked', null)
      helper: (event) ->
        if $(this).parent().next().find('input').hasClass('group_checkbox')
          checkboxes = $('.id_checkbox.group_checkbox:checked').length
        else
          checkboxes = $('.id_checkbox:checked').length

        if $(this).parent().next().find('input').prop('checked')
          length = checkboxes
        else
          length = 1

        if length == 1
          helper_text = $('#drag_helper_text_one').html()
        else
          helper_text = $('#drag_helper_text_other').html().replace('0', length)
        $('<div class="drag-contact">' + helper_text + '</div>').appendTo($('body'))

  if $.fn.superfish?
    $('ul.sf-menu').superfish({
      pathClass: 'current',
      speed: 0,
      pathLevels: 0,
      delay: 300
    })
    if $('.sf-scrolling')[0]
      $('.sf-scrolling').superscroll()

window.t = (s) -> I18n.translate(s)

$.blur = (selector, hide) ->
  el = $(selector)
  id = selector.replace(/\.|\#/g,'_').replace(/\ /g,'')

  pad_top = el.css('padding-top')
  pad_bottom = el.css('padding-bottom')
  pad_left = el.css('padding-left')
  pad_right = el.css('padding-right')
  width = parseInt(el.width()) + parseInt(pad_left) + parseInt(pad_right)
  height = parseInt(el.height()) + parseInt(pad_top) + parseInt(pad_bottom)

  if $("#"+id).size() == 0
    el.prepend("<div style='width:"+width+"px; height:"+height+"px; background:#666; position: absolute; z-index: 999; opacity: 0.1; display: none;' id='"+id+"'></div>")

  $('#'+id).css('margin-top','-'+pad_top)
  $('#'+id).css('margin-left','-'+pad_left)
  $('#'+id).css('width',width+'px')
  $('#'+id).css('height',height+'px')

  if hide == 'hide'
    $("#"+id).fadeOut('slow')
  else
    if $("#"+id).is(':visible')
      $("#"+id).fadeOut('slow')
    else
      $("#"+id).fadeIn('slow')

$.toggleLoader = (div_id, words) ->
  $(document).ready ->
    $.fn.tip()
  if words != ""
    if $('#' + div_id).children('.loader').size() > 0
      $('#' + div_id).children('.loader').last().fadeOut().remove()
    $('#' + div_id).append("<div class='loader'><img src='/assets/loader.gif'>" + words + "</div>")
  else
    $('#' + div_id).children('.loader').last().fadeOut().remove()
  false

$.a = (msg, title) ->
  unless title?
    title = "Alert"
  $('#custom_alert_div .mh_popup_heading').text(title)
  $('#custom_alert_div .fancy').html(msg)
  $.showDialog($('#custom_alert_div'))

window.addFields = (link, association, content) ->
  new_id = new Date().getTime()
  regexp = new RegExp("new_" + association, "g")
  $(link).closest(".sfield").before(content.replace(regexp, new_id))
  fieldset = $(link).closest('.fieldset')
  $('.remove_field', fieldset).show()
  false

$.mh = {}
$.mh.logout = (url) ->
  next =   if url?
    '/sign_out?next=' + url
  else
    '/sign_out'
  if FB? && FB._userStatus != "unknown"
    #try
    #  FB.logout((request) ->
    #    document.location = next
    #  )
    #catch err
    document.location = next

  else
    document.location = next


$.mh.fbEnsureInit = (callback) ->
  if(!$.mh.fb)
    setTimeout(()->
      $.mh.fbEnsureInit(callback)
    , 50)
  else
    if(callback)
      setTimeout(()->
        callback
      , 50)

