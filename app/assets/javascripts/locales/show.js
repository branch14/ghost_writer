//=require jquery.purr
//=require best_in_place
//=require jquery.delayed_observer
//=require_self

$(document).ready(function() {

  $(".best_in_place").best_in_place();

  $('#filter').delayedObserver(0.5, function(value, object) {
    var theSearchString = $("#filter").val();
    if(theSearchString.length < 3) { return false; }
    $('#translations').html("<img src='/images/spinner.gif' />");
    var localeId = $("#locale_id").val();
    var projectId = $("#project_id").val();
    var url = '/translations';
    $.get(url, { locale_id: localeId,
                 filter: theSearchString }, function(data) {
      $('#translations').html(data);
      $(".best_in_place").best_in_place();
    });
  });
});
