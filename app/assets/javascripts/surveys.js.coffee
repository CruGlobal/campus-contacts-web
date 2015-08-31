$.fn.stop_editing = (move_row) ->
  mass_entry = $("#mass_entry_table")
  cell = mass_entry.handsontable('getSelected')
  max_row_index = mass_entry.handsontable("countRows") - 1
  max_column_index = mass_entry.handsontable("countCols") - 1
  if cell[0] == max_row_index && cell[1] == max_column_index
    $.fn.add_row()
  else if cell[1] == max_column_index
    if move_row
      mass_entry.scrollLeft(0)
      selected = mass_entry.handsontable('getSelected')
      mass_entry.handsontable("selectCell", selected[0], selected[1], true)

$.fn.add_row = () ->
  mass_entry = $("#mass_entry_table")
  mass_entry.handsontable("alter", "insert_row")
  x = 0
  while x <= (mass_entry.handsontable("countCols") - 1)
    mass_entry.handsontable('setDataAtCell', mass_entry.handsontable("countRows") - 1, x, '')
    x++
  mass_entry.scrollLeft(0)
  $(document).scrollTop(9999999)


$.fn.load_answers = () ->
  survey_id = $("#mass_entry_table").data("survey-id")
  $(".fetching-loader").show()
  $(".saving-loader").hide()
  $("#mass_entry_table").hide()
  $("#mass_entry_table").handsontable("destroy")
  $(".mass_entry_buttons").hide()
  $.getJSON "/surveys/#{survey_id}/mass_entry_data.json", (response)->
    $(".fetching-loader").hide()
    $(".saving-loader").hide()
    $("#mass_entry_table").show()
    $(".mass_entry_buttons").show()
    $("#mass_entry_table").handsontable
      width: $(window).width()
      autoColumnSize: true
      data: response['data']
      columns: response['settings']
      colHeaders: response['headers']
      rowHeaders: true
      outsideClickDeselects: true
      removeRowPlugin: true
      enterBeginsEditing: true
      enterMoves: {row: 0, col: 1}
      fillHandle: false
      # minSpareRows: 1
      # manualColumnResize: true
      # nativeScrollbars: true
      stretchH: 'all'
      columnSorting: true
      wordWrap: true
      allowInvalid: true
      # contextMenu: ['undo','redo','remove_row']
      # fixedColumnsLeft: 2
      autoWrapRow: true
      autoWrapCol: true
      multiSelect: false
      # fillHandle: false
      beforeKeyDown: (e)->
        # if e.which == 9
        #   cell = $('#mass_entry_table').handsontable('getSelected')
        #   $('#mass_entry_table').handsontable('selectCell', cell[0], cell[1], cell[2], cell[3], scrollToSelection = true)
        if e.which == 13 || e.which == 9
          $.fn.stop_editing(true)
      afterChange: (changes, source)->
        current_row = changes[0][0]
        if $("body").data('changed_rows') == undefined
          $("body").data('changed_rows',[])
        if $.inArray(current_row, $("body").data('changed_rows')) == -1
          $("body").data('changed_rows').push(current_row)
      beforeChange: ->
        $("body").data('has_changes','true')
      cells: (row, col, prop) ->
        cellProperties = {}
        id = $("#mass_entry_table").handsontable("getDataAtCell", row, 0)
        val = $("#mass_entry_table").handsontable("getDataAtCell", row, col)
        if id == "" || id == null || id == undefined
          cellProperties.readOnly = false
        else if (val == "" || val == null)
          cellProperties.readOnly = false
        # else if (val != "" && val != null) && (col == 1 || col == 2 || col == 3)
        #   cellProperties.readOnly = true
        return cellProperties
    $.fn.add_row()


$ ->
  $(document).on "click", "#apply_label_to_all_checkbox", (e)->
    $("#apply_label_to_new_checkbox").prop("checked", false) if $(this).is(":checked")

  $(document).on "click", "#apply_label_to_new_checkbox", (e)->
    $("#apply_label_to_all_checkbox").prop("checked", false) if $(this).is(":checked")

  # New Label button in mass entry
  $(document).on 'click', '.new_label_in_mass_entry', (e)->
    e.preventDefault()
    $('#new_label_input').val("")
    $(".save_mass_entry").removeClass("save_label_to_all")
    $(".save_mass_entry").removeClass("save_label_to_new")
    $("#apply_label_to_all_checkbox").prop("checked", false)
    $("#apply_label_to_new_checkbox").prop("checked", false)
    $.showDialog($("#mass_entry_new_label_dialog"))

  # Save new Label from mass entry
  $(document).on 'click', '#mass_entry_new_label_save_button', (e)->
    e.preventDefault()
    new_label_name = $.trim($('#new_label_input').val())
    if new_label_name != ""
      $('#labels_notice').text("")
      $.toggleLoader('labels_notice','Creating new Label...')
      $.ajax
        type: 'POST',
        url: "/surveys/create_label?name=" + escape(new_label_name)

  # Add new row in Mass Entry after entering data to the current last row
  $(document).on "change", ".handsontableInput, .htSelectEditor", (e)->
    mass_entry = $("#mass_entry_table")
    max_row_index = mass_entry.handsontable("countRows") - 1
    if mass_entry.handsontable("getDataAtCell", max_row_index, 0) != ""
      $.fn.add_row()

  $(document).on "keydown", ".handsontableInput, .htSelectEditor", (e)->
    # Save value on tab press
    if e.which == 9
      $.fn.stop_editing(false)

  $(document).on "keypress", ".handsontableInput, .htSelectEditor", (e)->
    if e.which == 13
      mass_entry = $("#mass_entry_table")

      cell = mass_entry.handsontable('getSelected')
      max_row_index = mass_entry.handsontable("countRows") - 1
      max_column_index = mass_entry.handsontable("countCols") - 1
      console.log (cell[1] + 1) > max_column_index
      if (cell[1] + 1) > max_column_index
        mass_entry.handsontable("selectCell", cell[0] + 1, 0)
      else
        mass_entry.handsontable("selectCell", cell[0], cell[1] + 1)
      return false

  $("#mass_entry_table").bind 'scroll', (e)->
    $(window).scroll();

  $(document).on "click", ".htSelectEditor option", (e)->
    if $(this).attr('value') == ''
      $(".htSelectEditor").find("option").prop("selected", false)
      $(this).prop("selected", true)
    else
      if $(this).is(":selected")
        $(this).prop("selected", false)
      else
        $(this).prop("selected", true)
        if $(this).attr('value') != ''
          $(".htSelectEditor").find("option[value='']").prop("selected", false)

  # if $("#copy_mass_entry").size() > 0
  #   $(document).on "click", "#copy_mass_entry", (e)->
  #     e.preventDefault()

  $(document).on "click", ".new_mass_entry", (e)->
    e.preventDefault()
    $.fn.add_row()
    $("#mass_entry_table").handsontable("selectCell", $("#mass_entry_table").handsontable("countRows") - 1, 0)

  $(document).on "click", ".reload_mass_entry", (e)->
    e.preventDefault()
    if $("body").data('changed_rows') == undefined || $("body").data('changed_rows').length == 0
      $.a("You do not have any changes to reload!")
    else
      if(confirm('Warning! Reloading the Mass Entry table will not save your changes. Save changes before reloading page.'))
        $("body").data('changed_rows', [])
        $.fn.load_answers()

  $(document).on "click", ".save_mass_entry", (e)->
    e.preventDefault()
    if $("body").data('changed_rows') == undefined || $("body").data('changed_rows').length == 0
      $.a("You do not have any changes to save!")
    else
      $(".saving-loader").show()
      $("#mass_entry_table").hide()
      $(".mass_entry_buttons").hide()
      survey_id = $("#mass_entry_table").data("survey-id")
      table_val = $("#mass_entry_table").handsontable("getData")
      valid_table_val = []
      for row in $("body").data('changed_rows')
        row_value = $("#mass_entry_table").handsontable("getData")[row]
        if row_value != undefined
          valid_table_val.push(row_value)

      new_label_to_all = ""
      if $(this).hasClass("save_label_to_all")
        new_label_to_all = $.trim($('#new_label_input').val())
      new_label_to_new = ""
      if $(this).hasClass("save_label_to_new")
        new_label_to_new = $.trim($('#new_label_input').val())

      $.ajax
        type: "POST"
        url: "/surveys/#{survey_id}/mass_entry_save"
        data: {values: valid_table_val, new_label_to_all: new_label_to_all, new_label_to_new: new_label_to_new}

  if $("#mass_entry_table").size() > 0
    $.fn.load_answers()


  $('#survey_background_color, #survey_text_color').excolor({root_path: '/assets/'})
  false

  $(".file_upload_container .file_field").on "change", () ->
    parent = $(this).parents(".file_upload_container")
    file_name = parent.find(".file_upload_name_container")
    file_name.html($(this).val().split('\\').pop())

  $('#show_advanced_survey_option').live 'click', ()->
    $('#advanced_survey_option').toggle()
    if($('#advanced_survey_option').is(":visible"))
      $(this).html($(this).html().replace("Show","Hide"))
    else
      $(this).html($(this).html().replace("Hide","Show"))

  $('#transfer_survey_content #other_orgs_list .other_org').live 'click', ->
    org_id = $(this).attr('data-org-id')
    org_name = $(this).attr('data-org-name')
    survey_id = $('#transfer_survey_div').attr('data-survey-id')
    survey_name = $('#transfer_survey_div').attr('data-survey-name')
    if(confirm('Are you sure you want to copy ' + survey_name + ' to ' + org_name + ' organization?'))
      $('#transfer_survey_div #transfer_survey_processing #org_name').text(org_name)
      $('#transfer_survey_div #transfer_survey_content').hide()
      $('#transfer_survey_div #transfer_survey_error').hide()
      $('#transfer_survey_div #transfer_survey_processing').show()
      $.ajax
        type: 'GET',
        url: '/copy_survey?survey_id=' + survey_id + '&organization_id=' + org_id

  $('a.transfer_survey').live 'click', (e)->
    e.preventDefault()
    survey_id = $(this).attr('data-id')
    survey_name = $(this).attr('data-name')
    $('#transfer_survey_div #transfer_survey_guide #survey_name').text($(this).attr('data-name'))
    $('#transfer_survey_div').attr('data-survey-id',survey_id)
    $('#transfer_survey_div').attr('data-survey-name',survey_name)
    $.showDialog($("#transfer_survey_div"))
    $('#transfer_survey_div #transfer_survey_processing').hide()
    $('#transfer_survey_div #transfer_survey_error').hide()
    $('#transfer_survey_div #transfer_survey_content').show()
    $("#other_orgs_filter_keyword").removeClass("ui-autocomplete-loading")
    $("#other_orgs_filter_keyword").val("")
    $("#other_orgs_filter_keyword").focus()
    $(".other_org").remove()

  $('#other_orgs_filter_keyword').live 'keyup', ->
    $('#transfer_survey_div #transfer_survey_processing').hide()
    $('#transfer_survey_div #transfer_survey_error').hide()

    keyword = $(this).val().toLowerCase()
    if keyword.length >= 3
      $(this).addClass("ui-autocomplete-loading")
      window.setTimeout (->
        $.ajax
          type: 'GET',
          url: '/show_other_orgs?keyword=' + encodeURIComponent(keyword)
      ), 1000
    else if keyword.length == 0
      $(".other_org").remove()
      $(this).removeClass("ui-autocomplete-loading")