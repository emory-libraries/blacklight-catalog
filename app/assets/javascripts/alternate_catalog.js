(function (global) {
  var AlternateCatalog = {
    container: null,
    titleElement: null,

    init: function(el) {
      this.container = $(el);
      this.titleElement = this.container.find('.alternate-catalog-title');

      // Insert between the 3rd and 4th document
      this.injectAlternateCatalogInotResults();

    },

    injectAlternateCatalogInotResults: function() {
      var $documents = $('#documents');
      var afterThird = $documents.find('.document-position-2').after(this.container);
      var _this = this;

      // If there is no third document, just append to the end of #documents
      if (afterThird.length === 0) {
        $documents.append(_this.container);
      }
    },
  };

  global.AlternateCatalog = AlternateCatalog;
}(this));

Blacklight.onLoad(function () {
  'use strict';

  if($('#data-alternate-catalog').length > 0){
    AlternateCatalog.init($('#data-alternate-catalog'));
  };
});
