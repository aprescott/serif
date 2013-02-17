// All credit to Alex MacCaw
//
// https://gist.github.com/maccman/2907189

(function($){
  var insertAtCaret = function(value) {
    if (document.selection) { // IE
      this.focus();
      sel = document.selection.createRange();
      sel.text = value;
      this.focus();
    }
    else if (this.selectionStart || this.selectionStart == '0') {
      var startPos  = this.selectionStart;
      var endPos    = this.selectionEnd;
      var scrollTop = this.scrollTop;
 
      this.value = [
        this.value.substring(0, startPos),
        value,
        this.value.substring(endPos, this.value.length)
      ].join('');
 
      this.focus();
      this.selectionStart = startPos + value.length;
      this.selectionEnd   = startPos + value.length;
      this.scrollTop      = scrollTop;
 
    } else {
      throw new Error('insertAtCaret not supported');
    }
  };
 
  $.fn.insertAtCaret = function(value){
    $(this).each(function(){
      insertAtCaret.call(this, value);
    })
  };
})(jQuery);