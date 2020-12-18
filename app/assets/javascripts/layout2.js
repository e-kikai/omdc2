$(document).on('ready, turbolinks:load', function() {
  /// tooltip ///
  // $('.tooltip').remove();
  $('[data-toggle="tooltip"]').tooltip();
});


/// タブ切り替え ///
var display = function(tab) {
  $(".items_block").css("display", "none");
  $(".items_block").eq(tab).css("display", "inline-table");

  return false;
}
