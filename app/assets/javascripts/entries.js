
function expandTextarea(id) {
  var $element = $('.myclass').get(0);

  $element.addEventListener('keyup', function() {
    this.style.overflow = 'hidden';
    this.style.height = 0;
    this.style.height = this.scrollHeight + 'px';
  }, false);
}

$(document).keypress(function(event){
  // Automatically take the user to new page when pressing n
  if (event.which == 110) {
    window.location = '/new';
  }
});
