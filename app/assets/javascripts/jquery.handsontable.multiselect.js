(function (Handsontable) {

  var MultiSelectEditor = Handsontable.editors.BaseEditor.prototype.extend();

  MultiSelectEditor.prototype.init = function(){
    this.select = document.createElement('SELECT');
    Handsontable.Dom.addClass(this.select, 'htSelectEditor');
    this.select.multiple = 'multiple';
    this.select.style.display = 'none';
    this.instance.rootElement[0].appendChild(this.select);
  };

  MultiSelectEditor.prototype.prepare = function(){
    Handsontable.editors.BaseEditor.prototype.prepare.apply(this, arguments);


    var selectOptions = this.cellProperties.selectOptions;
    var options;

    if (typeof selectOptions == 'function'){
      options =  this.prepareOptions(selectOptions(this.row, this.col, this.prop))
    } else {
      options =  this.prepareOptions(selectOptions);
    }

    Handsontable.Dom.empty(this.select);

    for (var option in options){
      if (options.hasOwnProperty(option)){
        var optionElement = document.createElement('OPTION');
        optionElement.value = option;
        Handsontable.Dom.fastInnerHTML(optionElement, options[option]);
        this.select.appendChild(optionElement);
      }
    }
  };

  MultiSelectEditor.prototype.prepareOptions = function(optionsToPrepare){

    var preparedOptions = {};

    if (Handsontable.helper.isArray(optionsToPrepare)){
      for(var i = 0, len = optionsToPrepare.length; i < len; i++){
        preparedOptions[optionsToPrepare[i]] = optionsToPrepare[i];
      }
    }
    else if (typeof optionsToPrepare == 'object') {
      preparedOptions = optionsToPrepare;
    }

    return preparedOptions;

  };

  MultiSelectEditor.prototype.getValue = function () {
    var values = [].map.call(this.select.selectedOptions, function(option) {
      return option.value;
    });
    return values.join(", ");
    // return this.select.value;
  };

  MultiSelectEditor.prototype.setValue = function (value) {
    this.select.value = value;
  };

  var onBeforeKeyDown = function (event) {
    var instance = this;
    var editor = instance.getActiveEditor();

    switch (event.keyCode){
      case Handsontable.helper.keyCode.ARROW_UP:

        var previousOption = editor.select.find('option:selected');
        if (previousOption) {
          previousOption = previousOption.prev();
        }

        if (previousOption.length == 1){
          previousOption.prop('selected', true);
        }

        event.stopImmediatePropagation();
        event.preventDefault();
        break;

      case Handsontable.helper.keyCode.ARROW_DOWN:

        var nextOption = editor.select.find('option:selected').next();
        if (nextOption) {
          nextOption = nextOption.prev();
        }

        if (nextOption.length == 1){
          nextOption.prop('selected', true);
        }

        event.stopImmediatePropagation();
        event.preventDefault();
        break;

      case Handsontable.helper.keyCode.ENTER:

        editor.close();
        event.stopImmediatePropagation();
        event.preventDefault();
        break;
    }
  };

  MultiSelectEditor.prototype.open = function () {
    var width = Handsontable.Dom.outerWidth(this.TD); //important - group layout reads together for better performance
    var height = Handsontable.Dom.outerHeight(this.TD);
    var rootOffset = Handsontable.Dom.offset(this.instance.rootElement[0]);
    var tdOffset = Handsontable.Dom.offset(this.TD);

    value = $.map(this.TD.innerHTML.split(","), function(e,i) {return $.trim(e)})
    $(".htSelectEditor").val(value);

    this.select.style.height = (($(".htSelectEditor").children("option").size() * 15) - 1) + 'px';
    this.select.style.minWidth = width + 'px';
    this.select.style.top = tdOffset.top - rootOffset.top + 'px';
    this.select.style.left = tdOffset.left - rootOffset.left + 'px';
    this.select.style.margin = '0px';
    this.select.style.display = '';

    this.instance.addHook('beforeKeyDown', onBeforeKeyDown);
  };

  MultiSelectEditor.prototype.close = function () {
    this.select.style.display = 'none';
    // this.TD.innerHTML = $(".htSelectEditor").val().join(", ");
    this.instance.removeHook('beforeKeyDown', onBeforeKeyDown);
  };

  MultiSelectEditor.prototype.focus = function () {
    this.select.focus();
  };


  MultiSelectEditor.prototype.beginEditing = function (initialValue) {
      var onBeginEditing = this.instance.getSettings().onBeginEditing;
      if (onBeginEditing && onBeginEditing() === false) {
          return;
      }

      Handsontable.editors.TextEditor.prototype.beginEditing.apply(this, arguments);
  };

  Handsontable.editors.MultiSelectEditor = MultiSelectEditor;
  Handsontable.editors.registerEditor('multiselect', MultiSelectEditor);

})(Handsontable);