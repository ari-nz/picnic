$(document).ready(function() {
  /**
    Custom slider labels
  **/

    // Convert numbers of min to max to "lower" and "higher"
    function returnLabels(value) {
      // remove label of selected
      $('#park_size').find('.irs-single').remove();
    //  $('.park_size_slider').find('.irs-grid-text').remove(); // this is an alternative to ticks=F



        switch (value) {
          case 1:
               return "Tiny";
          case 2:
               return "Small";
          case 3:
               return "Medium";
          case 4:
               return "Large";
          case 5:
               return "Massive";


        }


    }

    var someID = $("#park_size").ionRangeSlider({ // enter your shiny slider ID here
          prettify: returnLabels,
          force_edges: true,
          grid: false
        });


});



