$ ->
  $('#dashboard_error form').submit ->
    $(this).find('[type="submit"]').prop("disabled",true);
  .on("ajax:error", (e, data, status, xhr) ->
    $(this).find('[type="submit"]').prop("disabled",false);
    $('#find_by_email_addresses_error, #user_not_found_more_steps').show()
    $('#find_by_email_addresses_no_emails').hide()
  )

  $secrets = $('.secret')
  $(window).on('hashchange', ->
    showSecrets = window.location.hash == '#/people' || window.location.hash == '#/ministries';
    $secrets.removeClass('hidden') if showSecrets
    $secrets.addClass('hidden') if !showSecrets
  ).trigger('hashchange')
