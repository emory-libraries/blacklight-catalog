// Truncation ellipsis toggle for long fields
$(document).ready(function() {
  (function() {
    var showChar = 160;
    var ellipsestext = "…";

    $(".truncate").each(function() {
      var content = $(this).html();
      if (content.length > showChar) {
        var c = content.substr(0, showChar);
        var h = content;
        var html =
          '<div class="truncate-text" id="trunc-short-text" style="display:block">' +
          c +
          '<span class="moreellipses">' +
          ellipsestext +
          '&nbsp;&nbsp;<a href="" class="moreless more">Read more</a></span></span></div><div class="truncate-text" id="trunc-full-text" style="display:none">' +
          h +
          '&nbsp;&nbsp;<a href="" class="moreless less">Read Less</a></span></div>';

        $(this).html(html);
      }
    });

    $(".moreless").click(function() {
      var thisEl = $(this);
      var cT = thisEl.closest(".truncate-text");
      var tX = ".truncate-text";

      if (thisEl.hasClass("less")) {
        cT.prev(tX).toggle();
        cT.toggle();
      } else {
        cT.toggle();
        cT.next(tX).toggle();
      }
      return false;
    });
    /* end iffe */
  })();

  $(".toggle-table").click(function(){
    $(this).closest('td').find(".toggled-table").toggle();
    $(this).toggleClass('collapsed');
    return false;
  });

  $('#show-all').on('click', function(e) {
      $('#other-resources-panel .collapse').removeAttr("data-parent");
      $('#other-resources-panel .collapse').collapse('show');
      $('.resource-body').css('background', 'rgba(231, 234, 241, 0.5)')
      $('.panel-title').css('background', 'rgba(231, 234, 241, 0.5)')
  })
  $('#hide-all').on('click', function(e) {
      $('#other-resources-panel .collapse').attr("data-parent","#other-resources-panel");
      $('#other-resources-panel .collapse').collapse('hide');
      $('.resource-body').css('background', 'none')
      $('.panel-title').css('background', 'none')
  });

  $('.resource-body').on('hide.bs.collapse', function () {
    $(this).css('background', 'none')
    $(this).prev().children('.panel-title').css('background', 'none')
  })
  $('.resource-body').on('show.bs.collapse', function () {
    $(this).css('background', 'rgba(231, 234, 241, 0.5)')
    $(this).prev().children('.panel-title').css('background', 'rgba(231, 234, 241, 0.5)')
  // do something…
  })

  if ($('#availability_indicators_document_ids').val() != null) {
    $.ajax({
      type: "GET",
      data: {
        document_ids: $('#availability_indicators_document_ids').val().split(',')
      },
      url: "/availability_indicators",
      dataType: "json",
      success: function(data) {
        for (const [key, value] of Object.entries(data)) {
          $(`#availability-indicator-${key}`).replaceWith(value);
        }
      }
    });
  }

  /* end ready */
});

const redirect = selectObject => {

  const selection = selectObject.value;

  // Ignore empty selections.
  if(selection == null || selection === '') return;

  // Get the location of the targeted site.
  const href = selection.startsWith('http://') || selection.startsWith('https://') ? selection : `${selection}`;

  // Redirect the site to the target location.
  window.location.href = href;

}

