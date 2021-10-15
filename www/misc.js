$(document).ready(function() {

  $(document).on('click', 'button', function() {
    ga('send', 'event', 'button', 'button click');
  });

}


$(document).on('shiny:connected', function(event) {
    console.log('1')

     document.getElementsByClassName("confirm")[0].addEventListener("click", function() {

      console.log('run')
      swal.close()

    });


}