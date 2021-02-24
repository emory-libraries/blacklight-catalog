function checkRequestOptions(){
  $(".availability").click(function(e){
    var i = $(this).parent().siblings("iframe").first();
    i.attr('src',$(this).data('url'));
    $(this).children('.fa').toggleClass("fa-chevron-right fa-chevron-down");
    i.toggle();
  });
}