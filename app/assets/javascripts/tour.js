$(function() {
  $("table.actionpack tr:even").addClass("even");
  $(".touraccordion").accordion({animated: 'bounceslide', autoHeight: false});

  $( "#thetour" ).tabs();
});