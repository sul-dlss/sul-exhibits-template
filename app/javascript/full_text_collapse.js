/* global Blacklight */

Blacklight.onLoad(function(){
  var uniqueId = (function() {
  		var uuid = 0;

  		return function(el) {
        el.id = 'ui-id-' + ( ++uuid );
  		};
  	} )();

  $('dd.blacklight-full_text_tesimv').addClass('collapse').each(function() {
    $(this).attr('id', uniqueId(this));
  });

  $('dt.blacklight-full_text_tesimv').each(function() {
    var $dt = $(this);
    var $dd = $dt.next('dd');
    var $link = $dd.find('a.prepared-search-link');

    $dt.text($dt.text().replace(/:$/, ''));
    $dt.addClass('show-hide-toggle');
    $dt.attr('data-bs-toggle', 'collapse');
    $dt.attr('data-bs-target', '#' + $dd.attr('id'));

    if ($link.length > 0) {
      $dt.before(
        $('<dt class="prepared-search-container"></dt>')
          .html($link.clone())
      );
      $dt.before($('<dd class="w-100"></dd>'));
      $link.remove();
      if ($dd.find('p').length === 0) { // There is no highlight
        $dt.remove();
        $dd.remove();
      }
    }
  });
});
