function checkRequestOptions(){
  $(".availability").click(function(e){
    var i = $(this).parent().siblings("iframe").first();
    i.attr('src',$(this).data('url'));
  });
}